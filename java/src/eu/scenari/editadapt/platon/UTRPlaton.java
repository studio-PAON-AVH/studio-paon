package eu.scenari.editadapt.platon;

import eu.scenari.commons.stream.StreamUtils;
import eu.scenari.commons.syntax.json.JsonParser;
import eu.scenari.urltree.renderer.IUrlTreeRenderer;
import eu.scenari.urltree.renderer.UrlTreeRendererContext;
import eu.scenari.urltree.storesquare.IPersistentMetas;
import eu.scenari.commons.stream.Utf8BufferedWriter;

import javax.servlet.ServletInputStream;
import javax.servlet.http.HttpServletResponse;
import java.io.InputStreamReader;
import java.io.Writer;
import java.util.Map;

/**
 * Récupération des notices electres pour une resource possédant une méta isbn
 */
public class UTRPlaton implements IUrlTreeRenderer {

    private static class ACTIONS {
        public static final String RUN_DEMANDE_A_PLATON = "runDemandeAPlaton";
        public static final String GET_PLATON_CATALOGUE_INFO = "getPlatonCatalogueInfo";
    }

    @Override
    public void renderUrl(UrlTreeRendererContext pContext) throws Exception {
        try{
            HttpServletResponse vResp = pContext.response;
            if(!(pContext.request.getMethod() == "POST")){
                vResp.setStatus(404);
            } else {
                ServletInputStream data = pContext.request.getInputStream();
                Writer vWriter = new Utf8BufferedWriter(vResp.getOutputStream());
                vResp.setContentType("application/json; charset=UTF-8");

                JsonParser parser = new JsonParser();
                Map<String, Object> inputData = (Map<String, Object>) parser.parseValue(StreamUtils.buildString(new InputStreamReader(pContext.request.getInputStream())));
                // Valeurs attendu ici :
                // user:string
                // password:string
                // action:'runDemandeAPlaton' | 'getPlatonCatalogueInfo'
                // ean:string? (optionnel si appelé sur une ressource avec une meta ISBN)
                String user = (String) inputData.get("user");
                if(user == null || user.isEmpty()){
                    vResp.setStatus(400);
                    vWriter.write(String.format(
                            "{ \"type\":\"%s\", \"message\":\"%s\" }",
                            APIPlaton.NotificationType.ERROR,
                            "Identifiant platon manquant"
                    ));
                    vWriter.close();
                    return;
                }
                String password = (String) inputData.get("password");
                if(password == null || password.isEmpty()){
                    vResp.setStatus(400);
                    vWriter.write(String.format(
                            "{ \"type\":\"%s\", \"message\":\"%s\" }",
                            APIPlaton.NotificationType.ERROR,
                            "Mot de passe platon manquant"
                    ));
                    vWriter.close();
                    return;
                }
                String action = (String) inputData.get("action");
                if(action == null || action.isEmpty()){
                    vResp.setStatus(400);
                    vWriter.write(String.format(
                            "{ \"type\":\"%s\", \"message\":\"%s\" }",
                            APIPlaton.NotificationType.ERROR,
                            "Aucune action demandé"
                    ));
                    vWriter.close();
                    return;
                }
                IPersistentMetas pMetas = pContext.getPersistMetas();
                String ISBN = null;
                if(pMetas != null){
                    ISBN = (String) pMetas.get("isbn");
                }
                if(ISBN == null){
                    ISBN = (String) inputData.get("ean");
                }
                if(ISBN == null || ISBN.isEmpty()){
                    vResp.setStatus(400);
                    vWriter.write(String.format(
                            "{ \"type\":\"%s\", \"message\":\"%s\" }",
                            APIPlaton.NotificationType.ERROR,
                            "Aucun EAN fourni"
                    ));
                    vWriter.close();
                    return;
                }
                if(action.equals(ACTIONS.RUN_DEMANDE_A_PLATON)){
                    // Connection au service platon
                    String jsonResult = APIPlaton.runDemandeAPlaton(user, password, ISBN);
                    if(jsonResult == null){
                        vResp.setStatus(400);
                        vWriter.write(String.format(
                                "{ \"type\":\"%s\", \"message\":\"%s\" }",
                                APIPlaton.NotificationType.ERROR,
                                "Erreur inconnu lors de la demande à platon"
                        ));
                        vWriter.close();
                    } else {
                        vResp.setStatus(200);
                        vWriter.write(jsonResult);
                        vWriter.close();
                    }
                } else if(action.equals(ACTIONS.GET_PLATON_CATALOGUE_INFO)){
                    // Connection au service platon
                    String jsonResult = APIPlaton.getPlatonCatalogueInfo(user, password, ISBN);
                    if(jsonResult == null){
                        vResp.setStatus(400);
                        vWriter.write(String.format(
                                "{ \"type\":\"%s\", \"message\":\"%s\" }",
                                APIPlaton.NotificationType.ERROR,
                                "Erreur inconnu lors de l'accès au catalogue de platon"
                        ));
                        vWriter.close();
                    } else {
                        vResp.setStatus(200);
                        vWriter.write(jsonResult);
                        vWriter.close();
                    }
                } else {
                    vResp.setStatus(400);
                    vWriter.write(String.format(
                            "{ \"type\":\"%s\", \"message\":\"%s\" }",
                            APIPlaton.NotificationType.ERROR,
                            "Action " + action + " inconnue"
                    ));
                    vWriter.close();
                }

            }
        } finally {
            pContext.lockToUnlock.unlock();
        }
    }
}