using System;
using System.Data.Entity;
using System.Data.Entity.Infrastructure;

namespace IntegradorDeGP.BLL
{
    public partial class DynamicsGPEntities : DbContext
    {
        public DynamicsGPEntities(String connectionString): base(connectionString)
        {

        }
    }
}
