package eu.scenari.editadapt.platon;

import eu.scenari.commons.syntax.json.JsonParser;


import java.net.CookieManager;
import java.net.CookiePolicy;
import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Portage du code de connection à platon originellement définis en javascript
 * du coté du tableau de suivi.
 */
public class APIPlaton {

	private static final String BASEURL = "https://exceptionhandicap.bnf.fr";
	private static class ENDPOINTS
	{
		public static final String LOGIN = "/connexion/miglogin2";
		public static final String LOGIN_SUCCESS = "/pmeh/accueil";
		public static final String GET_ID_FROM_EAN = "/ajaxGetRechercheAvanceeData";
		//public static final String GET_ID_FROM_EAN = "/ajaxGetRechercheAvanceeDataEtFacets?estampille=1";
		public static final String GET_DEMANDES_FROM_EAN = "/ajaxGetDemandePmehResponse";
		public static final String GET_FICHIERS_EDITEUR = "/ajaxGetFichiersEditeurResponse";
		public static final String GET_FICHIERS_ADAPTES = "/ajaxGetFichiersAdaptesResponse";
		public static final String GET_ADAPTATIONS_NON_DEPOSEES = "/ajaxGetAdaptationsNonDeposeesResponse";
		public static final String GET_ADAPTATIONS_EN_COURS = "/ajaxGetAdaptationsEnCoursResponse";
		public static final String CREATE_DEMANDE = "/pmeh/creation-demande-livre";
		public static final String SAVE_DEMANDE = "/pmeh/enregistrer-demande";
	}

	public static class NotificationType {
		public static final String ERROR = "error";
		public static final String SUCCESS =  "success";
		public static final String WARNING = "warning";
	}

	public static String ResponsePlaton(String notifType, String message){
		return String.format("{" +
						"\"type\":\"%s\", " +
						"\"date\":\"%s\", " +
						"\"message\":\"%s\"" +
				"}",
				notifType,
				new SimpleDateFormat("yyyy/MM/dd HH:mm:ss.SSS").format(new Date()),
				message.replace("\n", "\\n").replace("\r", "\\r")
		);
	}

	protected static HttpClient logOnPlaton(String user, String password) throws Exception {
		HttpClient client = HttpClient.newBuilder()
				.followRedirects(HttpClient.Redirect.ALWAYS)
				.cookieHandler(new CookieManager(null, CookiePolicy.ACCEPT_ALL))
				.build();
		HttpRequest request = HttpRequest.newBuilder(new URI(BASEURL + ENDPOINTS.LOGIN))
				.header("Content-Type", "application/x-www-form-urlencoded")
				.POST(HttpRequest.BodyPublishers.ofString(String.format(
						"identifiant=%s&motDePasse=%s",
						URLEncoder.encode(user, StandardCharsets.UTF_8),
						URLEncoder.encode(password, StandardCharsets.UTF_8)
				)))
				.build();

		HttpResponse resp = client.send(request, HttpResponse.BodyHandlers.ofString());
		// Controle si le client est redirigé vers /pmeh/acceuil (= succes de la connexion)
		if(resp.statusCode() == 200 && resp.uri().getPath().startsWith(ENDPOINTS.LOGIN_SUCCESS)){
			return client;
		} else throw new Exception("Echec de la connexion a platon, veuillez vérifier vos identifiants. (" + resp.statusCode() + ", " + resp.uri().getPath() + ")");

	}

