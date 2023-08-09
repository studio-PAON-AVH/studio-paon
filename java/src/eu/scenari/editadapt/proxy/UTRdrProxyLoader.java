package eu.scenari.editadapt.proxy;

import eu.scenari.editadapt.electre.UTRElectre;
import eu.scenari.urltree.renderer.IUrlTreeRenderer;
import eu.scenari.urltree.renderer.UTRdrLoaderBase;
import org.xml.sax.Attributes;

/**
 * Chargeur du service de proxy
 */
public class UTRdrProxyLoader   extends UTRdrLoaderBase {

    protected UTRProxy fRenderer;

    @Override
    public IUrlTreeRenderer getLoadedObject() {
        return fRenderer;
    }

    @Override
    protected boolean xStartElement(String pUri, String pLocalName, String pQName, Attributes pAttributes) throws Exception {
        if (isRootElt()) {
            fRenderer = xDeclareUrlTreeRenderer(new UTRProxy(), pAttributes);
        } else return false;
        return true;
    }
}
