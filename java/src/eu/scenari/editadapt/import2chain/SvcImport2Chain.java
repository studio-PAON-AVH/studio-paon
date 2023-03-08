package eu.scenari.editadapt.import2chain;

import java.io.FileInputStream;
import java.nio.file.Path;
import java.util.HashMap;
import java.util.Map;

import com.scenari.m.bdp.item.IHWorkspace;
import com.scenari.src.ISrcNode;
import com.scenari.src.ISrcServer;
import com.scenari.src.feature.ids.SrcFeatureIds;
import com.scenari.src.feature.streams.SrcFeatureStreams;

import eu.scenari.commons.util.lang.ScException;
import eu.scenari.core.service.ISvcDialog;
import eu.scenari.core.service.SvcBase;
import eu.scenari.core.universe.IUniverse;
import eu.scenari.store.cid.ICidTask;
import eu.scenari.store.cid.ICidTaskFactory;
import eu.scenari.store.service.mkviews.InfoViews;
import eu.scenari.store.service.storesquare.SvcStoreSquare;
import eu.scenari.urltree.storesquare.IPersistentMetas;
import eu.scenari.urltree.storesquare.ResId;
import eu.scenari.wsp.repos.wsptype.IWspTypeInst;
import eu.scenari.wsp.service.repos.SvcRepos;

public class SvcImport2Chain extends SvcBase implements ICidTaskFactory {
	protected static String wspCode = "wsp";

	protected static String wspTitle = "Édition";

	protected SvcStoreSquare store = null;

	private IWspTypeInst fWspType;

	@Override
	public void initAndLinkSvcs() {
		store = (SvcStoreSquare) getUniverse().getService("store");
	}

	@Override
	public ISvcDialog newDialog() {
		return null;
	}

	@Override
	public ICidTask createCidTask() {
		return new Import2ChainCidTask(this);
	}

	public void importFromResId(ResId resId, IPersistentMetas metas) throws Exception {
		Path dtmodel = InfoViews.getViewSource("dtmodel", resId, store);
		if (dtmodel == null) throw new ScException("Unable to find dtmodel view. The upload XML does not seem to be a XML LG or XMl DTBook");

		String uid = (String) metas.get("uid");

		IUniverse chain = getUniverse().getSiblingUniverses().get("chain");
		chain.startThreadSession();
		try {
			IHWorkspace workspace = getWorkspace(wspTitle, wspCode);
			ISrcNode vNode = SrcFeatureIds.findNodeByRefUri(workspace.findNodeByUri(ISrcServer.URI_ROOT), "/" + uid + ".book");
			if (vNode.getContentStatus() == -1) {
				SrcFeatureStreams.writeFrom(vNode, new FileInputStream(dtmodel.toFile()));
			}
		} finally {
			chain.endThreadSession();
		}

	}

	protected IHWorkspace getWorkspace(String title, String code) throws Exception {
		IHWorkspace workspace = ((SvcRepos) getUniverse().getSiblingUniverses().get("chain").getService("repos")).getRepository().getWsp(code, true);
		if (workspace == null) {
			createWsp(title, code);
			workspace = ((SvcRepos) getUniverse().getSiblingUniverses().get("chain").getService("repos")).getRepository().getWsp(code, true);
		}
		return workspace;
	}

	protected void createWsp(String title, String code) throws Exception {
		Map<String, Object> vWspParams = new HashMap<>();
		vWspParams.put("code", code);
		vWspParams.put("alias", code);
		vWspParams.put("title", title != null && title.length() > 0 ? title : "Titre inconnu");
		((SvcRepos) getUniverse().getSiblingUniverses().get("chain").getService("repos")).getRepository().getWspProvider().createWsp(vWspParams, fWspType);

	}

	public void setDefaultWspType(IWspTypeInst pWspType) {
		fWspType = pWspType;
	}

}
