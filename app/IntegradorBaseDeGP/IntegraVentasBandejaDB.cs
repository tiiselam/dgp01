using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using IntegradorDeGP.BLL;
using System.Data.SqlClient;
using Microsoft.Dynamics.GP.eConnect.Serialization;
using Microsoft.Dynamics.GP.eConnect;
using System.Data.Entity.Core.Objects;
using IntegradorDeGP.Herramientas;
using System.Data;

namespace IntegradorDeGP
{
    public class IntegraVentasBandejaDB : IntegraGPeconnect
    {
        IParametrosDB parametrosDB;
        private string connectionStringOrigenEF;
        private string connectionStringDestino;
        private string usuarioQueProcesa;

        public IntegraVentasBandejaDB(IParametrosDB paramDB, string usr) 
        {
            connectionStringOrigenEF = paramDB.ConnectionStringSourceEF;
            connectionStringDestino = paramDB.ConnStringTarget;
            parametrosDB = paramDB;
            usuarioQueProcesa = usr;
        }

        //// Permite comprobar la conexión con la base de datos
        private bool probarConexionDBIntegra()
        {
            using (var db = this.getDbContextIntegra())
            {
                return db.Database.Exists();
            }
        }

        private INTEGRAEntities getDbContextIntegra()
        {
            if (string.IsNullOrEmpty(this.connectionStringOrigenEF))
                return new INTEGRAEntities();

            return new INTEGRAEntities(this.connectionStringOrigenEF);
        }

        private bool probarConexionDBGP()
        {
            using (var db = this.getDbContextGP())
            {
                return db.Database.Exists();
            }
        }
        private DynamicsGPEntities getDbContextGP()
        {
            if (string.IsNullOrEmpty(this.parametrosDB.ConnectionStringTargetEF))
                return new DynamicsGPEntities();

            return new DynamicsGPEntities(this.parametrosDB.ConnectionStringTargetEF);
        }

        //// Devuelve las prefacturas que cumplan con los criterios de filtrado seleccionados
        private IList<vwIntegracionesVentas> getPrefacturasAIntegrar(String docStatus)
        {
            using (var db = this.getDbContextIntegra())
            {
                // verificar la conexión con el servidor de bd
                if (!this.probarConexionDBIntegra())
                {
                    throw new InvalidOperationException("No se pudo establecer la conexión con la bd de Integración. Revise la configuración. [getPrefacturasAIntegrar]");
                }

                var datos = db.vwIntegracionesVentas.AsQueryable();
                datos = datos.Where(m => m.DOCSTATUS == docStatus);
                return datos.ToList();
            }
        }

        private IList<vwIntegracionesVentas> getPrefacturasAIntegrarPorIdLog(int idLog, string docStatus)
        {
            using (var db = this.getDbContextIntegra())
            {
                // verificar la conexión con el servidor de bd
                if (!this.probarConexionDBIntegra())
                {
                    throw new InvalidOperationException("No se pudo establecer la conexión con la bd de Integración. Revise la configuración. [getPrefacturasAIntegrarPorIdLog]");
                }

                var datos = db.vwIntegracionesVentas.AsQueryable();
                datos = datos.Where(m => m.ID == idLog && m.DOCSTATUS == docStatus);
                return datos.ToList();
            }
        }

        //// Devuelve las prefacturas que cumplan con los criterios de filtrado seleccionados
        private IList<vwPreFacturas> getPrefacturasDetalle(String docnumber, short doctype)
        {
            using (var db = this.getDbContextIntegra())
            {
                // verificar la conexión con el servidor de bd
                if (!this.probarConexionDBIntegra())
                {
                    throw new InvalidOperationException("No se pudo establecer la conexión con el servidor al tratar de leer el detalle de la pre-factura "+docnumber);
                }

                var datos = db.vwPreFacturas.AsQueryable();
                datos = datos.Where(m => m.NUMERODOC == docnumber && m.TIPODOC == doctype);
                return datos.ToList();
            }
        }

        private string LocArgentina_GetTipoContribuyente(string custnmbr)
        {
            using (var db = this.getDbContextGP())
            {
                // verificar la conexión con el servidor de bd
                if (!this.probarConexionDBGP())
                {
                    throw new InvalidOperationException("No se pudo establecer la conexión con el servidor al tratar de leer los datos del cliente " + custnmbr);
                }

                var datos = db.vwRmClientes.AsQueryable();
                return datos.Where(m => m.custnmbr == custnmbr)?.Select(x => x.RESP_TYPE)?.First() ;
            }
        }
        //verifica si transición es válida
        private IList<docGetSiguienteStatus_Result> getSiguienteStatus(short tipoDoc, string numDoc, string transicion)
        {
            using (var db = this.getDbContextIntegra())
            {
                // verificar la conexión con el servidor de bd
                if (!this.probarConexionDBIntegra())
                {
                    throw new InvalidOperationException("No se pudo establecer la conexión con la bd de Integración para el documento: " + numDoc);
                }

                var datos = db.docGetSiguienteStatus(tipoDoc, numDoc, transicion).AsQueryable();
                return datos.ToList();
            }
        }

