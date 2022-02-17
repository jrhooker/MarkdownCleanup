<?xml version="1.0" encoding="UTF-8"?>
<!--
  Copyright 2001-2017 Syncro Soft SRL. All rights reserved.
 --> 
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs"
    xmlns:xr="http://www.oxygenxml.com/ns/xmlRefactoring"
    xmlns:xrf="http://www.oxygenxml.com/ns/xmlRefactoring/functions"
    xmlns:r="http://www.oxygenxml.com/ns/xmlRefactoring/functions/regex"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:fn="http://www.w3.org/2005/xpath-functions" version="3.0">
    
    <xsl:import href="oxy-mchp-reg-ex.xsl"/>
    
    <!-- 
        Converts to target-topic the xsd schema locatin.
    -->
    <xsl:template name="convert-schema-location">
        <xsl:attribute name="xsi:noNamespaceSchemaLocation">
            <xsl:variable name="value">
                <xsl:value-of select="."/>
            </xsl:variable>
            
            <xsl:value-of select="replace($value, '[a-zA-Z]+\.xsd', concat($target-topic, '.xsd'))"/>
        </xsl:attribute>
    </xsl:template>
    
    <!--
         Converts to target-topic the DOCTYPE and xml-model declaration.
    -->
    <xsl:template name="convert-header">
        
        <xsl:if test="not(/*/@xsi:noNamespaceSchemaLocation)">
            <xsl:variable name="header" as="xs:string" select="xrf:get-content-before-root()"/>
            
            <xsl:choose>
                <!-- DOCTYPE -->
                <xsl:when test="contains($header, '!DOCTYPE')">                    
                    <xsl:variable name="converted-header">
                        <xsl:choose>
                            <xsl:when test="$target-topic='bookmap'">
                                <xsl:text>&lt;!DOCTYPE map PUBLIC &quot;-//Atmel//DTD DITA Map//EN&quot; &quot;map.dtd&quot;[]&gt;</xsl:text>        
                            </xsl:when>
                            <xsl:when test="$target-topic='map'">
                                <xsl:text>&lt;!DOCTYPE map PUBLIC &quot;-//Atmel//DTD DITA Map//EN&quot; &quot;map.dtd&quot;[]&gt;</xsl:text>        
                            </xsl:when>
                            <xsl:when test="$target-topic='topic'">
                                <xsl:text>&lt;!DOCTYPE topic PUBLIC &quot;-//Atmel//DTD DITA Mathml Topic//EN&quot; &quot;AtmelTopic.dtd&quot;[]&gt;</xsl:text>        
                            </xsl:when>
                            <xsl:when test="$target-topic='reference'">
                                <xsl:text>&lt;!DOCTYPE reference PUBLIC &quot;-//Atmel//DTD DITA Mathml Reference//EN&quot; &quot;AtmelReference.dtd&quot;[]&gt;</xsl:text>        
                            </xsl:when>
                            <xsl:when test="$target-topic='concept'">
                                <xsl:text>&lt;!DOCTYPE concept PUBLIC &quot;-//Atmel//DTD DITA Mathml Concept//EN&quot; &quot;AtmelConcept.dtd&quot;[]&gt;</xsl:text>        
                            </xsl:when>
                            <xsl:when test="$target-topic='task'">
                                <xsl:choose>
                                    <xsl:when test="descendant::steps-informal">
                                        <xsl:text>&lt;!DOCTYPE task PUBLIC &quot;-//Atmel//DTD DITA Mathml General Task//EN&quot; &quot;AtmelGeneralTask.dtd&quot;[]&gt;</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>&lt;!DOCTYPE task PUBLIC &quot;-//Atmel//DTD DITA Mathml Task//EN&quot; &quot;AtmelTask.dtd&quot;[]&gt;</xsl:text>        
                                    </xsl:otherwise>
                                </xsl:choose>
                                
                            </xsl:when>
                        </xsl:choose>                                                
                    </xsl:variable>
                    <xsl:comment>
                    <xsl:value-of
                        select="xrf:set-content-before-root(string-join($converted-header))"/>
                    </xsl:comment>
                </xsl:when>
                
                
                <!-- xml-model -->
                <xsl:otherwise>
                    <xsl:variable name="converted-header">
                        <xsl:analyze-string select="$header" regex="{r:xml-model-pi-regex()}" flags="ims">
                            <xsl:matching-substring>
                                <xsl:variable name="sq">'</xsl:variable>
                                <xsl:variable name="href" select="concat('href\s*=\s*', '(', $sq, '[^', $sq, ']+\.rng', $sq, ') |', '(&quot;[^&quot;]+\.rng&quot;)')"/>
                                
                                <xsl:choose>
                                    <xsl:when test="matches(., $href)">
                                        <xsl:value-of select="replace(., '[a-zA-Z]+\.rng', concat($target-topic, '.rng'))"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <!-- Copy everything else -->
                                        <xsl:value-of select="."/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:matching-substring>
                            
                            <!-- Copy everything else -->
                            <xsl:non-matching-substring>
                                <xsl:value-of select="."/>
                            </xsl:non-matching-substring>
                        </xsl:analyze-string>
                    </xsl:variable>
                    <xsl:comment>
                        <xsl:value-of select="xrf:set-content-before-root(string-join($converted-header))"/>
                    </xsl:comment>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    
    
    <xsl:template match="chapter">
        <topicref>
           <xsl:call-template name="filtering-attribute-management"/>
          <xsl:call-template name="outputclass-conversion"/>     
            <xsl:apply-templates/>
        </topicref>
    </xsl:template>
    
    <xsl:template match="appendix">
        <topicref>
           <xsl:call-template name="filtering-attribute-management"/>
          <xsl:call-template name="outputclass-conversion"/>
            <!--<xsl:attribute name="outputclass" select="'appendix'"/>   -->         
            <xsl:apply-templates/>
        </topicref>
    </xsl:template>
    
   
    
    <xsl:template match="pmc-revhistory">
        <tbody>
           <xsl:call-template name="filtering-attribute-management"/>
          <xsl:call-template name="outputclass-conversion"/>
            <xsl:apply-templates/>
        </tbody>
    </xsl:template>
    
    <xsl:template match="pmc-revision">
        <row>
           <xsl:call-template name="filtering-attribute-management"/>
          <xsl:call-template name="outputclass-conversion"/>
            <xsl:apply-templates/>
        </row>
    </xsl:template>
    
    
    <xsl:template match="pmc-rev-number | pmc-date | pmc-name | pmc-description ">
        <entry>
           <xsl:call-template name="filtering-attribute-management"/>
          <xsl:call-template name="outputclass-conversion"/>         
            <xsl:apply-templates/>
        </entry>
    </xsl:template>
    
</xsl:stylesheet>
