/*
 * LICENCE[[
 * Version: MPL 1.1/GPL 2.0/LGPL 2.1/CeCILL 2.O
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is kelis.fr code.
 *
 * The Initial Developer of the Original Code is
 * thibaut.arribe@kelis.fr
 *
 * Portions created by the Initial Developer are Copyright (C) 2019
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *
 *
 * Alternatively, the contents of this file may be used under the terms of
 * either of the GNU General Public License Version 2 or later (the "GPL"),
 * or the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
 * or the CeCILL Licence Version 2.0 (http://www.cecill.info/licences.en.html),
 * in which case the provisions of the GPL, the LGPL or the CeCILL are applicable
 * instead of those above. If you wish to allow use of your version of this file
 * only under the terms of either the GPL or the LGPL, and not to allow others
 * to use your version of this file under the terms of the MPL, indicate your
 * decision by deleting the provisions above and replace them with the notice
 * and other provisions required by the GPL or the LGPL. If you do not delete
 * the provisions above, a recipient may use your version of this file under
 * the terms of any one of the MPL, the GPL, the LGPL or the CeCILL.
 * ]]LICENCE
 */

package eu.scenari.editadapt.import2depot;

import java.util.HashMap;
import java.util.Map;

import org.xml.sax.Attributes;

import com.scenari.m.co.donnee.IDataResolver;

import eu.scenari.commons.log.LogMgr;
import eu.scenari.commons.pools.PoolBuffers;
import eu.scenari.commons.util.lang.IAdaptable;
import eu.scenari.commons.util.xml.IFragmentSaxHandler;
import eu.scenari.core.dialog.DialogFake;
import eu.scenari.core.service.remotecontent.ISvcRemoteContent;
import eu.scenari.core.service.remotecontent.SendRequest;
import eu.scenari.core.webdav.HttpRespSimpleStatus;
import eu.scenari.store.cid.ICidMetasProvider;
import eu.scenari.store.service.storesquare.StoreSquareTask;
import eu.scenari.store.service.storesquare.SvcStoreSquare;
import eu.scenari.store.service.storesquare.steps.IfElseStepAbstract;
import eu.scenari.urltree.storesquare.IPersistentMetas;

/**
 * Envoie d'une requête HTTP
 * <pre>
 *  [step url="https://..." svcRemote="remoteContent" type=""/]
 * </pre>
 */
public class CheckIfExported extends IfElseStepAbstract {

	protected String fSvcRemoteCode = "remoteContent";

	protected String fUrl;

	@Override
	protected boolean xEvalCondition(ICidMetasProvider pCidMetas, IPersistentMetas pPersistMetas, StoreSquareTask pTask) {
		SendRequest vSendRequest = new SendRequest((ISvcRemoteContent) pTask.getSvc().getUniverse().getService(fSvcRemoteCode));

		Map<String, Object> vParams = new HashMap<>();
		vParams.put("method", "HEAD");
		vParams.put("url", PoolBuffers.getStringAndFreeStringBuilder(PoolBuffers.popStringBuilder().append(fUrl).append(pPersistMetas.get("path"))));

		try {
			HttpRespSimpleStatus vResponse = null;
			vResponse = vSendRequest.sendRequest(vParams, null, null, -1, DialogFake.newDialog(pTask.getSvc().getUniverse(), this));
			if (vResponse == null || vResponse.getStatus() >= 300) {
				return false;
			}
		} catch (Exception e) {
			throw LogMgr.wrapMessage(e, "Send Cid Request Step failed");
		}
		return true;
	}

	@Override
	public IFragmentSaxHandler initFromXml(SvcStoreSquare pSvc, IDataResolver pDataResolver, IAdaptable pInitContext, Attributes pAtts) {
		String vRemoteCode = pAtts.getValue("svcRemote");
		if (vRemoteCode != null) fSvcRemoteCode = vRemoteCode;
		fUrl = pAtts.getValue("url");
		return super.initFromXml(pSvc, pDataResolver, pInitContext, pAtts);
	}
}