package eu.scenari.editadapt.tts.acapela;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.HashMap;
import java.util.Map;

import com.scenari.src.ISrcContent;
import com.scenari.src.ISrcNode;

import eu.scenari.commons.log.LogMgr;
import eu.scenari.commons.log.TraceMgr;
import eu.scenari.commons.log.TracePoint;
import eu.scenari.commons.pools.PoolBuffers;
import eu.scenari.commons.stream.StreamUtils;
import eu.scenari.commons.syntax.json.IJsonSerializer;
import eu.scenari.commons.syntax.json.JsonParser;
import eu.scenari.commons.syntax.json.JsonSerializer;
import eu.scenari.commons.util.lang.ScException;
import eu.scenari.core.service.oauth.OAuthUrlEncoder;
import eu.scenari.core.webdav.HttpRespGet;
import eu.scenari.src.transform.TfmBase;
import eu.scenari.src.transform.TfmParams;
import eu.scenari.src.transform.TransformContentException;

/**
 * Transformation d'un txt en audio via un service de text 2 speech
 * Le txt d'origine peut être un fichier source ou un param txt
 * Le code du "svc" doit être passé en param
 */
public class TfmAcapelaTTS extends TfmBase {

	public static final TracePoint sTrace = TraceMgr.register(TfmAcapelaTTS.class.getName() + ".sTrace", "Traces TfmAcapelaTTS.");

	protected Boolean enable;

	protected String url;

	protected String user;

	protected String password;

	protected String token = null;

	@Override
	public void transform(Object pSrc, Object pRes, TfmParams pParams) throws TransformContentException, Exception {
		if (!enable) return;
		Map<String, Object> params = pParams.getParamsAsMap();
		String from = null;
		String to = null;
		Reader srcReader = null;
		if (pSrc instanceof ISrcNode) {
			ISrcContent vSrcContent = (ISrcContent) pSrc;
			srcReader = new InputStreamReader(vSrcContent.newInputStream(true));
		} else if (pSrc instanceof File) {
			File vFile = (File) pSrc;
			srcReader = new FileReader(vFile);
			from = vFile.getPath();
		} else if (srcReader != null) {
			srcReader = new InputStreamReader((InputStream) pSrc);
		}
		OutputStream targetStream = null;
		if (pRes instanceof OutputStream) {
			targetStream = (OutputStream) pRes;
		} else if (pRes instanceof File) {
			Path path = Path.of(((File) pRes).getPath());
			targetStream = Files.newOutputStream(path);
			to = path.toString();
		}

		try {
			String voice = (String) params.get("voice");
			String dico = (String) params.get("dico");
			StreamUtils.write(getAudioZip(srcReader, voice, dico), targetStream);
		} catch (Exception e) {
			throw LogMgr.addMessage(e, "Unable to TTS: " + ((File) pSrc).toPath() + " with Acapela provider");
		} finally {
			srcReader.close();
			targetStream.close();
		}
	}

	// https://www.acapela-cloud.com/docs/
	public InputStream getAudioZip(Reader txtReader, String voice, String dico) throws Exception {
		if (token == null) refreshToken();
		Map<String, String> data = new HashMap<String, String>(2);
		data.put("voice", voice);
		data.put("dico", dico);
		data.put("output", "file");
		data.put("wordpos", "on");

		//Requête de verif de la connexion
		HttpRespGet resp = sendRequest("/api/account/", null, null);
		if (resp.getStatus() == 401) refreshToken();
		resp = sendRequest("/api/command/", data, txtReader);
		return resp.getInputStream();
	}

	protected void refreshToken() throws Exception {
		token = null;
		Map<String, String> data = new HashMap<String, String>(2);
		data.put("email", user);
		data.put("password", password);
		HttpRespGet resp = sendRequest("/api/login/", data, null);
		JsonParser parser = new JsonParser();
		try {
			Map<String, String> respJson = (Map<String, String>) parser.parseValue(StreamUtils.buildString(new InputStreamReader(resp.getInputStream())));
			token = PoolBuffers.getStringAndFreeStringBuilder(PoolBuffers.popStringBuilder().append("Token ").append(respJson.get("token")));
		} catch (Exception e) {
			LogMgr.publishException(e);
		} finally {
			resp.getInputStream().close();
		}
	}

