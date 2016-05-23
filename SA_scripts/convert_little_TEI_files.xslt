<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" 
  xmlns="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="#all"
  version="2.0">

  <!-- Copyleft 2016 by Syd Bauman and Northeastern University Digital Scholarship Group -->
  <!-- Note: -->
  <!-- This program will work on either the 1853-12-31_to_1854-09-05_text_MH/ directory -->
  <!-- or the 1854-09_to_1859-03_both_ND/ directory; it could even process them both -->
  <!-- simultaneously if you wanted to (but that's harder to do w/ `saxon` than each -->
  <!-- directory on its own). But note that the code that is different for the two -->
  <!-- dirs depends entirely on the hard-coded name of the "text_MH" dir in the 2nd -->
  <!-- to last template. -->
  <!-- Also note that when it processes a file from the "text_MH" dir it also processes -->
  <!-- corresponding file in the 1853-12-31_to_1854-09-05_citations_MH/ directory -->
  <!-- by reading a hard-coded URL.) -->
  <!-- This does not work for 3 files (1855-01-25_rabbit_tracks_1.xml, -->
  <!-- 1855-02-04_skate_tracks.xml, and 1855-01-25_rabbit_tracks_2.xml) as they do not -->
  <!-- have corresponding citation files. Thus the crazy-looking test to avoid trying -->
  <!-- to suck in those 3 files. -->
  
  <xsl:param name="inPath" select="tokenize( document-uri(/),'/')"/>
  
  <xsl:output method="xml" indent="yes"/>
  
  <xsl:template match="node()">
    <xsl:if test="not(ancestor::*)">
      <xsl:text>&#x0A;</xsl:text>
    </xsl:if>
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="@*">
    <xsl:copy/>
  </xsl:template>
  
  <xsl:template match="revisionDesc"/>
  
  <xsl:template match="titleStmt/author">
    <xsl:copy>
      <xsl:text>Henry David Thoreau</xsl:text>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="titleStmt/title">
    <xsl:copy>
      <xsl:variable name="name" select="translate( $inPath[ last() ],'_','&#x20;')"/>
      <xsl:value-of select="substring( $name, 1, string-length( $name )-4 )"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="appInfo">
    <xsl:copy>
      <application when="{concat( normalize-space( substring-before( adjust-dateTime-to-timezone( current-dateTime(),'PT00H' cast as xs:dayTimeDuration ) cast as xs:string, '.') ),'Z')}" ident="convert_little_TEI_files.xslt" version="0.1.1">
        <desc>
          <label>pass 1:</label>
          <list>
            <item>indent</item>
            <item>insert title</item>
            <item>correct author</item>
            <item>move time of OxGarage conversion</item>
            <item>convert those “,” things to just comma</item>
	    <item>for MH text files, insert corresponding MH citation</item>
          </list>
        </desc>
      </application>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="application[@xml:id eq 'docxtotei']">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:attribute name="when" select="/TEI/teiHeader/revisionDesc/listChange/change/date"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="sourceDesc/p">
    <xsl:copy>
      <xsl:value-of select="."/>
      <xsl:text> written by </xsl:text>
      <xsl:value-of select="/TEI/teiHeader/fileDesc/titleStmt/author"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="p/text()">
    <!-- Yes, doing this here misses the content of MH's citation files; but -->
    <!-- I've checked, there are none there. -->
    <xsl:value-of select="replace( ., ' *“,” *',', ')"/>
  </xsl:template>
  
  <xsl:template match="body[ $inPath = '1853-12-31_to_1854-09-05_text_MH']">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
      <xsl:if test="not( $inPath[ last() ] =
        (
         '1855-01-25_rabbit_tracks_1.xml',
         '1855-02-04_skate_tracks.xml',
         '1855-01-25_rabbit_tracks_2.xml'
        ) )">
        <xsl:call-template name="suck_in_citation"/>
      </xsl:if>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template name="suck_in_citation">
    <xsl:variable name="citation">
      <xsl:text>file:///home/syd/Documents/DSG/Thoreau_drawings_project/1853-12-31_to_1854-09-05_citations_MH/</xsl:text>
      <xsl:value-of select="replace( $inPath[ last() ], '\.xml$','_info.txt')"/>
    </xsl:variable>
    <xsl:message>debug: sucking <xsl:value-of select="$citation"/></xsl:message>
    <p>
      <xsl:value-of select="unparsed-text($citation)"/>
    </p>
  </xsl:template>
  
</xsl:stylesheet>
