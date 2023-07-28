package eu.scenari.editadapt.electre;

import com.scenari.src.ISrcNode;
import com.scenari.src.feature.paths.ISrcNodeResolver;
import com.scenari.src.feature.paths.SrcFeaturePaths;
import com.scenari.src.fs.mini.FsMiniFactory;
import eu.scenari.commons.log.LogMgr;
import eu.scenari.commons.util.lang.Options;
import eu.scenari.urltree.renderer.IUrlTreeRenderer;
import eu.scenari.urltree.renderer.UTRdrLoaderBase;
import eu.scenari.urltree.renderer.lib.UTRdrListChildren;
import eu.scenari.xml.parser.PoolXmlReader;
import eu.scenari.xml.xalan.processor.TransformerFactoryImpl;
import org.xml.sax.Attributes;
import org.xml.sax.InputSource;
import org.xml.sax.XMLReader;

import javax.xml.transform.TransformerFactory;
import javax.xml.transform.sax.SAXSource;
import java.io.InputStream;

public class UTRdrElectreLoader  extends UTRdrLoaderBase {

    protected UTRElectre fRenderer;

    @Override
    public IUrlTreeRenderer getLoadedObject() {
        return fRenderer;
    }

    @Override
    protected boolean xStartElement(String pUri, String pLocalName, String pQName, Attributes pAttributes) throws Exception {
        if (isRootElt()) {
            fRenderer = xDeclareUrlTreeRenderer(new UTRElectre(), pAttributes);
        } else return false;
        return true;
    }
}
