<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:geo="http://aims.fao.org/aos/geopolitical.owl#" xmlns:afn="http://jena.hpl.hp.com/ARQ/function#" xmlns:prns="http://profiles.catalyst.harvard.edu/ontology/prns#" xmlns:obo="http://purl.obolibrary.org/obo/" xmlns:dcelem="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:event="http://purl.org/NET/c4dm/event.owl#" xmlns:bibo="http://purl.org/ontology/bibo/" xmlns:vann="http://purl.org/vocab/vann/" xmlns:vitro07="http://vitro.mannlib.cornell.edu/ns/vitro/0.7#" xmlns:vitro="http://vitro.mannlib.cornell.edu/ns/vitro/public#" xmlns:vivo="http://vivoweb.org/ontology/core#" xmlns:pvs="http://vivoweb.org/ontology/provenance-support#" xmlns:scirr="http://vivoweb.org/ontology/scientific-research-resource#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:xsd="http://www.w3.org/2001/XMLSchema#" xmlns:owl="http://www.w3.org/2002/07/owl#" xmlns:swvs="http://www.w3.org/2003/06/sw-vocab-status/ns#" xmlns:skco="http://www.w3.org/2004/02/skos/core#" xmlns:owl2="http://www.w3.org/2006/12/owl2-xml#" xmlns:skos="http://www.w3.org/2008/05/skos#" xmlns:foaf="http://xmlns.com/foaf/0.1/">
  <xsl:output method="html"/>
  <xsl:template match="/">
    <xsl:variable name="subjectID" select="LocalNetwork/NetworkPeople/NetworkPerson[@d='0']/@id"></xsl:variable>
    <xsl:variable name="subjectName">
      <xsl:value-of select="LocalNetwork/NetworkPeople/NetworkPerson[@d='0']/@fn"/>&#160;<xsl:value-of select="LocalNetwork/NetworkPeople/NetworkPerson[@d='0']/@ln"/>
    </xsl:variable>
    <xsl:variable name="subjectURI" select="LocalNetwork/NetworkPeople/NetworkPerson[@d='0']/@uri"></xsl:variable>
    <xsl:variable name="onehop">
      <xsl:text>-</xsl:text>
      <xsl:for-each select="LocalNetwork/NetworkPeople/NetworkPerson[@d='1']">
        <xsl:value-of select="@id" />
        <xsl:text>-</xsl:text>
      </xsl:for-each>
    </xsl:variable>
    <h2>
      Co-Authors
    </h2>
    <div class="listTable" style="margin-top: 12px, margin-bottom:8px ">
      <table>
        <tr>
          <th>Name</th>
          <th>Publications</th>
          <th>
            Publications Co-Authored with <xsl:value-of select="$subjectName"/>
          </th>
          <th>
            Connections to <xsl:value-of select="$subjectName"/>'s Co-Authors
          </th>
          <th>
            Connections to <xsl:value-of select="$subjectName"/>'s Network
          </th>
        </tr>
        <xsl:for-each select="LocalNetwork/NetworkPeople/NetworkPerson[@d='1']">
          <xsl:variable name="nodeId" select="@id"/>
          <xsl:variable name="uri" select="@uri"/>
          <tr>
            <td style="text-align:left">
              <a href="{$uri}">
                <xsl:value-of select="@fn"/>&#160;<xsl:value-of select="@ln"/>
              </a>
            </td>
            <td>
              <xsl:value-of select="@pubs"/>
            </td>
            <td>
              <xsl:if test="/LocalNetwork/NetworkCoAuthors/NetworkCoAuthor[@id1=$subjectID and @id2=$nodeId]">
                <xsl:value-of select="/LocalNetwork/NetworkCoAuthors/NetworkCoAuthor[@id1=$subjectID and @id2=$nodeId]/@n"   />
              </xsl:if>
              <xsl:if test="/LocalNetwork/NetworkCoAuthors/NetworkCoAuthor[@id2=$subjectID and @id1=$nodeId]">
                <xsl:value-of select="/LocalNetwork/NetworkCoAuthors/NetworkCoAuthor[@id2=$subjectID and @id1=$nodeId]/@n"   />
              </xsl:if>
            </td>
            <td>
              <xsl:value-of select="count(/LocalNetwork/NetworkCoAuthors/NetworkCoAuthor[@id1=$nodeId and contains( $onehop, concat( '-', @id2, '-' ) )]) + count(/LocalNetwork/NetworkCoAuthors/NetworkCoAuthor[@id2=$nodeId and contains( $onehop, concat( '-', @id1, '-' ) )])"/>
            </td>
            <td>
              <xsl:value-of select="count(/LocalNetwork/NetworkCoAuthors/NetworkCoAuthor[@id1=$nodeId]) + count(/LocalNetwork/NetworkCoAuthors/NetworkCoAuthor[@id2=$nodeId])"   />
            </td>
          </tr>
        </xsl:for-each>
      </table>
    </div>
    <br/>
    <br/>
    <h2>Co-Authors of Co-Authors</h2>
    <div class="listTable" style="margin-top: 12px, margin-bottom:8px ">
      <table>
        <tr>
          <th>Name</th>
          <th>Total Publication</th>
          <th>
            Connections to <xsl:value-of select="$subjectName"/>'s Co-Authors
          </th>
          <th>
            Connections to <xsl:value-of select="$subjectName"/>'s Network
          </th>
        </tr>
        <xsl:for-each select="LocalNetwork/NetworkPeople/NetworkPerson[@d='2']">
          <xsl:variable name="nodeId" select="@id"/>
          <xsl:variable name="uri" select="@uri"/>
          <tr>
            <td style="text-align:left">
              <a href="{$uri}">
                <xsl:value-of select="@fn"/>&#160;<xsl:value-of select="@ln"/>
              </a>
            </td>
            <td>
              <xsl:value-of select="@pubs"/>
            </td>
            <td>
              <xsl:value-of select="count(/LocalNetwork/NetworkCoAuthors/NetworkCoAuthor[@id1=$nodeId and contains( $onehop, concat( '-', @id2, '-' ) )]) + count(/LocalNetwork/NetworkCoAuthors/NetworkCoAuthor[@id2=$nodeId and contains( $onehop, concat( '-', @id1, '-' ) )])"/>
            </td>
            <td>
              <xsl:value-of select="count(/LocalNetwork/NetworkCoAuthors/NetworkCoAuthor[@id1=$nodeId]) + count(/LocalNetwork/NetworkCoAuthors/NetworkCoAuthor[@id2=$nodeId])"   />
            </td>
          </tr>
        </xsl:for-each>
      </table>
    </div>
  </xsl:template>
</xsl:stylesheet>