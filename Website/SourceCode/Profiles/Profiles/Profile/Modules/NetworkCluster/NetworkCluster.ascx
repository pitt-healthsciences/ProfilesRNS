<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="NetworkCluster.ascx.cs"
    Inherits="Profiles.Profile.Modules.NetworkCluster.NetworkCluster" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%-- 
    Copyright (c) 2008-2012 by the President and Fellows of Harvard College. All rights reserved.  
    Profiles Research Networking Software was developed under the supervision of Griffin M Weber, MD, PhD.,
    and Harvard Catalyst: The Harvard Clinical and Translational Science Center, with support from the 
    National Center for Research Resources and Harvard University.

    Code licensed under a BSD License. 
    For details, see: LICENSE.txt 
--%>



<SCRIPT language=JavaScript type=text/javascript>
<!--
    //v1.7
    // Flash Player Version Detection
    // Detect Client Browser type
    // Copyright 2005-2008 Adobe Systems Incorporated.  All rights reserved.
    var isIE = (navigator.appVersion.indexOf("MSIE") != -1) ? true : false;
    var isWin = (navigator.appVersion.toLowerCase().indexOf("win") != -1) ? true : false;
    var isOpera = (navigator.userAgent.indexOf("Opera") != -1) ? true : false;
    function ControlVersion() {
        var version;
        var axo;
        var e;
        // NOTE : new ActiveXObject(strFoo) throws an exception if strFoo isn't in the registry
        try {
            // version will be set for 7.X or greater players
            axo = new ActiveXObject("ShockwaveFlash.ShockwaveFlash.7");
            version = axo.GetVariable("$version");
        } catch (e) {
        }
        if (!version) {
            try {
                // version will be set for 6.X players only
                axo = new ActiveXObject("ShockwaveFlash.ShockwaveFlash.6");

                // installed player is some revision of 6.0
                // GetVariable("$version") crashes for versions 6.0.22 through 6.0.29,
                // so we have to be careful.

                // default to the first public version
                version = "WIN 6,0,21,0";
                // throws if AllowScripAccess does not exist (introduced in 6.0r47)
                axo.AllowScriptAccess = "always";
                // safe to call for 6.0r47 or greater
                version = axo.GetVariable("$version");
            } catch (e) {
            }
        }
        if (!version) {
            try {
                // version will be set for 4.X or 5.X player
                axo = new ActiveXObject("ShockwaveFlash.ShockwaveFlash.3");
                version = axo.GetVariable("$version");
            } catch (e) {
            }
        }
        if (!version) {
            try {
                // version will be set for 3.X player
                axo = new ActiveXObject("ShockwaveFlash.ShockwaveFlash.3");
                version = "WIN 3,0,18,0";
            } catch (e) {
            }
        }
        if (!version) {
            try {
                // version will be set for 2.X player
                axo = new ActiveXObject("ShockwaveFlash.ShockwaveFlash");
                version = "WIN 2,0,0,11";
            } catch (e) {
                version = -1;
            }
        }

        return version;
    }
    // JavaScript helper required to detect Flash Player PlugIn version information
    function GetSwfVer() {
        // NS/Opera version >= 3 check for Flash plugin in plugin array
        var flashVer = -1;

        if (navigator.plugins != null && navigator.plugins.length > 0) {
            if (navigator.plugins["Shockwave Flash 2.0"] || navigator.plugins["Shockwave Flash"]) {
                var swVer2 = navigator.plugins["Shockwave Flash 2.0"] ? " 2.0" : "";
                var flashDescription = navigator.plugins["Shockwave Flash" + swVer2].description;
                var descArray = flashDescription.split(" ");
                var tempArrayMajor = descArray[2].split(".");
                var versionMajor = tempArrayMajor[0];
                var versionMinor = tempArrayMajor[1];
                var versionRevision = descArray[3];
                if (versionRevision == "") {
                    versionRevision = descArray[4];
                }
                if (versionRevision[0] == "d") {
                    versionRevision = versionRevision.substring(1);
                } else if (versionRevision[0] == "r") {
                    versionRevision = versionRevision.substring(1);
                    if (versionRevision.indexOf("d") > 0) {
                        versionRevision = versionRevision.substring(0, versionRevision.indexOf("d"));
                    }
                }
                var flashVer = versionMajor + "." + versionMinor + "." + versionRevision;
            }
        }
        // MSN/WebTV 2.6 supports Flash 4
        else if (navigator.userAgent.toLowerCase().indexOf("webtv/2.6") != -1) flashVer = 4;
        // WebTV 2.5 supports Flash 3
        else if (navigator.userAgent.toLowerCase().indexOf("webtv/2.5") != -1) flashVer = 3;
        // older WebTV supports Flash 2
        else if (navigator.userAgent.toLowerCase().indexOf("webtv") != -1) flashVer = 2;
        else if (isIE && isWin && !isOpera) {
            flashVer = ControlVersion();
        }
        return flashVer;
    }
    // When called with reqMajorVer, reqMinorVer, reqRevision returns true if that version or greater is available
    function DetectFlashVer(reqMajorVer, reqMinorVer, reqRevision) {
        versionStr = GetSwfVer();
        if (versionStr == -1) {
            return false;
        } else if (versionStr != 0) {
            if (isIE && isWin && !isOpera) {
                // Given "WIN 2,0,0,11"
                tempArray = versionStr.split(" "); 	// ["WIN", "2,0,0,11"]
                tempString = tempArray[1]; 		// "2,0,0,11"
                versionArray = tempString.split(","); // ['2', '0', '0', '11']
            } else {
                versionArray = versionStr.split(".");
            }
            var versionMajor = versionArray[0];
            var versionMinor = versionArray[1];
            var versionRevision = versionArray[2];
            // is the major.revision >= requested major.revision AND the minor version >= requested minor
            if (versionMajor > parseFloat(reqMajorVer)) {
                return true;
            } else if (versionMajor == parseFloat(reqMajorVer)) {
                if (versionMinor > parseFloat(reqMinorVer))
                    return true;
                else if (versionMinor == parseFloat(reqMinorVer)) {
                    if (versionRevision >= parseFloat(reqRevision))
                        return true;
                }
            }
            return false;
        }
    }
    function AC_AddExtension(src, ext) {
        if (src.indexOf('?') != -1)
            return src.replace(/\?/, ext + '?');
        else
            return src + ext;
    }
    function AC_Generateobj(objAttrs, params, embedAttrs) {
        var str = '';
        if (isIE && isWin && !isOpera) {
            str += '<object ';
            for (var i in objAttrs) {
                str += i + '="' + objAttrs[i] + '" ';
            }
            str += '>';
            for (var i in params) {
                str += '<param name="' + i + '" value="' + params[i] + '" /> ';
            }
            str += '</object>';
        }
        else {
            str += '<embed ';
            for (var i in embedAttrs) {
                str += i + '="' + embedAttrs[i] + '" ';
            }
            str += '> </embed>';
        }
        document.write(str);
    }
    function AC_FL_RunContent() {
        var ret =
    AC_GetArgs
    (arguments, ".swf", "movie", "clsid:d27cdb6e-ae6d-11cf-96b8-444553540000"
     , "application/x-shockwave-flash"
    );
        AC_Generateobj(ret.objAttrs, ret.params, ret.embedAttrs);
    }
    function AC_SW_RunContent() {
        var ret =
    AC_GetArgs
    (arguments, ".dcr", "src", "clsid:166B1BCA-3F9C-11CF-8075-444553540000"
     , null
    );
        AC_Generateobj(ret.objAttrs, ret.params, ret.embedAttrs);
    }
    function AC_GetArgs(args, ext, srcParamName, classid, mimeType) {
        var ret = new Object();
        ret.embedAttrs = new Object();
        ret.params = new Object();
        ret.objAttrs = new Object();
        for (var i = 0; i < args.length; i = i + 2) {
            var currArg = args[i].toLowerCase();
            switch (currArg) {
                case "classid":
                    break;
                case "pluginspage":
                    ret.embedAttrs[args[i]] = args[i + 1];
                    break;
                case "src":
                case "movie":
                    args[i + 1] = AC_AddExtension(args[i + 1], ext);
                    ret.embedAttrs["src"] = args[i + 1];
                    ret.params[srcParamName] = args[i + 1];
                    break;
                case "onafterupdate":
                case "onbeforeupdate":
                case "onblur":
                case "oncellchange":
                case "onclick":
                case "ondblclick":
                case "ondrag":
                case "ondragend":
                case "ondragenter":
                case "ondragleave":
                case "ondragover":
                case "ondrop":
                case "onfinish":
                case "onfocus":
                case "onhelp":
                case "onmousedown":
                case "onmouseup":
                case "onmouseover":
                case "onmousemove":
                case "onmouseout":
                case "onkeypress":
                case "onkeydown":
                case "onkeyup":
                case "onload":
                case "onlosecapture":
                case "onpropertychange":
                case "onreadystatechange":
                case "onrowsdelete":
                case "onrowenter":
                case "onrowexit":
                case "onrowsinserted":
                case "onstart":
                case "onscroll":
                case "onbeforeeditfocus":
                case "onactivate":
                case "onbeforedeactivate":
                case "ondeactivate":
                case "type":
                case "codebase":
                case "id":
                    ret.objAttrs[args[i]] = args[i + 1];
                    break;
                case "width":
                case "height":
                case "align":
                case "vspace":
                case "hspace":
                case "class":
                case "title":
                case "accesskey":
                case "name":
                case "tabindex":
                    ret.embedAttrs[args[i]] = ret.objAttrs[args[i]] = args[i + 1];
                    break;
                default:
                    ret.embedAttrs[args[i]] = ret.params[args[i]] = args[i + 1];
            }
        }
        ret.objAttrs["classid"] = classid;
        if (mimeType) ret.embedAttrs["type"] = mimeType;
        return ret;
    }