	/**
	 * checkDemandeBeforeDemandeAPlaton
	 * @param client
	 * @param EAN13
	 * @return
	 * @throws Exception
	 */
	protected static String getDemandesForEAN(HttpClient client, String EAN13) throws Exception {
		String dataRaw = String.format(
				"{\"jtStartIndex\":0,\"jtPageSize\":100,\"ean13\":\"%s\",\"filtreEan13\":\"Contient\",\"isbnIsmnIssn\":\"\",\"titre\":\"\",\"auteur\":\"\",\"editeur\":\"\",\"filtreNumeroFascicule\":\"=\",\"numeroFascicule\":\"\",\"filtreDateCreation\":\"=\",\"dateCreationCase1\":\"\",\"dateCreationCase2\":\"\",\"listeEtatDemande\":[\"0\",\"1\",\"8\",\"4\",\"9\",\"11\",\"5\",\"6\",\"3\",\"10\",\"14\",\"13\"],\"listeTypeDemande\":[\"TYPE_LIVRE\",\"TYPE_LIVRESCOLAIRE\",\"TYPE_PARTITIONMUSICALE\",\"TYPE_PERIODIQUE\",\"TYPE_INCONNU\"]}",
				EAN13
		);
		HttpRequest request = HttpRequest.newBuilder(new URI(BASEURL + ENDPOINTS.GET_DEMANDES_FROM_EAN))
				.header("Content-Type", "application/json; charset=UTF-8")
				.POST(HttpRequest.BodyPublishers.ofString(dataRaw))
				.build();

		HttpResponse resp = client.send(request, HttpResponse.BodyHandlers.ofString());
		if(resp.statusCode() != 200) throw new Exception("Error Lors de la récupération des demandes pour l'EAN " + EAN13 + " : " + resp.statusCode());

		return resp.body().toString();
	}

	protected static int getPlatonIdFromCatalogue(HttpClient client, String EAN13) throws Exception {
		String dataRaw = String.format(
				"{\"listeTypeDemande\":[],\"listeGenre\":[],\"listePublicDestinataire\":[],\"listeClassementId\":[],\"listeFiltreFacet\":[],\"listeFiltreDynamique\":[{\"operateur\":null,\"field\":\"TITRE\",\"valeur\":\"\",\"expression\":\"TOUS\"},{\"operateur\":\"ET\",\"field\":\"EAN13\",\"valeur\":\"%s\",\"expression\":\"TOUS\"}],\"contientFichierEditeur\":false,\"contientFichierAdapte\":false,\"contientAdaptationDeclaree\":false,\"contientAdaptationEnCours\":false,\"listeFormatsFichiersAdaptes\":[],\"listeFormatsAdaptationsDeclarees\":[],\"uniquementPeriodiques\":false,\"jtStartIndex\":0,\"jtPageSize\":100}",
				EAN13
		);
		HttpRequest request = HttpRequest.newBuilder(new URI(BASEURL + ENDPOINTS.GET_ID_FROM_EAN))
				.header("Content-Type", "application/json; charset=UTF-8")
				.POST(HttpRequest.BodyPublishers.ofString(dataRaw))
				.build();

		HttpResponse resp = client.send(request, HttpResponse.BodyHandlers.ofString());
		if(resp.statusCode() != 200) throw new Exception("Error lors de la récupération de l'identifiant du titre " + EAN13 + " : " + resp.statusCode());

		String respBody = resp.body().toString();
		JsonParser parser = new JsonParser();
		Map<String, Object> result = (Map<String, Object>) parser.parseValue(respBody);
		if(result == null) throw new Exception("getPlatonIdFromCatalogue API KO");
		if(!result.containsKey("Result") || !"OK".equals(result.get("Result"))) throw new Exception("getPlatonIdFromCatalogue API KO");
		//Map<String, Object> data = (Map<String, Object>)result.get("data");
		//if(data == null) throw new Exception("getPlatonIdFromCatalogue API KO");
		//if(!data.containsKey("Result") || !"OK".equals(data.get("Result"))) throw new Exception("getPlatonIdFromCatalogue API KO");
		List<Map<String, Object>> records = (List<Map<String, Object>>) result.get("Records");
		if(records.size() == 0) throw new Exception("Aucune donnée disponible pour l'ean " + EAN13);
		Map<String, Object> first = records.get(0);
		if(first.containsKey("id")) return (int) first.get("id");
		else {
			throw new Exception("Erreur d'identifiant platon pour l'ean " + EAN13);
		}
	}

