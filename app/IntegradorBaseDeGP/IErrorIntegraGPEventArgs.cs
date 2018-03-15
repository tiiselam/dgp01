using System;
using System.Collections.Generic;
using System.Text;

namespace IntegradorDeGP
{
    public class ErrorEventArgs: EventArgs
    {
        //public string Archivo { get; set; }
        public string mensajeError { get; set; }
    }
}
