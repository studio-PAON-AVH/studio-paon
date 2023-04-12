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
 * sylvains.spinelli@kelis.fr
 *
 * Portions created by the Initial Developer are Copyright (C) 2014
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

package eu.scenari.editadapt.index;

import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.file.Files;
import java.nio.file.Path;

import org.xml.sax.Attributes;

import com.scenari.src.ISrcNode;

import eu.scenari.commons.log.LogMgr;
import eu.scenari.commons.stream.StreamUtils;
import eu.scenari.commons.util.lang.IAdaptable;
import eu.scenari.commons.util.xml.IFragmentSaxHandler;
import eu.scenari.store.service.esdriver.EsDriverTask;
import eu.scenari.store.service.esdriver.SvcEsDriverLoader;
import eu.scenari.store.service.esdriver.makers.PersistMetaCopyEOM;
import eu.scenari.store.service.esdriver.makers.utils.IEsIdMaker;
import eu.scenari.store.service.mkviews.InfoViews;
import eu.scenari.store.service.storesquare.StoreSquareTask;
import eu.scenari.urltree.storesquare.ResId;

public class RawEOM extends PersistMetaCopyEOM {

	protected String fFromCdView;
	protected String fToEsField;
	protected String fEsIndex;
	protected String fPrefixId;

	protected IEsIdMaker fEsIdMaker;

	protected class RawFileHandler extends PersistMetaCopyHandler {
	}

	public void buildEsOjects(EsDriverTask pTask) {
		ResId vResId = (ResId) pTask.getSessionDatas().get(StoreSquareTask.KEY_resId);
		for (ObjectMk vMaker : fObjectMakers) {
			vMaker.buildEsOjects(vResId, pTask);
			Path Path = InfoViews.getViewSource(fFromCdView, pTask.getSessionDatas(), pTask.getSvcStoreSquare());
			if (Path != null && Files.exists(Path)) {
				try (InputStream vIn = Files.newInputStream(Path)) {
					vMaker.getOrCreateEsObject(vResId, pTask).setField(fToEsField, StreamUtils.buildString(new InputStreamReader(vIn)));
				} catch (Exception e) {
					LogMgr.publishException(e);
				}
			}
		}
	}


	@Override
	public IFragmentSaxHandler initFromXml(SvcEsDriverLoader pSvcLoader, IAdaptable pInitContext, ISrcNode pInitSrc, Attributes pAtts) {
		fFromCdView = pAtts.getValue("rawTxtView");
		fToEsField = pAtts.getValue("esField");
		return new RawFileHandler();
	}
}