	protected static String getFichiersEditeursFromId(HttpClient client, int platonId) throws Exception {
		String dataRaw = String.format(
				"{\"jtStartIndex\":0,\"jtPageSize\":10,\"jtSorting\":\"format ASC,taille DESC\",\"idDocument\":\"%s\",\"idTitrePeriodique\":null}",
				platonId
		);
		HttpRequest request = HttpRequest.newBuilder(new URI(BASEURL + ENDPOINTS.GET_FICHIERS_EDITEUR))
				.header("Content-Type", "application/json; charset=UTF-8")
				.POST(HttpRequest.BodyPublishers.ofString(dataRaw))
				.build();

		HttpResponse resp = client.send(request, HttpResponse.BodyHandlers.ofString());
		if(resp.statusCode() != 200) throw new Exception("Une erreur s'est produite lors de la requête des fichiers éditeurs : " + resp.statusCode());
		JsonParser parser = new JsonParser();
		Map<String, Object> data = (Map<String, Object>) parser.parseValue(resp.body().toString());
		if(data == null) throw new Exception("ajaxGetRechercheAvanceeData API KO");
		if(!data.containsKey("Result") || !"OK".equals(data.get("Result"))) throw new Exception("ajaxGetRechercheAvanceeData API KO");
		List<Map<String, Object>> records = (List<Map<String, Object>>) data.get("Records");
		if(records.size() == 0) return "";
		StringBuilder filesTxt = new StringBuilder();
		for (Map<String, Object> v: records) {
			if(v.get("nomFichier") == null) continue;
			filesTxt.append(" - ").append(v.get("nomFichier"));
			if(v.get("tailleFichier") != null){
				int taille = Integer.parseInt(v.get("tailleFichier").toString());
				filesTxt
						.append(" (")
						.append(Math.round(taille / 1048.576) * 0.001) // Taille en MO aroundi a 3 chiffres apres la virgule
						.append("Mo)");
			}
			filesTxt.append("\n");
		}
		String files = filesTxt.toString();

		return files.isEmpty() ? "" : "Fichiers éditeurs :\n" + files;
	}