// -->
</SCRIPT>
<div id="divClusterGraph">
<div>
	<div class="clusterWarning">
		Please note that this visualization requires a fast computer and video card. It might cause web browsers on slower machines to become unresponsive.
		<div style='margin-top: 10px;'>
		<a id='showClusterViewLink'>
			<img src="<%= Profiles.Framework.Utilities.Root.Domain %>/Framework/images/icon_squareArrow.gif" border="0" alt="" style="position:relative;top:1px;">&nbsp;Continue to Cluster View
		</a>
		</div>
	</div>
	
<%--<div style="position: absolute; z-index: 999;">--%>
	<div style='display:none;'>
		<div style="width: 600px; font-size: 12px; line-height: 16px; border-bottom: 1px dotted #999;
			padding-bottom: 12px; margin-bottom: 6px;">
			This cluster graph shows the co-authors (green circles) and top co-authors of co-authors (blue circles) of <span style="font-weight: bold; color: #666;">
				<asp:Label ID="lblProfileName" runat="server"></asp:Label></span> (red circle). 
			The size of a circle is proportional to the number of publications that author has. The thickness of a line connecting two authors' names 
			is proportional to the number of publications that they share. Options for customizing this network view are listed below the graph.
		</div>
		<div style="margin-top: 8px; font-weight: bold; color: #BD2F3C; border-bottom: none;
			width: 600px; height: 20px; text-align: center;">
			<div id="person_name">
				<b></b>
			</div>
		</div>
	</div>


