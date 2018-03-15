﻿
using ManipulaArchivos;
using Microsoft.Dynamics.GP.eConnect;
using Microsoft.Dynamics.GP.eConnect.Serialization;
using OfficeOpenXml;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml;
using System.Xml.Serialization;

namespace IntegradorDeGP
{
    public class IntegraVentasBandejaXL
    {
        private int _iError;
        private string _sMensajeErr;
        private string _mensaje = "";

        private IParametrosXL _ParamExcel;

        private XmlDocument _xDocXml;
        private string _sDocXml = "";
        private int _filaNuevaFactura = 0;

        public int IError
        {
            get
            {
                return _iError;
            }

            set
            {
                _iError = value;
            }
        }

        public string SMensajeErr
        {
            get
            {
                return _sMensajeErr;
            }

            set
            {
                _sMensajeErr = value;
            }
        }

        public delegate void LogHandler(int iAvance, string sMsj);
        public event LogHandler Progreso;
        public event LogHandler Actualiza;

        /// <summary>
        /// Dispara el evento para actualizar la barra de progreso
        /// </summary>
        /// <param name="iProgreso"></param>
        public void OnProgreso(int iAvance, string sMsj)
        {
            if (Progreso != null)
                Progreso(iAvance, sMsj);
        }
        public void OnActualiza(int i, string carpeta)
        {
            if (Actualiza != null)
                Actualiza(i, carpeta);
        }

        public IntegraVentasBandejaXL(IParametrosXL paramIntegraGP)
        {
            _iError = 0;
            _ParamExcel = paramIntegraGP;
        }

        /// <summary>
        /// Construye documento xml en un xmlDocument.
        /// </summary>
        /// <param name="eConnect"></param>
        public void serializa(eConnectType eConnect)
        {
            try
            {
                _sDocXml = "";
                _xDocXml = new XmlDocument();
                StringBuilder sbDocXml = new StringBuilder();

                XmlSerializer serializer = new XmlSerializer(eConnect.GetType());
                XmlWriterSettings sett = new XmlWriterSettings();
                sett.Encoding = new UTF8Encoding();  //UTF8Encoding.UTF8; // Encoding.UTF8;
                using (XmlWriter writer = XmlWriter.Create(sbDocXml, sett))
                {
                    serializer.Serialize(writer, eConnect);
                    _sDocXml = sbDocXml.ToString();
                    _xDocXml.LoadXml(_sDocXml);
                }
            }
            catch (Exception)
            {
                throw;
            }
        }

        /// <summary>
        /// Crea el xml de una factura sop a partir de una fila de datos en una hoja excel.
        /// </summary>
        /// <param name="hojaXl">Hoja excel</param>
        /// <param name="filaXl">Fila de la hoja excel a procesar</param>
        public void IntegraFacturaSOP(ExcelWorksheet hojaXl, int filaXl, string sTimeStamp)
        {

            _iError = 0;
            _mensaje = String.Empty;
            string eConnResult = String.Empty;
            eConnectType docEConnectSOP = new eConnectType();
            eConnectType entEconnect = new eConnectType();
            FacturaDeVentaSOP documentoSOP = new FacturaDeVentaSOP(_ParamExcel.ConnectionStringTargetEF);
            eConnectMethods eConnObject = new eConnectMethods();

            Cliente entidadCliente;

            try
            {
                _mensaje = " Número Doc: " + hojaXl.Cells[filaXl, int.Parse(_ParamExcel.FacturaSopnumbe)].Value.ToString().Trim() ;

                entidadCliente = new Cliente(_ParamExcel.ConnectionStringTargetEF, _ParamExcel.FacturaSopTXRGNNUM, _ParamExcel.FacturaSopCUSTNAME, _ParamExcel.ClienteDefaultCUSTCLAS);
                if (entidadCliente.preparaClienteEconn(hojaXl, filaXl))
                {
                   entEconnect.RMCustomerMasterType = entidadCliente.ArrCustomerType;
                   serializa(entEconnect);
                   if (eConnObject.CreateEntity(_ParamExcel.ConnStringTarget, _sDocXml))
                        _mensaje += "--> Cliente Integrado a GP";
                }

                documentoSOP.preparaFacturaSOP(hojaXl, filaXl, sTimeStamp, _ParamExcel);
                docEConnectSOP.SOPTransactionType = new SOPTransactionType[] { documentoSOP.FacturaSop };
                serializa(docEConnectSOP);
                eConnResult = eConnObject.CreateTransactionEntity(_ParamExcel.ConnStringTarget, _sDocXml);
                _sMensajeErr = "--> Integrado a GP";
            }
            catch (NullReferenceException nr)
            {
                string sInner = nr.InnerException == null ? String.Empty : nr.InnerException.Message;
                if (nr.InnerException != null)
                    sInner += nr.InnerException.InnerException == null ? String.Empty : " " + nr.InnerException.InnerException.Message;
                _sMensajeErr = "Excepción al validar datos de la factura SOP. " + nr.Message + " " + sInner + " [" + nr.TargetSite.ToString() + "]";
                _iError++;
            }
            catch (eConnectException eConnErr)
            {

                string sInner = eConnErr.InnerException == null ? String.Empty : eConnErr.InnerException.Message;
                _sMensajeErr = "Excepción eConnect al integrar factura SOP. " + eConnErr.Message + " " + sInner + " [" + eConnErr.TargetSite.ToString() + "]";
                _iError++;
            }
            catch (Exception errorGral)
            {
                string sInner = errorGral.InnerException == null ? String.Empty : errorGral.InnerException.Message;
                if (errorGral.InnerException != null)
                    sInner += errorGral.InnerException.InnerException == null ? String.Empty : " " + errorGral.InnerException.InnerException.Message;
                _sMensajeErr = "Excepción desconocida al integrar factura SOP. " + errorGral.Message + " " + sInner + " [" + errorGral.TargetSite.ToString() + "]";
                _iError++;
            }
            finally
            {
                _filaNuevaFactura = filaXl+1;
                _mensaje = "Fila: " + filaXl.ToString() + _mensaje;
            }
        }