	protected HttpRespGet sendRequest(String api, Map<String, String> data, Reader text) throws Exception {
		String vUrlStr = PoolBuffers.getStringAndFreeStringBuilder(PoolBuffers.popStringBuilder().append(url).append(api));
		String vMeth = data != null || text != null ? "POST" : "GET";

		HttpURLConnection vCon = (HttpURLConnection) new URL(vUrlStr).openConnection();
		vCon.setUseCaches(false);
		vCon.setAllowUserInteraction(false);
		vCon.setInstanceFollowRedirects(false);
		vCon.setRequestMethod(vMeth);

		if (token != null) vCon.setRequestProperty("Authorization", token);
		vCon.setRequestProperty("Content-type", "application/json");

		StringWriter traceText = null;

		if (data != null || text != null) {
			traceText = PoolBuffers.popStringWriter();
			vCon.setDoOutput(true);
			try (Writer writer = new OutputStreamWriter(vCon.getOutputStream())) {
				IJsonSerializer json = new JsonSerializer(writer);
				json.startObject();
				if (data != null) for (String key : data.keySet())
					json.key(key).valString(data.get(key));
				if (text != null) {
					json.getAppendable().append(",\"text\":\"");

					char[] buffer = PoolBuffers.popChars64k();
					String strBuffer;
					int offset = 0;
					while (offset >= 0) {
						offset = text.read(buffer);
						if (offset > 0) {
							char[] encodedChars = OAuthUrlEncoder.encode(new String(buffer, 0, offset)).toCharArray();
							for (int i = 0; i < encodedChars.length; i++) {
								traceText.write(encodedChars[i]);
								JsonSerializer.writeJsChar(encodedChars[i], json.getAppendable());
							}
						}
					}
					PoolBuffers.freeChars(buffer);
					json.getAppendable().append('"');
				}
				json.endObject();
			}
			vCon.getOutputStream().close();
		}

		vCon.connect();
		int vRespCode = vCon.getResponseCode();

		InputStream response = vRespCode >= 400 ? vCon.getErrorStream() : vCon.getInputStream();
		if (sTrace.isEnabled()) {
			if (traceText != null) {
				data.put("text", traceText.toString());
			}
			PoolBuffers.freeStringWriter(traceText);
			sTrace.publishDebug("[SvcAcapela] - SvcAcapela sent' \n" + vMeth + " " + vUrlStr + "\nContent-Type: application/json\nAuthorization" + token + "\n\nBody:" + JsonSerializer.stringify(data) + "\n\nResponse status: " + vRespCode);

		}

		if (vRespCode >= 300 && vRespCode != 403 && vRespCode != 401) {
			String responseStr = StreamUtils.buildString(new InputStreamReader(response));
			throw new ScException("Unable to reach '" + vUrlStr + "' : " + vRespCode + "\n" + responseStr);
		}

		//Handle Response
		HttpRespGet vGetResult = new HttpRespGet(vRespCode);
		vGetResult.setContentType(vCon.getContentType());
		vGetResult.setInputStream(response);
		vGetResult.setLength(vCon.getContentLengthLong());
		return vGetResult;
	}

	@Override
	public String getMimeType(TfmParams pParams) throws Exception {
		return "application/zip";
	}

	@Override
	public String getFileExtension(TfmParams pParams) throws Exception {
		return ".zip";
	}

	@Override
	public boolean isSrcAllowed(Class pClassSrc, TfmParams pParams) {
		return ISrcContent.class.isAssignableFrom(pClassSrc) || File.class.isAssignableFrom(pClassSrc) || InputStream.class.isAssignableFrom(pClassSrc);
	}

	@Override
	public boolean isResAllowed(Class pClassRes, TfmParams pParams) {
		return File.class.isAssignableFrom(pClassRes) || OutputStream.class.isAssignableFrom(pClassRes);
	}

	@Override
	public void setTransformProperty(String pKey, String pValue) {
		switch (pKey) {
			case "user":
				this.user = pValue;
				break;
			case "password":
				this.password = pValue;
				break;
			case "url":
				this.url = pValue;
				break;
			case "enable":
				this.enable = Boolean.parseBoolean(pValue);
				break;
		}
	}

}
