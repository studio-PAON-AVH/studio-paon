package eu.scenari.editadapt.electre;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import javax.xml.parsers.ParserConfigurationException;
import javax.xml.parsers.SAXParser;
import javax.xml.parsers.SAXParserFactory;

import org.xml.sax.Attributes;
import org.xml.sax.SAXException;
import org.xml.sax.helpers.AttributesImpl;
import org.xml.sax.helpers.DefaultHandler;

import eu.scenari.commons.log.LogMgr;
import eu.scenari.commons.pools.PoolBuffers;
import eu.scenari.commons.stream.StreamUtils;
import eu.scenari.commons.syntax.json.JsonParser;
import eu.scenari.commons.util.lang.ScException;
import eu.scenari.core.service.ISvcDialog;
import eu.scenari.core.service.SvcBase;
import eu.scenari.core.service.remotecontent.SvcRemoteContent;
import eu.scenari.store.cid.ICidTask;
import eu.scenari.store.cid.ICidTaskFactory;
import eu.scenari.xml.serializer.IXSerializer;
import eu.scenari.xml.serializer.xerces.OutputFormat;
import eu.scenari.xml.serializer.xerces.impl.XMLSerializer;

public class SvcElectre extends SvcBase implements ICidTaskFactory {

	protected Boolean enable;
	protected String tokenUrl;
	protected String noticeUrl;
	protected String user;
	protected String password;
	protected String token;
	protected long tokenExpirationDate;
	protected SvcRemoteContent remoteContent = null;

	static public String noResume() {
		return "<sc:para xml:space=\"preserve\"><sc:inlineStyle role=\"error\">Échec de l'obtention du résumé (absent de la base electre).</sc:inlineStyle></sc:para>";
	}

	@Override
	public void initAndLinkSvcs() {
		remoteContent = (SvcRemoteContent) getUniverse().getService("remoteContent");
	}

	@Override
	public ISvcDialog newDialog() {
		return null;
	}

	@Override
	public ICidTask createCidTask() {
		return new FetchResumeCidTask(this);
	}

	/**
	 *
	 */
	public String fetchResume(String isbn) {
		String ean = isbn.replaceAll("\\D", "");
		return getResume(ean);
	}

	public Boolean getEnable() {
		return enable;
	}

	public void setEnable(Boolean pEnable) {
		enable = pEnable;
	}

	public String getTokenUrl() {
		return tokenUrl;
	}

	public void setTokenUrl(String pTokenUrl) {
		tokenUrl = pTokenUrl;
	}

	public String getNoticeUrl() {
		return noticeUrl;
	}

	public void setNoticeUrl(String pNoticeUrl) {
		noticeUrl = pNoticeUrl;
	}

	public String getUser() {
		return user;
	}

	public void setUser(String pUser) {
		user = pUser;
	}

	public String getPassword() {
		return password;
	}

	public void setPassword(String pPassword) {
		password = pPassword;
	}

	protected void getAuthorization() throws Exception {
		StringBuilder vReqBodSB = PoolBuffers.popStringBuilder();
		vReqBodSB.append("grant_type=password&username=").append(user);
		vReqBodSB.append("&password=").append(password);
		vReqBodSB.append("&client_id=api-client");
		InputStream vBod = new ByteArrayInputStream(PoolBuffers.getStringAndFreeStringBuilder(vReqBodSB).getBytes(StandardCharsets.UTF_8));

		HttpURLConnection vCon = (HttpURLConnection) new URL(tokenUrl).openConnection();
		vCon.setUseCaches(false);
		vCon.setAllowUserInteraction(false);
		vCon.setInstanceFollowRedirects(true);
		vCon.setRequestMethod("POST");
		vCon.setRequestProperty("Content-type", "application/x-www-form-urlencoded");

		vCon.setDoOutput(true);
		StreamUtils.write(vBod, vCon.getOutputStream());
		vCon.getOutputStream().close();

		//Send request
		vCon.connect();
		int vRespCode = vCon.getResponseCode();
		if (vRespCode >= 300) {
			throw new ScException("Unable to reach '" + tokenUrl + "' : " + vRespCode);
		}

		JsonParser parser = new JsonParser();
		Map<String, Object> response = (Map<String, Object>) parser.parseValue(StreamUtils.buildString(new InputStreamReader(vCon.getInputStream())));
		token = PoolBuffers.getStringAndFreeStringBuilder(PoolBuffers.popStringBuilder().append("Bearer ").append(response.get("access_token")));
		tokenExpirationDate = System.currentTimeMillis() + ((Integer) response.get("expires_in")).longValue() * 1000;
	}

