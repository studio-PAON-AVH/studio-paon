package eu.scenari.editadapt.platon;

import eu.scenari.urltree.renderer.IUrlTreeRenderer;
import eu.scenari.urltree.renderer.UTRdrLoaderBase;
import org.xml.sax.Attributes;

public class UTRdrPlatonLoader  extends UTRdrLoaderBase {

    protected UTRPlaton fRenderer;

    @Override
    public IUrlTreeRenderer getLoadedObject() {
        return fRenderer;
    }

    @Override
    protected boolean xStartElement(String pUri, String pLocalName, String pQName, Attributes pAttributes) throws Exception {
        if (isRootElt()) {
            fRenderer = xDeclareUrlTreeRenderer(new UTRPlaton(), pAttributes);
        } else return false;
        return true;
    }
}