        public IList<comgp_fnDocStatusPreCondiciones_Result> getPreCondiciones(short? tipoDocGP, string numDocGP, string transicion)
        {
            using (var db = this.getDbContextGP())
            {
                if (!this.probarConexionDBGP())
                {
                    throw new InvalidOperationException("No se pudo establecer la conexión con la bd de GP para el documento GP: " + numDocGP);
                }
                var datos = db.comgp_fnDocStatusPreCondiciones(tipoDocGP, numDocGP, transicion).AsQueryable();
                return datos.ToList();
            }
        }

        public IList<comgp_fnDocStatusPreCondiciones_Result> getStatusPreCondiciones(short? tipoDocGP, string numDocGP, string transicion)
        {
            using (var db = this.getDbContextGP())
            {
                var preCondiciones = db.Database.SqlQuery<comgp_fnDocStatusPreCondiciones_Result>
                    ("SELECT cumplePreCondiciones, msjPreCondiciones FROM dbo.comgp_fnDocStatusPreCondiciones(" + string.Concat(tipoDocGP?.ToString(), ", '", numDocGP, "', '", transicion, "')")) //+ )3, 'FV A0088-T0000042', 'ELIMINA_FACTURA_EN_GP') ")
                    .Select(field => new comgp_fnDocStatusPreCondiciones_Result
                    {
                        cumplePreCondiciones = field.cumplePreCondiciones,
                        msjPreCondiciones = field.msjPreCondiciones,
                    })
                    .AsQueryable()
                    .ToList();

                return preCondiciones;

            }
        }

        /// <summary>
        /// Crea el xml de una factura sop a partir de una vista sql.
        /// </summary>
        private taSopHdrIvcInsert IntegraFacturaSOP(vwIntegracionesVentas preFacturasAIntegrar, string sTimeStamp)
        {
            string eConnResult = String.Empty;
            eConnectType docEConnectSOP = new eConnectType();
            eConnectType entEconnect = new eConnectType();
            FacturaDeVentaSOPBandejaDB documentoSOP = new FacturaDeVentaSOPBandejaDB(parametrosDB);
            eConnectMethods eConnObject = new eConnectMethods();

            var dpf = getPrefacturasDetalle(preFacturasAIntegrar.NUMDOCARN, preFacturasAIntegrar.TIPODOCARN);
            string tipoContribuyente = LocArgentina_GetTipoContribuyente(preFacturasAIntegrar.IDCLIENTE);
            documentoSOP.preparaFacturaSOP(preFacturasAIntegrar, dpf, sTimeStamp, tipoContribuyente);
            docEConnectSOP.SOPTransactionType = new SOPTransactionType[] { documentoSOP.FacturaSop };
            serializa(docEConnectSOP);
            eConnResult = eConnObject.CreateTransactionEntity(connectionStringDestino, this.SDocXml);
           return documentoSOP.FacturaSop.taSopHdrIvcInsert;

        }

        private string IngresaLogFactura(vwIntegracionesVentas integraVentas, short? soptype, string sopnumbe, string transicion, string msj, string msjLargo)
        {
            using (var db = this.getDbContextIntegra())
            {
                // verificar la conexión con el servidor de bd
                if (!this.probarConexionDBIntegra())
                {
                    throw new InvalidOperationException("No se pudo establecer la conexión con el servidor al tratar de ingresar el Log de la transacción. Prefactura: "+integraVentas.NUMDOCARN+" Factura:"+integraVentas.NUMDOCGP);
                }
                ObjectParameter ID = new ObjectParameter("ID", typeof(int));

                db.sp_LOGINTEGRACIONESInsert(ID, integraVentas.TIPODOCARN, integraVentas.NUMDOCARN, soptype, sopnumbe, transicion, usuarioQueProcesa, msj, msjLargo, 1);

                return ID.Value.ToString();
            }
        }