	protected static String getFichiersAdaptesFromId(HttpClient client, int platonId) throws Exception {
		String dataRaw = String.format(
				"{\"jtStartIndex\":0,\"jtPageSize\":10,\"jtSorting\":\"organisme ASC\",\"idDocument\":\"%s\"}",
				platonId
		);
		HttpRequest request = HttpRequest.newBuilder(new URI(BASEURL + ENDPOINTS.GET_FICHIERS_ADAPTES))
				.header("Content-Type", "application/json; charset=UTF-8")
				.POST(HttpRequest.BodyPublishers.ofString(dataRaw))
				.build();

		HttpResponse resp = client.send(request, HttpResponse.BodyHandlers.ofString());
		if(resp.statusCode() != 200) throw new Exception("Une erreur s'est produite lors de la requête des fichiers adaptés : " + resp.statusCode());
		JsonParser parser = new JsonParser();
		Map<String, Object> data = (Map<String, Object>) parser.parseValue(resp.body().toString());
		if(data == null) throw new Exception("ajaxGetFichiersAdaptesResponse API KO");
		if(!data.containsKey("Result") || !"OK".equals(data.get("Result"))) throw new Exception("ajaxGetFichiersAdaptesResponse API KO");
		List<Map<String, Object>> records = (List<Map<String, Object>>) data.get("Records");
		if(records.size() == 0) return "";
		StringBuilder filesTxt = new StringBuilder();
		for (Map<String, Object> v: records) {
			if(v.get("nomFichier") == null) continue;
			filesTxt.append(" - ").append(v.get("nomFichier"));
			if(v.get("tailleFichier") != null){
				int taille = Integer.parseInt(v.get("tailleFichier").toString());
				filesTxt
						.append(" (")
						.append(Math.round(taille / 1048.576) * 0.001) // Taille en MO aroundi a 3 chiffres apres la virgule
						.append("Mo)");
			}
			if(v.get("formatLibelle") != null){
				filesTxt.append(" ").append(v.get("formatLibelle"));
			}
			if(v.get("etatDemande") != null){
				Map<String, Object> etat = (Map<String, Object>) v.get("etatDemande");
				filesTxt.append(" (étatDemande=").append(etat.get("libelle") != null ?  etat.get("libelle").toString() : "inconnu").append(")");
			}
			if(v.get("pmeh") != null){
				Map<String, Object> pmeh = (Map<String, Object>) v.get("pmeh");
				if(pmeh.get("nom") != null){
					filesTxt.append(" par [").append(pmeh.get("nom")).append("]");
				}
			}
			filesTxt.append("\n");
		}
		String files = filesTxt.toString();

		return files.isEmpty() ? "" : "Fichiers adaptés :\n" + files;
	}
	protected static String getAdaptationsNonDeposeesFromId(HttpClient client, int platonId) throws Exception {
		String dataRaw = String.format(
				"{\"jtStartIndex\":0,\"jtPageSize\":10,\"jtSorting\":\"organisme ASC\",\"idDocument\":\"%s\",\"idTitrePeriodique\":null}",
				platonId
		);
		HttpRequest request = HttpRequest.newBuilder(new URI(BASEURL + ENDPOINTS.GET_ADAPTATIONS_NON_DEPOSEES))
				.header("Content-Type", "application/json; charset=UTF-8")
				.POST(HttpRequest.BodyPublishers.ofString(dataRaw))
				.build();

		HttpResponse resp = client.send(request, HttpResponse.BodyHandlers.ofString());
		if(resp.statusCode() != 200) throw new Exception("Une erreur s'est produite lors de la requête des adaptations non déposées : " + resp.statusCode());
		JsonParser parser = new JsonParser();
		Map<String, Object> data = (Map<String, Object>) parser.parseValue(resp.body().toString());
		if(data == null) throw new Exception("ajaxGetAdaptationsNonDeposeesResponse API KO");
		if(!data.containsKey("Result") || !"OK".equals(data.get("Result"))) throw new Exception("ajaxGetAdaptationsNonDeposeesResponse API KO");
		List<Map<String, Object>> records = (List<Map<String, Object>>) data.get("Records");
		if(records.size() == 0) return "";
		StringBuilder filesTxt = new StringBuilder();
		for (Map<String, Object> v: records) {
			if(v.get("nomFichier") == null) continue;
			filesTxt.append(" - ").append(v.get("nomFichier"));
			if(v.get("tailleFichier") != null){
				int taille = Integer.parseInt(v.get("tailleFichier").toString());
				filesTxt
						.append(" (")
						.append(Math.round(taille / 1048.576) * 0.001) // Taille en MO aroundi a 3 chiffres apres la virgule
						.append("Mo)");
			}
			if(v.get("formatLibelle") != null){
				filesTxt.append(" ").append(v.get("formatLibelle"));
			}
			if(v.get("etatDemande") != null){
				Map<String, Object> etat = (Map<String, Object>) v.get("etatDemande");
				filesTxt.append(" (étatDemande=").append(etat.get("libelle") != null ?  etat.get("libelle").toString() : "inconnu").append(")");
			}
			if(v.get("pmeh") != null){
				Map<String, Object> pmeh = (Map<String, Object>) v.get("pmeh");
				if(pmeh.get("nom") != null){
					filesTxt.append(" par [").append(pmeh.get("nom")).append("]");
				}
			}
			filesTxt.append("\n");
		}
		String files = filesTxt.toString();

		return files.isEmpty() ? "" : "Adaptations non déposées réalisées :\n" + files;
	}

