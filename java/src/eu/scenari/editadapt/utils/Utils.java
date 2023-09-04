package eu.scenari.editadapt.utils;

import java.text.Normalizer;
import java.text.SimpleDateFormat;
import java.time.Duration;
import java.util.Calendar;
import java.util.LinkedList;
import java.util.Locale;
import java.util.regex.Pattern;

import org.w3c.dom.Node;

import eu.scenari.xml.xpath.axes.AttributeIterator;
import eu.scenari.xml.xpath.axes.LocPathIterator;
import eu.scenari.xml.xpath.objects.XNumber;

public class Utils {
	static protected final Pattern doubleSpace = Pattern.compile("\\p{Z}(\\p{Z})+");

	static protected final Pattern comma = Pattern.compile("\\p{Z},");

	static protected final Pattern specialDashes = Pattern.compile("[‑]");

	static protected final Pattern specialSimpleSpaces = Pattern.compile("[          \\u200B]+");

	static protected final Pattern specialNbsp = Pattern.compile("[  ]+");

	static protected final Pattern quotation = Pattern.compile("'\\p{Z}([«\"])");

	static protected final Pattern punct = Pattern.compile("(?<=[!?:;])\\p{Z}+([!;:?])");

	static protected final Pattern nbsp = Pattern.compile("\\p{Z}([!?:;])");

	static protected final Pattern normlzBrailleTxtBfrSpc = Pattern.compile("(?: | )(:|;|\\?|!|…|»|,|>)");

	static protected final Pattern normlzBrailleTxtAftrSpc = Pattern.compile("(«|<)(?: | )");

	static protected final Pattern normlzBrailleCurrency = Pattern.compile("((?:\\d|\\.|,)+)(?: | )(\\$|£|€|%)");

	static protected final Pattern normlzBrailleHour = Pattern.compile("(\\d\\d?)(?:(?: | ?)(h|H)(?: | )?)(\\d\\d)");

	static protected final Pattern noXhtml1Id = Pattern.compile("[^a-zA-Z0-9_\\-]+");
	static protected final Pattern spaces = Pattern.compile("\\s+");
	static protected final Pattern empty = Pattern.compile("^[\\s ]*$");


	// backup de regex fonctionnelle avant simplification
	//"((☂[^☂]+☂)((\\p{Z}|(☂[^☂]+☂))*(☂[^☂]+☂))?)(\\p{Z}*([:;\\.,?!)»”\\]…]((\\p{Z}|[:;\\.,?!)»”\\]…])*[:;\\.,?!)»”\\]…])?))"
	static protected final Pattern notesWithClosingPunctuations = Pattern.compile(
			"((☂[^☂]+☂)(\\p{Z}*(☂[^☂]+☂))*)(\\p{Z}*([:;\\.,?!)»”\\]…](\\p{Z}*[:;\\.,?!)»”\\]…])*))"

	);
	static protected final Pattern deleteNoteMarker = Pattern.compile("☂");

	//static protected final Pattern deleteChars = Pattern.compile("\u2028");
	static protected SimpleDateFormat dateformat = new SimpleDateFormat("yyyy-MM-dd");

	public static String normalizeString(String str, boolean toUpperCase) {
		str = specialSimpleSpaces.matcher(str).replaceAll(" ");
		str = specialNbsp.matcher(str).replaceAll(" ");
		str = specialDashes.matcher(str).replaceAll("-");
		str = doubleSpace.matcher(str).replaceAll("$1");
		str = comma.matcher(str).replaceAll(",");
		str = quotation.matcher(str).replaceAll("'$1");
		str = punct.matcher(str).replaceAll("$1");
		str = nbsp.matcher(str).replaceAll(" $1");
		//str = deleteChars.matcher(str).replaceAll("");
		return toUpperCase ? str.toUpperCase(Locale.FRANCE) : str;
	}

	public static String isEmptyStr(String str) {
		return empty.matcher(str).matches() ? "true" : "false";
	}

	public static String postOdTxt(String str) {
		// TODO: Normalisation des espaces pour le braille (remplacement des espaces spéciaux par des normaux)
		// aussi possible
		String tmp = normlzBrailleTxtAftrSpc.matcher(str).replaceAll("$1");
		tmp = normlzBrailleTxtBfrSpc.matcher(tmp).replaceAll("$1");
		tmp = normlzBrailleCurrency.matcher(tmp).replaceAll("$1$2");
		return normlzBrailleHour.matcher(tmp).replaceAll("$1$2$3");
	}

