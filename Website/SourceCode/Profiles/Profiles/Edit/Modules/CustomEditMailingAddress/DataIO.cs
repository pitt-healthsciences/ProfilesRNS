
using System.Configuration;
using System.Data.SqlClient;
using System.Data;
using System;
using System.Web;

namespace Profiles.Edit.Modules.CustomEditMailingAddress
{

    public class DataIO : Profiles.Edit.Utilities.DataIO
    {
        public MailingAddress GetMailingAddress(Int64 NodeID, string Predicate)
        {
            string connstr = ConfigurationManager.ConnectionStrings["ProfilesDB"].ConnectionString;

            using (SqlConnection dbconnection = new SqlConnection(connstr))
            {
                try
                {
                    dbconnection.Open();

                    SqlParameter[] param = new SqlParameter[1];
                    param[0] = new SqlParameter("@NodeID", NodeID);
                    SqlCommand comm = GetDBCommand(dbconnection, "[Edit.Module].[CustomEditAddress.Get]", CommandType.StoredProcedure, CommandBehavior.CloseConnection, param);

                    comm.Connection = dbconnection;

                    MailingAddress addr = new MailingAddress();
                    using (SqlDataReader dbreader = comm.ExecuteReader(CommandBehavior.CloseConnection))
                    {
                        while (dbreader.Read())
                        {
                            addr.Line1 = dbreader.GetString(0);
                            addr.Line2 = dbreader.GetString(1);
                            addr.City = dbreader.GetString(2);
                            addr.State = dbreader.GetString(3);
                            addr.Zip = dbreader.GetString(4);
                            break;
                        }
                    }
                    return addr;
                }
                catch (Exception e)
                {
                    Framework.Utilities.DebugLogging.Log(e.Message + e.StackTrace);
                    throw new Exception(e.Message);
                }
            }
        }

        public void SaveMailingAddress(Int64 NodeID, string Predicate, 
            string line1, string line2, string city, string state, string zip
        )
        {
            if (HttpContext.Current.Request.QueryString["subject"] != null)
            {
                Framework.Utilities.Cache.AlterDependency(HttpContext.Current.Request.QueryString["subject"].ToString());
            }
            string connstr = ConfigurationManager.ConnectionStrings["ProfilesDB"].ConnectionString;

            using (SqlConnection dbconnection = new SqlConnection(connstr))
            {
                try
                {
                    dbconnection.Open();

                    SqlCommand dbcommand = new SqlCommand();
                    dbcommand.CommandType = CommandType.StoredProcedure;

                    dbcommand.CommandText = "[Edit.Module].[CustomEditAddress.Set]";
                    dbcommand.CommandTimeout = base.GetCommandTimeout();

                    dbcommand.Parameters.Add(new SqlParameter("@NodeID", NodeID));
                    dbcommand.Parameters.Add(new SqlParameter("@AddressLine1", line1));
                    dbcommand.Parameters.Add(new SqlParameter("@AddressLine2", line2));
                    dbcommand.Parameters.Add(new SqlParameter("@City", city));
                    dbcommand.Parameters.Add(new SqlParameter("@State", state));
                    dbcommand.Parameters.Add(new SqlParameter("@Zip", zip));
                    dbcommand.Connection = dbconnection;
                    dbcommand.ExecuteNonQuery();
                }
                catch (Exception e)
                {
                    throw new Exception(e.Message);
                }
            }
        }


    }

}