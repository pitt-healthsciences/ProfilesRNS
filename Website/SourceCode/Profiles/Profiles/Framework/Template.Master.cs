﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml;
using System.Web.UI.HtmlControls;
using Profiles.Framework.Utilities;
using System.Configuration;

namespace Profiles.Framework
{
    public partial class Template : System.Web.UI.MasterPage
    {
        #region "Private Properties"

        private XmlDocument _presentationxml;
        private List<Framework.Utilities.Panel> _panels;
        private ModulesProcessing mp;
        #endregion
        override protected void OnInit(EventArgs e)
        {

        }
        protected void Page_Load(object sender, EventArgs e)
        {
            try
            {
                toolkitScriptMaster.AsyncPostBackTimeout = 3600;

                if (this.RDFData == null) { this.RDFData = new XmlDocument(); }
                if (this.RDFNamespaces == null) { this.RDFNamespaces = new XmlNamespaceManager(this.RDFData.NameTable); }
/*
                if (this.GetStringFromPresentationXML("Presentation/PageOptions/@CanEdit") == "true")
                    this.CanEdit = true;
                else
                    this.CanEdit = false;
*/
                this.LoadAssets();

                this.InitFrameworkPanels();

                this.BindRepeaterToPanel(ref rptHeader, GetPanelByType("header"));
                this.BindRepeaterToPanel(ref rptActive, GetPanelByType("active"));
                this.BindRepeaterToPanel(ref rptMain, GetPanelByType("main"));
                this.BindRepeaterToPanel(ref rptPassive, GetPanelByType("passive"));

                if (rptHeader.Items.Count == 0)
                {
                    divProfilesHeader.Visible = false;
                }

                this.DrawTabs();
                if (this.GetStringFromPresentationXML("Presentation/PanelList/Panel[@Type='left']") != string.Empty)
                {
                    this.BindRepeaterToPanel(ref rptLeft, GetPanelByType("left"));
                }
                else
                {
                    divContentLeft.Visible = false;
                }



            }
            catch (Exception ex)
            {
                Framework.Utilities.DebugLogging.Log(ex.Message + " ++ master page  protected void Page_Load(object sender, EventArgs e) " + ex.StackTrace);

                HttpContext.Current.Session["GLOBAL_ERROR"] = ex.Message + " ++ " + ex.StackTrace;
                Response.Redirect(Root.Domain + "/error/default.aspx");
                Response.End();
            }
        }



