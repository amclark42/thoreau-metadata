<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns="http://www.w3.org/1999/xhtml"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="#all"
  version="2.0">
  
  <!-- run this file on itself, specify input dir via param -->
  <!-- reads in param-specified files, generates table of   -->
  <!-- extracted info -->
  
  <xsl:output method="xhtml" indent="yes"/>
  
  <xsl:param name="homeName" select="'home'">
    <!-- should be 'home' for GNU/Linux, 'Users' for Mac OS X -->
  </xsl:param>
  <xsl:param name="dataSel" select="'select=*.xml;'"/>
  <xsl:param name="dataParams" select="'recurse=yes;on-error=ignore'"/>
  <xsl:param name="collected"
    select="escape-html-uri( concat('file:///',$homeName,'/syd/Documents/DSG/thoreau-metadata/data_files?',$dataSel,$dataParams) )"/>
  
  <xsl:template match="/">
    <html>
      <head>
        <title>4GP</title>
        <meta name="generated_by" content="???"/>
        <script type="application/javascript" src="http://www.wwp.neu.edu/utils/bin/javascript/sorttable.js"/>
        <style type="text/css">
          td { padding: 0.5ex; }
          thead { background-color: #FAC; }
          td.date { color: #101820; }
          td.titl { }
          td.iden { font-family: monospace; font-size: x-small; }
          td.pars { background-color: #F8F0E8; }
          td.pros { font-size: xx-small; }
          td.note { }
        </style>
      </head>
      <body>
        <h1>Thoreau Drawings</h1>
        <table class="sortable" border="1">
          <thead>
            <tr>
              <td>seq #</td>
              <td>date</td>
              <td>name</td>
              <td>ID</td>
              <td>one</td>
              <td>two</td>
              <td>three</td>
              <td>four</td>
              <td>five</td>
              <td>six</td>
              <td>prose</td>
              <td>notes</td>
            </tr>
          </thead>
          <tbody>
            <xsl:for-each select="collection( $collected )">
              <tr>
                <td><xsl:value-of select="position()"/></td>
                <xsl:apply-templates select="./TEI"/>
              </tr>
            </xsl:for-each>
          </tbody>
        </table>
        <p>Generated <xsl:value-of
          select="substring( xs:string(current-date()), 1, 10 )"/> at 
          <xsl:value-of
            select="substring( current-time() cast as xs:string, 1, 5)"/></p>
      </body>
    </html>
  </xsl:template>
  
  <xsl:template match="TEI">
    <xsl:variable name="title" select="teiHeader/fileDesc/titleStmt/title"/>
    <td class="date"><xsl:value-of select="format-date( xs:date( substring($title, 1, 10) ),'[D01] [MNn,3-3] [Y0001]')"/></td>
    <td class="titl"><xsl:value-of select="substring($title,11)"/></td>
    <td class="iden"><xsl:value-of select="translate( $title,' ','_')"/></td>
    <xsl:apply-templates select="text/body/p[2]" mode="parse"/>
    <td class="pros"><xsl:apply-templates select="text/body/p[1]"/></td>
    <td class="note"><xsl:apply-templates select="text/body/p[ position() gt 2]"/></td>
  </xsl:template>
  
  <xsl:template match="p">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="p" mode="parse">
    <xsl:variable name="stuff" select="tokenize( normalize-space(.), '/')"/>
    <xsl:variable name="stuff" select="( $stuff, '','','','','' )"/>
    <xsl:for-each select="$stuff">
      <xsl:if test="position() lt 7">
        <td class="pars"><xsl:value-of select="normalize-space(.)"/></td>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>

<!--               <tr style="background-color: {if (position() mod 3 eq 0) then '#EDC' else '#EEE'};">
 -->