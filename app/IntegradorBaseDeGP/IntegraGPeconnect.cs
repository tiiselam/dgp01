using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml;
using System.Xml.Serialization;
using Microsoft.Dynamics.GP.eConnect;
using Microsoft.Dynamics.GP.eConnect.Serialization;

namespace IntegradorDeGP
{
    public class IntegraGPeconnect
    {
        private XmlDocument _xDocXml;
        private string _sDocXml = "";

        public XmlDocument XDocXml
        {
            get
            {
                return _xDocXml;
            }

            set
            {
                _xDocXml = value;
            }
        }

        public string SDocXml
        {
            get
            {
                return _sDocXml;
            }

            set
            {
                _sDocXml = value;
            }
        }

        public delegate void LogHandler(int iAvance, string sMsj);
        public event LogHandler eventoProgreso;

        /// <summary>
        /// Dispara el evento para actualizar la barra de progreso
        /// </summary>
        /// <param name="iProgreso"></param>
        public void OnProgreso(int iAvance, string sMsj)
        {
            eventoProgreso?.Invoke(iAvance, sMsj);
        }

        public event EventHandler<ErrorEventArgs> eventoErrorDB;
        protected virtual void OnErrorDB(ErrorEventArgs e)
        {
            //si no es null notificar
            eventoErrorDB?.Invoke(this, e);
        }


        public IntegraGPeconnect()
        {
        }

        /// <summary>
        /// Construye documento xml en un xmlDocument.
        /// </summary>
        /// <param name="eConnect"></param>
        public void serializa(eConnectType eConnect)
        {
            try
            {
                SDocXml = "";
                XDocXml = new XmlDocument();
                StringBuilder sbDocXml = new StringBuilder();

                XmlSerializer serializer = new XmlSerializer(eConnect.GetType());
                XmlWriterSettings sett = new XmlWriterSettings();
                sett.Encoding = new UTF8Encoding();  //UTF8Encoding.UTF8; // Encoding.UTF8;
                using (XmlWriter writer = XmlWriter.Create(sbDocXml, sett))
                {
                    serializer.Serialize(writer, eConnect);
                    SDocXml = sbDocXml.ToString();
                    XDocXml.LoadXml(SDocXml);
                }
            }
            catch (Exception)
            {
                throw;
            }
        }

    }
}
