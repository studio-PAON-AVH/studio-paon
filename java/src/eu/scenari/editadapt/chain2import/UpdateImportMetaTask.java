package eu.scenari.editadapt.chain2import;

import eu.scenari.commons.pools.PoolBuffers;
import eu.scenari.commons.util.xml.FragmentSaxHandlerBase;
import eu.scenari.core.service.batch.IBatchStatus;
import eu.scenari.core.service.batch.SvcBatch;
import eu.scenari.core.service.batch.SvcBatchDialog;
import eu.scenari.core.service.batch.tasks.TaskBase;
import eu.scenari.store.cid.ICidMetasProvider;
import eu.scenari.store.service.cidserver.SvcCidServer;
import eu.scenari.store.service.cidserver.SvcCidServerDialog;
import eu.scenari.store.service.cidserver.SvcCidServerReader;
import org.apache.tools.ant.util.regexp.Regexp;
import org.xml.sax.Attributes;
import org.xml.sax.SAXException;

import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Special task
 */
public class UpdateImportMetaTask extends TaskBase {

    /**
     * uri de la ressource dans la chain (un .book)
     */
    public static final String ATT_URI = "bookUri";

    /**
     * Balise de metas a mettre a jour
     */
    public static final String TAG_META = "meta";


    protected Map<String, String> fMetaMap;

    protected String fCurrentMetaKey;

    protected StringBuilder fCurrentValueSB;

    protected IBatchStatus fDialogBatchResult;

    protected String fBookUri;

    protected Pattern extractPathFromUri = Pattern.compile("(.*)\\.book");

    @Override
    public FragmentSaxHandlerBase initTask(SvcBatch.TaskDef pTaskDef, SvcBatchDialog pDialog, Attributes pAtts) throws Exception {
        fTaskDef = pTaskDef;
        fInitDialog = pDialog;
        fBookUri = pAtts.getValue(ATT_URI);
        System.out.println(fBookUri);
        fMetaMap = new HashMap<>();
        return this;
    }

    @Override
    protected boolean xStartElement(String pUri, String pLocalName, String pQName, Attributes pAttributes) throws Exception {
        if (pLocalName == TAG_META) {
            fCurrentMetaKey = pAttributes.getValue("name");
            String vValue = pAttributes.getValue("value");
            fCurrentValueSB = PoolBuffers.popStringBuilder();
            if (vValue != null) fCurrentValueSB.append(pAttributes.getValue("value"));
        } else return false;
        return true;
    }

    @Override
    public void characters(char[] pCh, int pStart, int pLength) throws SAXException {
        if (fCurrentValueSB != null) fCurrentValueSB.append(pCh, pStart, pLength);
    }

    @Override
    protected void xEndElement(String pNamespaceURI, String pLocalName, String pQName) throws Exception {
        if (pLocalName == TAG_META) fMetaMap.put(fCurrentMetaKey, PoolBuffers.getStringAndFreeStringBuilder(fCurrentValueSB));
        fCurrentValueSB = null;
    }

    public UpdateImportMetaTask() {
        super();
    }

    public class CidMetasProvider implements ICidMetasProvider {

        HashMap<String, ArrayList<String>> metas;

        CidMetasProvider(){
            this.metas = new HashMap<>();
        }

        public void addMeta(String pKey, String value){
            if(!metas.containsKey(pKey)){
                metas.put(pKey, new ArrayList<String>());
            }
            metas.get(pKey).add(value);
        }


        @Override
        public String getFirstMeta(String pKey) {
            if(!this.metas.containsKey(pKey) || this.metas.get(pKey).size() == 0) return null;
            return this.metas.get(pKey).get(0);
        }

        @Override
        public String[] getMeta(String pKey) {
            if(!this.metas.containsKey(pKey)) return null;
            return (String[]) this.metas.get(pKey).toArray();
        }
    }

    @Override
    public void run() {
        xSetStatus(StatusTask.Pending);
        try{
            // update path in import
            Matcher testPath = extractPathFromUri.matcher(
                    fBatchContext != null ? replaceVars(fBookUri, fBatchContext) : fBookUri
            );
            if(testPath.find()){
                String path = testPath.group(1);
                // get the service to update meta
                SvcCidServer importCid = ((SvcCidServer) fInitDialog.getUniverse().getSiblingUniverses().get("import")
                        .getService("cid"));
                SvcCidServerDialog updater = (SvcCidServerDialog) importCid.newDialog(fInitDialog);

                CidMetasProvider metas = new CidMetasProvider();
                metas.addMeta("synch", "false");
                metas.addMeta("scContent", "none");
                metas.addMeta("createMetas", "true");
                metas.addMeta("olderPath", path);
                for(String metaName : fMetaMap.keySet()){
                    metas.addMeta(metaName, fMetaMap.get(metaName));
                }
                updater.setParamMetasProvider(metas);
                updater.executeDialog();
                Object vDialogResult = updater.getDialogResult(fBatchContext, null);
                if (vDialogResult instanceof IBatchStatus) fDialogBatchResult = (IBatchStatus) vDialogResult;
            }
        } catch (Exception e){
            e.printStackTrace();
        }
        xSetStatus(StatusTask.Finished);
    }
}
