<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:exsl="http://exslt.org/common" xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:ng="http://docbook.org/docbook-ng" xmlns:db="http://docbook.org/ns/docbook"
    xmlns:xi="http://www.w3.org/2001/XInclude" xmlns:xml="http://www.w3.org/XML/1998/namespace"
    xmlns:ditaarch="http://dita.oasis-open.org/architecture/2005/"
    exclude-result-prefixes="db ng exsl" version="2.0">


    <!--<xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:call-template name="filtering-attribute-management"></xsl:call-template>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>-->
    
    
    <xsl:template match="processing-instruction('xxe-sn')"/>        
    

    <xsl:template name="filtering-attribute-management">
        <xsl:variable name="attribute-count"
            select="
                count(@*[name(.) =
                ('revision', 'audience', 'product', 'sp-version', 'component', 'media',
                'pmc_phy', 'pmc_switch', 'pmc_package', 'sas-ports',
                'pcie-host-ports', 'pcie-drive-ports', 'ddr-width',
                'raid-support', 'fw_package', 'revision', 'package')])"/>
        <xsl:variable name="attribute-names"
            select="
                @*[name(.) =
                ('revision', 'audience', 'product', 'sp-version', 'component', 'media',
                'pmc_phy', 'pmc_switch', 'pmc_package', 'sas-ports',
                'pcie-host-ports', 'pcie-drive-ports', 'ddr-width',
                'raid-support', 'fw_package', 'revision', 'package')]/name()"/>
        <xsl:if test="($attribute-count > 0)">
            <xsl:attribute name="ishcondition">
                <xsl:variable name="attribute-value">
                    <xsl:call-template name="form-otherprops">
                        <xsl:with-param name="attribute-count" select="$attribute-count"/>
                        <xsl:with-param name="attribute-names" select="$attribute-names"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:value-of select="concat($attribute-value, ' ')"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:for-each
            select="
                @*[not(name(.) = (
                'revision', 'audience', 'product', 'domains', 'class', 'otherprops', 'sp-version', 'component', 'media',
                'pmc_phy', 'pmc_switch', 'pmc_package', 'sas-ports',
                'pcie-host-ports', 'pcie-drive-ports', 'ddr-width',
                'raid-support', 'fw_package', 'revision', 'package', 'bg_color', 'text_color'))]">
            <xsl:copy/>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="form-otherprops">
        <xsl:param name="attribute-count"/>
        <xsl:param name="attribute-names"/>
        <xsl:param name="collected-value"> </xsl:param>
        <xsl:param name="internal-count" select="1"/>
        <xsl:choose>
            <xsl:when test="number($attribute-count) >= number($internal-count)">
                <xsl:variable name="values"
                    select="tokenize(normalize-space(@*[name(.) = $attribute-names[$internal-count]]), ' ')"/>
                <xsl:call-template name="form-value">
                    <xsl:with-param name="collected-value" select="$collected-value"/>
                    <xsl:with-param name="values" select="$values"/>
                    <xsl:with-param name="current-name">
                        <xsl:value-of select="$attribute-names[$internal-count]"/>
                    </xsl:with-param>
                    <xsl:with-param name="attribute-count" select="$attribute-count"/>
                    <xsl:with-param name="attribute-internal-count" select="$internal-count"/>
                    <xsl:with-param name="attribute-names" select="$attribute-names"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$collected-value"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="form-value">
        <xsl:param name="values"/>
        <xsl:param name="current-name"/>
        <xsl:param name="collected-value"> </xsl:param>
        <xsl:param name="count" select="1"/>
        <xsl:param name="attribute-count"/>
        <xsl:param name="attribute-internal-count"/>
        <xsl:param name="attribute-names"/>

        <xsl:variable name="prefix">
            <xsl:choose>
                <xsl:when test="number($attribute-internal-count) = 1 and $count = 1">((</xsl:when>
                <xsl:when test="number($attribute-internal-count) > 1 and $count = 1">and
                    ((</xsl:when>
                <xsl:when test="$count > 1">(</xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="suffix">
            <xsl:choose>
                <xsl:when test="count($values) = 1 and number($attribute-count) = 1">))</xsl:when>
                <xsl:when test="count($values) > $count">) or </xsl:when>
                <xsl:when test="count($values) = $count">))</xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="count($values) >= $count">
                <xsl:variable name="value-swap">
                    <xsl:choose>
                        <xsl:when test="$values[$count] = 'internal'">Internal</xsl:when>
                        <xsl:when test="$values[$count] = 'Internal'">Internal</xsl:when>
                        <xsl:when test="$values[$count] = 'MCSCInternal'">Internal</xsl:when>
                        <xsl:when test="$values[$count] = 'MSCCInternal'">Internal</xsl:when>
                        <xsl:when test="$values[$count] = 'PMCInternal'">Internal</xsl:when>
                        <xsl:when test="$values[$count] = 'PMC_Internal'">Internal</xsl:when>
                        <xsl:when test="$values[$count] = 'standard_customers'">ROW</xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$values[$count]"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:call-template name="form-value">
                    <xsl:with-param name="values" select="$values"/>
                    <xsl:with-param name="current-name" select="$current-name"/>
                    <xsl:with-param name="count" select="$count + 1"/>
                    <xsl:with-param name="collected-value">
                        <xsl:value-of
                            select="concat($collected-value, $prefix, $current-name, '=', $value-swap, $suffix)"
                        />
                    </xsl:with-param>
                    <xsl:with-param name="attribute-count" select="number($attribute-count)"/>
                    <xsl:with-param name="attribute-internal-count"
                        select="number($attribute-internal-count)"/>
                    <xsl:with-param name="attribute-names" select="$attribute-names"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="count($values) &lt; $count">
                <xsl:call-template name="form-otherprops">
                    <xsl:with-param name="collected-value">
                        <xsl:value-of select="concat($collected-value, ' ')"/>
                    </xsl:with-param>
                    <xsl:with-param name="attribute-count" select="number($attribute-count)"/>
                    <xsl:with-param name="internal-count"
                        select="number($attribute-internal-count) + 1"/>
                    <xsl:with-param name="attribute-names" select="$attribute-names"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>Something went wrong.</xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Add default footers -->

</xsl:stylesheet>