        private string IngresaLogFactura(vwIntegracionesVentas integraVentas, string transicion, string mensaje)
        {
            short cumplePreCondiciones=0;
            string mensajePreCondicion = string.Empty;

            var precondiciones = getStatusPreCondiciones(integraVentas.TIPODOCGP, integraVentas.NUMDOCGP, transicion);

            int condicionesCumplidas = precondiciones.Where(x => x.cumplePreCondiciones == 1).Count();
            if (condicionesCumplidas == precondiciones.Count())
                {
                    cumplePreCondiciones = 1;
                    mensajePreCondicion = precondiciones.First().msjPreCondiciones; 
                }
            else
                    mensajePreCondicion = precondiciones.Where(x => x.cumplePreCondiciones == 0).First().msjPreCondiciones; //sería bueno mostrar todas condiciones que no fueron cumplidas.

            using (var db = this.getDbContextIntegra())
            {
                if (!this.probarConexionDBIntegra())
                    throw new InvalidOperationException("No se pudo establecer la conexión con la bd de Integración. Documento Ariane: " + integraVentas.NUMDOCARN + " Documento GP:" + integraVentas.NUMDOCGP ?? string.Empty);

                ObjectParameter ID = new ObjectParameter("ID", typeof(int));

                db.sp_LOGINTEGRACIONESInsert(ID, integraVentas.TIPODOCARN, integraVentas.NUMDOCARN, integraVentas.TIPODOCGP, integraVentas.NUMDOCGP, transicion, usuarioQueProcesa, Utiles.Izquierda(mensaje, 150), mensajePreCondicion, cumplePreCondiciones);

                return ID.Value.ToString();
            }
        }

        /// <summary>
        /// Revisa las prefacturas a integrar desde la base de datos.
        /// Posibles transiciones: ENVIAR_A_GP
        /// </summary>
        /// <param name="docStatus"></param>
        /// <param name="transicion"></param>
        public void ProcesaBandejaDB(string docStatus, string transicion)
        {

            try
            {
                var pfi = getPrefacturasAIntegrar(docStatus);
                int iFacturasIntegradas = 0;

                string sTimeStamp = System.DateTime.Now.ToString("yyMMddHHmmssfff");
                foreach (var item in pfi)
                {
                    try
                    {
                        var proximoStatus = getSiguienteStatus(item.TIPODOCARN, item.NUMDOCARN, transicion).First();
                        if (proximoStatus.transicionFactible == 1)
                        {

                            taSopHdrIvcInsert sopDoc = this.IntegraFacturaSOP(item, sTimeStamp);
                            iFacturasIntegradas++;

                            string idLog = IngresaLogFactura(item, sopDoc.SOPTYPE, sopDoc.SOPNUMBE, transicion, "OK", string.Empty);
                            OnProgreso(100 / pfi.Count, string.Concat("Pre factura: ", item.NUMDOCARN, " -> Factura GP: ", sopDoc.SOPNUMBE, " Log:", idLog));
                        }
                        else
                            OnProgreso(100 / pfi.Count, string.Concat("Pre factura: ", item.NUMDOCARN, " -> El documento continúa ", docStatus, " ", proximoStatus.mensaje));

                    }
                    catch(eConnectException ec)
                    {
                        OnProgreso(100 / pfi.Count, string.Concat("Pre factura: ", item.NUMDOCARN, " eConnect no pudo integrar el documento a GP. Verifique el mensaje de error. " + ec.Message, Environment.NewLine, ec?.InnerException?.Message));
                    }
                    catch (SqlException se)
                    {
                        OnProgreso(100 / pfi.Count, string.Concat("Pre factura: ", item.NUMDOCARN, " Excepción al ingresar el log. " + se.Message, Environment.NewLine, se?.InnerException?.Message));

                    }
                    catch (Exception ee)
                    {
                        //IngresaLogFactura(item, transicion, "No se pudo integrar la pre factura. Revise el mensaje de error.", string.Concat(ee.Message, Environment.NewLine, ee?.InnerException?.Message));
                        OnProgreso(100 / pfi.Count, string.Concat("Pre factura: ", item.NUMDOCARN, " Excepción desconocida. No se pudo integrar el documento a GP. " + ee.Message, Environment.NewLine, ee?.InnerException?.Message));

                    }
                }
                OnProgreso(100, "----------------------------------------------");
                OnProgreso(100, "Nuevos documentos integrados: " + iFacturasIntegradas.ToString());
                OnProgreso(100, "Número de documentos con error: " + (pfi.Count - iFacturasIntegradas).ToString());
                OnProgreso(100, "Total de documentos leídos: " + pfi.Count.ToString());

            }
            catch (Exception errorGral)
             {
                OnProgreso(0, string.Concat("Excepción al procesar la bandeja de la bd de Integraciones. " + errorGral.Message+Environment.NewLine + errorGral?.InnerException?.Message));
            }
        }

