using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.Dynamics.GP.eConnect;
using Microsoft.Dynamics.GP.eConnect.Serialization;
using IntegradorDeGP.BLL;

//using System.Diagnostics;
//using System.IO;

namespace IntegradorDeGP
{
    public class FacturaDeVentaSOPBandejaDB
    {
        taSopHdrIvcInsert facturaSopCa;
        taSopLineIvcInsert_ItemsTaSopLineIvcInsert facturaSopDe;
        SOPTransactionType facturaSop;
        IParametrosDB parametrosDB;

        //string formatoFecha;
        public event EventHandler<ErrorEventArgs> eventoErrorDB;
        protected virtual void OnErrorDB(ErrorEventArgs e)
        {
            //si no es null notificar
            eventoErrorDB?.Invoke(this, e);
        }

        //TraceSource trace;
        //TextWriterTraceListener textListener;

        public SOPTransactionType FacturaSop
        {
            get
            {
                return facturaSop;
            }

            set
            {
                facturaSop = value;
            }
        }

        public FacturaDeVentaSOPBandejaDB(IParametrosDB paramDB)
        {
            //Stream outputFile = File.Create(paramDB.RutaLog+@"\traceInterfazGP.txt");
            //textListener = new TextWriterTraceListener(outputFile);
            //trace = new TraceSource("trSource", SourceLevels.All);
            //trace.Listeners.Clear();
            //trace.Listeners.Add(textListener);
            //trace.TraceInformation("integra factura sop");

            parametrosDB = paramDB;
            facturaSopCa = new taSopHdrIvcInsert();
            facturaSop = new SOPTransactionType();
        }

        string getNextSopNumbe(short soptype, string docId)
        {
            var sn = new Microsoft.Dynamics.GP.eConnect.GetSopNumber();
            return sn.GetNextSopNumber(soptype, docId, parametrosDB.ConnStringTarget);
        }

        public void armaFacturaCaEconn(vwIntegracionesVentas preFacturasIntegCab, IList<vwPreFacturas> preFacturasDet, string sTimeStamp, string tipoContribuyente) 
        {
            try
            {
                short soptype = preFacturasIntegCab.SOPTYPE_GP ?? 3;
                
                //var docId = parametrosDB.IdsDocumento.Where(x=>x.Key.CompareTo(tipoContribuyente)==0)?.First() ;
                string docId = string.Empty;
                parametrosDB.IdsDocumento.TryGetValue(tipoContribuyente.Trim(), out docId);

                if (string.IsNullOrEmpty( docId))
                    throw new InvalidOperationException(string.Concat("No existe configurado el tipo de contribuyente ", tipoContribuyente ," en el archivo de parámetros. [FacturaDeVentaSOPBandejaDB.armaFacturaCaEconn]"));

                string sopnumbe = getNextSopNumbe(soptype, docId);

                facturaSopCa.CREATETAXES = 1;   //1: crear impuestos automáticamente
                facturaSopCa.DEFPRICING = 1;    //1: calcular automáticamente; 0:se debe indicar el precio unitario

                facturaSopCa.BACHNUMB = sTimeStamp;
                facturaSopCa.SOPTYPE = soptype;
                facturaSopCa.DOCID = docId;
                facturaSopCa.SOPNUMBE = sopnumbe;
                facturaSopCa.DOCDATE = preFacturasIntegCab.FECHADOC.ToString(parametrosDB.FormatoFechaDB);
                facturaSopCa.CUSTNMBR = preFacturasIntegCab.IDCLIENTE;
                facturaSopCa.CSTPONBR = preFacturasIntegCab.NUMDOCARN;

                facturaSopCa.REFRENCE = preFacturasIntegCab.OBSERVACIONES;

                //facturaSopCa.SUBTOTAL = Decimal.Round(unitprice, 2);
                //facturaSopCa.DOCAMNT = facturaSopCa.SUBTOTAL;

                facturaSop.taSopLineIvcInsert_Items = new taSopLineIvcInsert_ItemsTaSopLineIvcInsert[preFacturasDet.Count];
                int i = 0;
                foreach (var d in preFacturasDet)
                {
                    facturaSopDe = new taSopLineIvcInsert_ItemsTaSopLineIvcInsert();
                    facturaSopDe.SOPTYPE = facturaSopCa.SOPTYPE;
                    facturaSopDe.SOPNUMBE = facturaSopCa.SOPNUMBE;
                    facturaSopDe.CUSTNMBR = facturaSopCa.CUSTNMBR;
                    facturaSopDe.DOCDATE = facturaSopCa.DOCDATE;
                    facturaSopDe.ITEMNMBR = d.IDITEM;
                    facturaSopDe.ITEMDESC = d.DESCRIPCION;
                    facturaSopDe.QUANTITY = d.CANTIDAD;
                    facturaSopDe.DEFPRICING = 1;     //1: calcular el precio y precio extendido automáticamente
                    //facturaSopDe.DEFEXTPRICE = 1;   //1: calcular el precio extendido en base al precio unitario y la cantidad
                    facturaSop.taSopLineIvcInsert_Items[i] = facturaSopDe;
                    i++;
                    //Decimal unitprice = 0;
                    //if (Decimal.TryParse(hojaXl.Cells[fila, int.Parse(param.FacturaSopUNITPRCE)].Value.ToString(), out unitprice))
                    //{
                    //    facturaSopDe.UNITPRCE = Decimal.Round(unitprice, 2);
                    //}
                    //else
                    //    throw new FormatException("El monto es incorrecto en la fila " + fila.ToString() + ", columna " + param.FacturaSopUNITPRCE + " [armaFacturaCaEconn]");
                }
            }
            catch (FormatException fmt)
            {
                throw new FormatException("Formato incorrecto [armaFacturaCaEconn]", fmt);
            }
            catch (OverflowException ovr)
            {
                throw new OverflowException("Monto demasiado grande [armaFacturaCaEconn]", ovr);
            }
            //finally
            //{
            //    trace.Flush();
            //    trace.Close();

            //}
        }

        public void preparaFacturaSOP(vwIntegracionesVentas pfIntegraCab, IList<vwPreFacturas> preFacturasDet, string sTimeStamp, string tipoContribuyente)
        {
            armaFacturaCaEconn(pfIntegraCab, preFacturasDet, sTimeStamp, tipoContribuyente);

            facturaSop.taSopHdrIvcInsert = facturaSopCa;

        }

    }
}
