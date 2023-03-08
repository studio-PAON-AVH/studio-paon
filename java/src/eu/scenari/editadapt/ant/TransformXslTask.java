package eu.scenari.editadapt.ant;

import java.io.File;
import java.io.OutputStream;

import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.sax.SAXResult;
import javax.xml.transform.stream.StreamResult;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Project;
import org.w3c.dom.Document;

import com.scenari.src.ISrcContent;
import com.scenari.src.ISrcNode;
import com.scenari.src.feature.cachedobjects.SrcFeatureCachedObjects;
import com.scenari.src.feature.paths.ISrcAliasResolver;
import com.scenari.src.feature.paths.SrcFeaturePaths;
import com.scenari.src.fs.mini.FsMiniFactory;

import eu.scenari.commons.log.LogMgr;
import eu.scenari.xml.serializer.IXSerializer;
import eu.scenari.xml.serializer.xerces.OutputFormat;
import eu.scenari.xml.serializer.xerces.SerializerFactory;
import eu.scenari.xml.serializer.xerces.impl.XMLSerializer;
import eu.scenari.xml.xpath.XPath;
import eu.scenari.xml.xpath.XPathContext;
import eu.scenari.xml.xpath.objects.XObject;

/**
 *
 */
public class TransformXslTask extends com.scenari.m.co.ant.TransformXslTask implements ISrcAliasResolver {
	/**
	 * Input XML
	 */
	private File fInFile = null;

	/**
	 * Output XML
	 */
	private File fOutFile = null;

	/**
	 *
	 */
	@Override
	public void execute() throws BuildException {
		try {
			if (this.fInFile != null && this.fOutFile != null) {
				ISrcNode vInFile = FsMiniFactory.newNodeFromCanonicalFile(fInFile, false);
				ISrcNode vOutFile = FsMiniFactory.newNodeFromCanonicalFile(fOutFile, false);
				process(vInFile, vOutFile);
			}
		} catch (Exception e) {
			if (fFailonerror) {
				throw e;
			} else {
				log(LogMgr.getMessage(e).readAsTextFormat(true), org.apache.tools.ant.Project.MSG_ERR);
			}
		} finally {
			fStylesheet = null;
			fXPath = null;
		}
	}

	@Override
	protected boolean process(ISrcNode pSrc, ISrcNode pDst) throws BuildException {
		File outFile = null;
		try {
			int vSt = pSrc.getContentStatus();
			if (vSt == ISrcContent.STATUS_FOLDER) {
				log("Skipping " + pSrc.getSrcUri() + ": it is a directory.", Project.MSG_VERBOSE);
				return false;
			}
			if (pDst.getContentStatus() == ISrcContent.STATUS_FOLDER) {
				log("Skipping " + pDst.getSrcUri() + ": it is a directory.", Project.MSG_VERBOSE);
				return false;
			}

			if (vSt == ISrcContent.STATUS_FILE) {
				Document vDoc;
				try {
					vDoc = SrcFeatureCachedObjects.getDom(pSrc, true);
				} catch (Exception e) {
					if (fSkipOnXmlParsingFailed) {
						log("Skipping " + pSrc.getSrcUri() + ": it is not a well formed xml file.", Project.MSG_VERBOSE);
						return false;
					}
					throw e;
				}

				//Test de la condition
				XPath vXPath = getXPath();
				XPathContext vXpathCtx = new XPathContext();
				if (vXPath != null) {
					XObject vRes = vXPath.execute(vXpathCtx, vDoc);
					if (!vRes.bool()) return false;
				}

				// Execution de la XSL
				try {
					Transformer vTransf = createTransformer(vXpathCtx);
					this.initTransformer(vTransf, pSrc);
					vTransf.setURIResolver(SrcFeaturePaths.newSrcNodeResolver(pSrc, this));
					OutputStream vOut = pDst.newOutputStream(false);
					try {
						String vMethod = vTransf.getOutputProperty("method");
						if (vMethod != null && (vMethod.equals("text"))) {
							vTransf.transform(new DOMSource(vDoc), new StreamResult(vOut));
						} else if (vMethod.equals("json") || vMethod.equals("js")) {
							OutputFormat vFormat = new OutputFormat(IXSerializer.XSLMETHOD_xml, "UTF-8", true);
							vTransf.transform(new DOMSource(vDoc), new SAXResult(SerializerFactory.getSerializerFactory(vMethod).makeSerializer(vOut, vFormat).asContentHandler()));
						} else {
							OutputFormat vFormat = new OutputFormat();
							// Affectation forcée temporaire du preserveSpace, le temps que les tags des zones de texte multiline soient complétées
							// de xml:space="preserve"
							// FIXME 5.1 : supprimer ce "preserveSpace" global, incohérent avec la canoniser faite coté DB
							vFormat.setPreserveSpace(true);
							vTransf.transform(new DOMSource(vDoc), new SAXResult(new XMLSerializer(vOut, vFormat)));
						}
					} finally {
						vOut.close();
					}
				} catch (TransformerException e) {
					throw e;
				}

			} else {
				log("File '" + pSrc.getSrcUri() + " does not exist. Ignored", Project.MSG_INFO);
			}
		} catch (Exception e) {
			if (fFailonerror) {
				throw LogMgr.wrapMessage(e, "Failed to process " + pSrc.getSrcUri());
			} else {
				log("Failed to process " + pSrc.getSrcUri() + " :\n" + LogMgr.getMessage(e).readAsTextFormat(true), org.apache.tools.ant.Project.MSG_ERR);
			}
		} finally {
			if (outFile != null) {
				outFile.delete();
			}
		}
		return true;

	}


	public void setOutFile(File outFile) {
		this.fOutFile = outFile;
	}

	public void setInFile(File inFile) {
		this.fInFile = inFile;
	}

	@Override
	public String resolveAlias(String pPath) {
		if (pPath.startsWith("inDir:")) return pPath.substring(6);
		else return null;
	}
}