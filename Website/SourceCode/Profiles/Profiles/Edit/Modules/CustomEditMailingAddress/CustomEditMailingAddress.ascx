<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="CustomEditMailingAddress.ascx.cs"
    Inherits="Profiles.Edit.Modules.CustomEditMailingAddress.CustomEditMailingAddress" %>
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
        <table id="tblEditMailingAddress" width="100%">
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
                                <asp:LinkButton ID="btnEditAddress" runat="server" OnClick="btnEditAddress_OnClick"
                                    CssClass="profileHypLinks"><asp:Image runat="server" ID="btnImgEditAddress" AlternateText=" " ImageUrl="~/Framework/Images/icon_squareArrow.gif"/> 
                                    &nbsp;Edit Mailing Address</asp:LinkButton>
                            </div>
                        </asp:PlaceHolder>
                    </div>
                </td>
            </tr>
            <tr>
                <td colspan="3">
                    <div class="editPage">
                        <asp:PlaceHolder ID="phViewAddress" runat="server">
                            <table>
                                <tr class="topRow">
                                    <td>
                                        Mailing Address
                                    </td>
                                </tr>
                                <tr>
                                    <td style="padding: 5px 10px">
                                        <div><asp:Literal runat="server" ID="litLine1"></asp:Literal></div>
                                        <div><asp:Literal runat="server" ID="litLine2"></asp:Literal></div>
                                        <div>
                                            <asp:Literal runat="server" ID="litCity"></asp:Literal>
                                            <asp:Literal runat="server" ID="litComma"></asp:Literal>&nbsp;
                                            <asp:Literal runat="server" ID="litState"></asp:Literal>&nbsp;
                                            <asp:Literal runat="server" ID="litZip"></asp:Literal>
                                        </div>
                                    </td>
                                </tr>
                            </table>
                        </asp:PlaceHolder>
                        
                        <asp:PlaceHolder ID="phEditAddress" runat="server">
                            <div style="background: yellow; padding: 0.5rem 1.75rem">
                                Changes to mailing address take up to 24 hours to be added to your profile.
                            </div> 
                            <div>
                                <b>Mailing Address</b>
                                <div><asp:TextBox ID="tbLine1" runat="server" placeholder="Line One" MaxLength="200" style="width:100%" /></div>
                                <div><asp:TextBox ID="tbLine2" runat="server" placeholder="Line Two" MaxLength="200" style="width:100%" /></div>
                                <div>
                                    <asp:TextBox ID="tbCity" runat="server" placeholder="City" MaxLength="55" style="width:60ch" />
                                    <asp:TextBox ID="tbState" runat="server" placeholder="State" MaxLength="2" style="width:10ch" />
                                    <asp:TextBox ID="tbZip" runat="server" placeholder="Zip Code" MaxLength="10" style="width:15ch" />
                                </div>
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
