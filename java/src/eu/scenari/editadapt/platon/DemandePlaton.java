package eu.scenari.editadapt.platon;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

/**
 * Classe de gestion des demandes d'adaptation à platon
 */
public class DemandePlaton {
    public String ean13;
    public String isbn;
    public String origine;
    public String documentEnrichi;
    public String commentaire;
    public DemandePlaton(){
        this.ean13 = "";
        this.isbn = "";
        this.origine = "";
        this.documentEnrichi = "";
        this.commentaire = "";
    };
    public DemandePlaton(String ean13, String isbn, String origine, String documentEnrichi, String commentaire) {
        this.ean13 = ean13;
        this.isbn = isbn;
        this.origine = origine;
        this.documentEnrichi = documentEnrichi;
        this.commentaire = commentaire;
    }

    public String toUrlParams(){
        return String.format(
                "ean13=%s&isbn=%s&origine=%s&documentEnrichi=%s&commentaire=%s",
                URLEncoder.encode(ean13, StandardCharsets.UTF_8),
                URLEncoder.encode(isbn, StandardCharsets.UTF_8),
                URLEncoder.encode(origine, StandardCharsets.UTF_8),
                URLEncoder.encode(documentEnrichi, StandardCharsets.UTF_8),
                URLEncoder.encode(commentaire, StandardCharsets.UTF_8)
        );
    }
}
