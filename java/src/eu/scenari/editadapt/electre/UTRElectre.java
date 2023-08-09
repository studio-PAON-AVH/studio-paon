package eu.scenari.editadapt.electre;

import eu.scenari.commons.stream.Utf8BufferedWriter;
import eu.scenari.urltree.renderer.IUrlTreeRenderer;
import eu.scenari.urltree.renderer.UrlTreeRendererContext;
import eu.scenari.urltree.storesquare.IPersistentMetas;

import javax.servlet.http.HttpServletResponse;

import java.io.Writer;

/**
 * Récupération des notices electres pour une resource possédant une méta isbn
 */
public class UTRElectre implements IUrlTreeRenderer {
    @Override
    public void renderUrl(UrlTreeRendererContext pContext) throws Exception {
        try{
            // Si la requete est un
            // recuperer la meta isbn si on est sur une ressource avec une meta ISBN
            IPersistentMetas pMetas = pContext.getPersistMetas();
            String ISBN = (String) pMetas.get("isbn");
            if(ISBN == null){
                // renvoyer une erreur 404
                pContext.response.sendError(404);
            } else
            {
                // Connection au service electre
                SvcElectre electre = (SvcElectre) pContext.getUniverse().getService("electre");
                String jsonNotices = electre.getNotices(ISBN);
                if(jsonNotices == null){
                    pContext.response.sendError(404);
                }
                // transférer la réponse
                HttpServletResponse vResp = pContext.response;
                vResp.setStatus(200);
                vResp.setContentType("application/json; charset=UTF-8");
                Writer vWriter = new Utf8BufferedWriter(vResp.getOutputStream());
                vWriter.write(jsonNotices);
                vWriter.close();

            }
        } finally {
            pContext.lockToUnlock.unlock();
        }
    }
}
