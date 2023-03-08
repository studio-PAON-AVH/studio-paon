package eu.scenari.editadapt.ant;

import java.nio.file.Path;
import java.util.Map;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Project;
import org.apache.tools.ant.Task;

import com.scenari.m.co.donnee.IData;

import eu.scenari.commons.log.LogMgr;
import eu.scenari.commons.util.path.PathUtils;
import eu.scenari.core.dialog.IDialog;
import eu.scenari.store.service.mkviews.IDescView;
import eu.scenari.store.service.mkviews.MkViewsTask;
import eu.scenari.urltree.storesquare.ResId;


/**
 * Task ant qui dezip un ensemble de vue dans un repertoire courant
 */
public class AggregateZippedViewsTask extends Task {

	String filter;

	String output;


	/**
	 *
	 */
	public AggregateZippedViewsTask() {
		super();
	}

	@Override
	public void execute() throws BuildException {
		Project vProject = getProject();
		try {
			IDialog vDialog = (IDialog) vProject.getReference(IData.NAMEVARINSCRIPT_vDialog);

			MkViewsTask task = (MkViewsTask) vDialog.getVar("task");
			ResId resId = (ResId) vDialog.getVar("resId");
			Map<String, IDescView> views = (Map<String, IDescView>) vDialog.getVar("views");

			Path path = Path.of(output);
			for (String code : views.keySet()) {
				if (code.indexOf(filter) != -1) {
					IDescView vFromView = views.get(code);
					final Path vFromDst = vFromView != null ? vFromView.getBuildPath(task.getSvcStoreSquare(), resId) : null;
					Path dirPath = path.resolve(code);
					PathUtils.unzip(vFromDst, dirPath);
				}
			}

		} catch (BuildException e) {
			throw e;
		} catch (Exception e) {
			throw (BuildException) LogMgr.addMessage(new BuildException(e, getLocation()), LogMgr.getMessage(e));
		}
	}

	public void setOutput(String output) {
		this.output = output;
	}

	public void setFilter(String filter) {
		this.filter = filter;
	}
}
