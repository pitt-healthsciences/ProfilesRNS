﻿/*  
 
    Copyright (c) 2008-2012 by the President and Fellows of Harvard College. All rights reserved.  
    Profiles Research Networking Software was developed under the supervision of Griffin M Weber, MD, PhD.,
    and Harvard Catalyst: The Harvard Clinical and Translational Science Center, with support from the 
    National Center for Research Resources and Harvard University.


    Code licensed under a BSD License. 
    For details, see: LICENSE.txt 
  
*/
using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;

using Profiles.Framework.Utilities;
using System.DirectoryServices.AccountManagement;
using System.DirectoryServices;
using System.Web.UI.WebControls;

namespace Profiles.Login.Utilities
{
    public class DataIO : Framework.Utilities.DataIO
    {

        #region "USER MANAGEMENT"

        /// <summary>
        /// For User Authentication 
        /// </summary>
        /// <param name="user"></param>
        /// <param name="session"></param>
        public bool UserLogin(ref User user)
        {
            bool loginsuccess = false;

            try
            {
                SessionManagement sm = new SessionManagement();
                string connstr = ConfigurationManager.ConnectionStrings["ProfilesDB"].ConnectionString;

                SqlConnection dbconnection = new SqlConnection(connstr);

                SqlParameter[] param = new SqlParameter[4];

                dbconnection.Open();

                param[0] = new SqlParameter("@UserName", user.UserName);
                param[1] = new SqlParameter("@Password", user.Password);


                param[2] = new SqlParameter("@UserID", null);
                param[2].DbType = DbType.Int32;
                param[2].Direction = ParameterDirection.Output;

                param[3] = new SqlParameter("@PersonID", null);
                param[3].DbType = DbType.Int32;
                param[3].Direction = ParameterDirection.Output;


                //For Output Parameters you need to pass a connection object to the framework so you can close it before reading the output params value.
                ExecuteSQLDataCommand(GetDBCommand(ref dbconnection, "[User.Account].[Authenticate]", CommandType.StoredProcedure, CommandBehavior.CloseConnection, param));

                dbconnection.Close();
                try
                {
                    user.UserID = Convert.ToInt32(param[2].Value.ToString());

                    if (param[3].Value != DBNull.Value)
                        user.PersonID = Convert.ToInt32(param[3].Value.ToString());
                }
                catch { }
                if (user.UserID != 0)
                {
                    loginsuccess = true;
                    sm.Session().UserID = user.UserID;
                    sm.Session().PersonID = user.PersonID;
                    sm.Session().LoginDate = DateTime.Now;
                    sm.Session().ViewSecurityGroup = -20;
                    Session session = sm.Session();
                    SessionUpdate(ref session);
                    SessionActivityLog();
                }

            }
            catch (Exception ex)
            {

                throw ex;
            }

            return loginsuccess;

        }


        public bool UserLoginExternal(ref User user)
        {
            bool loginsuccess = false;
            String internalusername = LookupEmployeeNumber(user);

            try
            {
                SessionManagement sm = new SessionManagement();
                string connstr = ConfigurationManager.ConnectionStrings["ProfilesDB"].ConnectionString;

                SqlConnection dbconnection = new SqlConnection(connstr);

                SqlParameter[] param = new SqlParameter[3];

                dbconnection.Open();

                param[0] = new SqlParameter("@UserName", internalusername);

                param[1] = new SqlParameter("@UserID", null);
                param[1].DbType = DbType.Int32;
                param[1].Direction = ParameterDirection.Output;

                param[2] = new SqlParameter("@PersonID", null);
                param[2].DbType = DbType.Int32;
                param[2].Direction = ParameterDirection.Output;


                //For Output Parameters you need to pass a connection object to the framework so you can close it before reading the output params value.
                ExecuteSQLDataCommand(GetDBCommand(ref dbconnection, "[User.Account].[AuthenticateExternal]", CommandType.StoredProcedure, CommandBehavior.CloseConnection, param));

                dbconnection.Close();
                try
                {
                    user.UserID = Convert.ToInt32(param[1].Value.ToString());

                    if (param[2].Value != DBNull.Value)
                        user.PersonID = Convert.ToInt32(param[2].Value.ToString());
                }
                catch { }
                if (user.UserID != 0)
                {
                    loginsuccess = true;
                    sm.Session().UserID = user.UserID;
                    sm.Session().PersonID = user.PersonID;
                    sm.Session().LoginDate = DateTime.Now;
                    sm.Session().ViewSecurityGroup = -20;
                    Session session = sm.Session();
                    SessionUpdate(ref session);
                    SessionActivityLog();
                }

            }
            catch (Exception ex)
            {
                throw ex;
            }
            return loginsuccess;
        }

        /// <summary>
        /// For User Authentication 
        /// </summary>
        /// <param name="user"></param>
        /// <param name="session"></param>
        public void UserLogout()
        {

            SessionManagement sm = new SessionManagement();
            sm.SessionLogout();

        }





        #endregion



        private String LookupEmployeeNumber(User user)
        {
            String adDomain = ConfigurationSettings.AppSettings["AD.Domain"];
            if (null != adDomain)
            {
                using (var pc = new PrincipalContext(ContextType.Domain, adDomain, user.UserName, user.Password))
                {
                    UserPrincipal x = UserPrincipal.FindByIdentity(pc, IdentityType.SamAccountName, "PITT\\" + user.UserName);
                    DirectoryEntry entry = (DirectoryEntry)x.GetUnderlyingObject();
                    var props = entry.Properties;
                    string employeeNumber = null;
                    if (props.Contains("employeeNumber"))
                    {
                        employeeNumber = entry.Properties["employeeNumber"].Value.ToString();
                    }
                    return String.IsNullOrEmpty(employeeNumber) ? user.UserName : employeeNumber;
                }
            } 
            else
            {
                return null;
            }
        }


    }
}
