using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace IntegradorDeGP
{
    public interface IParametrosXL : IParametros
    {
        string ClienteDefaultCUSTCLAS { get; set; }
        string rutaCarpeta { get; set; }
        int FacturaSopFilaInicial { get; set; }
        int FacturaSopColumnaMensajes { get; set; }

        string FacturaSopnumbe { get; set; }
        string FacturaSopDocdate { get; set; }
        string FacturaSopDuedate { get; set; }
        string FormatoFechaXL { get; set; }
        string FacturaSopTXRGNNUM { get; set; }
        string FacturaSopUNITPRCE { get; set; }
        string FacturaSopCUSTNAME { get; set; }
    }
}
