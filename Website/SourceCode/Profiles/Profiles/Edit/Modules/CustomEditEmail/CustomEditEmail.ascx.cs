/*  
 
    Copyright (c) 2008-2012 by the President and Fellows of Harvard College. All rights reserved.  
    Profiles Research Networking Software was developed under the supervision of Griffin M Weber, MD, PhD.,
    and Harvard Catalyst: The Harvard Clinical and Translational Science Center, with support from the 
    National Center for Research Resources and Harvard University.


    Code licensed under a BSD License. 
    For details, see: LICENSE.txt 
  
*/
using System;
using System.Collections.Generic;
using System.Xml;

using Profiles.Framework.Utilities;


namespace Profiles.Edit.Modules.CustomEditEmail
{

    public partial class CustomEditEmail : BaseModule
    {
        Edit.Modules.CustomEditEmail.DataIO data;

        protected void Page_Load(object sender, EventArgs e)
        {
            DrawProfilesModule();
        }

        public CustomEditEmail() : base() { }

        public CustomEditEmail(XmlDocument pagedata, List<ModuleParams> moduleparams, XmlNamespaceManager pagenamespaces)
            : base(pagedata, moduleparams, pagenamespaces)
        {
            SessionManagement sm = new SessionManagement();
            base.BaseData = pagedata;

            data = new Profiles.Edit.Modules.CustomEditEmail.DataIO();

            Profiles.Profile.Utilities.DataIO propdata = new Profiles.Profile.Utilities.DataIO();


            if (Request.QueryString["subject"] != null)
                this.SubjectID = Convert.ToInt64(Request.QueryString["subject"]);
            else if (base.GetRawQueryStringItem("subject") != null)
                this.SubjectID = Convert.ToInt64(base.GetRawQueryStringItem("subject"));
            else
                Response.Redirect("~/search");

            this.PredicateURI = Request.QueryString["predicateuri"].Replace("!", "#");
            this.PropertyListXML = propdata.GetPropertyList(this.BaseData, base.PresentationXML, this.PredicateURI, false, true, false);
            litBackLink.Text = "<a href='" + Root.Domain + "/edit/" + this.SubjectID.ToString() + "'>Edit Menu</a> &gt; <b>" + PropertyListXML.SelectSingleNode("PropertyList/PropertyGroup/Property/@Label").Value + "</b>";


            //create a new network triple request.
            base.RDFTriple = new RDFTriple(this.SubjectID, data.GetStoreNode(this.PredicateURI));
            base.RDFTriple.Expand = true;
            base.RDFTriple.ShowDetails = true;
            base.GetDataByURI();//This will reset the data to a Network.

            securityOptions.Subject = this.SubjectID;
            securityOptions.PredicateURI = this.PredicateURI;
            securityOptions.PrivacyCode = Convert.ToInt32(this.PropertyListXML.SelectSingleNode("PropertyList/PropertyGroup/Property/@ViewSecurityGroup").Value);
            securityOptions.SecurityGroups = new XmlDataDocument();
            securityOptions.SecurityGroups.LoadXml(base.PresentationXML.DocumentElement.LastChild.OuterXml);
            securityOptions.BubbleClick += SecurityClicked;

            this.phEditEmail.Visible = false;

            this.Email = data.GetEmailAddress(this.SubjectID, this.PredicateURI);
        }

        private void DrawProfilesModule()
        {
            tbEmail.Text = this.Email;
            litEmailAddress.Text = this.Email;
        }

        private void SecurityClicked(object sender, EventArgs e)
        {
            bool securing 
                = Session["pnlSecurityOptions.Visible"] == null
                  ? false : (bool)Session["pnlSecurityOptions.Visible"];
            btnEditEmail.Visible = !securing;
            phViewEmail.Visible = true;
            phEditEmail.Visible = false;
        }

        private void UpdateVisibility()
        {
            Edit.Utilities.DataIO data = new Profiles.Edit.Utilities.DataIO();
            int securitygroup = Convert.ToInt32(this.PropertyListXML.SelectSingleNode("PropertyList/PropertyGroup/Property/@ViewSecurityGroup").Value);

            data.UpdateSecuritySetting(this.SubjectID, data.GetStoreNode(this.PredicateURI), securitygroup);

            if (securitygroup >= -10 && securitygroup < 0)
            {
                data.UpdateSecuritySetting(this.SubjectID, data.GetStoreNode("http://vivoweb.org/ontology/core#email"), -20);
            }
            else
            {
                data.UpdateSecuritySetting(this.SubjectID, data.GetStoreNode("http://vivoweb.org/ontology/core#email"), securitygroup);
            }

        }

        protected void btnEditEmail_OnClick(object sender, EventArgs e)
        {
            bool editing
                = Session["editingEmailAddress"] == null
                  ? true : !(bool)Session["editingEmailAddress"];
            securityOptions.Visible = !editing;
            phViewEmail.Visible = !editing;
            phEditEmail.Visible = editing;
            btnImgEditEmail.ImageUrl
              = editing
                ? "~/Framework/Images/icon_squareDownArrow.gif"
                : "~/Framework/Images/icon_squareArrow.gif";
            Session["editingEmailAddress"] = editing;
        }

        protected void btnSaveAndClose_OnClick(object sender, EventArgs e)
        {
            this.Email = tbEmail.Text;
            data.SaveEmailAddress(this.SubjectID, this.PredicateURI, this.Email);
            this.btnCancel_OnClick(sender, e);
        }

        protected void btnCancel_OnClick(object sender, EventArgs e)
        {
            securityOptions.Visible = true;
            btnEditEmail.Visible = true;
            phViewEmail.Visible = true;
            phEditEmail.Visible = false;
            Session["editingEmailAddress"] = false;
            this.DrawProfilesModule();
        }

        public Int64 SubjectID { get; set; }
        public XmlDocument PropertyListXML { get; set; }
        public string PredicateURI { get; set; }
        public string Email { get; set; }

    }
}