	/**
	 * Récupère les adaptations en cours pour un document
	 * @param client
	 * @param platonId
	 * @return
	 * @throws Exception
	 */
	protected static String getAdaptationsEnCoursFromId(HttpClient client, int platonId) throws Exception {
		String dataRaw = String.format(
				"{\"jtStartIndex\":0,\"jtPageSize\":10,\"jtSorting\":\"organisme ASC\",\"idDocument\":\"%s\",\"idTitrePeriodique\":null}",
				platonId
		);
		HttpRequest request = HttpRequest.newBuilder(new URI(BASEURL + ENDPOINTS.GET_ADAPTATIONS_EN_COURS))
				.header("Content-Type", "application/json; charset=UTF-8")
				.POST(HttpRequest.BodyPublishers.ofString(dataRaw))
				.build();

		HttpResponse resp = client.send(request, HttpResponse.BodyHandlers.ofString());
		if(resp.statusCode() != 200) throw new Exception("Une erreur s'est produite lors de la requête des adaptations en cours : " + resp.statusCode());
		JsonParser parser = new JsonParser();
		Map<String, Object> data = (Map<String, Object>) parser.parseValue(resp.body().toString());
		if(data == null) throw new Exception("ajaxGetAdaptationsEnCoursResponse API KO");
		if(!data.containsKey("Result") || !"OK".equals(data.get("Result"))) throw new Exception("ajaxGetAdaptationsEnCoursResponse API KO");
		List<Map<String, Object>> records = (List<Map<String, Object>>) data.get("Records");
		if(records.size() == 0) return "";
		StringBuilder filesTxt = new StringBuilder();
		for (Map<String, Object> v: records) {
			if(v.get("nomFichier") == null) continue;
			filesTxt.append(" - ").append(v.get("nomFichier"));
			if(v.get("tailleFichier") != null){
				int taille = Integer.parseInt(v.get("tailleFichier").toString());
				filesTxt
						.append(" (")
						.append(Math.round(taille / 1048.576) * 0.001) // Taille en MO aroundi a 3 chiffres apres la virgule
						.append("Mo)");
			}
			if(v.get("formatLibelle") != null){
				filesTxt.append(" ").append(v.get("formatLibelle"));
			}
			if(v.get("etatDemande") != null){
				Map<String, Object> etat = (Map<String, Object>) v.get("etatDemande");
				filesTxt.append(" (étatDemande=").append(etat.get("libelle") != null ?  etat.get("libelle").toString() : "inconnu").append(")");
			}
			if(v.get("pmeh") != null){
				Map<String, Object> pmeh = (Map<String, Object>) v.get("pmeh");
				if(pmeh.get("nom") != null){
					filesTxt.append(" par [").append(pmeh.get("nom")).append("]");
				}
			}
			filesTxt.append("\n");
		}
		String files = filesTxt.toString();

		return files.isEmpty() ? "" : "Adaptations en cours :\n" + files;
	}



