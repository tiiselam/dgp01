using System;
using System.Data.Entity;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace IntegradorDeGP.BLL
{
    public partial class INTEGRAEntities :DbContext
    {
        public INTEGRAEntities(String connectionString): base(connectionString)
        {

        }

    }
}
