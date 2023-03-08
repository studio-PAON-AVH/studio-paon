package eu.scenari.editadapt.ant;

import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.Map;

import javax.xml.parsers.SAXParser;
import javax.xml.parsers.SAXParserFactory;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Task;
import org.xml.sax.Attributes;
import org.xml.sax.SAXException;
import org.xml.sax.helpers.AttributesImpl;
import org.xml.sax.helpers.DefaultHandler;

import eu.scenari.commons.log.LogMgr;
import eu.scenari.commons.log.TraceMgr;
import eu.scenari.commons.log.TracePoint;
import eu.scenari.xml.serializer.xerces.impl.XMLSerializer;


/**
 * Task ant qui permet de sortir les notes des tags p et line en prenant soin de refermer puis réouvrir d'éventuelles stack de balisage inline avant et après.
 */
public class SplitOnD3NoteTask extends Task {
	public static final TracePoint sTrace = TraceMgr.register(SplitOnD3NoteTask.class.getName() + ".sTrace", "Traces SplitOnD3NoteTask.");
	protected File inFile;
	protected File outFile;

	public void setOutFile(File outFile) {
		this.outFile = outFile;
	}

	public void setInFile(File inFile) {
		this.inFile = inFile;
	}

	@Override
	public void execute() throws BuildException {
		try (FileWriter writer = new FileWriter(outFile);
				 FileReader reader = new FileReader(inFile)) {
			if (sTrace.isEnabled()) LogMgr.publishTrace("[SplitOnD3NoteTask] START: transform %s to %s", inFile.getAbsolutePath(), outFile.toString());
			XMLSerializer xml = new XMLSerializer(writer, XMLSerializer.XML_OUTPUT);
			SAXParser parser = SAXParserFactory.newInstance().newSAXParser();
			DefaultHandler handler = new SplitOnD3NoteTaskSaxHandler(xml);
			parser.parse(inFile, handler);
		} catch (BuildException e) {
			throw e;
		} catch (Exception e) {
			throw LogMgr.addMessage(new BuildException(e, getLocation()), LogMgr.getMessage(e));
		}
	}

	protected class SplitOnD3NoteTaskSaxHandler extends DefaultHandler {

		protected LinkedList<Map<String, Object>> elmntStack = new LinkedList<>();

		protected XMLSerializer xml;

		protected boolean inFlow = false;

		protected boolean inNote = false;

		SplitOnD3NoteTaskSaxHandler(XMLSerializer xml) {
			this.xml = xml;
		}

		@Override
		public void startDocument() throws SAXException {
			if (sTrace.isEnabled()) LogMgr.publishTrace("[SplitOnD3NoteTask] Start document - ", outFile.getAbsolutePath());
			xml.startDocument();
		}

		protected boolean isInFlow(String uri, String localName, String qName) {
			if (qName.startsWith("p") || qName.equals("line")) return true;
			return false;
		}

		@Override
		public void startElement(String uri, String localName, String qName, Attributes attributes) throws SAXException {
			if (sTrace.isEnabled()) LogMgr.publishTrace("[SplitOnD3NoteTask] Start element %s", qName);

			if (qName.equals("note") && inFlow == true) {
				if (sTrace.isEnabled()) LogMgr.publishTrace("[SplitOnD3NoteTask] note found. Close stack");
				inNote = true;
				inFlow = false;

				//close stack
				for (Iterator<Map<String, Object>> it = elmntStack.descendingIterator(); it.hasNext(); ) {
					Map<String, Object> element = it.next();
					if (sTrace.isEnabled()) LogMgr.publishTrace("[SplitOnD3NoteTask] close in stack - %s", element.get("qName"));
					xml.endElement((String) element.get("uri"), (String) element.get("localName"), (String) element.get("qName"));
				}
			} else if ((qName.equals("p") || qName.equals("line")) && !inNote) {
				inFlow = true;
			}

			if (inFlow) {
				if (sTrace.isEnabled()) LogMgr.publishTrace("[SplitOnD3NoteTask] 'inFlow' is ON - element %s added to stack", qName);
				Map<String, Object> element = new HashMap<>(4);
				element.put("uri", uri);
				element.put("localName", localName);
				element.put("qName", qName);
				Map<String, String> elementAtts = new HashMap<>(attributes.getLength());
				for (int i = 0; i < attributes.getLength(); i++) {
					elementAtts.put(attributes.getQName(i), attributes.getValue(i));
				}
				element.put("attributes", elementAtts);
				elmntStack.add(element);
			}

			xml.startElement(uri, localName, qName, attributes);

		}

		@Override
		public void characters(char[] ch, int start, int length) throws SAXException {
			xml.characters(ch, start, length);
		}

		@Override
		public void endElement(String uri, String localName, String qName) throws SAXException {
			if (sTrace.isEnabled()) LogMgr.publishTrace("[SplitOnD3NoteTask] End element %s", qName);

			xml.endElement(uri, localName, qName);

			if (qName.equals("note")) {
				if (sTrace.isEnabled()) LogMgr.publishTrace("[SplitOnD3NoteTask] Note is cloed. Reopen stack");

				for (Map<String, Object> element : elmntStack) {
					if (sTrace.isEnabled()) LogMgr.publishTrace("[SplitSentencesBySpanTask] open in stack %s", element.get("qName"));
					AttributesImpl attributes = new AttributesImpl();
					Map<String, String> elementAtts = (Map<String, String>) element.get("attributes");
					for (String key : elementAtts.keySet()) {
						attributes.addAttribute(null, "", key, "string", elementAtts.get(key));
					}
					xml.startElement((String) element.get("uri"), (String) element.get("localName"), (String) element.get("qName"), attributes);
				}
				inNote = false;
				inFlow = true;
			} else if ((qName.equals("p") || qName.equals("line")) && !inNote) {
				inFlow = false;
			}

		}

		@Override
		public void endDocument() throws SAXException {
			if (sTrace.isEnabled()) LogMgr.publishTrace("[SplitOnD3NoteTask] End document - ", outFile.getAbsolutePath());
			xml.endDocument();
		}

	}
}

