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
package com.br_automation.buoat.xddcheck.handlers;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.URISyntaxException;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import javax.xml.XMLConstants;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.parsers.SAXParser;
import javax.xml.parsers.SAXParserFactory;
import javax.xml.transform.TransformerException;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;
import javax.xml.validation.Schema;
import javax.xml.validation.SchemaFactory;

import org.apache.commons.io.FilenameUtils;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.IWorkspace;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.FileLocator;
import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Path;
import org.eclipse.core.runtime.Platform;
import org.eclipse.core.runtime.Status;
import org.eclipse.core.runtime.SubMonitor;
import org.eclipse.core.runtime.jobs.Job;
import org.eclipse.swt.widgets.Display;
import org.eclipse.ui.IWorkbenchPage;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.console.ConsolePlugin;
import org.eclipse.ui.console.IConsole;
import org.eclipse.ui.console.MessageConsole;
import org.eclipse.ui.console.MessageConsoleStream;
import org.eclipse.ui.ide.IDE;
import org.osgi.framework.Bundle;
import org.xml.sax.SAXException;
import org.xml.sax.SAXParseException;
import org.xml.sax.helpers.DefaultHandler;

public class CheckerJob extends Job {

	private static class SaxErrorHandler extends DefaultHandler {

		private MessageConsoleStream logstream;
		private List<String> validationErrors = new ArrayList<String>();

		public SaxErrorHandler(MessageConsoleStream stream) {
			this.logstream = stream;
		}

		@Override
		public void error(SAXParseException e) throws SAXException {
			this.validationErrors.add(String.format("Error at line %d: %s", e.getLineNumber(), e.getMessage()));
			this.logstream.println(String.format("Error at line %d: %s", e.getLineNumber(), e.getMessage()));
		}

		@Override
		public void fatalError(SAXParseException e) throws SAXException {
			this.validationErrors.add(String.format("Fatal error at line %d: %s", e.getLineNumber(), e.getMessage()));
			this.logstream.println(String.format("Fatal error at line %d: %s", e.getLineNumber(), e.getMessage()));
		}

		@Override
		public void warning(SAXParseException e) throws SAXException {
			this.validationErrors.add(String.format("Warning at line %d: %s", e.getLineNumber(), e.getMessage()));
			this.logstream.println(String.format("Warning at line %d: %s", e.getLineNumber(), e.getMessage()));
		}

	}// SaxErrorHandler

	private File fileToCheck;
	private Object element;
	private Map<String, String> parameterMap;
	MessageConsoleStream logstream;

	public CheckerJob(File fileToCheck, Object element, Map<String, String> parameterMap, String name) {
		super(name);
		this.fileToCheck = fileToCheck;
		this.parameterMap = parameterMap;
		this.element = element;

		MessageConsole console = new MessageConsole("POWERLINK XDD checker", null);
		console.activate();
		ConsolePlugin.getDefault().getConsoleManager().addConsoles(new IConsole[] { console });
		this.logstream = console.newMessageStream();
	}

	@Override
	protected IStatus run(IProgressMonitor monitor) {
		try {
			SubMonitor subMonitor = SubMonitor.convert(monitor, 100);
			Bundle bundle = Platform.getBundle("com.br_automation.buoat.xddcheck.plugin");
			ByteArrayOutputStream checkerStream = new ByteArrayOutputStream();
			ByteArrayOutputStream htmlStream = new ByteArrayOutputStream();

			URL xddCheckUrl = FileLocator.find(bundle, new Path("/schema/xdd_check.xsl"), null);
			xddCheckUrl = FileLocator.resolve(xddCheckUrl);

			URL xddUrl = FileLocator.find(bundle, new Path("/schema/xdd/Powerlink_Main.xsd"), null);
			xddUrl = FileLocator.resolve(xddUrl);

			InputStream inputStream = xddCheckUrl.openConnection().getInputStream();
			File schemaFile = new File(xddUrl.toURI());

			SaxErrorHandler errHandler = new SaxErrorHandler(this.logstream);

			InputStream input = new FileInputStream(fileToCheck);

			SchemaFactory schemaFactory = SchemaFactory.newInstance(XMLConstants.W3C_XML_SCHEMA_NS_URI);
			Schema schema = schemaFactory.newSchema(schemaFile);

			SAXParserFactory saxParserFactory = SAXParserFactory.newInstance();
			saxParserFactory.setNamespaceAware(true);
			saxParserFactory.setSchema(schema);

			SAXParser saxParser = saxParserFactory.newSAXParser();
			saxParser.parse(input, errHandler);

			subMonitor.worked(50);

			XslTransformerUtils.xsltTransform(new StreamSource(this.fileToCheck), inputStream,
					new StreamResult(checkerStream), parameterMap);

			URL htmlUrl = FileLocator.find(bundle, new Path("/schema/transform2HTML_full.xsl"), null);
			htmlUrl = FileLocator.resolve(htmlUrl);

			InputStream htmlInputStream = htmlUrl.openConnection().getInputStream();

			ByteArrayInputStream internalInputStreamHTML = new ByteArrayInputStream(checkerStream.toByteArray());

			parameterMap.put("prmReportFilename", FilenameUtils.removeExtension(this.fileToCheck.getName()) + ".html");

			XslTransformerUtils.xsltTransform(new StreamSource(internalInputStreamHTML), htmlInputStream,
					new StreamResult(htmlStream), parameterMap);

			OutputStream outputStream = new FileOutputStream(
					FilenameUtils.removeExtension(this.fileToCheck.getAbsolutePath()) + ".html");
			htmlStream.writeTo(outputStream);

			htmlStream.close();
			checkerStream.close();
			htmlInputStream.close();
			inputStream.close();
			outputStream.close();

			Display.getDefault().asyncExec(new Runnable() {
				public void run() {
					try {
						IProject project = ((IResource) element).getProject();
						project.refreshLocal(IResource.DEPTH_INFINITE, null);
						IWorkspace workspace = ResourcesPlugin.getWorkspace();
						IPath location = Path
								.fromOSString(FilenameUtils.removeExtension(fileToCheck.getAbsolutePath()) + ".html");
						IFile ifile = workspace.getRoot().getFileForLocation(location);

						IWorkbenchPage page = PlatformUI.getWorkbench().getActiveWorkbenchWindow().getActivePage();
						IDE.openEditor(page, ifile);
					} catch (CoreException e) {
						logstream.println(e.getMessage());	
					}
				}
			});
			
			this.logstream.flush();
			this.logstream.close();
		} catch (IOException | TransformerException | SAXException | ParserConfigurationException
				| URISyntaxException e) {
			if(e instanceof SAXException)
			{}
			else
				logstream.println(e.getMessage());
			return Status.CANCEL_STATUS;
		}
		return Status.OK_STATUS;
	}
}
