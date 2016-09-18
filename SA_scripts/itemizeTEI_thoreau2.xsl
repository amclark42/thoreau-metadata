<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="xs xsl tei"
  version="2.0">
  
  <xsl:output indent="yes" exclude-result-prefixes="#all"/>
  
  <xsl:variable name="regex" select="'Title'"/>
  
  <xsl:template match="/">
    <TEI xmlns="http://www.tei-c.org/ns/1.0">
      <teiHeader>
        <xsl:apply-templates select="//teiHeader/*" mode="header"/>
      </teiHeader>
      <text>
        <body>
          <xsl:apply-templates select="//p"/>
        </body>
      </text>
    </TEI>
  </xsl:template>
  
  <xsl:template match="*" mode="header">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="header"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="text()[not(ancestor::p)]"/>
  
  <xsl:template match="p"/>
  <xsl:template match="p//*">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="p[matches(normalize-space(.),$regex)]">
    <!-- This only needs to be changed if there's a need to test for text outside of the 
      entries. If rewriting this template to identify preceding-sibling::p, for 
      example, getting the first entry will require you to provide the starting index (or 
      risk out-of-bounds sequencing errors). -->
    <xsl:variable name="seqStartIndex" select="0"/>
    
    <xsl:variable name="allFollowing" select="following-sibling::p"/>
    
    <!-- The next entry will be the next following <p> matching the same selection 
      criteria that runs this template. -->
    <xsl:variable name="nextEntry" select="$allFollowing[descendant::text()[matches(normalize-space(.),$regex)]][1]"/>
    
    <!-- Get the index of the next entry. If there is no next entry, consider all 
      remaining <p>s to be part of this entry. -->
    <xsl:variable name="entryDelimiter" select="if ( $nextEntry ) then 
                                                  index-of($allFollowing,$nextEntry)
                                                else min($allFollowing/last()) + 1"/>
    
    <!-- Test $entryDelimiter for the presence of multiple index matches. If so, take the 
      minimum index to get the next entry. -->
    <xsl:variable name="endLoc" select="if ( count($entryDelimiter) = 1 ) then 
                                          if ( $nextEntry and $entryDelimiter ne 1 ) then
                                            $entryDelimiter - 1
                                          else $entryDelimiter
                                        else min($entryDelimiter) - 1"/>
    
    <!-- Get all <p>s between this entry heading and the next, to form a complete entry. -->
    <xsl:variable name="content" select="subsequence($allFollowing,1,$endLoc)"/>
    
    <div xmlns="http://www.tei-c.org/ns/1.0" type="entry">
      <!--<xsl:attribute name="n" select="$entryDelimiter"/>-->
      <xsl:copy>
        <xsl:apply-templates/>
      </xsl:copy>
      <xsl:copy-of select="$content"/>
    </div>
    <!-- Add extra spacing to aid proofing. -->
    <xsl:text>&#10;&#10;</xsl:text>
  </xsl:template>
  
</xsl:stylesheet>