	/**
	 * Prépare une demande d'apatation a platon
	 * @param client
	 * @param ean13
	 * @return un document html
	 * @throws Exception
	 */
	protected static DemandePlaton createDemandeAPlaton(HttpClient client, String ean13) throws Exception {
		String dataRaw = String.format(
				"ean13=%s&isbn=&ismn=",
				ean13
		);
		HttpRequest request = HttpRequest.newBuilder(new URI(BASEURL + ENDPOINTS.CREATE_DEMANDE))
				.header("Content-Type", "application/x-www-form-urlencoded")
				.POST(HttpRequest.BodyPublishers.ofString(dataRaw))
				.build();

		HttpResponse resp = client.send(request, HttpResponse.BodyHandlers.ofString());
		if(resp.statusCode() != 200) throw new Exception("Une erreur s'est produite lors de la requête des adaptations en cours : " + resp.statusCode());
		String resultingDocument = resp.body().toString()
				.replaceAll("\\n|\\r", "")
				.replaceAll("\\s+|\\t+", " ");

		int formStart = resultingDocument.indexOf("id=\"saisie-demande-form\"");
		if(formStart == -1) throw new Exception("Une erreur s'est produite lors de la récupération du formulaire de demande : pas de formulaire détecter dans la réponse");
		int formEnd = resultingDocument.indexOf("</form>", formStart);
		if(formEnd == -1) throw new Exception("Une erreur s'est produite lors de la récupération du formulaire de demande : pas de fin de formulaire détecter dans la réponse");
		String formContent = resultingDocument.substring(formStart, formEnd);
		Matcher ean13Pattern = Pattern.compile("name=\"ean13\".*?value=\"([^\"]+)\"").matcher(formContent);
		Matcher isbnPattern = Pattern.compile("name=\"isbn\".*?value=\"([^\"]+)\"").matcher(formContent);
		Matcher originePattern = Pattern.compile("id=\"origine\".*?value=\"([^\"]+)\"").matcher(formContent);
		Matcher documentEnrichiPattern = Pattern.compile("id=\"documentEnrichi\".*?value=\"([^\"]+)\"").matcher(formContent);

		DemandePlaton result = new DemandePlaton();
		if(ean13Pattern.find()){
			result.ean13 = ean13Pattern.group(1);
		}
		if(isbnPattern.find()){
			result.isbn = isbnPattern.group(1);
		}
		if(originePattern.find()){
			result.origine = originePattern.group(1);
		}
		if(documentEnrichiPattern.find()){
			result.documentEnrichi = documentEnrichiPattern.group(1);
		}

		if(!result.ean13.equals(ean13)) throw new Exception("L'EAN13 du formulaire ne correspond pas à l'EAN13 remonté dans le formulaire de demande");
		result.commentaire = "Demande faite par AVH Studio-Paon le "
				+ new SimpleDateFormat("yyyy/MM/dd HH:mm:ss.SSS").format(new Date());
		return result;
	}


	/**
	 * Confirme une demande d'adaptation a platon
	 * @param client
	 * @param dataForm
	 * @return un document html
	 * @throws Exception
	 */
	protected static void saveDemandeAPlaton(HttpClient client, DemandePlaton dataForm) throws Exception {

		HttpRequest request = HttpRequest.newBuilder(new URI(BASEURL + ENDPOINTS.SAVE_DEMANDE))
				.header("Content-Type", "application/x-www-form-urlencoded")
				.POST(HttpRequest.BodyPublishers.ofString(dataForm.toUrlParams()))
				.build();

		HttpResponse resp = client.send(request, HttpResponse.BodyHandlers.ofString());
		if(resp.statusCode() < 200 || resp.statusCode() > 299) throw new Exception("Une erreur s'est produite lors de la validation de la demande : " + resp.statusCode());
	}


	/**
	 * Vérifie si une demande a déjà été faite pour un EAN13
	 * @param response
	 * @throws Exception
	 */
	protected static void checkDemandeBeforeDemandeAPlaton(Map<String, Object> response) throws Exception {
		if(response == null) throw new Exception("check demande A Platon API KO");
		if(!response.containsKey("Result") || !"OK".equals(response.get("Result"))) throw new Exception("check demande A Platon API KO");
		List<Map<String, Object>> records = (List<Map<String, Object>>) response.get("Records");
		if(records.size() > 1) throw new Exception("Plus d'un enregistrement de demande trouvé sur platon");
		if(records.size() == 1){
			Map<String, Object> record = records.get(0);
			Map<String, Object> historique =  record != null ? (Map<String, Object>) record.get("historique") : null;
			Map<String, Object> dernierHistorique = historique != null ? (Map<String, Object>) historique.get("dernierHistorique") : null;
			Map<String, Object> etat = dernierHistorique != null ? (Map<String, Object>) dernierHistorique.get("etat") : null;
			String libelle = etat != null ? (String) etat.get("libelle") : null;
			if(libelle != null) throw new Exception("Demande déja faite - dernier état de l'historique : " + libelle);
			else throw new Exception("Demande déja faite mais sans historique disponible");
		}
	}