        /// <summary>
        /// Used to set the link for css/js client Assets
        /// </summary>
        protected void LoadAssets()
        {
            //This should loop the application table or be set based on the contest of the RESTFul URL to know
            //What application is currently being viewed then set the correct asset link.

            HtmlLink Profilescss = new HtmlLink();
            Profilescss.Href = Root.Domain + "/framework/css/profiles.css";
            Profilescss.Attributes["rel"] = "stylesheet";
            Profilescss.Attributes["type"] = "text/css";
            Profilescss.Attributes["media"] = "all";
            head.Controls.Add(Profilescss);


            HtmlGenericControl jsscript = new HtmlGenericControl("script");
            jsscript.Attributes.Add("type", "text/javascript");
            jsscript.Attributes.Add("src", Root.Domain + "/Framework/JavaScript/profiles.js");
            Page.Header.Controls.Add(jsscript);



            HtmlLink PRNStheme = new HtmlLink();
            PRNStheme.Href = Root.Domain + "/framework/css/prns-theme.css";
            PRNStheme.Attributes["rel"] = "stylesheet";
            PRNStheme.Attributes["type"] = "text/css";
            PRNStheme.Attributes["media"] = "all";
            head.Controls.Add(PRNStheme);


            HtmlLink PRNSthemeMenusTop = new HtmlLink();
            PRNSthemeMenusTop.Href = Root.Domain + "/framework/css/prns-theme-menus-top.css";
            PRNSthemeMenusTop.Attributes["rel"] = "stylesheet";
            PRNSthemeMenusTop.Attributes["type"] = "text/css";
            PRNSthemeMenusTop.Attributes["media"] = "all";
            head.Controls.Add(PRNSthemeMenusTop);


            HtmlLink PRNSthemePitt = new HtmlLink();
            PRNSthemePitt.Href = Root.Domain + "/framework/css/profiles-pitt.css";
            PRNSthemePitt.Attributes["rel"] = "stylesheet";
            PRNSthemePitt.Attributes["type"] = "text/css";
            PRNSthemePitt.Attributes["media"] = "all";
            head.Controls.Add(PRNSthemePitt);


            Framework.Utilities.DataIO data = new DataIO();
/*
            if (data.CheckSystemMessage() != "")
            {
                ProfilesNotification.Visible = true;
                litSystemNotice.Visible = true;
                litSystemNotice.Text = data.CheckSystemMessage();
            }
            else
            {
 */               ProfilesNotification.Visible = false;
                litSystemNotice.Visible = false;
 //           }

        }
        /// <summary>
        /// Draws the Tabs dispaly based on the presentation xml and the restful URL pattern.
        /// </summary>
        protected void DrawTabs()
        {
            System.Text.StringBuilder tabs = new System.Text.StringBuilder();
            List<Tab> listtabs = new List<Tab>();
            bool currenttab = false;
            foreach (Framework.Utilities.Panel p in _panels)
            {
                if (p.Alias != string.Empty && this.Tab != string.Empty)
                    p.DefaultTab = false;
                else if (p.Alias != string.Empty && p.TabType == "Default" && this.Tab == string.Empty)
                    p.DefaultTab = true;

                if ((p.Alias == this.Tab) || (p.DefaultTab))
                    currenttab = true;
                else
                    currenttab = false;

                if (!p.Alias.IsNullOrEmpty())
                    listtabs.Add(new Tab(p.Name, p.Alias, currenttab, p.DefaultTab));

            }

            if (listtabs.Count > 0)
            {
                bool drawstart = true;

                foreach (Tab t in listtabs)
                {
                    //[MAPS]
                    if (t.Name != "Map")
                    {
                        if (t.URL != null)
                        {
                            if (drawstart)
                            {
                                tabs.Append(Framework.Utilities.Tabs.DrawTabsStart());
                                drawstart = false;
                            }

                            if (t.Active)
                            {
                                tabs.Append(Framework.Utilities.Tabs.DrawActiveTab(t.Name));
                            }
                            else if (Root.AbsolutePath.ToLower().Contains("display.aspx"))
                            {
                                string newtab = t.URL;

                                t.URL = Root.AbsolutePath;

                                t.URL = t.URL.ToLower().Replace("/display.aspx", "");

                                if (!HttpContext.Current.Request.QueryString["subject"].IsNullOrEmpty())
                                    t.URL += "/" + HttpContext.Current.Request.QueryString["subject"].ToString();

                                if (!HttpContext.Current.Request.QueryString["predicate"].IsNullOrEmpty())
                                    t.URL += "/" + HttpContext.Current.Request.QueryString["predicate"].ToString();

                                if (!HttpContext.Current.Request.QueryString["object"].IsNullOrEmpty())
                                    t.URL += "/" + HttpContext.Current.Request.QueryString["object"].ToString();


                                if (this.Tab != string.Empty)
                                {
                                    t.URL = Root.Domain + t.URL + "/" + newtab;
                                }
                                else
                                {
                                    t.URL = Root.Domain + t.URL;
                                }


                                tabs.Append(Framework.Utilities.Tabs.DrawDisabledTab(t.Name, t.URL));

                            }
                            else
                            {
                                //Then its a disabled tab
                                if (this.Tab != string.Empty)
                                {
                                    string[] url = Root.AbsolutePath.Split('/');
                                    string buffer = string.Empty;

                                    if (url.Length == 2)
                                    {

                                        t.URL = Root.Domain + Root.AbsolutePath + "/" + t.URL;
                                    }
                                    else
                                    {
                                        for (int i = 0; i < url.Length - 1; i++)
                                            buffer = buffer + url[i] + "/";

                                        t.URL = Root.Domain + buffer + t.URL;
                                    }

                                }
                                else
                                {

                                    t.URL = Root.Domain + Root.AbsolutePath + "/" + t.URL;
                                }

                                tabs.Append(Framework.Utilities.Tabs.DrawDisabledTab(t.Name, t.URL));
                            }
                        }
                    }
                }

                if (!drawstart)
                    tabs.Append(Framework.Utilities.Tabs.DrawTabsEnd());

                litTabs.Text = tabs.ToString();
            }
            else
            {
                litTabs.Visible = false;
                litJS.Text += "$(document).ready(function () {$('.prns-screen-search').remove();});";
            }
        }