	/**
	 * Déplacement des notes situé immédiatement avant une ponctuation fermante.
	 *
	 * @param str contenu d'un paragraphe de l'odt contenant des balises <text:note/>
	 * @return le paragraphe modifié pour que les notes situés avant les ponctuations soit situés après.
	 */
	public static String moveNote(String str) {
		String tmp = notesWithClosingPunctuations.matcher(str)
				.replaceAll("$5$1");
		return deleteNoteMarker.matcher(tmp).replaceAll("");
	}

	public static String getDateStr() {
		return dateformat.format(Calendar.getInstance().getTime());
	}

	protected static String escape(String str) {
		StringBuffer out = new StringBuffer(str.length());
		for (int i = 0; i < str.length(); i++) {
			char c = str.charAt(i);
			switch (c) {
				case '+':
					out.append('.');
					break;
				case '/':
					out.append('-');
					break;
				case '=':
					out.append('_');
					break;
				default:
					out.append(c);
					break;
			}
		}
		return out.toString();
	}

	public static String formatSumDuration(LinkedList list, int until, String format) {
		Duration duration = Duration.ofMillis(0);
		for (int i = 0; i < until; i++)
			duration = duration.plus((Duration) list.get(i));
		return String.format(format, duration.toHoursPart() + 24 * duration.toDaysPart(), duration.toMinutesPart(), duration.toSecondsPart(), duration.toMillisPart());
	}

	public static String formatSumDuration(LinkedList list, String format) {
		Duration duration = Duration.ofMillis(0);
		for (int i = 0; i < list.size(); i++)
			duration = duration.plus((Duration) list.get(i));
		return String.format(format, duration.toHoursPart() + 24 * duration.toDaysPart(), duration.toMinutesPart(), duration.toSecondsPart(), duration.toMillisPart());
	}

	public static String formatDuration(LinkedList list, int until, String format) {
		if (until >= list.size()) return "Out of boundary";
		Duration duration = (Duration) list.get(until);
		return String.format(format, duration.toHoursPart() + 24 * duration.toDaysPart(), duration.toMinutesPart(), duration.toSecondsPart(), duration.toMillisPart());
	}

	/**
	 * Exploité dans le modèle pour constuire les IDs des divs.
	 * La taille max est limitée à 45 caractères dut à des restrictions de certains vieux parser Daisy2
	 */
	public static String escapeXhtmlId(String id) {
		String escapedId = noXhtml1Id.matcher(spaces.matcher(Normalizer.normalize(id, Normalizer.Form.NFD)).replaceAll("_")).replaceAll("");
		return escapedId.length() > 45 ? escapedId.substring(0, 45) : escapedId;
	}

	public static XNumber sentencesIndex(Object xnodes, Object xid) {
		int count = 1;
		Node nodeid = ((AttributeIterator) xid).nextNode();
		String id = nodeid.getNodeValue();
		Node node = ((LocPathIterator) xnodes).nextNode();
		while (node != null) {
			String curNodeId = node.getAttributes().getNamedItem("id").getNodeValue();
			if (curNodeId.equals(id)) return new XNumber(count);
			else count++;
			node = ((LocPathIterator) xnodes).nextNode();
		}
		return null;
	}

	public static void main(String[] args) {

		/*
		LinkedList<Duration> list = new LinkedList();
		list.add(Duration.parse("PT42522.123S"));
		list.add(Duration.parse("PT42522.123S"));
		list.add(Duration.parse("PT42522.123S"));
		list.add(Duration.parse("PT42522.123S"));
		list.add(Duration.parse("PT42522.123S"));
		list.add(Duration.parse("PT42522.123S"));
		list.add(Duration.parse("PT42522.123S"));
		list.add(Duration.parse("PT42522.123S"));
		list.add(Duration.parse("PT42522.123S"));
		list.add(Duration.parse("PT42522.123S"));
		System.out.println(formatDuration(list, 3, "%02d:%02d:%02d.%03d"));
		System.out.println(formatSumDuration(list, 3, "%02d:%02d:%02d.%03d"));
		System.out.println(formatSumDuration(list, "%02d:%02d:%02d"));
		*/
		//System.out.println(postOdTxt("Test : de < reformatage > de contenu 1 h 12 et 1H 12 ou 1.12, $"));
		//Formatter format = new Formatter();
		//System.out.println(format.format("%03.0f", 2.0));

		//System.out.println("test".substring(0, 22));

		System.out.println();
	}

}
