package eu.scenari.editadapt.ant;

import java.io.File;
import java.nio.file.Path;
import java.util.Map;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Project;
import org.apache.tools.ant.ProjectHelper;

import com.scenari.m.co.ant.TransformTask;
import com.scenari.m.co.donnee.IData;
import com.scenari.m.ge.generator.ant.AntGenerator;

import eu.scenari.commons.log.LogMgr;
import eu.scenari.commons.util.lang.ScException;
import eu.scenari.core.dialog.DialogFake;
import eu.scenari.core.dialog.IDialog;
import eu.scenari.store.cid.ICidTask;
import eu.scenari.store.service.mkviews.DescView;
import eu.scenari.store.service.mkviews.IDescView;
import eu.scenari.store.service.mkviews.MkViewsTask;
import eu.scenari.store.service.storesquare.StoreSquareTask;
import eu.scenari.urltree.storesquare.ResId;

/**
 * Class identique au AntViewMaker avec hack sur le src pour autoriser un builtOn Content
 * avec une view en src.
 */
public class AntViewMk extends eu.scenari.store.service.mkviews.makers.AntViewMk {

	@Override
	public void buildViews(MkViewsTask pTask, ResId pResId, Map<String, IDescView> pViews) {
		IDescView vView = pViews.get(getCodeViewMaker());
		try {
			final Path vDst = vView != null ? vView.getBuildPath(pTask.getSvcStoreSquare(), pResId) : null;
			if (vDst == null) return;

			//Si manip de directory uniquement...
			//Files.createDirectory(vDst);
			Map<String, Object> vSessionDatas = pTask.getSessionDatas();
			String vSrc;

			//Hack de la déclaration standards pour avoir des views builtOn content avec un contenu de view en input
			if (fFromCdView != null) {
				IDescView vFromView = pViews.get(fFromCdView);
				vSrc = DescView.resolveView(pResId, vFromView, pTask.getSvcStoreSquare()).toString();
			} else
				vSrc = ((File) vSessionDatas.get(ICidTask.KEY_file)).getAbsolutePath();

			//Projet ANT
			Project vProject = new Project();
			vProject.setCoreLoader(AntGenerator.class.getClassLoader());
			vProject.addTaskDefinition("transform", TransformTask.class);
			vProject.init();
			IDialog vDialog = DialogFake.newDialog(pTask.getSvcMkViews().getUniverse(), null);
			vDialog.setVar("sessionDatas", pTask.getSessionDatas());
			vDialog.setVar("persistMetas", pTask.getSessionDatas().get(StoreSquareTask.KEY_persistentMetas));
			vDialog.setVar("task", pTask);
			vDialog.setVar("views", pViews);
			vDialog.setVar("resId", pResId);
			vProject.addReference(IData.NAMEVARINSCRIPT_vDialog, vDialog);
			vProject.setUserProperty(NAMEVAR_INPUT, vSrc);
			vProject.setUserProperty(NAMEVAR_DESTPATH, vDst.toString());
			AntViewLogger vLogger = new AntViewLogger();

			try {
				ProjectHelper.getProjectHelper();
				vProject.addBuildListener(vLogger);
				ProjectHelper.configureProject(vProject, fBuildFile);
				vProject.executeTarget(vProject.getDefaultTarget());
				if (vLogger.hasErrors()) throw new ScException("Ant project has errors");
			} catch (BuildException e) {
				StringBuilder vSb = new StringBuilder();
				throw LogMgr.wrapMessage(unwrapBuildException(e, vSb), vSb.toString());
			} catch (ScException vE) {
				throw LogMgr.newException(vLogger.getErrorsMsg());
			}
			vView.markAsDone();
		} catch (Throwable e) {
			vView.onBuiltFailed(e, pTask);
		}
	}
}