        /// <summary>
        /// Each repeater on the master page will fire this event when its bound with presentation xml data.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void DrawModule(object sender, RepeaterItemEventArgs e)
        {
            PlaceHolder placeholder = null;
            mp = new ModulesProcessing();
            Literal literal = null;

            if (e.Item.ItemType == ListItemType.Header)
            {
                literal = (Literal)e.Item.FindControl("litHeader");
                return;
            }
            if (e.Item.ItemType == ListItemType.Footer)
            {
                literal = (Literal)e.Item.FindControl("litFooter");
                return;
            }

            Utilities.Module module = (Utilities.Module)e.Item.DataItem;
            bool display = true;

            if (module == null) { return; }

            placeholder = (PlaceHolder)e.Item.FindControl("phHeader");

            if (placeholder == null)
                placeholder = (PlaceHolder)e.Item.FindControl("phActive");

            if (placeholder == null)
                placeholder = (PlaceHolder)e.Item.FindControl("phLeft");

            if (placeholder == null)
                placeholder = (PlaceHolder)e.Item.FindControl("phMain");

            if (placeholder == null)
                placeholder = (PlaceHolder)e.Item.FindControl("phPage");

            if (placeholder == null)
                placeholder = (PlaceHolder)e.Item.FindControl("phPassive");


            if (module.Path != "")
            {
                if (module.DisplayRule != string.Empty)
                    if (this.RDFData.SelectSingleNode(module.DisplayRule, this.RDFNamespaces).InnerText != "")
                    {
                        display = false;
                    }
                if (display == true)
                    placeholder.Controls.Add(mp.LoadControl(module.Path, this, this.RDFData, module.ParamList, this.RDFNamespaces));
            }


            display = true;
        }
        protected string GetStringFromPresentationXML(string XPath)
        {
            string buffer = string.Empty;

            XmlNode MyXMLNode = this.PresentationXML.SelectSingleNode(XPath);

            if (MyXMLNode != null)
            {
                buffer = CustomParse.Parse(MyXMLNode.InnerText, this.RDFData, this.RDFNamespaces);
            }

            return buffer.Trim();
        }

        protected void ProcessPresentationXML()
        {

            string js = string.Empty;
            string buffer = string.Empty;
            SessionManagement sm = new SessionManagement();

            // PageTitle
            buffer = GetStringFromPresentationXML("Presentation/PageTitle");
            if (buffer != String.Empty)
                litPageTitle.Text = " <div class=\"pageTitle\"><h2 style='margin-bottom:0px;'>" + buffer + "</h2></div>";
            else
            {
                divTopMainRow.Visible = false;
                litPageTitle.Visible = false;
                js += "$(document).ready(function () {$('#divTopMainRow').remove();});";
            }

            // PageSubTitle
            buffer = GetStringFromPresentationXML("Presentation/PageSubTitle");
            if (buffer != String.Empty)
                litPageSubTitle.Text = "<div class=\"pageSubTitle\"><h2 style=\"margin-bottom:0px;margin-top:0px;font-weight:bold\">" + buffer + "</h2></div>";
            else
            {
                litPageSubTitle.Visible = false;
                js += "$(document).ready(function () {jQuery('.pageSubTitle').remove();});";
            }

            // PageDescription
            buffer = GetStringFromPresentationXML("Presentation/PageDescription");
            if (buffer != String.Empty)
                litPageDescription.Text = buffer;
            else
            {
                litPageDescription.Visible = false;
                js += "$(document).ready(function () {$('.pageDescription').remove();});";
            }

            // PageBackLink
            string PageBackLinkURL = GetStringFromPresentationXML("Presentation/PageBackLinkURL");
            string PageBackLinkName = GetStringFromPresentationXML("Presentation/PageBackLinkName");
            if ((PageBackLinkURL != String.Empty) & (PageBackLinkName != String.Empty))
            {
                string url = string.Empty;

                if (PageBackLinkURL.Contains("~/"))
                    url = Root.Domain + "/" + PageBackLinkURL.Replace("~/", "");
                else if (PageBackLinkURL.Contains("~"))
                    url = Root.Domain + PageBackLinkURL.Replace("~", "");
                else
                    url = PageBackLinkURL;

                litBackLink.Text = "<a class='masterpage-backlink' href=\"" + url + "\"><img src=\"" + Root.Domain + "/Framework/Images/arrowLeft.png\" class=\"pageBackLinkIcon\" alt=\"\" />" + PageBackLinkName + "</a>";
            }
            else
            {
                js += "$(document).ready(function () {$('.backLink').remove();});";
            }

            // Window Title
            buffer = GetStringFromPresentationXML("Presentation/WindowName");

            Page.Header.Title = buffer + " | Profiles RNS";
            litJS.Text += js;

        }

        #region "Panel Methods"

