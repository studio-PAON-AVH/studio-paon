package eu.scenari.editadapt.electre;

import java.util.Map;

import eu.scenari.store.cid.ICidMetasProvider;
import eu.scenari.store.cid.impl.CidTaskBase;
import eu.scenari.store.service.storesquare.StoreSquareTask;
import eu.scenari.store.service.urltreedriver.UTDriverTask;

public class FetchResumeCidTask extends CidTaskBase {
	public static String META_ELECTRE_RESUME = "resumeElectre";
	protected SvcElectre service;

	public FetchResumeCidTask(SvcElectre electre) {
		service = electre;
	}


	@SuppressWarnings("deprecation")
	@Override
	protected ECidStatus xExecuteStartCidTask(ICidMetasProvider pMetasProvider) {
		Map<String, Object> metas = (Map<String, Object>) getSessionDatas().get(StoreSquareTask.KEY_persistentMetas);
		String prc = (String) metas.get(UTDriverTask.META_processing);
		String action = (String) metas.get(UTDriverTask.META_action);
		if (action != null && (action.equals(UTDriverTask.EUrlTreeNodeAction.remove.toString()) || action.equals(UTDriverTask.EUrlTreeNodeAction.removeAll.toString()))) return ECidStatus.waitingForCommit;
		if (!"xml".equals(prc) && !"data".equals(prc) && !"epub3".equals(prc)) return ECidStatus.waitingForCommit;
		if (!service.getEnable()) {
			metas.put(META_ELECTRE_RESUME, "");
			return ECidStatus.waitingForCommit;
		}

		String resume = service.fetchResume((String) metas.get("isbn"));
		if (resume != null) metas.put(META_ELECTRE_RESUME, resume);
		else metas.put(META_ELECTRE_RESUME, SvcElectre.noResume());
		return ECidStatus.waitingForCommit;
	}

	@Override
	protected boolean xExecuteCommit() throws Exception {
		return true;
	}

	@Override
	protected boolean xExecuteRollback() {
		return true;
	}

}