	/**
	 * Vérifie si une demande a bien été faite pour un EAN13
	 * @param response
	 * @return
	 * @throws Exception
	 */
	protected static String checkDemandeAfterDemandeAPlaton(Map<String, Object> response) throws Exception {
		if(response == null) throw new Exception("check demande A Platon API KO");
		if(!response.containsKey("Result") || !"OK".equals(response.get("Result"))) throw new Exception("check demande A Platon API KO");
		List<Map<String, Object>> records = (List<Map<String, Object>>) response.get("Records");
		if(records.size() > 1) throw new Exception("Demande faite mais la verification de la demande par l'API Platon a échouée (tooManyRecords)");
		if(records.size() == 1){
			Map<String, Object> record = records.get(0);
			Map<String, Object> historique =  record != null ? (Map<String, Object>) record.get("historique") : null;
			Map<String, Object> dernierHistorique = historique != null ? (Map<String, Object>) historique.get("dernierHistorique") : null;
			Map<String, Object> etat = dernierHistorique != null ? (Map<String, Object>) dernierHistorique.get("etat") : null;
			String libelle = etat != null ? (String) etat.get("libelle") : null;
			if(libelle != null) return "demande faite avec l'état : " + libelle;
			else throw new Exception("Demande faite avec cependant aucun état dans l'historique, la demande a du échouée");
		}
		throw new Exception("la demande semble ne pas avoir aboutie, aucun retour d'état (verifier le formulaire sur le site platon)");
	}

	/**
	 * Lance une demande d'adaptation à platon
	 * (Portage du code javascript)
	 * @param user
	 * @param password
	 * @param ean13
	 * @return
	 */
	public static String runDemandeAPlaton(String user, String password, String ean13){
		try{
			HttpClient platon = logOnPlaton(user,password);
			JsonParser parser = new JsonParser();
			checkDemandeBeforeDemandeAPlaton((Map<String, Object>) parser.parseValue(getDemandesForEAN(platon, ean13)));
			DemandePlaton dataForm = createDemandeAPlaton(platon, ean13);
			saveDemandeAPlaton(platon, dataForm);
			return ResponsePlaton(
					NotificationType.SUCCESS,
					checkDemandeAfterDemandeAPlaton((Map<String, Object>) parser.parseValue(getDemandesForEAN(platon, ean13)))
			);
		} catch (Exception e) {
			return ResponsePlaton(NotificationType.ERROR, e.getMessage());

		}
	}

	public static String getPlatonCatalogueInfo(String user, String password, String ean13){
		try{
			HttpClient platon = logOnPlaton(user,password);
			JsonParser parser = new JsonParser();
			int id = getPlatonIdFromCatalogue(platon, ean13);
			String s1 = "";
			try{
				s1 = getFichiersEditeursFromId(platon, id);
			} catch (Exception e) {
				s1 = e.getMessage();
			}

			String s2 = "";
			try{
				s2 = getFichiersAdaptesFromId(platon, id);
			} catch (Exception e) {
				s2 = e.getMessage();
			}

			String s3 = "";
			try{
				s3 = getAdaptationsNonDeposeesFromId(platon, id);
			} catch (Exception e) {
				s3 = e.getMessage();
			}

			String s4 = "";
			try{
				s4 = getAdaptationsEnCoursFromId(platon, id);
			} catch (Exception e) {
				s4 = e.getMessage();
			}
			String sf = "";
			if(s1 != null && !s1.isEmpty()) sf += s1 + "\n";
			if(s2 != null && !s2.isEmpty()) sf += s2 + "\n";
			if(s3 != null && !s3.isEmpty()) sf += s3 + "\n";
			if(s4 != null && !s4.isEmpty()) sf += s4 + "\n";
			return ResponsePlaton(NotificationType.SUCCESS, sf.length() > 0 ? sf : "Aucune information trouvée");
		} catch (Exception e) {
			return ResponsePlaton(NotificationType.ERROR, e.getMessage());
		}
	}

}