        private void InitFrameworkPanels()
        {
            XmlNodeList panels = this.PresentationXML.GetElementsByTagName("Panel");
            bool display = true;

            if (_panels == null) { _panels = new List<Framework.Utilities.Panel>(); }

            for (int i = 0; i < panels.Count; i++)
            {
                if (panels[i].SelectSingleNode("@DisplayRule") != null)
                {
                    if (panels[i].SelectSingleNode("@DisplayRule").Value != string.Empty)
                    {
                        if (this.RDFData.SelectSingleNode(panels[i].SelectSingleNode("@DisplayRule").Value, this.RDFNamespaces) != null)
                            if (this.RDFData.SelectSingleNode(panels[i].SelectSingleNode("@DisplayRule").Value, this.RDFNamespaces).InnerText == string.Empty)
                            { display = false; }
                    }
                }

                if (display)
                {



                        _panels.Add(new Framework.Utilities.Panel(panels[i]));


                }

                //reset the default to true.  All Panels will display by default unless a DisplayRule is supplied and that rule fails the test to see
                //if data exists for its display
                display = true;
            }
        }

        private List<Framework.Utilities.Panel> GetPanelByType(string paneltype)
        {
            List<Framework.Utilities.Panel> rtnpanel = null;

            try
            {
                //Query the list of panels for the current panel type
                var p = (from panel in _panels
                         where (panel.Type == paneltype)
                         select panel).OrderBy(a => a.TabSort);

                rtnpanel = p.ToList();

            }
            catch (Exception ex) { Framework.Utilities.DebugLogging.Log(ex.Message + " ++  private List<Framework.Utilities.Panel> GetPanelByType(string paneltype) " + ex.StackTrace); }

            return rtnpanel;
        }

        /// <summary>
        /// Used to bind a repeater for a given Panel to a List of Modules.  Each panel is defined by a type.  Each type can be assigned
        /// one or more modules. 
        /// </summary>
        /// <param name="repeater">A repeater control is passed by ref to this method.</param>
        /// <param name="paneltype">The type of the Panel as defined in the PresentationXML //Panel/@Type attribute</param>
        public void BindRepeaterToPanel(ref Repeater repeater, List<Framework.Utilities.Panel> panels)
        {

            Framework.Utilities.Panel rtnpanel = new Profiles.Framework.Utilities.Panel();
            try
            {
                if (panels.Count() == 1)
                {
                    foreach (Framework.Utilities.Panel f in panels)
                        rtnpanel.Modules = f.Modules;
                }
                else
                {
                    rtnpanel.Modules = new List<Utilities.Module>();
                    foreach (Framework.Utilities.Panel f in panels)
                    {
                        if (f.Alias != string.Empty && this.Tab != string.Empty)
                            f.DefaultTab = false;
                        else if (f.Alias != string.Empty && f.TabType == "Default" && this.Tab == string.Empty)
                            f.DefaultTab = true;

                        if ((f.Alias == this.Tab) || (f.DefaultTab))
                        {
                            foreach (Utilities.Module m in f.Modules)
                                rtnpanel.Modules.Add(m);
                        }
                    }
                }
            }
            catch (Exception ex) { Framework.Utilities.DebugLogging.Log(ex.Message + " ++ at public void BindRepeaterToPanel(ref Repeater repeater, List<Framework.Utilities.Panel> panels) " + ex.StackTrace); }

            repeater.DataSource = rtnpanel.Modules;
            repeater.DataBind();

        }

        #endregion

        public string GetURLDomain()
        {
            return Root.Domain;
        }

        public string GetVersion()
        {
            return "3.1.0";
        }

        public String GetMatomoURL()
        {
            return ConfigurationManager.AppSettings["Matomo.URL"];
        }

        public Int32 GetMatomoSiteID()
        {
            string siteID = ConfigurationManager.AppSettings["Matomo.SiteID"];
            return Int32.TryParse(siteID, out int value) ? value : -1;
        }

        #region "Public Properties"
        public XmlDocument PresentationXML
        {
            get { return _presentationxml; }
            set
            {
                string buffer = value.InnerXml;

                //clean out the junk from the text editor people use.
                buffer = buffer.Replace("\t", "");
                buffer = buffer.Replace("\n", "");
                buffer = buffer.Replace("\r", "");

                if (_presentationxml == null)
                    _presentationxml = new XmlDocument();

                _presentationxml.LoadXml(buffer);

                this.ProcessPresentationXML();

            }
        }
        public XmlDocument RDFData { get; set; }
        public XmlNamespaceManager RDFNamespaces { get; set; }
        public string SearchRequest { get; set; }

        public string Tab { get; set; }
        public string SessionID { get; set; }
        public Boolean CanEdit { get; set; }

        #endregion

    }


}

