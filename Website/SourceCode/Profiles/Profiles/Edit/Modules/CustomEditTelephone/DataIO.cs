
using System.Configuration;
using System.Data.SqlClient;
using System.Data;
using System;
using System.Web;

namespace Profiles.Edit.Modules.CustomEditTelephone
{

    public class DataIO : Profiles.Edit.Utilities.DataIO
    {
        public string GetTelephone(Int64 NodeID, string Predicate)
        {
            string connstr = ConfigurationManager.ConnectionStrings["ProfilesDB"].ConnectionString;

            using (SqlConnection dbconnection = new SqlConnection(connstr))
            {
                try
                {
                    dbconnection.Open();

                    SqlParameter[] param = new SqlParameter[1];
                    param[0] = new SqlParameter("@NodeID", NodeID);
                    SqlCommand comm = GetDBCommand(dbconnection, "[Edit.Module].[CustomEditPhone.Get]", CommandType.StoredProcedure, CommandBehavior.CloseConnection, param);

                    comm.Connection = dbconnection;

                    string email = "";
                    using (SqlDataReader dbreader = comm.ExecuteReader(CommandBehavior.CloseConnection))
                    {

                        while (dbreader.Read())
                        {
                            email = dbreader.GetString(0);
                            break;
                        }

                    }
                    return email;
                }
                catch (Exception e)
                {
                    Framework.Utilities.DebugLogging.Log(e.Message + e.StackTrace);
                    throw new Exception(e.Message);
                }
            }
        }

        public void SaveTelephones(Int64 NodeID, string Predicate, string phone)
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

                    dbcommand.CommandText = "[Edit.Module].[CustomEditPhone.Set]";
                    dbcommand.CommandTimeout = base.GetCommandTimeout();

                    dbcommand.Parameters.Add(new SqlParameter("@NodeID", NodeID));
                    dbcommand.Parameters.Add(new SqlParameter("@Phone", phone));
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