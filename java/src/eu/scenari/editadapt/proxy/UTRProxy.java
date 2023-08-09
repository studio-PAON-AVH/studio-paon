package eu.scenari.editadapt.proxy;

import eu.scenari.commons.log.LogMgr;
import eu.scenari.commons.pools.PoolBuffers;
import eu.scenari.commons.stream.StreamUtils;
import eu.scenari.commons.stream.Utf8BufferedWriter;
import eu.scenari.commons.syntax.json.JsonParser;
import eu.scenari.commons.syntax.json.JsonSerializer;
import eu.scenari.commons.util.lang.ScException;
import eu.scenari.urltree.renderer.IUrlTreeRenderer;
import eu.scenari.urltree.renderer.UrlTreeRendererContext;

import javax.servlet.ServletInputStream;
import javax.servlet.http.HttpServletResponse;
import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Writer;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Map;

/**
 * Proxy via scenari pour permettre le développement de connexions à des services tiers
 */
public class UTRProxy implements IUrlTreeRenderer {

    @Override
    public void renderUrl(UrlTreeRendererContext pContext) throws Exception {
        try {
            HttpServletResponse vResp = pContext.response;
            if(!(pContext.request.getMethod() == "POST")){
                vResp.setStatus(404);
            } else {
                ServletInputStream data = pContext.request.getInputStream();
                JsonParser parser = new JsonParser();
                Map<String, Object> inputData = (Map<String, Object>) parser.parseValue(StreamUtils.buildString(new InputStreamReader(pContext.request.getInputStream())));
                URL url = new URL(inputData.get("url").toString());
                String method = inputData.get("method").toString();
                Map<String, String> headers = (Map<String, String>) inputData.get("headers");
                Object body = inputData.get("body");

                HttpURLConnection vCon = (HttpURLConnection) url.openConnection();
                vCon.setUseCaches(false);
                vCon.setAllowUserInteraction(false);
                vCon.setInstanceFollowRedirects(true);
                vCon.setRequestMethod(method);

                for (String header:headers.keySet()) {
                    vCon.setRequestProperty(header, headers.get(header));
                }

                StringBuilder vReqBodSB = PoolBuffers.popStringBuilder();
                if(body instanceof String){
                    vReqBodSB.append(body);
                } else {
                    vReqBodSB.append(JsonSerializer.stringify(body));
                }


                InputStream vBod = new ByteArrayInputStream(PoolBuffers.getStringAndFreeStringBuilder(vReqBodSB).getBytes(StandardCharsets.UTF_8));

                vCon.setDoOutput(true);
                StreamUtils.write(vBod, vCon.getOutputStream());
                vCon.getOutputStream().close();
                //Send request
                vCon.connect();
                int vRespCode = vCon.getResponseCode();
                if (vRespCode >= 300) {
                    vResp.setStatus(vRespCode);
                    vResp.setContentType("application/json");
                    Writer vWriter = new Utf8BufferedWriter(vResp.getOutputStream());
                    vWriter.write("{ \"error\" : \"Unable to reach '" + inputData.get("url").toString() + "' : " + vRespCode + "\" }");
                    vWriter.close();
                } else {
                    vResp.setStatus(200);
                    vResp.setContentType("application/json; charset=UTF-8");
                    Writer vWriter = new Utf8BufferedWriter(vResp.getOutputStream());

                    JsonSerializer response = new JsonSerializer(vWriter);
                    response.startObject()
                        .key("header")
                            .startObject();
                    Map<String, List<String>> respHeaders = vCon.getHeaderFields();
                    for (String respKey: respHeaders.keySet()) if(respKey != null){
                        try{
                            String headValue = String.join(";", respHeaders.get(respKey));
                            response.key(respKey).valString(headValue);
                        } catch (Exception e){
                            LogMgr.publishException(e);
                        }
                    }
                    response.endObject()
                        .key("body").valString(StreamUtils.buildString(new InputStreamReader(vCon.getInputStream())))
                    .endObject();
                    vWriter.close();
                }
            }
        } finally {
            pContext.lockToUnlock.unlock();
        }
    }
}
