<?xml version="1.0" encoding="UTF-8"?>
<!-- Git version: @GIT_VERSION@ -->
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" 	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"  	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 	xmlns:svrl="http://purl.oclc.org/dsdl/svrl" 	xsi:schemaLocation="http://www.w3.org/1999/XSL/Transform http://www.w3.org/2007/schema-for-xslt10.xsd" 	exclude-result-prefixes="xsi svrl">
	<!-- 	Report-language, valid values: 'en', 'de'.	Supply additional languages by creating another diagnostics_<prmLang>.sch file (and including it in the main Schematron-Schema)	and a dicitionary_<prmLang>.xml file. 	-->
	<xsl:param name="prmLang" select="'en'" />
	<xsl:param name="prmCreatedBy" select="'-'" />
	<!-- Datetime string following the pattern: yyyy-MM-dd'T'HH:mm:ss'Z' -->
	<xsl:param name="prmCreatedOn" select="'-'" />
	<!-- A string specifying the name of the source of the transformation -->
	<xsl:param name="prmReportFilename" select="'-'" />
	<!-- A string specifying the version of the XDD XML-Schema used for validation -->
	<xsl:param name="prmXddSchemaVersion" select="'-'" />
	<!-- 	Whether this stylesheet should insert references to external resources (i.e. pics) into the output-document or not,	supply true if those external resources will be available, false otherwise. -->
	<xsl:param name="prmIncludeExternalRefs" select="false()" />
	<!-- Dictionary support for i18n -->
	<xsl:param name="prmCssFile" select="''" />
	<xsl:param name="prmDictionaryFile" select="''" />
	<xsl:param name="prmCheckerVersion" select="''" />
	<xsl:variable name="dictionaryName">dictionary_<xsl:value-of select="$prmLang" />.xml</xsl:variable>
	<xsl:variable name="dictionary" select="document($prmDictionaryFile)" />
	<!-- Dictionary support for i18n -->
	<xsl:output method="xml"	doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"	doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" indent="yes" />
	<xsl:template match="/">
		<html>
			<head>
				<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
				<title>
					<xsl:value-of select="$dictionary//Label[@id='DOC_TITLE']/LabelText" />
				</title>
				<style type="text/css">
					<xsl:value-of select="document($prmCssFile)" disable-output-escaping="yes" />
				</style>
			</head>
			<body>
				<h2 style="text-align:center; margin-bottom:50px;">
					<xsl:value-of select="$dictionary//Label[@id='DOC_TITLE']/LabelText"/>
				</h2>
				<!-- Test-Execution Info -->
				<h3>
					<xsl:value-of select="$dictionary//Label[@id='HEADING_TESTEXECUTION']/LabelText"/>
				</h3>
				<table class="indented">
					<tr>
						<td>
							<xsl:value-of select="$dictionary//Label[@id='TEXT_CREATED_BY']/LabelText"/>
						</td>
						<td>
							<xsl:value-of select="$prmCreatedBy"/>
						</td>
					</tr>
					<tr>
						<td>
							<xsl:value-of select="$dictionary//Label[@id='TEXT_CREATED_ON']/LabelText"/>
						</td>
						<td>
							<xsl:choose>
								<xsl:when test="$prmCreatedOn != '-'">
									<xsl:value-of select="$prmCreatedOn" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$prmCreatedOn" />
								</xsl:otherwise>
							</xsl:choose>
						</td>
					</tr>
					<tr>
						<td>
							<xsl:value-of select="$dictionary//Label[@id='TEXT_FILENAME']/LabelText"/>
						</td>
						<td>
							<xsl:value-of select="$prmReportFilename" />
						</td>
					</tr>
				</table>
				<!-- XDD-Info -->
				<h3>
					<xsl:value-of select="$dictionary//Label[@id='HEADING_XDD']/LabelText"/>
				</h3>
				<table class="indented">
					<xsl:for-each select="//svrl:diagnostic-reference[@xml:lang=$prmLang and ../@role='info' and not(starts-with(@diagnostic, 'info.schematronSchemaVersion'))]">
						<tr>
							<td>
								<xsl:value-of select="concat(substring-before(., ':'), ':')" />
							</td>
							<td>
								<xsl:value-of select="substring-after(., ':')" />
							</td>
						</tr>
					</xsl:for-each>
				</table>
				<!-- Test-Environment -->
				<h3>
					<xsl:value-of select="$dictionary//Label[@id='HEADING_TESTENVIRONMENT']/LabelText"/>
				</h3>
				<table class="indented">
					<tr>
						<td>
							<xsl:value-of select="concat(substring-before(//svrl:diagnostic-reference[@xml:lang=$prmLang and ../@role='info' and starts-with(@diagnostic, 'info.schematronSchemaVersion')], ':'), ':')" />
						</td>
						<td>
							<xsl:value-of select="$prmCheckerVersion"/>
						</td>
					</tr>
					<tr>
						<td>
							POWERLINK Spec version:
						</td>
						<td>
							1.3.0
						</td>
					</tr>
					<tr>
						<td>
							XDD Spec version:
						</td>
						<td>
							1.2.0
						</td>
					</tr>
					<tr>
						<td>
							<xsl:value-of select="$dictionary//Label[@id='TEXT_XDD_SCHEMA_VERSION']/LabelText"/>
						</td>
						<td>
							<xsl:value-of select="$prmXddSchemaVersion"/>
						</td>
					</tr>
				</table>
				<!-- Test-Results -->
				<h3>
					<xsl:value-of select="$dictionary//Label[@id='HEADING_TESTRESULTS']/LabelText"/>
				</h3>
				<xsl:variable name="isModularChild"	select="boolean(//svrl:diagnostic-reference[@xml:lang=$prmLang and ../@role='warning' and starts-with(@diagnostic, 'warning.cnType')])" />
				<xsl:choose>
					<xsl:when test="$isModularChild" >
						<h4>
							<xsl:value-of select="//svrl:diagnostic-reference[@xml:lang=$prmLang and ../@role='warning' and starts-with(@diagnostic, 'warning.cnType')]" />
						</h4>
					</xsl:when>
					<xsl:otherwise>
						<xsl:variable name="nrOfErrors"	select="count(//svrl:diagnostic-reference[@xml:lang=$prmLang and ../@role='error'])" />
						<xsl:variable name="nrOfWarnings"	select="count(//svrl:diagnostic-reference[@xml:lang=$prmLang and ../@role='warning'])" />
						<xsl:choose>
							<xsl:when test="$nrOfErrors != 0 or $nrOfWarnings != 0">
								<!-- We have validation-errors/warnings -->
								<xsl:if test="$nrOfErrors != 0">
									<!-- Create a list of errors -->
									<p>
										<xsl:value-of select="$nrOfErrors" />
										<xsl:value-of select="$dictionary//Label[@id='TEXT_ERRORS_FOUND']/LabelText" />
									</p>
									<table class="results">
										<tr>
											<th>
												<xsl:value-of select="$dictionary//Label[@id='TABLE_HEADER_LINE']/LabelText"/>
											</th>
											<th>
												<xsl:value-of select="$dictionary//Label[@id='TABLE_HEADER_COLUMN']/LabelText"/>
											</th>
											<th>
												<xsl:value-of select="$dictionary//Label[@id='TABLE_HEADER_MESSAGE']/LabelText"/>
											</th>
										</tr>
										<xsl:for-each select="//svrl:diagnostic-reference[@xml:lang=$prmLang and ../@role='error']">
											<xsl:sort select="number(../svrl:diagnostic-reference[@diagnostic='diag.lineNumber'])" data-type="number" />
											<xsl:choose>
												<xsl:when test="../svrl:diagnostic-reference[@diagnostic='diag.lineNumber']">
													<tr>
														<td>
															<xsl:value-of select="../svrl:diagnostic-reference[@diagnostic='diag.lineNumber']" />
														</td>
														<td>
															<xsl:value-of select="../svrl:diagnostic-reference[@diagnostic='diag.columnNumber']" />
														</td>
														<td>
															<xsl:value-of select="." />
														</td>
													</tr>
												</xsl:when>
												<xsl:otherwise>
													<tr>
														<td>NA</td>
														<td>NA</td>
														<td>
															<xsl:value-of select="." />
														</td>
													</tr>
												</xsl:otherwise>
											</xsl:choose>
										</xsl:for-each>
									</table>
								</xsl:if>
								<xsl:if test="$nrOfWarnings != 0">
									<!-- Create a list of warnings -->
									<p>
										<xsl:value-of select="$nrOfWarnings" />
										<xsl:value-of select="$dictionary//Label[@id='TEXT_WARNINGS_FOUND']/LabelText" />
									</p>
									<table class="results">
										<tr>
											<th>
												<xsl:value-of select="$dictionary//Label[@id='TABLE_HEADER_LINE']/LabelText"/>
											</th>
											<th>
												<xsl:value-of select="$dictionary//Label[@id='TABLE_HEADER_COLUMN']/LabelText"/>
											</th>
											<th>
												<xsl:value-of select="$dictionary//Label[@id='TABLE_HEADER_MESSAGE']/LabelText"/>
											</th>
										</tr>
										<xsl:for-each select="//svrl:diagnostic-reference[@xml:lang=$prmLang and ../@role='warning']">
											<xsl:sort select="number(../svrl:diagnostic-reference[@diagnostic='diag.lineNumber'])" data-type="number" />
											<xsl:choose>
												<xsl:when test="../svrl:diagnostic-reference[@diagnostic='diag.lineNumber']">
													<tr>
														<td>
															<xsl:value-of select="../svrl:diagnostic-reference[@diagnostic='diag.lineNumber']" />
														</td>
														<td>
															<xsl:value-of select="../svrl:diagnostic-reference[@diagnostic='diag.columnNumber']" />
														</td>
														<td>
															<xsl:value-of select="." />
														</td>
													</tr>
												</xsl:when>
												<xsl:otherwise>
													<tr>
														<td>NA</td>
														<td>NA</td>
														<td>
															<xsl:value-of select="." />
														</td>
													</tr>
												</xsl:otherwise>
											</xsl:choose>
										</xsl:for-each>
									</table>
								</xsl:if>
							</xsl:when>
							<xsl:otherwise>
								<!-- There are no errors/warnings, validation successful -->
								<ul id="inputValid">
									<li>
										<xsl:value-of select="$dictionary//Label[@id='TEXT_SCHEMA_VALIDATION_SUCCESSFUL']/LabelText" />
									</li>
									<li>
										<xsl:value-of select="$dictionary//Label[@id='TEXT_SEMANTIC_VALIDATION_SUCCESSFUL']/LabelText" />
									</li>
								</ul>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</body>
		</html>
	</xsl:template>
</xsl:stylesheet>