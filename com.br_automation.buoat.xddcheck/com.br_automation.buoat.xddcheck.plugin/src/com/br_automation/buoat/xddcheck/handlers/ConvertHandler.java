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

import java.io.File;
import java.io.IOException;
import java.net.URL;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.HashMap;
import java.util.Map;

import org.eclipse.core.commands.AbstractHandler;
import org.eclipse.core.commands.ExecutionEvent;
import org.eclipse.core.commands.ExecutionException;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.runtime.FileLocator;
import org.eclipse.core.runtime.Path;
import org.eclipse.core.runtime.Platform;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.ui.handlers.HandlerUtil;
import org.osgi.framework.Bundle;

public class ConvertHandler extends AbstractHandler {

	public ConvertHandler() {
	}

	public Object execute(final ExecutionEvent event) throws ExecutionException {
		try {
			String timeStamp = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss").format(Calendar.getInstance().getTime());
			
			final Bundle bundle = Platform.getBundle("com.br_automation.buoat.xddcheck.plugin");
			final Map<String, String> parameterMap = new HashMap<String, String>();

			URL odUrl = FileLocator.find(bundle, new Path("/schema/template_completeOD.xml"), null);
			URL cssUrl = FileLocator.find(bundle, new Path("/schema/styles.css"), null);
			URL dicUrl = FileLocator.find(bundle, new Path("/schema/dictionary_en.xml"), null);

			odUrl = FileLocator.resolve(odUrl);
			cssUrl = FileLocator.resolve(cssUrl);
			dicUrl = FileLocator.resolve(dicUrl);

			parameterMap.put("prmPathToXddTemplate", odUrl.getPath());
			parameterMap.put("prmCssFile", cssUrl.getPath());
			parameterMap.put("prmDictionaryFile", dicUrl.getPath());
			parameterMap.put("prmCreatedBy", System.getProperty("user.name"));
			parameterMap.put("prmCreatedOn", timeStamp);
			parameterMap.put("prmCheckerVersion", "1.0.0");
			parameterMap.put("prmXddSchemaVersion", "0.16");
			

			ISelection selection = HandlerUtil.getCurrentSelectionChecked(event);
			if (selection instanceof IStructuredSelection) {
				IStructuredSelection structuredSelection = (IStructuredSelection) selection;
				Object element = structuredSelection.iterator().next();
				if (element instanceof IFile) {
					IFile resource = (IFile) element;
					File file = resource.getRawLocation().makeAbsolute().toFile();

					CheckerJob job = new CheckerJob(file, element, parameterMap, "Running POWERLINK XDD checker");
					job.setUser(true);
					job.schedule();
				}
			}
		} catch (IOException e) {
			e.printStackTrace();
		}
		return null;
	}
}
