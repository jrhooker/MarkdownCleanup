<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:xrf="http://www.oxygenxml.com/ns/xmlRefactoring/functions"
    exclude-result-prefixes="xs math xd xrf xsi xr xra "
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xr="http://www.oxygenxml.com/ns/xmlRefactoring"
    xmlns:xra="http://www.oxygenxml.com/ns/xmlRefactoring/additional_attributes" version="3.0">

    <xsl:import href="MCHP-schema-conversion.xsl"/>
    <xsl:import href="filtering-attribute-resolver.xsl"/>
    <xsl:import href="markdown-conversion.xsl"/>

    <xsl:param name="CHIPLINK">0</xsl:param>

    <xsl:variable name="target-topic" select="name(/*)"/>
    <xsl:variable name="header" as="xs:string" select="xrf:get-content-before-root()"/>

    <xsl:output method="xml"/>

    <xsl:template match="/">
        <xsl:choose>
            <xsl:when test="/*[local-name() = $target-topic]">
                <xsl:call-template name="convert-header"/>
                <xsl:apply-imports/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="xref" mode="#all">
        <xsl:choose>
            <xsl:when test="contains(@href, '#')">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains(@href, 'http')">
                <xsl:element name="xref">
                    <xsl:attribute name="scope">external</xsl:attribute>
                    <xsl:attribute name="href">
                        <xsl:value-of select="@href"/>
                    </xsl:attribute>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains(@href, '.md')">
                <xsl:element name="xref">                 
                    <xsl:attribute name="href"><xsl:value-of select="substring-before(@href, '.md')"
                        />.dita</xsl:attribute>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>                
                    <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="topic[not(ancestor::topic)]/body">
        <xsl:element name="body">
            <xsl:apply-templates/>
            <xsl:for-each select="following-sibling::topic">
                <xsl:element name="section">
                    <xsl:if test="@id">
                        <xsl:attribute name="id" select="@id"/>
                    </xsl:if>
                    <xsl:apply-templates mode="sections"/>
                </xsl:element>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>

    <xsl:template match="topic" mode="sections">        
  <xsl:choose>
         <xsl:when test="ancestor::topic/ancestor::topic">
             <xsl:apply-templates mode="sections"/>            
         </xsl:when>
      <xsl:otherwise>
          <xsl:element name="section">
              <xsl:if test="@id">
                  <xsl:attribute name="id" select="@id"/>
              </xsl:if>
              <xsl:apply-templates mode="sections"/>
          </xsl:element>
      </xsl:otherwise>
     </xsl:choose>
       
    </xsl:template>
    
    <xsl:template match="div" mode="sections">
        <xsl:apply-templates mode="sections"/>
    </xsl:template>

    <xsl:template match="div">
        <xsl:apply-templates />
    </xsl:template>
    
    <xsl:template match="title[parent::topic]" mode="sections">
        <xsl:choose>
            <xsl:when test="ancestor::topic/ancestor::topic/ancestor::topic">
                <xsl:element name="p">
                    <xsl:element name="b"> <xsl:value-of select="."/></xsl:element>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="title">
                    <xsl:value-of select="."/>
                </xsl:element>
            </xsl:otherwise>            
        </xsl:choose>      
    </xsl:template>

    <xsl:template match="body" mode="sections">
        <xsl:apply-templates mode="sections"/>
    </xsl:template>

    <xsl:template match="*" mode="sections">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="sections"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="topic[ancestor::topic]"/>
    
    <xsl:template name="outputclass-conversion">
        <xsl:choose>
            <xsl:when test="@id[not(@outputclass)]">
                <xsl:attribute name="id">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
                <xsl:variable name="current-value" select="@outputclass"/>
                <xsl:attribute name="outputclass">
                    <xsl:choose>
                        <xsl:when test="string-length($current-value) &gt; 0">
                            <xsl:value-of select="concat($current-value, ' CHPLK_', @id)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="concat('CHPLK_', @id)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
            </xsl:when>
            <xsl:when test="@outputclass">
                <xsl:variable name="current-value" select="@outputclass"/>
                <xsl:attribute name="outputclass">
                    <xsl:choose>
                        <xsl:when test="string-length($current-value) &gt; 0">
                            <xsl:value-of select="concat($current-value, ' CHPLK_', @id)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="concat('CHPLK_', @id)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
            </xsl:when>
            <xsl:when test="@id">
                <xsl:attribute name="outputclass">
                    <xsl:value-of select="concat('CHPLK_', @id)"/>
                </xsl:attribute>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
        <xsl:if test="@xsi:noNamespaceSchemaLocation">
            <xsl:call-template name="convert-schema-location"/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="node()">
        <xsl:copy>
            <xsl:call-template name="filtering-attribute-management"/>
            <xsl:if test="$CHIPLINK = 1">
                <xsl:call-template name="outputclass-conversion"/>
            </xsl:if>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="@class"/>


    <xsl:template match="bookmap">
        <map>
            <xsl:call-template name="filtering-attribute-management"/>
            <xsl:if test="$CHIPLINK = 1">
                <xsl:call-template name="outputclass-conversion"/>
            </xsl:if>

            <xsl:apply-templates/>
        </map>
    </xsl:template>

    <xsl:template match="chapter | preface | appendix | frontmatter | notices">
        <xsl:element name="topicref">
            <xsl:call-template name="filtering-attribute-management"/>
            <xsl:if test="$CHIPLINK = 1">
                <xsl:call-template name="outputclass-conversion"/>
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template
        match="pmc-history | reg-references | struct | includeslist | reg-def | address-map | test | pmc-revhistory">
        <xsl:element name="tbody">
            <xsl:call-template name="filtering-attribute-management"/>
            <xsl:if test="$CHIPLINK = 1">
                <xsl:call-template name="outputclass-conversion"/>
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template
        match="pmc-revision | reg-reference | dword | includeslist/include | field | register-reference | test-row">
        <xsl:element name="row">
            <xsl:call-template name="filtering-attribute-management"/>
            <xsl:if test="$CHIPLINK = 1">
                <xsl:call-template name="outputclass-conversion"/>
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template
        match="
            pmc-rev-number | pmc-date | pmc-description | pmc-name | reg-address | reg-size | reg-name | reg-details | value | position | dword/name | dword/description
            | include/name | include/description | field-bits | field-name | field-type | field-default | field-desc | register-reference/address | addr-element | address-details
            | test-row-type | test-owner | test-desc | test-proc | test-exp-rslt">
        <xsl:element name="entry">
            <xsl:call-template name="filtering-attribute-management"/>
            <xsl:if test="$CHIPLINK = 1">
                <xsl:call-template name="outputclass-conversion"/>
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="addr-mnemonic">
        <xsl:element name="p">
            <xsl:call-template name="filtering-attribute-management"/>
            <xsl:if test="$CHIPLINK = 1">
                <xsl:call-template name="outputclass-conversion"/>
            </xsl:if>
            <xsl:element name="ph"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="position/double | field-desc/desc-title | desc-title | double">
        <xsl:element name="p">
            <xsl:call-template name="filtering-attribute-management"/>
            <xsl:if test="$CHIPLINK = 1">
                <xsl:call-template name="outputclass-conversion"/>
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template
        match="double/msb | test-matrix-nm-short | test-matrix-nm-long | test-name-short | test-name-long | reg-name-main | title/reg-desc | msg-name-main | title/msg-desc">
        <xsl:element name="ph">
            <xsl:call-template name="filtering-attribute-management"/>
            <xsl:if test="$CHIPLINK = 1">
                <xsl:call-template name="outputclass-conversion"/>
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="position/single | single">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="double/lsb">
        <xsl:element name="ph">
            <xsl:call-template name="filtering-attribute-management"/>
            <xsl:if test="$CHIPLINK = 1">
                <xsl:call-template name="outputclass-conversion"/>
            </xsl:if>
            <xsl:text>:</xsl:text>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="field-enum-name | field-enum-desc">
        <xsl:element name="ph">
            <xsl:call-template name="filtering-attribute-management"/>
            <xsl:if test="$CHIPLINK = 1">
                <xsl:call-template name="outputclass-conversion"/>
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="field-enum-list">
        <xsl:element name="dl">
            <xsl:call-template name="filtering-attribute-management"/>
            <xsl:if test="$CHIPLINK = 1">
                <xsl:call-template name="outputclass-conversion"/>
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="field-enum">
        <xsl:element name="dlentry">
            <xsl:call-template name="filtering-attribute-management"/>
            <xsl:if test="$CHIPLINK = 1">
                <xsl:call-template name="outputclass-conversion"/>
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="field-enum-value">
        <xsl:element name="dt">
            <xsl:call-template name="filtering-attribute-management"/>
            <xsl:if test="$CHIPLINK = 1">
                <xsl:call-template name="outputclass-conversion"/>
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="field-enum-def">
        <xsl:element name="dd">
            <xsl:call-template name="filtering-attribute-management"/>
            <xsl:if test="$CHIPLINK = 1">
                <xsl:call-template name="outputclass-conversion"/>
            </xsl:if>
            <xsl:element name="p">
                <xsl:apply-templates/>
            </xsl:element>
        </xsl:element>
    </xsl:template>



    <xsl:template match="bookmeta | pmc-requirement"/>

    <xsl:template match="node()" mode="wrap">
        <xsl:copy>
            <xsl:call-template name="filtering-attribute-management"/>
            <xsl:if test="$CHIPLINK = 1">
                <xsl:call-template name="outputclass-conversion"/>
            </xsl:if>
            <xsl:apply-templates select="node()" mode="wrap"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="@xra:*" mode="wrap" priority="100"/>

    <xsl:template match="text() | comment() | processing-instruction()">
        <xsl:copy>
            <xsl:call-template name="filtering-attribute-management"/>
            <xsl:if test="$CHIPLINK = 1">
                <xsl:call-template name="outputclass-conversion"/>
            </xsl:if>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template name="process-filtering-attributes">
        <!-- create an array of all the attributes on a node -->
        <!-- Just copy most of them, but all of the proprietary PMC attributes should be combined under an otherprops value -->
    </xsl:template>


    <xsl:template match="frontmatter">
        <xsl:choose>
            <xsl:when test="@href">
                <xsl:element name="topicref">
                    <xsl:call-template name="filtering-attribute-management"/>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="backmatter">
        <xsl:choose>
            <xsl:when test="@href">
                <xsl:element name="topicref">
                    <xsl:call-template name="filtering-attribute-management"/>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="instances">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="instance">
        <xsl:element name="p">
            <xsl:element name="b">Instance:</xsl:element>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="instance-start">
        <xsl:value-of select="."/>
        <xsl:text>:</xsl:text>
    </xsl:template>

    <xsl:template match="instance-stop">
        <xsl:value-of select="."/>
    </xsl:template>

    <xsl:template match="ul">
        <xsl:choose>
            <xsl:when test="string-length(li[1]) = 0">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="ul">
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>   
    
    <xsl:template match="li">
        <xsl:choose>
            <xsl:when test="string-length(.) = 0"/>
            <xsl:otherwise>
                <xsl:element name="li">
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>    
    
    <xsl:template match="ul" mode="sections">
        <xsl:choose>
            <xsl:when test="string-length(li[1]) = 0">
                <xsl:apply-templates  mode="sections"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="ul">
                    <xsl:apply-templates  mode="sections" />
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="li" mode="sections">
        <xsl:choose>
            <xsl:when test="string-length(.) = 0"/>
            <xsl:otherwise>
                <xsl:element name="li">
                    <xsl:apply-templates  mode="sections" />
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>    

</xsl:stylesheet>
