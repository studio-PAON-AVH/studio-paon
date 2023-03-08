package eu.scenari.editadapt.import2chain;

import org.xml.sax.Attributes;

import eu.scenari.commons.log.LogMgr;
import eu.scenari.core.service.SvcLoaderBase;
import eu.scenari.wsp.repos.wsptype.WspTypeInst.WspTypeInstHandler;

/**
 * <pre>
 * [service code="import2chain" type="eu.scenari.editadapt.import2chain.SvcImport2ChainLoader"]
 * 		[defaultWspType]
 * 			[wspType key="legiMaRef1-0" lang="fr-FR" uri="legiMaRef1-0_fr-FR_000" version="1.0.000"]
 * 				[wspUpdate localAutoUpdate="minor"]
 * 					[res key="legiMaRef1-0.wsp"/]
 * 				[/wspUpdate]
 * 			[/wspType]
 * 		[/defaultWspType]
 * [/service]
 * </pre>
 */
public class SvcImport2ChainLoader extends SvcLoaderBase {

	protected WspTypeInstHandler wspTypeLoader;

	/**
	 *
	 */
	public SvcImport2ChainLoader() {
		super();
	}

	@Override
	protected boolean xStartElement(String pUri, String pLocalName, String pQName, Attributes pAttributes) throws Exception {
		boolean vResult = true;
		if (isRootElt()) {
			String vCode = pAttributes.getValue(TAG_xxx_ATT_code);
			if (vCode != null) {
				try {
					fCurrentService = new SvcImport2Chain().declareInUniverse(fUniverse, vCode);
				} catch (Exception e) {
					LogMgr.publishException(e, "Le chargement du service '" + vCode + "' a échoué lors de la lecture de la source '" + getCurrentSrcNode() + "'.");
				}

			} else {
				LogMgr.publishException("Le tag '" + pLocalName + "' du document source [" + getCurrentSrcNode() + "] n'a pas pas d'attribut '" + TAG_xxx_ATT_code + "'.");
			}
		} else if (pLocalName == "defaultWspType") {
			wspTypeLoader = new WspTypeInstHandler();
			wspTypeLoader.setContext(fContext);
			wspTypeLoader.initSaxHandlerForChildren(fXMLReader);
		} else {
			vResult = super.xStartElement(pUri, pLocalName, pQName, pAttributes);
		}
		return vResult;
	}

	@Override
	protected void xEndElement(String pNamespaceURI, String pLocalName, String pQName) throws Exception {
		if (pLocalName == "defaultWspType") {
			getService().setDefaultWspType(wspTypeLoader.getLoadedObject());
		} else {
			super.xEndElement(pNamespaceURI, pLocalName, pQName);
		}
	}

	public SvcImport2Chain getService() {
		return (SvcImport2Chain) fCurrentService;
	}
}
