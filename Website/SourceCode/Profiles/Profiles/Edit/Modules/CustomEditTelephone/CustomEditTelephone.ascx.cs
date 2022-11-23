
using System;
using System.Collections.Generic;
using System.Xml;

using Profiles.Framework.Utilities;


namespace Profiles.Edit.Modules.CustomEditTelephone
{
    public partial class CustomEditTelephone : BaseModule
    {
        Edit.Modules.CustomEditTelephone.DataIO data;

        protected void Page_Load(object sender, EventArgs e)
        {
            DrawProfilesModule();
        }


        public CustomEditTelephone() : base() { }

        public CustomEditTelephone(XmlDocument pagedata, List<ModuleParams> moduleparams, XmlNamespaceManager pagenamespaces)
            : base(pagedata, moduleparams, pagenamespaces)
        {
            SessionManagement sm = new SessionManagement();
            base.BaseData = pagedata;

            data = new Profiles.Edit.Modules.CustomEditTelephone.DataIO();


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

            this.phEditTelephone.Visible = false;

            this.Phone = data.GetTelephone(this.SubjectID, this.PredicateURI);
        }

        private void DrawProfilesModule()
        {
            tbTelephone.Text = litTelephone.Text = this.Phone;
        }

        private void SecurityClicked(object sender, EventArgs e)
        {
            bool securing
                = Session["pnlSecurityOptions.Visible"] == null
                  ? false : (bool)Session["pnlSecurityOptions.Visible"];
            btnEditTelephone.Visible = !securing;
            phViewTelephone.Visible = true;
            phEditTelephone.Visible = false;
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

        protected void btnEditTelephone_OnClick(object sender, EventArgs e)
        {
            bool editing
                = Session["editingTelephone"] == null
                  ? true : !(bool)Session["editingTelephone"];
            securityOptions.Visible = !editing;
            phViewTelephone.Visible = !editing;
            phEditTelephone.Visible = editing;
            btnImgEditTelephone.ImageUrl
              = editing
                ? "~/Framework/Images/icon_squareDownArrow.gif"
                : "~/Framework/Images/icon_squareArrow.gif";
            Session["editingTelephone"] = editing;
        }

        protected void btnSaveAndClose_OnClick(object sender, EventArgs e)
        {
            this.Phone = tbTelephone.Text;
            data.SaveTelephones(this.SubjectID, this.PredicateURI, this.Phone);
            this.btnCancel_OnClick(sender, e);
        }

        protected void btnCancel_OnClick(object sender, EventArgs e)
        {
            securityOptions.Visible = true;
            btnEditTelephone.Visible = true;
            phViewTelephone.Visible = true;
            phEditTelephone.Visible = false;
            Session["editingTelephone"] = false;
            this.DrawProfilesModule();
        }


        public Int64 SubjectID { get; set; }

        public XmlDocument PropertyListXML { get; set; }

        public string PredicateURI { get; set; }

        public string Phone { get; set; }

    }
}