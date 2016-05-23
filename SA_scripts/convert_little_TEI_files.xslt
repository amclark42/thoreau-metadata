<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" 
  xmlns="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="#all"
  version="2.0">
  
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
      <application when="{concat( normalize-space( substring-before( adjust-dateTime-to-timezone( current-dateTime(),'PT00H' cast as xs:dayTimeDuration ) cast as xs:string, '.') ),'Z')}" ident="convert_little_TEI_files.xslt" version="0.0.1">
        <desc>
          <label>pass 1:</label>
          <list>
            <item>indent</item>
            <item>insert title</item>
            <item>correct author</item>
            <item>move time of OxGarage conversion</item>
            <item>convert those “,” things to just comma</item>
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
  
  <xsl:template match="body[ $inPath = '1853-12-31_to_1854-09-05_text_MH']">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
      <xsl:call-template name="suck_in_citation"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="p/text()">
    <!-- Yes, doing this here misses the content of MH's citation files; but -->
    <!-- I've checked, there are none there. -->
    <xsl:value-of select="replace( ., ' *“,” *',', ')"/>
  </xsl:template>
  
  <xsl:template name="suck_in_citation">
    <xsl:variable name="cit">
      <xsl:for-each select="$inPath">
        <xsl:value-of select="if ( position() > last()-3 ) then '' else concat(.,'/')"/>
      </xsl:for-each>
      <xsl:text>1853-12-31_to_1854-09-05_citations_MH/</xsl:text>
      <xsl:value-of select="replace( $inPath[ last() ], '\.xml$','_info.txt')"/>
    </xsl:variable>
    <xsl:variable name="citation" select="replace( $cit, '^file:','file://')"/>
    <xsl:variable name="citation">
      <xsl:text>../</xsl:text>
      <xsl:text>1853-12-31_to_1854-09-05_citations_MH/</xsl:text>
      <xsl:value-of select="replace( $inPath[ last() ], '\.xml$','_info.txt')"/>
    </xsl:variable>
    <xsl:message>debug: sucking <xsl:value-of select="$citation"/></xsl:message>
    <p>
      <xsl:value-of select="unparsed-text($cit)"/>
    </p>
  </xsl:template>
  
</xsl:stylesheet>