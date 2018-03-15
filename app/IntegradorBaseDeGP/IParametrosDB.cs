
using System.Collections.Generic;


namespace IntegradorDeGP
{
    public interface IParametrosDB: IParametros
    {
        string ConnStringSource { get; set; }
        string ConnectionStringSourceEF { get; set; }
        string FormatoFechaDB { get; set; }
        Dictionary<string, string> IdsDocumento { get; set; } //= new Dictionary<string, Int16>();
    }

}
