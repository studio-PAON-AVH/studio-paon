package eu.scenari.editadapt.import2chain;

import eu.scenari.commons.log.LogMgr;
import eu.scenari.store.service.mkviews.RelaunchCidTasksJob;
import eu.scenari.store.service.urltreedriver.UTDriverTask;

public class ReImport2ChainJob extends RelaunchCidTasksJob {

	protected SvcImport2Chain svc;

	@Override
	public String getJobSgn() {
		return "ReImport2ChainJob";
	}

	@Override
	protected boolean skipContext(ResContext pCtx) {
		String vPrc = (String) pCtx.fOldPersistMetas.get(UTDriverTask.META_processing);
		return !vPrc.equals("xml") && !vPrc.equals("epub3");
	}

	@Override
	protected boolean handleContext(ResContext pCtx) {
		try {
			getSvcImport2Chain().importFromResId(pCtx.fResId, pCtx.fOldPersistMetas);
			return true;
		} catch (Exception e) {
			LogMgr.publishException(e);
		}
		return false;
	}

	protected SvcImport2Chain getSvcImport2Chain() {
		if (svc == null) svc = (SvcImport2Chain) getUniverse().getService("chainImport");
		return svc;
	}

}