        /// <summary>
        /// Abre los archivos excel de una carpeta y los integra a GP.
        /// </summary>
        public void ProcesaCarpetaEnTrabajo(List<string> archivosSeleccionados)
        {
            try
            {
                _iError = 0;
                DirectoryInfo enTrabajoDir = new DirectoryInfo(this._ParamExcel.rutaCarpeta.ToString() + "\\EnTrabajo");
                archivosExcel archivosEnTrabajo = new archivosExcel();

                foreach (string item in archivosSeleccionados)
                {
                    _iError = 0;
                    string sTimeStamp = System.DateTime.Now.ToString("yyMMddHHmmssfff");
                    string sNombreArchivo = item;

                    archivosEnTrabajo.abreArchivoExcel(enTrabajoDir.ToString(), sNombreArchivo);
                    ExcelWorksheet hojaXl = archivosEnTrabajo.paqueteExcel.Workbook.Worksheets.First();
                    if (archivosEnTrabajo.iError == 0)
                    {
                        int startRow = _ParamExcel.FacturaSopFilaInicial;
                        int iTotal = hojaXl.Dimension.End.Row - startRow + 1;
                        int iFacturasIntegradas = 0;
                        int iFilasIntegradas = 0;
                        int iFacturaIniciaEn = 0;
                        int iAntesIntegradas = 0;
                        OnProgreso(1, "INICIANDO CARGA DE ARCHIVO " + sNombreArchivo + "...");              //Notifica al suscriptor
                        if (startRow > 1)
                            hojaXl.Cells[startRow - 1, this._ParamExcel.FacturaSopColumnaMensajes].Value = "Observaciones";

                        for (int rowNumber = startRow; rowNumber <= hojaXl.Dimension.End.Row; rowNumber++)
                        {
                            if (hojaXl.Cells[rowNumber, this._ParamExcel.FacturaSopColumnaMensajes].Value == null ||
                                !hojaXl.Cells[rowNumber, this._ParamExcel.FacturaSopColumnaMensajes].Value.ToString().Equals("Integrado a GP"))
                            {
                                IntegraFacturaSOP(hojaXl, rowNumber, sTimeStamp);

                                iFacturaIniciaEn = rowNumber;
                                rowNumber = _filaNuevaFactura - 1;

                                if (_iError == 0)
                                {
                                    iFacturasIntegradas++;
                                    for (int ind = iFacturaIniciaEn; ind <= rowNumber; ind++)
                                    {
                                        hojaXl.Cells[ind, this._ParamExcel.FacturaSopColumnaMensajes].Value = "Integrado a GP";
                                        iFilasIntegradas++;
                                    }
                                }
                                else
                                {
                                    hojaXl.Cells[rowNumber, this._ParamExcel.FacturaSopColumnaMensajes].Value = _sMensajeErr;
                                }
                            }
                            else
                            {
                                iAntesIntegradas++;
                                this._mensaje = "Fila: " + rowNumber.ToString();
                                this._sMensajeErr = "anteriormente integrada.";
                            }
                            OnProgreso(100 / iTotal, _mensaje + " " + _sMensajeErr);
                        }
                        OnProgreso(100, "----------------------------------------------");
                        _sMensajeErr = "INTEGRACION FINALIZADA";
                        OnProgreso(100, _sMensajeErr);
                        OnProgreso(100, "Nuevas facturas integradas: " + iFacturasIntegradas.ToString());
                        OnProgreso(100, "Nuevas filas integradas: " + iFilasIntegradas.ToString());
                        OnProgreso(100, "Número de filas con error: " + (iTotal - iFilasIntegradas - iAntesIntegradas).ToString());
                        OnProgreso(100, "Número de filas anteriormente integradas: " + iAntesIntegradas.ToString());
                        OnProgreso(100, "Total de filas leídas: " + iTotal.ToString());
                        archivosEnTrabajo.paqueteExcel.Save();
                        archivosEnTrabajo.paqueteExcel.Dispose();
                        archivosEnTrabajo.mueveAFinalizado(sNombreArchivo, this._ParamExcel.rutaCarpeta.ToString(), sTimeStamp);

                        if (archivosEnTrabajo.iError != 0)
                            OnProgreso(100, archivosEnTrabajo.sMensaje);

                        OnActualiza(0, _ParamExcel.rutaCarpeta);
                    }
                    else
                        OnProgreso(0, archivosEnTrabajo.sMensaje);
                }
            }
            catch (Exception errorGral)
            {
                String im = errorGral.InnerException == null ? " " : " "+errorGral.InnerException.Message;
                if (errorGral.InnerException != null)
                    im += errorGral.InnerException.InnerException == null ? " " : " " +errorGral.InnerException.InnerException.Message;

                _sMensajeErr = "Excepción al leer la carpeta En trabajo. (Verifique que la versión del archivo excel sea 2007 o superior) " + errorGral.Message + im + errorGral.TargetSite.ToString();
                _iError++;
                OnProgreso(0, _sMensajeErr);
            }
        }

    }
}
