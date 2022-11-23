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
using System.Xml.Xsl;

using Profiles.Framework.Utilities;


namespace Profiles.Edit.Modules.CustomEditMailingAddress
{
    public partial class CustomEditMailingAddress :  BaseModule
    {
        Edit.Modules.CustomEditMailingAddress.DataIO data;

        protected void Page_Load(object sender, EventArgs e)
        {
            DrawProfilesModule();          
        }

        public CustomEditMailingAddress() : base() { }
        public CustomEditMailingAddress(XmlDocument pagedata, List<ModuleParams> moduleparams, XmlNamespaceManager pagenamespaces)
            : base(pagedata, moduleparams, pagenamespaces)
        {
            SessionManagement sm = new SessionManagement();
            base.BaseData  = pagedata;

            data = new Profiles.Edit.Modules.CustomEditMailingAddress.DataIO();

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

            this.phEditAddress.Visible = false;

            this.Address = data.GetMailingAddress(this.SubjectID, this.PredicateURI);
        }

        private void DrawProfilesModule()
        {
            tbLine1.Text = litLine1.Text = this.Address.Line1;
            tbLine2.Text = litLine2.Text = this.Address.Line2;
            tbCity.Text = litCity.Text = this.Address.City;
            tbState.Text = litState.Text = this.Address.State;
            litComma.Text = String.IsNullOrEmpty(this.Address.State) ? "" : ",";
            tbZip.Text = litZip.Text = this.Address.Zip;
        }

        private void SecurityClicked(object sender, EventArgs e)
        {
            bool securing
                = Session["pnlSecurityOptions.Visible"] == null
                  ? false : (bool)Session["pnlSecurityOptions.Visible"];
            btnEditAddress.Visible = !securing;
            phViewAddress.Visible = true;
            phEditAddress.Visible = false;
        }

        private void UpdateVisibility()
        {
            Edit.Utilities.DataIO data = new Profiles.Edit.Utilities.DataIO();
            int securitygroup = Convert.ToInt32(this.PropertyListXML.SelectSingleNode("PropertyList/PropertyGroup/Property/@ViewSecurityGroup").Value);

            data.UpdateSecuritySetting(this.SubjectID, data.GetStoreNode(this.PredicateURI), securitygroup);

            if (securitygroup >= -10 && securitygroup < 0)
            {
                data.UpdateSecuritySetting(this.SubjectID, data.GetStoreNode("http://vivoweb.org/ontology/core#phoneNumber"), -20);
            }
            else
            {
                data.UpdateSecuritySetting(this.SubjectID, data.GetStoreNode("http://vivoweb.org/ontology/core#phoneNumber"), securitygroup);
            }

        }

        protected void btnEditAddress_OnClick(object sender, EventArgs e)
        {
            bool editing
                = Session["editingAddress"] == null
                  ? true : !(bool)Session["editingAddress"];
            securityOptions.Visible = !editing;
            phViewAddress.Visible = !editing;
            phEditAddress.Visible = editing;
            btnImgEditAddress.ImageUrl
              = editing
                ? "~/Framework/Images/icon_squareDownArrow.gif"
                : "~/Framework/Images/icon_squareArrow.gif";
            Session["editingAddress"] = editing;
        }

        protected void btnSaveAndClose_OnClick(object sender, EventArgs e)
        {
            data.SaveMailingAddress(
                this.SubjectID, this.PredicateURI,
                tbLine1.Text, tbLine2.Text, tbCity.Text, tbState.Text, tbZip.Text
            );
            this.Address = new MailingAddress(
                tbLine1.Text, tbLine2.Text, tbCity.Text, tbState.Text, tbZip.Text
            );
            this.btnCancel_OnClick(sender, e);
        }

        protected void btnCancel_OnClick(object sender, EventArgs e)
        {
            securityOptions.Visible = true;
            btnEditAddress.Visible = true;
            phViewAddress.Visible = true;
            phEditAddress.Visible = false;
            Session["editingAddress"] = false;
            this.DrawProfilesModule();
        }

        public Int64 SubjectID { get; set; }

        public string PredicateURI { get; set; }

        public XmlDocument PropertyListXML{get;set;}
 
        public MailingAddress Address { get; set; }
    }
}