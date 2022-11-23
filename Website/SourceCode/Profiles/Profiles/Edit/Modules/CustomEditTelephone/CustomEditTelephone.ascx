<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="CustomEditTelephone.ascx.cs" Inherits="Profiles.Edit.Modules.CustomEditTelephone.CustomEditTelephone" %>
<%@ Register TagName="Options" TagPrefix="security" Src="~/Edit/Modules/SecurityOptions/SecurityOptions.ascx" %>
<asp:UpdatePanel ID="upnlEditSection" runat="server">
    <ContentTemplate>
        <asp:UpdateProgress ID="updateProgress" runat="server">
            <ProgressTemplate>
                <div style="position: fixed; text-align: center; height: 100px; width: 100px; top: 0;
                    right: 0; left: 0; z-index: 9999999; opacity: 0.7;">
                    <span style="border-width: 0px; position: fixed; padding: 50px; background-color: #FFFFFF;
                        font-size: 25px; left: 40%; top: 40%;"><img alt="Loading..." src="../edit/images/loader.gif" /></span>
                </div>
            </ProgressTemplate>
        </asp:UpdateProgress>   
        <table id="tblEditTelephone" width="100%">
            <tr>
                <td colspan='3'>
                    <asp:Literal runat="server" ID="litBackLink"></asp:Literal>
                </td>
            </tr>
            <tr>
                <td colspan="3">
                    <div style="padding: 10px 0px;">
                        <asp:Panel runat="server" ID="pnlSecurityOptions">
                            <security:Options runat="server" ID="securityOptions"></security:Options>
                        </asp:Panel>          
                        <asp:PlaceHolder ID="phEditButtons" runat="server">
                            <div style="padding-bottom: 10px;">
                                <asp:LinkButton ID="btnEditTelephone" runat="server" OnClick="btnEditTelephone_OnClick"
                                    CssClass="profileHypLinks"><asp:Image runat="server" ID="btnImgEditTelephone" AlternateText=" " ImageUrl="~/Framework/Images/icon_squareArrow.gif"/> 
                                    &nbsp;Edit Telephone Number</asp:LinkButton>
                            </div>
                        </asp:PlaceHolder>
                    </div>
                </td>
            </tr>
            <tr>
                <td colspan="3">
                    <div class="editPage">
                        <asp:PlaceHolder ID="phViewTelephone" runat="server">
                            <table width="100%">
                                <tr class="topRow editTable">
                                    <td>
                                        Telephone
                                    </td>
                                </tr>
                                <tr class="editTable">
                                    <td style="padding: 5px 10px">
                                        <asp:Literal runat="server" ID="litTelephone"></asp:Literal>
                                    </td>
                                </tr>
                            </table>
                        </asp:PlaceHolder>

                        <asp:PlaceHolder ID="phEditTelephone" runat="server">
                            <div style="background: yellow; padding: 0.5rem 1.75rem">
                                Changes to phone number take up to 24 hours to be added to your profile.
                            </div> <div>
                                <b>Telephone Number</b>
                                <asp:TextBox ID="tbTelephone" runat="server"  />
                            </div>
                            <div class="actionbuttons">
                                <asp:LinkButton ID="btnSaveAndClose" runat="server" CausesValidation="False"
                                    OnClick="btnSaveAndClose_OnClick" Text="Save" TabIndex="11" />
                                <asp:Literal runat="server" ID="lblInsertResearcherRolePipe">&nbsp;&nbsp;<b>|</b>&nbsp;&nbsp;</asp:Literal>
                                <asp:LinkButton ID="btnCancel" runat="server" CausesValidation="False" OnClick="btnCancel_OnClick"
                                    Text="Cancel" TabIndex="7" />
                            </div>
                        </asp:PlaceHolder>

                    </div>
                </td>
            </tr>
        </table>
    </ContentTemplate>
</asp:UpdatePanel>