<%--<div runat="server" id="divSwfScript" style="width: 600px; height: 600px; position: relative; top: 35px;">--%>
	<div runat="server" id="divSwfScript" class='clusterView' style="height: 485px; position: relative; display: none;">
	   

	</div>

<%--<div style="padding: 0px; width: 600px; text-align: center; position: absolute; top: 770px; z-index: 999;">--%>
	<div style='display:none;'>
		<div style="border-top: 1px dotted #999; font-size: 12px; line-height: 16px; padding-top: 12px;
			margin-top: 8px; text-align: left;">
			<span style="font-weight: bold; color: #666;">Click and drag</span> the name of any author to adjust the clusters. 
			<span style="font-weight: bold; color: #666;">Ctrl-click</span> a name to view that person's network of co-authors. 
			<span style="font-weight: bold; color: #666;">Alt-click</span> a name to view that person's full profile. Please note that it 
			might take several minutes for the clusters in this graph to form, and each time you view the page the graph might look slightly different.	
		</div>
	</div>
</div>
    <br />
    To see the data from this visualization as text, <a id="divShowTimelineTable" tabindex="0">click here.</a>
        
    </div>
    <div id="divDataText" style="display:none;margin-top:12px;margin-bottom:8px;">
        <asp:Literal runat="server" ID="litNetworkText"></asp:Literal> 
        <br />
        To return to the cluster graph, <a id="dirReturnToTimeline" tabindex="0">click here.</a>                       
    </div>

<script type="text/javascript">
	// Use jQuery instead of $ to avoid conflicts
	jQuery(function() {
		jQuery('#showClusterViewLink').bind('click', function() {			
			jQuery('div.clusterWarning').hide().siblings('div').show();			
			loadClusterView();
		});
});

jQuery(function () {
    jQuery("#divShowTimelineTable").bind("click", function () {

        jQuery("#divDataText").show();
        jQuery("#divClusterGraph").hide();
    });

    jQuery("#divShowTimelineTable").bind("keypress", function (e) {
        if (e.keyCode == 13) {
            jQuery("#divDataText").show();
            jQuery("#divClusterGraph").hide();
        }
    });
});

jQuery(function () {
    jQuery("#dirReturnToTimeline").bind("click", function () {
        jQuery("#divDataText").hide();
        jQuery("#divClusterGraph").show();
    });

    jQuery("#dirReturnToTimeline").bind("keypress", function (e) {
        if (e.keyCode == 13) {
            jQuery("#divDataText").hide();
            jQuery("#divClusterGraph").show();
        }
    });
});
</script>