using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using IntegradorDeGP;

namespace consolaIntegraGP
{
    class Program
    {
        static void Main(string[] args)
        {
            try
            {
                ParametrosDB paramDB = new ParametrosDB();
                var empresa = paramDB.Empresas.Where(x => x.Idbd == paramDB.DefaultDB).First();
                int i = paramDB.Empresas.IndexOf(empresa);

                paramDB.GetParametros(i);

                //paramDB.ConnectionStringSourceEF = "metadata=res://*/BLL.ModelIntegra.csdl|res://*/BLL.ModelIntegra.ssdl|res://*/BLL.ModelIntegra.msl;provider=System.Data.SqlClient;provider connection string='data source=wwsqlad.centralus.cloudapp.azure.com,1433;initial catalog=INTEGRA50;user id=sa;password=tiiSelam$18;multipleactiveresultsets=True;application name=EntityFramework'";
                //paramDB.ConnStringSource = "User ID=sa;Password=tiiSelam$18;Initial Catalog=INTEGRA50;Data Source=wwsqlad.centralus.cloudapp.azure.com,1433";
                //paramDB.ConnectionStringTargetEF = "metadata=res://*/BLL.ModelGP.csdl|res://*/BLL.ModelGP.ssdl|res://*/BLL.ModelGP.msl;provider=System.Data.SqlClient;provider connection string='data source=wwsqlad.centralus.cloudapp.azure.com,1433;initial catalog=PRO12;user id=sa;password=tiiSelam$18;MultipleActiveResultSets=True;App=EntityFramework'";
                //paramDB.ConnStringTarget = "User ID=sa;Password=tiiSelam$18;Initial Catalog=TST12;Data Source=wwsqlad.centralus.cloudapp.azure.com,1433";
                //paramDB.FormatoFechaDB = "MM/dd/yyyy";

                //Cambia de status a un Id////////////////////////////////
                //IntegraVentasBandejaDB IntegraSOP = new IntegraVentasBandejaDB(paramDB, Environment.UserName);
                //IntegraSOP.eventoProgreso += new IntegraVentasBandejaDB.LogHandler(muestraError);
                //IntegraSOP.ProcesaBandejaDB(114, "INTEGRADO", "ELIMINA_FACTURA_EN_GP");

                //Integra todos los que están en estado LISTO//////////////////////////////
                IntegraVentasBandejaDB bandejaDB = new IntegraVentasBandejaDB(paramDB, Environment.UserName);
                bandejaDB.eventoProgreso += muestraError;   // BandejaDB_eventoProgreso;
                bandejaDB.ProcesaBandejaDB("LISTO", "ENVIAR_A_GP");

                //actualiza el status de los integrados
                //bandejaDB.ProcesaBandejaDBActualizaStatus("INTEGRADO", "CONTABILIZA_FACTURA_EN_GP");



                Console.ReadKey();

            }
            catch (Exception e)
            {
                muestraError(0, e.Message);
                Console.ReadKey();
            }
        }


        private static void muestraError(int i, string m)
        {
            Console.WriteLine(m);

        }
    }
}