        /// <summary>
        /// Revisa las prefacturas a integrar desde la base de datos.
        /// Posibles transiciones: CONTABILIZA_FACTURA_EN_GP
        /// </summary>
        /// <param name="docStatus"></param>
        /// <param name="transicion"></param>
        public void ProcesaBandejaDBActualizaStatus(string docStatus, string transicion)
        {

            try
            {
                var pfi = getPrefacturasAIntegrar(docStatus);
                int iFacturasIntegradas = 0;

                string sTimeStamp = System.DateTime.Now.ToString("yyMMddHHmmssfff");
                foreach (var item in pfi)
                {
                    try
                    {
                        var proximoStatus = getSiguienteStatus(item.TIPODOCARN, item.NUMDOCARN, transicion).First();
                        if (proximoStatus.transicionFactible == 1)
                        {
                            iFacturasIntegradas++;

                            string idLog = IngresaLogFactura(item, item.SOPTYPE_GP, item.NUMDOCGP, transicion, "OK", string.Empty);
                            OnProgreso(100 / pfi.Count, string.Concat("Pre factura: ", item.NUMDOCARN, " -> Factura GP: ", item.NUMDOCGP, " Log:", idLog));
                        }
                        else
                            OnProgreso(100 / pfi.Count, string.Concat("Pre factura: ", item.NUMDOCARN, " -> El documento continúa ", docStatus, " ", proximoStatus.mensaje));

                    }
                    catch (SqlException se)
                    {
                        OnProgreso(100 / pfi.Count, string.Concat("Pre factura: ", item.NUMDOCARN, " Excepción al ingresar el log. " + se.Message, Environment.NewLine, se?.InnerException?.Message));

                    }
                    catch (Exception ee)
                    {
                        //IngresaLogFactura(item, transicion, "No se pudo integrar la pre factura. Revise el mensaje de error.", string.Concat(ee.Message, Environment.NewLine, ee?.InnerException?.Message));
                        OnProgreso(100 / pfi.Count, string.Concat("Pre factura: ", item.NUMDOCARN, " Excepción desconocida. No se pudo actualizar el status del documento GP. " + ee.Message, Environment.NewLine, ee?.InnerException?.Message));

                    }
                }
                OnProgreso(100, "----------------------------------------------");
                OnProgreso(100, "Nuevos documentos actualizados: " + iFacturasIntegradas.ToString());
                OnProgreso(100, "Número de documentos con error: " + (pfi.Count - iFacturasIntegradas).ToString());
                OnProgreso(100, "Total de documentos leídos: " + pfi.Count.ToString());

            }
            catch (Exception errorGral)
            {
                OnProgreso(0, string.Concat("Excepción al procesar la bandeja de la bd de Integraciones para actualizar el status de documentos GP. " + errorGral.Message + Environment.NewLine + errorGral?.InnerException?.Message));
            }
        }
        /// <summary>
        /// Revisa las prefacturas a integrar desde la base de datos.
        /// Posibles transiciones: ELIMINA_FACTURA_EN_GP, ANULA_FACTURA_RM_EN_GP
        /// </summary>
        /// <param name="idLog"></param>
        /// <param name="docStatus"></param>
        /// <param name="transicion"></param>
        public void ProcesaBandejaDB(int idLog, string docStatus, string transicion)
        {
            string numDocARN = string.Empty;
            try
            {
                string sTimeStamp = System.DateTime.Now.ToString("yyMMddHHmmssfff");

                var pfi = getPrefacturasAIntegrarPorIdLog(idLog, docStatus).First();
                numDocARN = pfi.NUMDOCARN;

                IngresaLogFactura(pfi, transicion, "Cambia estado porque "+transicion);

                OnProgreso(0, string.Concat("Pre factura: ", pfi.NUMDOCARN, " -> Factura GP: ", pfi.NUMDOCGP, " Log:", idLog.ToString()));
            }
            catch (SqlException se)
            {
                OnProgreso(0, string.Concat("Pre factura: ", numDocARN, " Excepción en la bd de Integraciones. " + se.Message, Environment.NewLine, se?.InnerException?.Message));
            }
            catch (Exception errorGral)
            {
                OnProgreso(0, string.Concat("Excepción al procesar la banjeda de la bd de Integraciones. " + errorGral.Message + Environment.NewLine + errorGral?.InnerException?.Message));
            }
        }

    }
}
