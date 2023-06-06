package eu.scenari.editadapt.import2chain;

import java.util.Map;

import eu.scenari.commons.log.LogMgr;
import eu.scenari.store.cid.ICidMetasProvider;
import eu.scenari.store.cid.impl.CidTaskBase;
import eu.scenari.store.service.storesquare.StoreSquareTask;
import eu.scenari.store.service.urltreedriver.UTDriverTask;
import eu.scenari.urltree.storesquare.IPersistentMetas;
import eu.scenari.urltree.storesquare.ResId;

public class Import2ChainCidTask extends CidTaskBase {
	protected SvcImport2Chain service;

	public Import2ChainCidTask(SvcImport2Chain pSvcImportGesFor) {
		service = pSvcImportGesFor;
	}

	@Override
	protected ECidStatus xExecuteStartCidTask(ICidMetasProvider pMetasProvider) {
		return ECidStatus.waitingForCommit;
	}

	@SuppressWarnings("deprecation")
	@Override
	protected boolean xExecuteCommit() throws Exception {
		Map<String, Object> metas = (Map<String, Object>) getSessionDatas().get(StoreSquareTask.KEY_persistentMetas);
		String prc = (String) metas.get(UTDriverTask.META_processing);
		String action = (String) metas.get(UTDriverTask.META_action);
		if (action != null && (action.equals(UTDriverTask.EUrlTreeNodeAction.remove.toString()) || action.equals(UTDriverTask.EUrlTreeNodeAction.removeAll.toString()))) return true;
		if (!("xml".equals(prc)) && !"epub3".equals(prc)) return true;
		ResId resId = (ResId) fSessionDatas.get(StoreSquareTask.KEY_resId);
		if (!resId.getMetasCounter().equals("000")) return true;
		service.importFromResId(resId, (IPersistentMetas) fSessionDatas.get(StoreSquareTask.KEY_persistentMetas));
		return true;
	}

	@Override
	protected boolean xExecuteRollback() {
		throw LogMgr.newException("Unable to roll back");
	}

}