	protected String getResume(String isbn) {
		try {
			if (token == null || System.currentTimeMillis() + 60 * 1000 > tokenExpirationDate) getAuthorization();
			StringBuilder urlSB = PoolBuffers.popStringBuilder();
			urlSB.append(noticeUrl).append(isbn);

			HttpURLConnection vCon = (HttpURLConnection) new URL(PoolBuffers.getStringAndFreeStringBuilder(urlSB)).openConnection();
			vCon.setUseCaches(false);
			vCon.setAllowUserInteraction(false);
			vCon.setInstanceFollowRedirects(true);
			vCon.setRequestMethod("GET");
			vCon.setRequestProperty("Authorization", token);

			//Send request
			vCon.connect();
			int vRespCode = vCon.getResponseCode();
			if (vRespCode >= 500) {
				throw new ScException("Unable to reach '" + tokenUrl + "' : " + vRespCode);
			} else if (vRespCode >= 404) return null;
			else if (vRespCode >= 400) {
				token = null;
				return null;
			}

			JsonParser parser = new JsonParser();
			Map<String, Object> response = (Map<String, Object>) parser.parseValue(StreamUtils.buildString(new InputStreamReader(vCon.getInputStream())));
			List<Map<String, Object>> notices = (List<Map<String, Object>>) response.get("notices");
			if (notices.size() > 0) return transformHtml2Xml((String) notices.get(0).get("quatriemeDeCouverture"));
			else return null;
		} catch (Exception e) {
			LogMgr.publishException(e);
			return null;
		}

	}

	protected String transformHtml2Xml(String xml) {
		try {
			SAXParser parser = SAXParserFactory.newInstance().newSAXParser();
			TransformHtmlHandler handler = new TransformHtmlHandler();
			ByteArrayInputStream is = new ByteArrayInputStream(("<html>" + xml + "</html>").getBytes());
			parser.parse(is, handler);
			is.close();
			return handler.getString();
		} catch (ParserConfigurationException pE) {
			LogMgr.publishException(pE);
		} catch (IOException pE) {
			LogMgr.publishException(pE);
		} catch (SAXException pE) {
			LogMgr.publishException(pE);
		}
		return null;
	}

	/**
	 * Conversion du html reçu d'electre en résumé pour studio paon.
	 * <p>
	 * Notes :
	 * NP 2023-02-01: passage par un XMLSerializer aulieu d'un string builder pour corriger les problèmes d'import
	 */
	protected class TransformHtmlHandler extends DefaultHandler {
		protected StringWriter writer = PoolBuffers.popStringWriter();
		protected XMLSerializer xml;

		LinkedList<String> stack = new LinkedList<>();

		public TransformHtmlHandler() {
			OutputFormat format = new OutputFormat(IXSerializer.XSLMETHOD_xml, null, false);
			format.setOmitXMLDeclaration(true);
			xml = new XMLSerializer(writer, format);
		}

		@Override
		public void startDocument() throws SAXException {
			xml.startDocument();
		}

		@Override
		public void endDocument() throws SAXException {
			xml.endDocument();
		}

		@Override
		public void startElement(String uri, String localName, String qName, Attributes attributes) throws SAXException {
			if (qName.equals("html")) return;
			else if (qName.equals("br")) {
				LinkedList<String> closed = new LinkedList<>();

				for (Iterator<String> it = stack.descendingIterator(); it.hasNext(); ) {
					String tag = it.next();
					closeTag(tag);
					closed.add(tag);
					if (tag.equals("p")) break;
				}

				for (Iterator<String> closeIt = closed.descendingIterator(); closeIt.hasNext(); ) openTag(closeIt.next());
			} else openTag(qName);
			stack.add(qName);
		}

		@Override
		public void endElement(String uri, String localName, String qName) throws SAXException {
			if (qName.equals("html")) return;
			else closeTag(qName);
			stack.pollLast();
		}

		protected void openTag(String tag) throws SAXException {
			AttributesImpl attrs = new AttributesImpl();
			if (tag.equals("p")) {
				attrs.addAttribute("", "space", "xml:space", "", "preserve");
				xml.startElement("", "para", "sc:para", attrs);
			} else if (tag.equals("b")) {
				attrs.addAttribute("", "role", "role", "", "strong");
				xml.startElement("", "inlineStyle", "sc:inlineStyle", attrs);
			} else if (tag.equals("i")) {
				attrs.addAttribute("", "role", "role", "", "emphase");
				xml.startElement("", "inlineStyle", "sc:inlineStyle", attrs);
			} else if (tag.equals("sup")) {
				attrs.addAttribute("", "role", "role", "", "exposant");
				xml.startElement("", "inlineStyle", "sc:inlineStyle", attrs);
			} else if (tag.equals("br")) return;
			else {
				attrs.addAttribute("", "role", "role", "", "error");
				xml.startElement("", "inlineStyle", "sc:inlineStyle", attrs);
			}
		}

		@Override
		public void characters(char[] ch, int start, int length) throws SAXException {
			xml.characters(ch, start, length);
		}

		protected void closeTag(String tag) throws SAXException {
			if (tag.equals("p")) {
				xml.endElement("", "para", "sc:para");
			} else if (tag.equals("br")) return;
			else {
				xml.endElement("", "inlineStyle", "sc:inlineStyle");
			}
		}

		public String getString() {
			String result = writer.toString();
			PoolBuffers.freeStringWriter(writer);
			return result;
		}
	}

}
