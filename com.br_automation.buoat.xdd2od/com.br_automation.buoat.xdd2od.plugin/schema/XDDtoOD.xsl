<?xml version="1.0" encoding="UTF-8"?>
<!-- 
/*******************************************************************************
 * @author rueckerc, Bernecker + Rainer Industrie Elektronik Ges.m.b.H.
 *
 * @copyright (c) 2017, Bernecker + Rainer Industrie Elektronik Ges.m.b.H.
 *                    All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *   * Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *   * Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *   * Neither the name of the copyright holders nor the
 *     names of its contributors may be used to endorse or promote products
 *     derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL COPYRIGHT HOLDERS BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *******************************************************************************/
  -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xdd="http://www.ethernet-powerlink.org" xmlns:broat="http://www.br-automation.com/oat/xslfunction">
	<xsl:output method="text" encoding="UTF-8"/>
	<xsl:output omit-xml-declaration="yes" indent="yes"/>
	<xsl:strip-space elements="*"/>

	<xsl:variable name="version" select="'1.0.1'"/>
	<xsl:variable name="header" select="concat('//Created by openPOWERLINK object dictionary creator V',$version,' on ', current-dateTime())"/>

	<xsl:variable name="newline">
		<xsl:text>&#xA;</xsl:text>
	</xsl:variable>
	<xsl:variable name="tab">
		<xsl:text>&#x9;</xsl:text>
	</xsl:variable>

	<!-- Main Template -->
	<xsl:template match="/">
		<xsl:apply-templates select="//xdd:DeviceIdentity"/>
		<xsl:apply-templates select="//xdd:ObjectList"/>
	</xsl:template>

	<!-- Template for the XDD object list -->
	<xsl:template match="xdd:ObjectList">
		<!-- Define obd macro -->
		<xsl:value-of select="concat($newline,'#define OBD_DEFINE_MACRO')"/>
		<xsl:value-of select="concat($newline,$tab,'#include &lt;obdcreate/obdmacro.h&gt;')"/>
		<xsl:value-of select="concat($newline,'#undef OBD_DEFINE_MACRO', $newline)"/>

		<!-- Begin obd -->
		<xsl:value-of select="concat($newline,'OBD_BEGIN()',$newline)"/>

		<!-- Begin obd generic part -->
		<xsl:value-of select="concat($newline,$tab,'OBD_BEGIN_PART_GENERIC ()',$newline)"/>
		<xsl:apply-templates select="//xdd:Object[broat:hex2dec(concat('0x',string(@index))) &lt; 8192]"/>
		<xsl:value-of select="concat($newline,$tab,'OBD_END_PART()',$newline)"/>

		<!-- Begin obd manufacturer part -->
		<xsl:value-of select="concat($newline,$tab,'OBD_BEGIN_PART_MANUFACTURER ()',$newline)"/>
		<xsl:apply-templates select="//xdd:Object[broat:hex2dec(concat('0x',string(@index))) &gt;= 8192 and broat:hex2dec(concat('0x',string(@index))) &lt; 24576]"/>
		<xsl:value-of select="concat($newline,$tab,'OBD_END_PART()',$newline)"/>

		<!-- Begin obd device part -->
		<xsl:value-of select="concat($newline,$tab,'OBD_BEGIN_PART_DEVICE ()',$newline)"/>
		<xsl:apply-templates select="//xdd:Object[broat:hex2dec(concat('0x',string(@index))) &gt;= 24576]"/>
		<xsl:apply-templates select="//xdd:dynamicChannel"/>
		<xsl:value-of select="concat($newline,$tab,'OBD_END_PART()',$newline)"/>

		<!-- End obd -->
		<xsl:value-of select="concat($newline,'OBD_END()',$newline)"/>

		<!-- Undefine obd macro -->
		<xsl:value-of select="concat($newline,'#define OBD_UNDEFINE_MACRO')"/>
		<xsl:value-of select="concat($newline,$tab,'#include &lt;obdcreate/obdmacro.h&gt;')"/>
		<xsl:value-of select="concat($newline,'#undef OBD_UNDEFINE_MACRO', $newline)"/>
	</xsl:template>

	<!-- Template for XDD Device Identity representation -->
	<xsl:template match="xdd:DeviceIdentity">
		<xsl:value-of select="concat($header,$newline,'/*',$newline)"/>
		<xsl:for-each select="node()">
			<xsl:value-of select="concat($tab,local-name(.),': ')" />
			<xsl:if test="@versionType">
				<xsl:value-of select="concat(@versionType,' ')" />
			</xsl:if>
			<xsl:for-each select="child::node()[@lang='en']">
				<xsl:value-of select="concat(text(),' ')" />
			</xsl:for-each>
			<xsl:value-of select="concat(text(),$newline)" />
		</xsl:for-each>
		<xsl:value-of select="concat('*/',$newline)"/>
	</xsl:template>

	<!-- Template for Object representation -->
	<xsl:template match="xdd:Object">
		<xsl:call-template name="objectTypeTemplate"/>
	</xsl:template>

	<!-- Template for dynamicChannel representation -->
	<xsl:template match="xdd:dynamicChannel">
		<xsl:call-template name="dynamicChannelTemplate"/>
	</xsl:template>

	<xsl:template name="dynamicChannelTemplate">
		<xsl:variable name="startIndex" select="number(broat:hex2dec(concat('0x',string(@startIndex))))"/>
		<xsl:variable name="endIndex" select="number(broat:hex2dec(concat('0x',string(@endIndex))))"/>
		<xsl:variable name="maxNumber" select="number(@maxNumber)"/>

		<xsl:variable name="kEplObdTyp">
			<xsl:call-template name="BuildkEplObdTyp">
				<xsl:with-param name="kEplObdTyp" select="string(@dataType)"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="kEplObdAcc">
			<xsl:call-template name="BuildkEplObdDynamicChannelAcc">
				<xsl:with-param name="accessType" select="@accessType"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="tEplObd">
			<xsl:call-template name="BuildtEplObd">
				<xsl:with-param name="tEplObd" select="string(@dataType)"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="tEplName">
			<xsl:call-template name="BuildDynamicChannelObjectName">
				<xsl:with-param name="accessType" select="@accessType"/>
				<xsl:with-param name="tEplObd" select="string(@dataType)"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="tDynDefaultValue">
			<xsl:call-template name="BuildDynamicChannelDefValue">
				<xsl:with-param name="tEplObd" select="string(@dataType)"/>
			</xsl:call-template>
		</xsl:variable>

		<!-- Template for dynamicChannel creation -->
		<xsl:call-template name="BuildDynamicChannel">
			<xsl:with-param name="start" select="xs:integer($startIndex)"/>
			<xsl:with-param name="end" select="xs:integer($endIndex)"/>
			<xsl:with-param name="kEplObdTyp" select="$kEplObdTyp"/>
			<xsl:with-param name="kEplObdAcc" select="$kEplObdAcc"/>
			<xsl:with-param name="tEplObd" select="$tEplObd"/>
			<xsl:with-param name="tEplName" select="$tEplName"/>
			<xsl:with-param name="tDynDefaultValue" select="$tDynDefaultValue"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="BuildDynamicChannel">
		<xsl:param name="start"/>
		<xsl:param name="end"/>
		<xsl:param name="kEplObdTyp"/>
		<xsl:param name="kEplObdAcc"/>
		<xsl:param name="tEplObd"/>
		<xsl:param name="tEplName"/>
		<xsl:param name="tDynDefaultValue"/>
		<xsl:if test="$start &lt;= $end">
			<xsl:value-of select="concat($newline, $tab, $tab, 'OBD_RAM_INDEX_RAM_VARARRAY(0x',broat:decimalToHex($start),', (252), FALSE, ', $kEplObdTyp, ', ', $kEplObdAcc, ', ', $tEplObd, ', ', $tEplName, ', ', $tDynDefaultValue ,')', $newline)" />
			<xsl:call-template name="BuildDynamicChannel">
				<xsl:with-param name="start" select="number($start) + 1"/>
				<xsl:with-param name="end" select="$end"/>
				<xsl:with-param name="kEplObdTyp" select="$kEplObdTyp"/>
				<xsl:with-param name="kEplObdAcc" select="$kEplObdAcc"/>
				<xsl:with-param name="tEplObd" select="$tEplObd"/>
				<xsl:with-param name="tEplName" select="$tEplName"/>
				<xsl:with-param name="tDynDefaultValue" select="$tDynDefaultValue"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template name="BuildkEplObdDynamicChannelAcc">
		<xsl:param name="accessType"/>
		<xsl:text>kObdAccVP</xsl:text>
		<xsl:choose>
			<xsl:when test="$accessType='readOnly'">R</xsl:when>
			<xsl:when test="$accessType='writeOnly'">W</xsl:when>
			<xsl:when test="$accessType='readWriteOutput'">RW</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$accessType" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="BuildDynamicChannelObjectName">
		<xsl:param name="tEplObd"/>
		<xsl:param name="accessType"/>
		<xsl:text>PI_</xsl:text>
		<xsl:choose>
			<xsl:when test="$accessType='readOnly'">INPUT</xsl:when>
			<xsl:when test="$accessType='writeOnly'">OUTPUT</xsl:when>
			<xsl:when test="$accessType='readWriteOutput'">OUTPUT</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$accessType" />
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>_</xsl:text>
		<xsl:choose>
			<xsl:when test="$tEplObd='0001'">Boolean</xsl:when>
			<xsl:when test="$tEplObd='0002'">I8</xsl:when>
			<xsl:when test="$tEplObd='0003'">I16</xsl:when>
			<xsl:when test="$tEplObd='0004'">I32</xsl:when>
			<xsl:when test="$tEplObd='0005'">U8</xsl:when>
			<xsl:when test="$tEplObd='0006'">U16</xsl:when>
			<xsl:when test="$tEplObd='0007'">U32</xsl:when>
			<xsl:when test="$tEplObd='0008'">R32</xsl:when>
			<xsl:when test="$tEplObd='000C'">TimeOfDay</xsl:when>
			<xsl:when test="$tEplObd='000D'">TimeDifference</xsl:when>
			<xsl:when test="$tEplObd='000F'">Domain</xsl:when>
			<xsl:when test="$tEplObd='0010'">I24</xsl:when>
			<xsl:when test="$tEplObd='0011'">R64</xsl:when>
			<xsl:when test="$tEplObd='0012'">I40</xsl:when>
			<xsl:when test="$tEplObd='0013'">I48</xsl:when>
			<xsl:when test="$tEplObd='0014'">I56</xsl:when>
			<xsl:when test="$tEplObd='0015'">I64</xsl:when>
			<xsl:when test="$tEplObd='0016'">U24</xsl:when>
			<xsl:when test="$tEplObd='0018'">U40</xsl:when>
			<xsl:when test="$tEplObd='0019'">U48</xsl:when>
			<xsl:when test="$tEplObd='001A'">U56</xsl:when>
			<xsl:when test="$tEplObd='001B'">U64</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$tEplObd" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="BuildDynamicChannelDefValue">
		<xsl:param name="tEplObd"/>
		<xsl:text>0x</xsl:text>
		<xsl:choose>
			<xsl:when test="$tEplObd='0001'">00</xsl:when>
			<xsl:when test="$tEplObd='0002'">00</xsl:when>
			<xsl:when test="$tEplObd='0003'">0000</xsl:when>
			<xsl:when test="$tEplObd='0004'">00000000</xsl:when>
			<xsl:when test="$tEplObd='0005'">00</xsl:when>
			<xsl:when test="$tEplObd='0006'">0000</xsl:when>
			<xsl:when test="$tEplObd='0007'">00000000</xsl:when>
			<xsl:when test="$tEplObd='0008'">00000000</xsl:when>
			<xsl:when test="$tEplObd='000C'">0</xsl:when>
			<xsl:when test="$tEplObd='000D'">0</xsl:when>
			<xsl:when test="$tEplObd='000F'">0</xsl:when>
			<xsl:when test="$tEplObd='0010'">000000</xsl:when>
			<xsl:when test="$tEplObd='0011'">0000000000000000LL</xsl:when>
			<xsl:when test="$tEplObd='0012'">0000000000</xsl:when>
			<xsl:when test="$tEplObd='0013'">000000000000</xsl:when>
			<xsl:when test="$tEplObd='0014'">00000000000000</xsl:when>
			<xsl:when test="$tEplObd='0015'">0000000000000000LL</xsl:when>
			<xsl:when test="$tEplObd='0016'">000000</xsl:when>
			<xsl:when test="$tEplObd='0018'">0000000000</xsl:when>
			<xsl:when test="$tEplObd='0019'">000000000000</xsl:when>
			<xsl:when test="$tEplObd='001A'">00000000000000</xsl:when>
			<xsl:when test="$tEplObd='001B'">0000000000000000LL</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$tEplObd" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Template to distinguish the object types -->
	<xsl:template name="objectTypeTemplate">
		<xsl:choose>
			<!-- Variable -->
			<xsl:when test="@objectType = 7">
				<xsl:call-template name="objectVarTemplate"/>
			</xsl:when>
			<!-- Array -->
			<xsl:when test="@objectType = 8">
				<xsl:call-template name="objectArrayTemplate"/>
			</xsl:when>
			<!-- Record -->
			<xsl:when test="@objectType = 9">
				<xsl:call-template name="objectRecordTemplate"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat('ObjectType not supported: ',string(@objectType),$newline)" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Object Variable Template -->
	<xsl:template name="objectVarTemplate">
		<xsl:call-template name="BuildObjectHead">
			<xsl:with-param name="SubObjectCount" select="'1'"/>
		</xsl:call-template>

		<xsl:call-template name="BuildObjectBody">
			<xsl:with-param name="index" select="@index"/>
			<xsl:with-param name="subIndex" select="00"/>
			<xsl:with-param name="objType" select="'VAR'"/>
		</xsl:call-template>

		<xsl:call-template name="BuildObjectFoot"/>
	</xsl:template>

	<!-- Object Array Template -->
	<xsl:template name="objectArrayTemplate">
		<xsl:variable name="indexDec" select="broat:hex2dec(concat('0x', string(@index)))"/>
		<xsl:variable name="subObjCount" select="string(count(xdd:SubObject)-1)"/>

		<xsl:value-of select="concat($newline,$tab,$tab)"/>

		<xsl:choose>
			<xsl:when test="$indexDec &gt;= 8192 and xdd:SubObject[2]/@defaultValue">
				<xsl:text>OBD_RAM_INDEX_RAM_VARARRAY</xsl:text>
			</xsl:when>
			<xsl:when test="$indexDec &gt;= 8192">
				<xsl:text>OBD_RAM_INDEX_RAM_VARARRAY_NOINIT</xsl:text>
			</xsl:when>
			<xsl:when test="($indexDec &gt;= 5632 and $indexDec &lt;= 5887) or ($indexDec &gt;= 6656 and $indexDec &lt;= 6911)">
				<xsl:text>OBD_RAM_INDEX_RAM_PDO_MAPPING</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>OBD_RAM_INDEX_RAM_ARRAY</xsl:text>
			</xsl:otherwise>
		</xsl:choose>

		<xsl:text>(</xsl:text>
		<xsl:if test="string-length($subObjCount) eq 1">
			<xsl:value-of select="concat('0x',@index,', 0x0',broat:dec2hex($subObjCount), ', FALSE')"/>
		</xsl:if>
		<xsl:if test="string-length($subObjCount) &gt; 1">
			<xsl:value-of select="concat('0x',@index,', 0x',broat:dec2hex($subObjCount), ', FALSE')"/>
		</xsl:if>

		<xsl:variable name="kEplObdTyp">
			<xsl:call-template name="BuildkEplObdTyp">
				<xsl:with-param name="kEplObdTyp" select="xdd:SubObject[2]/string(@dataType)"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="kEplObdAcc">
			<xsl:call-template name="BuildkEplObdAcc">
				<xsl:with-param name="indexDec" select="$indexDec"/>
				<xsl:with-param name="accessType" select="xdd:SubObject[2]/@accessType"/>
				<xsl:with-param name="PDOmapping" select="xdd:SubObject[2]/@PDOmapping"/>
				<xsl:with-param name="lowLimit" select="xdd:SubObject[2]/@lowLimit"/>
				<xsl:with-param name="highLimit" select="xdd:SubObject[2]/@highLimit"/>
			</xsl:call-template>
</xsl:variable>

		<xsl:variable name="tEplObd">
			<xsl:call-template name="BuildtEplObd">
				<xsl:with-param name="tEplObd" select="xdd:SubObject[2]/string(@dataType)"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="($indexDec &gt;= 5632 and $indexDec &lt;= 5887) or ($indexDec &gt;= 6656 and $indexDec &lt;= 6911)">
				<xsl:value-of select="concat(', '
					,$kEplObdAcc,', '
					,translate(normalize-space(@name),'/:,. ','')
					)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat(', '
					,$kEplObdTyp,', '
					,$kEplObdAcc,', '
					,$tEplObd,', '
					,translate(normalize-space(@name),'/:,. ','')
					)"/>
			</xsl:otherwise>
		</xsl:choose>

		<xsl:if test="xdd:SubObject[2]/@defaultValue">
			<xsl:value-of select="concat(', ',xdd:SubObject[2]/@defaultValue)"/>
		</xsl:if>
		<xsl:if test="xdd:SubObject[2]/@defaultValue = '0x0000000000000000'">
			<xsl:text>LL</xsl:text>
		</xsl:if>

		<xsl:value-of select="concat(')',$newline)" />
	</xsl:template>

	<!-- Object Record Template -->
	<xsl:template name="objectRecordTemplate">
		<xsl:call-template name="BuildObjectHead">
			<xsl:with-param name="SubObjectCount" select="count(xdd:SubObject)"/>
		</xsl:call-template>

		<xsl:for-each select="xdd:SubObject">
			<xsl:call-template name="BuildObjectBody">
				<xsl:with-param name="index" select="../@index"/>
				<xsl:with-param name="subIndex" select="@subIndex"/>
				<xsl:with-param name="objType" select="'REC'"/>
			</xsl:call-template>
		</xsl:for-each>

		<xsl:call-template name="BuildObjectFoot"/>
	</xsl:template>

	<!-- Object Head Template -->
	<xsl:template name="BuildObjectHead">
		<xsl:param name="SubObjectCount"/>
		<xsl:variable name="subObjectCountHex" select="broat:dec2hex($SubObjectCount)"/>
		<xsl:value-of select="concat($newline,$tab,$tab,'OBD_BEGIN_INDEX_RAM(0x',@index,', ')" />
		<xsl:if test="string-length($subObjectCountHex) eq 1">
			<xsl:value-of select="concat('0x0', broat:dec2hex($SubObjectCount))"/>
		</xsl:if>
		<xsl:if test="string-length($subObjectCountHex) &gt; 1">
			<xsl:value-of select="concat('0x', broat:dec2hex($SubObjectCount))"/>
		</xsl:if>
		<xsl:value-of select="concat(', FALSE)',$newline)" />
	</xsl:template>

	<!-- Object Foot Template -->
	<xsl:template name="BuildObjectFoot">
		<xsl:value-of select="concat($tab,$tab,'OBD_END_INDEX(0x',@index,')',$newline)" />
	</xsl:template>

	<!-- Object Body Template -->
	<xsl:template name="BuildObjectBody">
		<xsl:param name="index"/>
		<xsl:param name="subIndex"/>
		<xsl:param name="objType"/>

		<xsl:variable name="indexDec" select="broat:hex2dec(concat('0x', string(@index)))"/>

		<xsl:value-of select="concat($tab,$tab,$tab)"/>
		<xsl:choose>
			<xsl:when test="string(@dataType)='0009'">
				<xsl:text>OBD_SUBINDEX_RAM_VSTRING</xsl:text>
			</xsl:when>
			<xsl:when test="string(@dataType)='000A'">
				<xsl:text>OBD_SUBINDEX_RAM_OSTRING</xsl:text>
			</xsl:when>
			<xsl:when test="string(@dataType)='000F'">
				<xsl:text>OBD_SUBINDEX_RAM_DOMAIN</xsl:text>
			</xsl:when>
			<xsl:when test="$indexDec &lt; 8192 and (@lowLimit or @highLimit)">
				<xsl:text>OBD_SUBINDEX_RAM_VAR_RG</xsl:text>
			</xsl:when>
			<xsl:when test="$indexDec &lt; 8192 and @defaultValue">
				<xsl:text>OBD_SUBINDEX_RAM_VAR</xsl:text>
			</xsl:when>
			<xsl:when test="$indexDec &lt; 8192">
				<xsl:text>OBD_SUBINDEX_RAM_VAR_NOINIT</xsl:text>
			</xsl:when>
			<xsl:when test="$objType='REC' and $indexDec &gt;= 8192 and $subIndex=0">
				<xsl:text>OBD_SUBINDEX_RAM_VAR</xsl:text>
			</xsl:when>
			<xsl:when test="$indexDec &gt;= 8192 and (@lowLimit or @highLimit)">
				<xsl:text>OBD_SUBINDEX_RAM_USERDEF_RG</xsl:text>
			</xsl:when>
			<xsl:when test="$indexDec &gt;= 8192 and @defaultValue">
				<xsl:text>OBD_SUBINDEX_RAM_USERDEF</xsl:text>
			</xsl:when>
			<xsl:when test="$indexDec &gt;= 8192">
				<xsl:text>OBD_SUBINDEX_RAM_USERDEF_NOINIT</xsl:text>
			</xsl:when>
		</xsl:choose>

		<xsl:text>(</xsl:text>
		<xsl:if test="string-length(string($subIndex)) eq 1">
			<xsl:value-of select="concat('0x',$index,', 0x0',$subIndex)"/>
		</xsl:if>
		<xsl:if test="string-length(string($subIndex)) &gt; 1">
			<xsl:value-of select="concat('0x',$index,', 0x',$subIndex)"/>
		</xsl:if>

		<xsl:variable name="kEplObdAcc">
			<xsl:call-template name="BuildkEplObdAcc">
				<xsl:with-param name="indexDec" select="$indexDec"/>
				<xsl:with-param name="accessType" select="@accessType"/>
				<xsl:with-param name="PDOmapping" select="@PDOmapping"/>
				<xsl:with-param name="lowLimit" select="@lowLimit"/>
				<xsl:with-param name="highLimit" select="@highLimit"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="string(@dataType)='0009' or string(@dataType)='000A' or string(@dataType)='000F'">
				<xsl:value-of select="concat(', '
				,$kEplObdAcc,', '
				,translate(normalize-space(@name),'/:,. ',''),', '
				,'OBD_MAX_STRING_SIZE'
				)"/>
				<xsl:if test="@defaultValue">
					<xsl:text>, "</xsl:text>
					<xsl:value-of select="@defaultValue" />
					<xsl:text>"</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="kEplObdTyp">
					<xsl:call-template name="BuildkEplObdTyp">
						<xsl:with-param name="kEplObdTyp" select="string(@dataType)"/>
					</xsl:call-template>
				</xsl:variable>

				<xsl:variable name="tEplObd">
					<xsl:call-template name="BuildtEplObd">
						<xsl:with-param name="tEplObd" select="string(@dataType)"/>
					</xsl:call-template>
				</xsl:variable>

				<xsl:value-of select="concat(', '
				,$kEplObdTyp,', '
				,$kEplObdAcc,', '
				,$tEplObd,', '
				,translate(normalize-space(@name),'/:,. ','')
				)"/>
				<xsl:if test="@defaultValue">
					<xsl:choose>
						<xsl:when test="string(@dataType)='0001' and string(@defaultValue)='true'">
							<xsl:text>, 0x01</xsl:text>
						</xsl:when>
						<xsl:when test="string(@dataType)='0001' and string(@defaultValue)='false'">
							<xsl:text>, 0x00</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="concat(', ',@defaultValue)"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:if test="@lowLimit">
			<xsl:value-of select="concat(', ',@lowLimit)"/>
		</xsl:if>
		<xsl:if test="@highLimit">
			<xsl:value-of select="concat(', ',@highLimit)"/>
		</xsl:if>

		<xsl:value-of select="concat(')',$newline)" />
	</xsl:template>

	<xsl:template name="BuildkEplObdTyp">
		<xsl:param name="kEplObdTyp"/>
		<xsl:choose>
			<xsl:when test="$kEplObdTyp='0001'">kObdTypeBool</xsl:when>
			<xsl:when test="$kEplObdTyp='0002'">kObdTypeInt8</xsl:when>
			<xsl:when test="$kEplObdTyp='0003'">kObdTypeInt16</xsl:when>
			<xsl:when test="$kEplObdTyp='0004'">kObdTypeInt32</xsl:when>
			<xsl:when test="$kEplObdTyp='0005'">kObdTypeUInt8</xsl:when>
			<xsl:when test="$kEplObdTyp='0006'">kObdTypeUInt16</xsl:when>
			<xsl:when test="$kEplObdTyp='0007'">kObdTypeUInt32</xsl:when>
			<xsl:when test="$kEplObdTyp='0008'">kObdTypeReal32</xsl:when>
			<xsl:when test="$kEplObdTyp='0009'">kObdTypeVString</xsl:when>
			<xsl:when test="$kEplObdTyp='000A'">kObdTypeOString</xsl:when>
			<xsl:when test="$kEplObdTyp='000B'">kObdTypeUnicodeString</xsl:when>
			<xsl:when test="$kEplObdTyp='000C'">kObdTypeTimeOfDay</xsl:when>
			<xsl:when test="$kEplObdTyp='000D'">kObdTypeTimeDiff</xsl:when>
			<xsl:when test="$kEplObdTyp='000F'">kObdTypeDomain</xsl:when>
			<xsl:when test="$kEplObdTyp='0010'">kObdTypeInt24</xsl:when>
			<xsl:when test="$kEplObdTyp='0011'">kObdTypeReal64</xsl:when>
			<xsl:when test="$kEplObdTyp='0012'">kObdTypeInt40</xsl:when>
			<xsl:when test="$kEplObdTyp='0013'">kObdTypeInt48</xsl:when>
			<xsl:when test="$kEplObdTyp='0014'">kObdTypeInt56</xsl:when>
			<xsl:when test="$kEplObdTyp='0015'">kObdTypeInt64</xsl:when>
			<xsl:when test="$kEplObdTyp='0016'">kObdTypeUInt24</xsl:when>
			<xsl:when test="$kEplObdTyp='0018'">kObdTypeUInt40</xsl:when>
			<xsl:when test="$kEplObdTyp='0019'">kObdTypeUInt48</xsl:when>
			<xsl:when test="$kEplObdTyp='001A'">kObdTypeUInt56</xsl:when>
			<xsl:when test="$kEplObdTyp='001B'">kObdTypeUInt64</xsl:when>
			<xsl:when test="$kEplObdTyp='0401'">kObdTypeMAC_Addr</xsl:when>
			<xsl:when test="$kEplObdTyp='0402'">kObdTypeIP_Addr</xsl:when>
			<xsl:when test="$kEplObdTyp='0403'">kObdTypeNetTime</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$kEplObdTyp" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="BuildkEplObdAcc">
		<xsl:param name="indexDec"/>
		<xsl:param name="accessType"/>
		<xsl:param name="PDOmapping"/>
		<xsl:param name="lowLimit"/>
		<xsl:param name="highLimit"/>
		<xsl:text>kObdAcc</xsl:text>

		<xsl:choose>
			<xsl:when test="$lowLimit and $highLimit">G</xsl:when>
		</xsl:choose>

		<xsl:choose>
			<xsl:when test="$PDOmapping='no'"/>
			<xsl:when test="$PDOmapping='default'"/>
			<xsl:when test="$PDOmapping='optional'"/>
			<xsl:when test="$PDOmapping='TPDO'">V</xsl:when>
			<xsl:when test="$PDOmapping='RPDO'">V</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$PDOmapping" />
			</xsl:otherwise>
		</xsl:choose>

		<xsl:choose>
			<xsl:when test="$accessType='ro'">R</xsl:when>
			<xsl:when test="$accessType='wo'">W</xsl:when>
			<xsl:when test="$accessType='rw'">RW</xsl:when>
			<xsl:when test="$accessType='const'">
				<xsl:choose>
					<xsl:when test="$PDOmapping!='no'">C</xsl:when>
					<xsl:otherwise>Const</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$accessType" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="BuildtEplObd">
		<xsl:param name="tEplObd"/>
		<xsl:text>tObd</xsl:text>
		<xsl:choose>
			<xsl:when test="$tEplObd='0001'">Boolean</xsl:when>
			<xsl:when test="$tEplObd='0002'">Integer8</xsl:when>
			<xsl:when test="$tEplObd='0003'">Integer16</xsl:when>
			<xsl:when test="$tEplObd='0004'">Integer32</xsl:when>
			<xsl:when test="$tEplObd='0005'">Unsigned8</xsl:when>
			<xsl:when test="$tEplObd='0006'">Unsigned16</xsl:when>
			<xsl:when test="$tEplObd='0007'">Unsigned32</xsl:when>
			<xsl:when test="$tEplObd='0008'">Real32</xsl:when>
			<xsl:when test="$tEplObd='000C'">TimeOfDay</xsl:when>
			<xsl:when test="$tEplObd='000D'">TimeDifference</xsl:when>
			<xsl:when test="$tEplObd='000F'">Domain</xsl:when>
			<xsl:when test="$tEplObd='0010'">Integer24</xsl:when>
			<xsl:when test="$tEplObd='0011'">Real64</xsl:when>
			<xsl:when test="$tEplObd='0012'">Integer40</xsl:when>
			<xsl:when test="$tEplObd='0013'">Integer48</xsl:when>
			<xsl:when test="$tEplObd='0014'">Integer56</xsl:when>
			<xsl:when test="$tEplObd='0015'">Integer64</xsl:when>
			<xsl:when test="$tEplObd='0016'">Unsigned24</xsl:when>
			<xsl:when test="$tEplObd='0018'">Unsigned40</xsl:when>
			<xsl:when test="$tEplObd='0019'">Unsigned48</xsl:when>
			<xsl:when test="$tEplObd='001A'">Unsigned56</xsl:when>
			<xsl:when test="$tEplObd='001B'">Unsigned64</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$tEplObd" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Helper functions -->
	<xsl:function name="broat:hex2dec">
		<xsl:param name="hex" />
		<xsl:choose>
			<xsl:when test="string-length(string($hex)) = 0">
				<xsl:value-of select="'NaN'"/>
			</xsl:when>
			<xsl:when test="contains(string($hex), 'NaN')">
				<xsl:value-of select="'NaN'"/>
			</xsl:when>
			<xsl:when test="starts-with($hex, '0x')">
				<xsl:variable name="hexCorrected"
					select="translate($hex, 'abcdef', 'ABCDEF')" />
				<xsl:choose>
					<xsl:when test="string-length($hexCorrected) = 1">
						<xsl:value-of select="broat:hexDigitToInteger($hexCorrected)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of
							select="xs:integer(16 * (broat:hex2dec(substring($hexCorrected, 1, string-length($hexCorrected) - 1))) + broat:hexDigitToInteger(substring($hexCorrected, string-length($hexCorrected), 1)))">
						</xsl:value-of>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="xs:integer($hex)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<xsl:function name="broat:hexDigitToInteger">
		<xsl:param name="char" />
		<xsl:value-of
			select="string-length(substring-before('0123456789ABCDEF', $char))" />
	</xsl:function>

	<xsl:function name="broat:dec2hex">
		<xsl:param name="dec" />
		<xsl:choose>
			<xsl:when test="starts-with(string($dec), '0x')">
				<xsl:value-of select="$dec"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="number($dec) &lt; 16">
						<xsl:value-of select="broat:intToHexChar(number($dec))"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of
							select="concat(broat:dec2hex(floor(number($dec) div 16)), broat:intToHexChar(number($dec) mod 16))">
						</xsl:value-of>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<xsl:function name="broat:intToHexChar">
		<xsl:param name="in" />
		<xsl:variable name="hexDigits" select="'0123456789ABCDEF'" />
		<xsl:value-of select="substring($hexDigits, (number($in) mod 16) + 1, 1)" />
	</xsl:function>

	<xsl:function name="broat:decimalToHex">
		<xsl:param name="dec"/>
		<xsl:if test="$dec > 0">
			<xsl:value-of
            select="broat:decimalToHex(floor($dec div 16)),substring('0123456789ABCDEF', (($dec mod 16) + 1), 1)"
            separator=""/>
		</xsl:if>
	</xsl:function>
</xsl:stylesheet>