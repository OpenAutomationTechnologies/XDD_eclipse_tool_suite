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

import java.io.InputStream;
import java.util.Map;

import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

/**
 * @file XslTransformerUtils.java
 * @author Christoph Ruecker, Bernecker + Rainer Industrie-Elektronik Ges.m.b.H
 * @version 1.0
 */
public final class XslTransformerUtils {

	/**
	 * @brief <b>Private constructor to disable the instantiation.</b>
	 */
	private XslTransformerUtils() {
	}

	/**
	 * @brief <b>Creates a TransformerFactory.</b>
	 * @return TransformerFactory
	 */
	private static TransformerFactory getTransformerFactory() {
		final TransformerFactory tFactory = TransformerFactory.newInstance();
		tFactory.setAttribute("http://saxon.sf.net/feature/linenumbering", true);
		tFactory.setAttribute("http://saxon.sf.net/feature/allow-external-functions", true);
		return tFactory;
	}

	/**
	 * @brief <b>XSLT Transformation without extended attributes.</b>
	 * @details The method performs an XSLT transformation with the given input
	 *          stream and an XSLT stylesheet. There are no extended attributes
	 *          defined for the transformation.
	 * @param inputStream
	 *            Input stream for the transformation.
	 * @param xslt
	 *            XSLT stylesheet for the transformation.
	 * @param outputStream
	 *            Output stream for the transformation.
	 * @throws TransformerException
	 *             Thrown when a transformation fails.
	 */
	public static void xsltTransform(final StreamSource inputStream, final InputStream xslt,
			final StreamResult outputStream, Map<String, String> parameterMap) throws TransformerException {
		final TransformerFactory tFactory = XslTransformerUtils.getTransformerFactory();
		final Transformer transformer = tFactory.newTransformer(new StreamSource(xslt));
		for (Map.Entry<String, String> param : parameterMap.entrySet()) {
			transformer.setParameter(param.getKey(), param.getValue());
		}
		transformer.transform(inputStream, outputStream);
	}
}
