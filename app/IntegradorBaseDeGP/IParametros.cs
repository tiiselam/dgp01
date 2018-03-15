using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace IntegradorDeGP
{
    public interface IParametros
    {
        string ConnStringTarget { get; set; }
        string ConnectionStringTargetEF { get; set; }
        string RutaLog { get; set; }
    }
}
