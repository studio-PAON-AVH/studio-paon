package eu.scenari.editadapt.utils;

import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.xml.sax.Attributes;

import com.scenari.m.co.donnee.IDataResolver;

import eu.scenari.commons.log.LogMgr;
import eu.scenari.commons.stream.StreamUtils;
import eu.scenari.commons.util.lang.IAdaptable;
import eu.scenari.commons.util.xml.IFragmentSaxHandler;
import eu.scenari.store.cid.ICidMetasProvider;
import eu.scenari.store.cid.ICidTask;
import eu.scenari.store.service.storesquare.IStoreStep;
import eu.scenari.store.service.storesquare.StoreSquareTask;
import eu.scenari.store.service.storesquare.StoreStepLoaderBase;
import eu.scenari.store.service.storesquare.SvcStoreSquare;
import eu.scenari.urltree.storesquare.IPersistentMetas;

/**
 * Ajoute les entités custom
 */
public class ImportLGUtilsStep implements IStoreStep {
	protected static Pattern doctype = Pattern.compile("\\A[^\\x00-\\x7F]*((?:(?:<\\?(?:(?!\\?>).)*\\?>)|\\s|(?:\\<!--(?:(?!-->).)*-->))*)[^\\x00-\\x7F]*(?:<!DOCTYPE[^>]+(?:\\[[^\\]]*])?>)?((?:(?:<\\?(?:(?!\\?>).)*\\?>)|\\s|(?:<!--(?:(?!-->).)*-->))*)[^\\x00-\\x7F]*<(livre|dtbook)");

	protected static Pattern extractDoctype = Pattern.compile("<!DOCTYPE ([^\\[>]+)(\\[.*\\])?\\s*>");

	protected static String entities = "$1<!DOCTYPE $3[\n" + "<!ENTITY laquo  \"«\" >\n" + "<!ENTITY raquo  \"»\" >\n" + "<!ENTITY lsquo  \"‘\" >\n" + "<!ENTITY rsquo  \"’\" >\n" + "<!ENTITY ldquo  \"“\" >\n" + "<!ENTITY rdquo  \"”\" >\n"
			+ "<!ENTITY lsquor  \"‚\" >\n" + "<!ENTITY rsquor  \"‛\" >\n" + "<!ENTITY ndash  \"–\" >\n" + "<!ENTITY mdash  \"—\" >\n" + "<!ENTITY euro  \"€\" >\n" + "<!ENTITY nbsp  \" \" >\n" + "<!ENTITY hellip  \"…\" >\n" + "<!ENTITY thinsp  \" \" >\n"
			+ "<!ENTITY Aacgr  \"&#x0386;\" >\n" + "<!ENTITY aacgr  \"&#x03AC;\" >\n" + "<!ENTITY Aacute  \"&#x00C1;\" >\n" + "<!ENTITY aacute  \"&#x00E1;\" >\n" + "<!ENTITY Abreve  \"&#x0102;\" >\n" + "<!ENTITY abreve  \"&#x0103;\" >\n"
			+ "<!ENTITY Acirc  \"&#x00C2;\" >\n" + "<!ENTITY acirc  \"&#x00E2;\" >\n" + "<!ENTITY acute  \"&#x00B4;\" >\n" + "<!ENTITY Acy  \"&#x0410;\" >\n" + "<!ENTITY acy  \"&#x0430;\" >\n" + "<!ENTITY AElig  \"&#x00C6;\" >\n"
			+ "<!ENTITY aelig  \"&#x00E6;\" >\n" + "<!ENTITY Agr  \"&#x0391;\" >\n" + "<!ENTITY agr  \"&#x03B1;\" >\n" + "<!ENTITY Agrave  \"&#x00C0;\" >\n" + "<!ENTITY agrave  \"&#x00E0;\" >\n" + "<!ENTITY aleph  \"&#x2135;\" >\n"
			+ "<!ENTITY alpha  \"&#x03B1;\" >\n" + "<!ENTITY Amacr  \"&#x0100;\" >\n" + "<!ENTITY amacr  \"&#x0101;\" >\n" + "<!ENTITY amp  \"&#38;#38;\" >\n" + "<!ENTITY and  \"&#x2227;\" >\n" + "<!ENTITY ang90  \"&#x221F;\" >\n"
			+ "<!ENTITY angsph  \"&#x2222;\" >\n" + "<!ENTITY angst  \"&#x212B;\" >\n" + "<!ENTITY Aogon  \"&#x0104;\" >\n" + "<!ENTITY aogon  \"&#x0105;\" >\n" + "<!ENTITY ap  \"&#x2248;\" >\n" + "<!ENTITY apos  \"&#8217;\" >\n"
			+ "<!ENTITY Aring  \"&#x00C5;\" >\n" + "<!ENTITY aring  \"&#x00E5;\" >\n" + "<!ENTITY ast  \"&#x002A;\" >\n" + "<!ENTITY Atilde  \"&#x00C3;\" >\n" + "<!ENTITY atilde  \"&#x00E3;\" >\n" + "<!ENTITY Auml  \"&#x00C4;\" >\n"
			+ "<!ENTITY auml  \"&#x00E4;\" >\n" + "<!ENTITY b.alpha  \"&#x03B1;\" >\n" + "<!ENTITY b.beta  \"&#x03B2;\" >\n" + "<!ENTITY b.chi  \"&#x03C7;\" >\n" + "<!ENTITY b.Delta  \"&#x0394;\" >\n" + "<!ENTITY b.delta  \"&#x03B4;\" >\n"
			+ "<!ENTITY b.epsi  \"&#x03B5;\" >\n" + "<!ENTITY b.epsis  \"&#x03B5;\" >\n" + "<!ENTITY b.epsiv  \"&#x03B5;\" >\n" + "<!ENTITY b.eta  \"&#x03B7;\" >\n" + "<!ENTITY b.Gamma  \"&#x0393;\" >\n" + "<!ENTITY b.gamma  \"&#x03B3;\" >\n"
			+ "<!ENTITY b.gammad  \"&#x03DC;\" >\n" + "<!ENTITY b.iota  \"&#x03B9;\" >\n" + "<!ENTITY b.kappa  \"&#x03BA;\" >\n" + "<!ENTITY b.kappav  \"&#x03F0;\" >\n" + "<!ENTITY b.Lambda  \"&#x039B;\" >\n" + "<!ENTITY b.lambda  \"&#x03BB;\" >\n"
			+ "<!ENTITY b.mu  \"&#x03BC;\" >\n" + "<!ENTITY b.nu  \"&#x03BD;\" >\n" + "<!ENTITY b.Omega  \"&#x03A9;\" >\n" + "<!ENTITY b.omega  \"&#x03C9;\" >\n" + "<!ENTITY b.Phi  \"&#x03A6;\" >\n" + "<!ENTITY b.phis  \"&#x03C6;\" >\n"
			+ "<!ENTITY b.phiv  \"&#x03D5;\" >\n" + "<!ENTITY b.Pi  \"&#x03A0;\" >\n" + "<!ENTITY b.pi  \"&#x03C0;\" >\n" + "<!ENTITY b.piv  \"&#x03D6;\" >\n" + "<!ENTITY b.Psi  \"&#x03A8;\" >\n" + "<!ENTITY b.psi  \"&#x03C8;\" >\n"
			+ "<!ENTITY b.rho  \"&#x03C1;\" >\n" + "<!ENTITY b.rhov  \"&#x03F1;\" >\n" + "<!ENTITY b.Sigma  \"&#x03A3;\" >\n" + "<!ENTITY b.sigma  \"&#x03C3;\" >\n" + "<!ENTITY b.sigmav  \"&#x03C2;\" >\n" + "<!ENTITY b.tau  \"&#x03C4;\" >\n"
			+ "<!ENTITY b.Theta  \"&#x0398;\" >\n" + "<!ENTITY b.thetas  \"&#x03B8;\" >\n" + "<!ENTITY b.thetav  \"&#x03D1;\" >\n" + "<!ENTITY b.upsi  \"&#x03C5;\" >\n" + "<!ENTITY b.Upsi  \"&#x03D2;\" >\n" + "<!ENTITY b.Xi  \"&#x039E;\" >\n"
			+ "<!ENTITY b.xi  \"&#x03BE;\" >\n" + "<!ENTITY b.zeta  \"&#x03B6;\" >\n" + "<!ENTITY Bcy  \"&#x0411;\" >\n" + "<!ENTITY bcy  \"&#x0431;\" >\n" + "<!ENTITY bdquo  \"&#x201E;\" >\n" + "<!ENTITY becaus  \"&#x2235;\" >\n"
			+ "<!ENTITY bernou  \"&#x212C;\" >\n" + "<!ENTITY beta  \"&#x03B2;\" >\n" + "<!ENTITY Bgr  \"&#x0392;\" >\n" + "<!ENTITY bgr  \"&#x03B2;\" >\n" + "<!ENTITY blank  \"&#x2423;\" >\n" + "<!ENTITY blk12  \"&#x2592;\" >\n"
			+ "<!ENTITY blk14  \"&#x2591;\" >\n" + "<!ENTITY blk34  \"&#x2593;\" >\n" + "<!ENTITY block  \"&#x2588;\" >\n" + "<!ENTITY bottom  \"&#x22A5;\" >\n" + "<!ENTITY breve  \"&#x02D8;\" >\n" + "<!ENTITY brvbar  \"&#x00A6;\" >\n"
			+ "<!ENTITY bsol  \"&#x005C;\" >\n" + "<!ENTITY bull  \"&#x2022;\" >\n" + "<!ENTITY Cacute  \"&#x0106;\" >\n" + "<!ENTITY cacute  \"&#x0107;\" >\n" + "<!ENTITY cap  \"&#x2229;\" >\n" + "<!ENTITY caret  \"&#x2041;\" >\n"
			+ "<!ENTITY caron  \"&#x02C7;\" >\n" + "<!ENTITY Ccaron  \"&#x010C;\" >\n" + "<!ENTITY ccaron  \"&#x010D;\" >\n" + "<!ENTITY Ccedil  \"&#x00C7;\" >\n" + "<!ENTITY ccedil  \"&#x00E7;\" >\n" + "<!ENTITY Ccirc  \"&#x0108;\" >\n"
			+ "<!ENTITY ccirc  \"&#x0109;\" >\n" + "<!ENTITY Cdot  \"&#x010A;\" >\n" + "<!ENTITY cdot  \"&#x010B;\" >\n" + "<!ENTITY cedil  \"&#x00B8;\" >\n" + "<!ENTITY cent  \"&#x00A2;\" >\n" + "<!ENTITY CHcy  \"&#x0427;\" >\n"
			+ "<!ENTITY chcy  \"&#x0447;\" >\n" + "<!ENTITY check  \"&#x2713;\" >\n" + "<!ENTITY chi  \"&#x03C7;\" >\n" + "<!ENTITY cir  \"&#x25CB;\" >\n" + "<!ENTITY circ  \"&#x005E;\" >\n" + "<!ENTITY clubs  \"&#x2663;\" >\n"
			+ "<!ENTITY colon  \"&#x003A;\" >\n" + "<!ENTITY comma  \"&#x002C;\" >\n" + "<!ENTITY commat  \"&#x0040;\" >\n" + "<!ENTITY compfn  \"&#x2218;\" >\n" + "<!ENTITY cong  \"&#x2245;\" >\n" + "<!ENTITY conint  \"&#x222E;\" >\n"
			+ "<!ENTITY copy  \"&#x00A9;\" >\n" + "<!ENTITY copyright  \"©&#8201;\" >\n" + "<!ENTITY copysr  \"&#x2117;\" >\n" + "<!ENTITY cross  \"&#x2717;\" >\n" + "<!ENTITY cup  \"&#x222A;\" >\n" + "<!ENTITY curren  \"&#x00A4;\" >\n"
			+ "<!ENTITY dagger  \"&#x2020;\" >\n" + "<!ENTITY Dagger  \"&#x2021;\" >\n" + "<!ENTITY darr  \"&#x2193;\" >\n" + "<!ENTITY dash  \"&#x2010;\" >\n" + "<!ENTITY dblac  \"&#x02DD;\" >\n" + "<!ENTITY Dcaron  \"&#x010E;\" >\n"
			+ "<!ENTITY dcaron  \"&#x010F;\" >\n" + "<!ENTITY Dcy  \"&#x0414;\" >\n" + "<!ENTITY dcy  \"&#x0434;\" >\n" + "<!ENTITY deg  \"&#x00B0;\" >\n" + "<!ENTITY Delta  \"&#x0394;\" >\n" + "<!ENTITY delta  \"&#x03B4;\" >\n"
			+ "<!ENTITY Dgr  \"&#x0394;\" >\n" + "<!ENTITY dgr  \"&#x03B4;\" >\n" + "<!ENTITY diams  \"&#x2666;\" >\n" + "<!ENTITY die  \"&#x00A8;\" >\n" + "<!ENTITY divide  \"&#x00F7;\" >\n" + "<!ENTITY DJcy  \"&#x0402;\" >\n"
			+ "<!ENTITY djcy  \"&#x0452;\" >\n" + "<!ENTITY dlcrop  \"&#x230D;\" >\n" + "<!ENTITY dollar  \"&#x0024;\" >\n" + "<!ENTITY Dot  \"&#x00A8;\" >\n" + "<!ENTITY dot  \"&#x02D9;\" >\n" + "<!ENTITY DotDot  \"&#x20DC;\" >\n"
			+ "<!ENTITY drcrop  \"&#x230C;\" >\n" + "<!ENTITY DScy  \"&#x0405;\" >\n" + "<!ENTITY dscy  \"&#x0455;\" >\n" + "<!ENTITY Dstrok  \"&#x0110;\" >\n" + "<!ENTITY dstrok  \"&#x0111;\" >\n" + "<!ENTITY dtri  \"&#x25BF;\" >\n"
			+ "<!ENTITY dtrif  \"&#x25BE;\" >\n" + "<!ENTITY DZcy  \"&#x040F;\" >\n" + "<!ENTITY dzcy  \"&#x045F;\" >\n" + "<!ENTITY Eacgr  \"&#x0388;\" >\n" + "<!ENTITY eacgr  \"&#x03AD;\" >\n" + "<!ENTITY Eacute  \"&#x00C9;\" >\n"
			+ "<!ENTITY eacute  \"&#x00E9;\" >\n" + "<!ENTITY Ecaron  \"&#x011A;\" >\n" + "<!ENTITY ecaron  \"&#x011B;\" >\n" + "<!ENTITY Ecirc  \"&#x00CA;\" >\n" + "<!ENTITY ecirc  \"&#x00EA;\" >\n" + "<!ENTITY Ecy  \"&#x042D;\" >\n"
			+ "<!ENTITY ecy  \"&#x044D;\" >\n" + "<!ENTITY Edot  \"&#x0116;\" >\n" + "<!ENTITY edot  \"&#x0117;\" >\n" + "<!ENTITY EEacgr  \"&#x0389;\" >\n" + "<!ENTITY eeacgr  \"&#x03AE;\" >\n" + "<!ENTITY EEgr  \"&#x0397;\" >\n"
			+ "<!ENTITY eegr  \"&#x03B7;\" >\n" + "<!ENTITY Egr  \"&#x0395;\" >\n" + "<!ENTITY egr  \"&#x03B5;\" >\n" + "<!ENTITY Egrave  \"&#x00C8;\" >\n" + "<!ENTITY egrave  \"&#x00E8;\" >\n" + "<!ENTITY Emacr  \"&#x0112;\" >\n"
			+ "<!ENTITY emacr  \"&#x0113;\" >\n" + "<!ENTITY emsp  \"&#x2003;\" >\n" + "<!ENTITY emsp13  \"&#x2004;\" >\n" + "<!ENTITY emsp14  \"&#x2005;\" >\n" + "<!ENTITY ENG  \"&#x014A;\" >\n" + "<!ENTITY eng  \"&#x014B;\" >\n"
			+ "<!ENTITY ensp  \"&#x2002;\" >\n" + "<!ENTITY Eogon  \"&#x0118;\" >\n" + "<!ENTITY eogon  \"&#x0119;\" >\n" + "<!ENTITY epsi  \"&#x220A;\" >\n" + "<!ENTITY epsis  \"&#x220A;\" >\n" + "<!ENTITY epsiv  \"&#x03B5;\" >\n"
			+ "<!ENTITY equals  \"&#x003D;\" >\n" + "<!ENTITY equiv  \"&#x2261;\" >\n" + "<!ENTITY eta  \"&#x03B7;\" >\n" + "<!ENTITY ETH  \"&#x00D0;\" >\n" + "<!ENTITY eth  \"&#x00F0;\" >\n" + "<!ENTITY Euml  \"&#x00CB;\" >\n"
			+ "<!ENTITY euml  \"&#x00EB;\" >\n" + "<!ENTITY excl  \"&#x0021;\" >\n" + "<!ENTITY exist  \"&#x2203;\" >\n" + "<!ENTITY Fcy  \"&#x0424;\" >\n" + "<!ENTITY fcy  \"&#x0444;\" >\n" + "<!ENTITY female  \"&#x2640;\" >\n"
			+ "<!ENTITY ffilig  \"&#xFB03;\" >\n" + "<!ENTITY fflig  \"&#xFB00;\" >\n" + "<!ENTITY ffllig  \"&#xFB04;\" >\n" + "<!ENTITY filig  \"&#xFB01;\" >\n" + "<!ENTITY flat  \"&#x266D;\" >\n" + "<!ENTITY fllig  \"&#xFB02;\" >\n"
			+ "<!ENTITY fnof  \"&#x0192;\" >\n" + "<!ENTITY forall  \"&#x2200;\" >\n" + "<!ENTITY frac12  \"&#x00BD;\" >\n" + "<!ENTITY frac13  \"&#x2153;\" >\n" + "<!ENTITY frac14  \"&#x00BC;\" >\n" + "<!ENTITY frac15  \"&#x2155;\" >\n"
			+ "<!ENTITY frac16  \"&#x2159;\" >\n" + "<!ENTITY frac18  \"&#x215B;\" >\n" + "<!ENTITY frac23  \"&#x2154;\" >\n" + "<!ENTITY frac25  \"&#x2156;\" >\n" + "<!ENTITY frac34  \"&#x00BE;\" >\n" + "<!ENTITY frac35  \"&#x2157;\" >\n"
			+ "<!ENTITY frac38  \"&#x215C;\" >\n" + "<!ENTITY frac45  \"&#x2158;\" >\n" + "<!ENTITY frac56  \"&#x215A;\" >\n" + "<!ENTITY frac58  \"&#x215D;\" >\n" + "<!ENTITY frac78  \"&#x215E;\" >\n" + "<!ENTITY frasl  \"&#x2044;\" >\n"
			+ "<!ENTITY gacute  \"&#x01F5;\" >\n" + "<!ENTITY Gamma  \"&#x0393;\" >\n" + "<!ENTITY gamma  \"&#x03B3;\" >\n" + "<!ENTITY gammad  \"&#x03DC;\" >\n" + "<!ENTITY Gbreve  \"&#x011E;\" >\n" + "<!ENTITY gbreve  \"&#x011F;\" >\n"
			+ "<!ENTITY Gcedil  \"&#x0122;\" >\n" + "<!ENTITY Gcirc  \"&#x011C;\" >\n" + "<!ENTITY gcirc  \"&#x011D;\" >\n" + "<!ENTITY Gcy  \"&#x0413;\" >\n" + "<!ENTITY gcy  \"&#x0433;\" >\n" + "<!ENTITY Gdot  \"&#x0120;\" >\n"
			+ "<!ENTITY gdot  \"&#x0121;\" >\n" + "<!ENTITY ge  \"&#x2265;\" >\n" + "<!ENTITY Ggr  \"&#x0393;\" >\n" + "<!ENTITY ggr  \"&#x03B3;\" >\n" + "<!ENTITY GJcy  \"&#x0403;\" >\n" + "<!ENTITY gjcy  \"&#x0453;\" >\n"
			+ "<!ENTITY grave  \"&#x0060;\" >\n" + "<!ENTITY gt  \"&#x003E;\" >\n" + "<!ENTITY hairsp  \"&#x200A;\" >\n" + "<!ENTITY half  \"&#x00BD;\" >\n" + "<!ENTITY hamilt  \"&#x210B;\" >\n" + "<!ENTITY HARDcy  \"&#x042A;\" >\n"
			+ "<!ENTITY hardcy  \"\\\\&#x044A;\" >\n" + "<!ENTITY Hcirc  \"&#x0124;\" >\n" + "<!ENTITY hcirc  \"&#x0125;\" >\n" + "<!ENTITY hearts  \"&#x2665;\" >\n" + "<!ENTITY hellip  \"&#x2026;\" >\n" + "<!ENTITY horbar  \"&#x2015;\" >\n"
			+ "<!ENTITY Hstrok  \"&#x0126;\" >\n" + "<!ENTITY hstrok  \"&#x0127;\" >\n" + "<!ENTITY hybull  \"&#x2043;\" >\n" + "<!ENTITY hyphen  \"&#x002D;\" >\n" + "<!ENTITY Iacgr  \"&#x038A;\" >\n" + "<!ENTITY iacgr  \"&#x03AF;\" >\n"
			+ "<!ENTITY Iacute  \"&#x00CD;\" >\n" + "<!ENTITY iacute  \"&#x00ED;\" >\n" + "<!ENTITY Icirc  \"&#x00CE;\" >\n" + "<!ENTITY icirc  \"&#x00EE;\" >\n" + "<!ENTITY Icy  \"&#x0418;\" >\n" + "<!ENTITY icy  \"&#x0438;\" >\n"
			+ "<!ENTITY idiagr  \"&#x0390;\" >\n" + "<!ENTITY Idigr  \"&#x03AA;\" >\n" + "<!ENTITY idigr  \"&#x03CA;\" >\n" + "<!ENTITY Idot  \"&#x0130;\" >\n" + "<!ENTITY IEcy  \"&#x0415;\" >\n" + "<!ENTITY iecy  \"&#x0435;\" >\n"
			+ "<!ENTITY iexcl  \"&#x00A1;\" >\n" + "<!ENTITY iff  \"&#x21D4;\" >\n" + "<!ENTITY Igr  \"&#x0399;\" >\n" + "<!ENTITY igr  \"&#x03B9;\" >\n" + "<!ENTITY Igrave  \"&#x00CC;\" >\n" + "<!ENTITY igrave  \"&#x00EC;\" >\n"
			+ "<!ENTITY IJlig  \"&#x0132;\" >\n" + "<!ENTITY ijlig  \"&#x0133;\" >\n" + "<!ENTITY Imacr  \"&#x012A;\" >\n" + "<!ENTITY imacr  \"&#x012B;\" >\n" + "<!ENTITY incare  \"&#x2105;\" >\n" + "<!ENTITY infin  \"&#x221E;\" >\n"
			+ "<!ENTITY inodot  \"&#x0131;\" >\n" + "<!ENTITY int  \"&#x222B;\" >\n" + "<!ENTITY IOcy  \"&#x0401;\" >\n" + "<!ENTITY iocy  \"&#x0451;\" >\n" + "<!ENTITY Iogon  \"&#x012E;\" >\n" + "<!ENTITY iogon  \"&#x012F;\" >\n"
			+ "<!ENTITY iota  \"&#x03B9;\" >\n" + "<!ENTITY iquest  \"&#x00BF;\" >\n" + "<!ENTITY isin  \"&#x220A;\" >\n" + "<!ENTITY Itilde  \"&#x0128;\" >\n" + "<!ENTITY itilde  \"&#x0129;\" >\n" + "<!ENTITY Iukcy  \"&#x0406;\" >\n"
			+ "<!ENTITY iukcy  \"&#x0456;\" >\n" + "<!ENTITY Iuml  \"&#x00CF;\" >\n" + "<!ENTITY iuml  \"&#x00EF;\" >\n" + "<!ENTITY Jcirc  \"&#x0134;\" >\n" + "<!ENTITY jcirc  \"&#x0135;\" >\n" + "<!ENTITY Jcy  \"&#x0419;\" >\n"
			+ "<!ENTITY jcy  \"&#x0439;\" >\n" + "<!ENTITY Jsercy  \"&#x0408;\" >\n" + "<!ENTITY jsercy  \"&#x0458;\" >\n" + "<!ENTITY Jukcy  \"&#x0404;\" >\n" + "<!ENTITY jukcy  \"&#x0454;\" >\n" + "<!ENTITY kappa  \"&#x03BA;\" >\n"
			+ "<!ENTITY kappav  \"&#x03F0;\" >\n" + "<!ENTITY Kcedil  \"&#x0136;\" >\n" + "<!ENTITY kcedil  \"&#x0137;\" >\n" + "<!ENTITY Kcy  \"&#x041A;\" >\n" + "<!ENTITY kcy  \"&#x043A;\" >\n" + "<!ENTITY Kgr  \"&#x039A;\" >\n"
			+ "<!ENTITY kgr  \"&#x03BA;\" >\n" + "<!ENTITY kgreen  \"&#x0138;\" >\n" + "<!ENTITY KHcy  \"&#x0425;\" >\n" + "<!ENTITY khcy  \"&#x0445;\" >\n" + "<!ENTITY KHgr  \"&#x03A7;\" >\n" + "<!ENTITY khgr  \"&#x03C7;\" >\n"
			+ "<!ENTITY KJcy  \"&#x040C;\" >\n" + "<!ENTITY kjcy  \"&#x045C;\" >\n" + "<!ENTITY Lacute  \"&#x0139;\" >\n" + "<!ENTITY lacute  \"&#x013A;\" >\n" + "<!ENTITY lagran  \"&#x2112;\" >\n" + "<!ENTITY Lambda  \"&#x039B;\" >\n"
			+ "<!ENTITY lambda  \"&#x03BB;\" >\n" + "<!ENTITY lang  \"&#x3008;\" >\n" + "<!ENTITY larr  \"&#x2190;\" >\n" + "<!ENTITY lArr  \"&#x21D0;\" >\n" + "<!ENTITY Lcaron  \"&#x013D;\" >\n" + "<!ENTITY lcaron  \"&#x013E;\" >\n"
			+ "<!ENTITY Lcedil  \"&#x013B;\" >\n" + "<!ENTITY lcedil  \"&#x013C;\" >\n" + "<!ENTITY lcub  \"&#x007B;\" >\n" + "<!ENTITY Lcy  \"&#x041B;\" >\n" + "<!ENTITY lcy  \"&#x043B;\" >\n" + "<!ENTITY ldquor  \"&#x201E;\" >\n"
			+ "<!ENTITY le  \"&#x2264;\" >\n" + "<!ENTITY Lgr  \"&#x039B;\" >\n" + "<!ENTITY lgr  \"&#x03BB;\" >\n" + "<!ENTITY lhblk  \"&#x2584;\" >\n" + "<!ENTITY LJcy  \"&#x0409;\" >\n" + "<!ENTITY ljcy  \"&#x0459;\" >\n"
			+ "<!ENTITY Lmidot  \"&#x013F;\" >\n" + "<!ENTITY lmidot  \"&#x0140;\" >\n" + "<!ENTITY lowast  \"&#x2217;\" >\n" + "<!ENTITY lowbar  \"&#x005F;\" >\n" + "<!ENTITY loz  \"&#x25CA;\" >\n" + "<!ENTITY lozf  \"&#x2726;\" >\n"
			+ "<!ENTITY lpar  \"&#x0028;\" >\n" + "<!ENTITY lrm  \"&#x200E;\" >\n" + "<!ENTITY lsaquo  \"&#x2039;\" >\n" + "<!ENTITY lsqb  \"&#x005B;\" >\n" + "<!ENTITY Lstrok  \"&#x0141;\" >\n" + "<!ENTITY lstrok  \"&#x0142;\" >\n"
			+ "<!ENTITY lt  \"&#38;#60;\" >\n" + "<!ENTITY ltri  \"&#x25C3;\" >\n" + "<!ENTITY ltrif  \"&#x25C2;\" >\n" + "<!ENTITY macr  \"&#x00AF;\" >\n" + "<!ENTITY male  \"&#x2642;\" >\n" + "<!ENTITY malt  \"&#x2720;\" >\n"
			+ "<!ENTITY marker  \"&#x25AE;\" >\n" + "<!ENTITY Mcy  \"&#x041C;\" >\n" + "<!ENTITY mcy  \"&#x043C;\" >\n" + "<!ENTITY Mgr  \"&#x039C;\" >\n" + "<!ENTITY mgr  \"&#x03BC;\" >\n" + "<!ENTITY micro  \"&#x00B5;\" >\n"
			+ "<!ENTITY middot  \"&#x00B7;\" >\n" + "<!ENTITY minus  \"&#x2212;\" >\n" + "<!ENTITY mldr  \"&#x2026;\" >\n" + "<!ENTITY mnplus  \"&#x2213;\" >\n" + "<!ENTITY mu  \"&#x03BC;\" >\n" + "<!ENTITY nabla  \"&#x2207;\" >\n"
			+ "<!ENTITY Nacute  \"&#x0143;\" >\n" + "<!ENTITY nacute  \"&#x0144;\" >\n" + "<!ENTITY napos  \"&#x0149;\" >\n" + "<!ENTITY natur  \"&#x266E;\" >\n" + "<!ENTITY Ncaron  \"&#x0147;\" >\n" + "<!ENTITY ncaron  \"&#x0148;\" >\n"
			+ "<!ENTITY Ncedil  \"&#x0145;\" >\n" + "<!ENTITY ncedil  \"&#x0146;\" >\n" + "<!ENTITY Ncy  \"&#x041D;\" >\n" + "<!ENTITY ncy  \"&#x043D;\" >\n" + "<!ENTITY ne  \"&#x2260;\" >\n" + "<!ENTITY Ngr  \"&#x039D;\" >\n"
			+ "<!ENTITY ngr  \"&#x03BD;\" >\n" + "<!ENTITY ni  \"&#x220D;\" >\n" + "<!ENTITY NJcy  \"&#x040A;\" >\n" + "<!ENTITY njcy  \"&#x045A;\" >\n" + "<!ENTITY nldr  \"&#x2025;\" >\n" + "<!ENTITY not  \"&#x00AC;\" >\n"
			+ "<!ENTITY notin  \"&#x2209;\" >\n" + "<!ENTITY Ntilde  \"&#x00D1;\" >\n" + "<!ENTITY ntilde  \"&#x00F1;\" >\n" + "<!ENTITY nu  \"&#x03BD;\" >\n" + "<!ENTITY num  \"&#x0023;\" >\n" + "<!ENTITY numero  \"&#x2116;\" >\n"
			+ "<!ENTITY numsp  \"&#x2007;\" >\n" + "<!ENTITY Oacgr  \"&#x038C;\" >\n" + "<!ENTITY oacgr  \"&#x03CC;\" >\n" + "<!ENTITY Oacute  \"&#x00D3;\" >\n" + "<!ENTITY oacute  \"&#x00F3;\" >\n" + "<!ENTITY Ocirc  \"&#x00D4;\" >\n"
			+ "<!ENTITY ocirc  \"&#x00F4;\" >\n" + "<!ENTITY Ocy  \"&#x041E;\" >\n" + "<!ENTITY ocy  \"&#x043E;\" >\n" + "<!ENTITY Odblac  \"&#x0150;\" >\n" + "<!ENTITY odblac  \"&#x0151;\" >\n" + "<!ENTITY OElig  \"&#x0152;\" >\n"
			+ "<!ENTITY oelig  \"&#x0153;\" >\n" + "<!ENTITY ogon  \"&#x02DB;\" >\n" + "<!ENTITY Ogr  \"&#x039F;\" >\n" + "<!ENTITY ogr  \"&#x03BF;\" >\n" + "<!ENTITY Ograve  \"&#x00D2;\" >\n" + "<!ENTITY ograve  \"&#x00F2;\" >\n"
			+ "<!ENTITY OHacgr  \"&#x038F;\" >\n" + "<!ENTITY ohacgr  \"&#x03CE;\" >\n" + "<!ENTITY OHgr  \"&#x03A9;\" >\n" + "<!ENTITY ohgr  \"&#x03C9;\" >\n" + "<!ENTITY ohm  \"&#x2126;\" >\n" + "<!ENTITY oline  \"&#x203E;\" >\n"
			+ "<!ENTITY Omacr  \"&#x014C;\" >\n" + "<!ENTITY omacr  \"&#x014D;\" >\n" + "<!ENTITY Omega  \"&#x03A9;\" >\n" + "<!ENTITY omega  \"&#x03C9;\" >\n" + "<!ENTITY or  \"&#x2228;\" >\n" + "<!ENTITY order  \"&#x2134;\" >\n"
			+ "<!ENTITY ordf  \"&#x00AA;\" >\n" + "<!ENTITY ordm  \"&#x00BA;\" >\n" + "<!ENTITY Oslash  \"&#x00D8;\" >\n" + "<!ENTITY oslash  \"&#x00F8;\" >\n" + "<!ENTITY Otilde  \"&#x00D5;\" >\n" + "<!ENTITY otilde  \"&#x00F5;\" >\n"
			+ "<!ENTITY Ouml  \"&#x00D6;\" >\n" + "<!ENTITY ouml  \"&#x00F6;\" >\n" + "<!ENTITY par  \"&#x2225;\" >\n" + "<!ENTITY para  \"&#x00B6;\" >\n" + "<!ENTITY part  \"&#x2202;\" >\n" + "<!ENTITY Pcy  \"&#x041F;\" >\n"
			+ "<!ENTITY pcy  \"&#x043F;\" >\n" + "<!ENTITY percnt  \"&#x0025;\" >\n" + "<!ENTITY period  \"&#x002E;\" >\n" + "<!ENTITY permil  \"&#x2030;\" >\n" + "<!ENTITY perp  \"&#x22A5;\" >\n" + "<!ENTITY Pgr  \"&#x03A0;\" >\n"
			+ "<!ENTITY pgr  \"&#x03C0;\" >\n" + "<!ENTITY PHgr  \"&#x03A6;\" >\n" + "<!ENTITY phgr  \"&#x03C6;\" >\n" + "<!ENTITY Phi  \"&#x03A6;\" >\n" + "<!ENTITY phis  \"&#x03C6;\" >\n" + "<!ENTITY phiv  \"&#x03D5;\" >\n"
			+ "<!ENTITY phmmat  \"&#x2133;\" >\n" + "<!ENTITY phone  \"&#x260E;\" >\n" + "<!ENTITY Pi  \"&#x03A0;\" >\n" + "<!ENTITY pi  \"&#x03C0;\" >\n" + "<!ENTITY piv  \"&#x03D6;\" >\n" + "<!ENTITY plus  \"&#x002B;\" >\n"
			+ "<!ENTITY plusmn  \"&#x00B1;\" >\n" + "<!ENTITY pound  \"&#x00A3;\" >\n" + "<!ENTITY prime  \"&#x2032;\" >\n" + "<!ENTITY Prime  \"&#x2033;\" >\n" + "<!ENTITY prop  \"&#x221D;\" >\n" + "<!ENTITY PSgr  \"&#x03A8;\" >\n"
			+ "<!ENTITY psgr  \"&#x03C8;\" >\n" + "<!ENTITY Psi  \"&#x03A8;\" >\n" + "<!ENTITY psi  \"&#x03C8;\" >\n" + "<!ENTITY puncsp  \"&#x2008;\" >\n" + "<!ENTITY quest  \"&#x003F;\" >\n" + "<!ENTITY quot  \"&#x0022;\" >\n"
			+ "<!ENTITY Racute  \"&#x0154;\" >\n" + "<!ENTITY racute  \"&#x0155;\" >\n" + "<!ENTITY radic  \"&#x221A;\" >\n" + "<!ENTITY rang  \"&#x3009;\" >\n" + "<!ENTITY rarr  \"&#x2192;\" >\n" + "<!ENTITY rArr  \"&#x21D2;\" >\n"
			+ "<!ENTITY Rcaron  \"&#x0158;\" >\n" + "<!ENTITY rcaron  \"&#x0159;\" >\n" + "<!ENTITY Rcedil  \"&#x0156;\" >\n" + "<!ENTITY rcedil  \"&#x0157;\" >\n" + "<!ENTITY rcub  \"&#x007D;\" >\n" + "<!ENTITY Rcy  \"&#x0420;\" >\n"
			+ "<!ENTITY rcy  \"&#x0440;\" >\n" + "<!ENTITY rdquor  \"&#x201C;\" >\n" + "<!ENTITY rect  \"&#x25AD;\" >\n" + "<!ENTITY reg  \"&#x00AE;\" >\n" + "<!ENTITY Rgr  \"&#x03A1;\" >\n" + "<!ENTITY rgr  \"&#x03C1;\" >\n"
			+ "<!ENTITY rho  \"&#x03C1;\" >\n" + "<!ENTITY rhov  \"&#x03F1;\" >\n" + "<!ENTITY ring  \"&#x02DA;\" >\n" + "<!ENTITY rlm  \"&#x200F;\" >\n" + "<!ENTITY rpar  \"&#x0029;\" >\n" + "<!ENTITY rsaquo  \"&#x203A;\" >\n"
			+ "<!ENTITY rsqb  \"&#x005D;\" >\n" + "<!ENTITY rtri  \"&#x25B9;\" >\n" + "<!ENTITY rtrif  \"&#x25B8;\" >\n" + "<!ENTITY rx  \"&#x211E;\" >\n" + "<!ENTITY Sacute  \"&#x015A;\" >\n" + "<!ENTITY sacute  \"&#x015B;\" >\n"
			+ "<!ENTITY sbquo  \"&#x201A;\" >\n" + "<!ENTITY Scaron  \"&#x0160;\" >\n" + "<!ENTITY scaron  \"&#x0161;\" >\n" + "<!ENTITY Scedil  \"&#x015E;\" >\n" + "<!ENTITY scedil  \"&#x015F;\" >\n" + "<!ENTITY Scirc  \"&#x015C;\" >\n"
			+ "<!ENTITY scirc  \"&#x015D;\" >\n" + "<!ENTITY Scy  \"&#x0421;\" >\n" + "<!ENTITY scy  \"&#x0441;\" >\n" + "<!ENTITY sect  \"&#x00A7;\" >\n" + "<!ENTITY semi  \"&#x003B;\" >\n" + "<!ENTITY sext  \"&#x2736;\" >\n"
			+ "<!ENTITY sfgr  \"&#x03C2;\" >\n" + "<!ENTITY Sgr  \"&#x03A3;\" >\n" + "<!ENTITY sgr  \"&#x03C3;\" >\n" + "<!ENTITY sharp  \"&#x266F;\" >\n" + "<!ENTITY SHCHcy  \"&#x0429;\" >\n" + "<!ENTITY shchcy  \"&#x0449;\" >\n"
			+ "<!ENTITY SHcy  \"&#x0428;\" >\n" + "<!ENTITY shcy  \"&#x0448;\" >\n" + "<!ENTITY shy  \"&#x00AD;\" >\n" + "<!ENTITY Sigma  \"&#x03A3;\" >\n" + "<!ENTITY sigma  \"&#x03C3;\" >\n" + "<!ENTITY sigmav  \"&#x03C2;\" >\n"
			+ "<!ENTITY sim  \"&#x223C;\" >\n" + "<!ENTITY sime  \"&#x2243;\" >\n" + "<!ENTITY SOFTcy  \"&#x042C;\" >\n" + "<!ENTITY softcy  \"&#x044C;\" >\n" + "<!ENTITY sol  \"&#x002F;\" >\n" + "<!ENTITY spades  \"&#x2660;\" >\n"
			+ "<!ENTITY squ  \"&#x25A1;\" >\n" + "<!ENTITY square  \"&#x25A1;\" >\n" + "<!ENTITY squf  \"&#x25AA;\" >\n" + "<!ENTITY star  \"&#x22C6;\" >\n" + "<!ENTITY starf  \"&#x2605;\" >\n" + "<!ENTITY sub  \"&#x2282;\" >\n"
			+ "<!ENTITY sube  \"&#x2286;\" >\n" + "<!ENTITY sung  \"&#x2669;\" >\n" + "<!ENTITY sup  \"&#x2283;\" >\n" + "<!ENTITY sup1  \"&#x00B9;\" >\n" + "<!ENTITY sup2  \"&#x00B2;\" >\n" + "<!ENTITY sup3  \"&#x00B3;\" >\n"
			+ "<!ENTITY supe  \"&#x2287;\" >\n" + "<!ENTITY szlig  \"&#x00DF;\" >\n" + "<!ENTITY target  \"&#x2316;\" >\n" + "<!ENTITY tau  \"&#x03C4;\" >\n" + "<!ENTITY Tcaron  \"&#x0164;\" >\n" + "<!ENTITY tcaron  \"&#x0165;\" >\n"
			+ "<!ENTITY Tcedil  \"&#x0162;\" >\n" + "<!ENTITY tcedil  \"&#x0163;\" >\n" + "<!ENTITY Tcy  \"&#x0422;\" >\n" + "<!ENTITY tcy  \"&#x0442;\" >\n" + "<!ENTITY tdot  \"&#x20DB;\" >\n" + "<!ENTITY telrec  \"&#x2315;\" >\n"
			+ "<!ENTITY Tgr  \"&#x03A4;\" >\n" + "<!ENTITY tgr  \"&#x03C4;\" >\n" + "<!ENTITY there4  \"&#x2234;\" >\n" + "<!ENTITY Theta  \"&#x0398;\" >\n" + "<!ENTITY thetas  \"&#x03B8;\" >\n" + "<!ENTITY thetav  \"&#x03D1;\" >\n"
			+ "<!ENTITY THgr  \"&#x0398;\" >\n" + "<!ENTITY thgr  \"&#x03B8;\" >\n" + "<!ENTITY THORN  \"&#x00DE;\" >\n" + "<!ENTITY thorn  \"&#x00FE;\" >\n" + "<!ENTITY tilde  \"&#x02DC;\" >\n" + "<!ENTITY times  \"&#x00D7;\" >\n"
			+ "<!ENTITY tprime  \"&#x2034;\" >\n" + "<!ENTITY trade  \"&#x2122;\" >\n" + "<!ENTITY TScy  \"&#x0426;\" >\n" + "<!ENTITY tscy  \"&#x0446;\" >\n" + "<!ENTITY TSHcy  \"&#x040B;\" >\n" + "<!ENTITY tshcy  \"&#x045B;\" >\n"
			+ "<!ENTITY Tstrok  \"&#x0166;\" >\n" + "<!ENTITY tstrok  \"&#x0167;\" >\n" + "<!ENTITY Uacgr  \"&#x038E;\" >\n" + "<!ENTITY uacgr  \"&#x03CD;\" >\n" + "<!ENTITY Uacute  \"&#x00DA;\" >\n" + "<!ENTITY uacute  \"&#x00FA;\" >\n"
			+ "<!ENTITY uarr  \"&#x2191;\" >\n" + "<!ENTITY Ubrcy  \"&#x040E;\" >\n" + "<!ENTITY ubrcy  \"&#x045E;\" >\n" + "<!ENTITY Ubreve  \"&#x016C;\" >\n" + "<!ENTITY ubreve  \"&#x016D;\" >\n" + "<!ENTITY Ucirc  \"&#x00DB;\" >\n"
			+ "<!ENTITY ucirc  \"&#x00FB;\" >\n" + "<!ENTITY Ucy  \"&#x0423;\" >\n" + "<!ENTITY ucy  \"&#x0443;\" >\n" + "<!ENTITY Udblac  \"&#x0170;\" >\n" + "<!ENTITY udblac  \"&#x0171;\" >\n" + "<!ENTITY udiagr  \"&#x03B0;\" >\n"
			+ "<!ENTITY Udigr  \"&#x03AB;\" >\n" + "<!ENTITY udigr  \"&#x03CB;\" >\n" + "<!ENTITY Ugr  \"&#x03A5;\" >\n" + "<!ENTITY ugr  \"&#x03C5;\" >\n" + "<!ENTITY Ugrave  \"&#x00D9;\" >\n" + "<!ENTITY ugrave  \"&#x00F9;\" >\n"
			+ "<!ENTITY uhblk  \"&#x2580;\" >\n" + "<!ENTITY ulcrop  \"&#x230F;\" >\n" + "<!ENTITY Umacr  \"&#x016A;\" >\n" + "<!ENTITY umacr  \"&#x016B;\" >\n" + "<!ENTITY uml  \"&#x00A8;\" >\n" + "<!ENTITY Uogon  \"&#x0172;\" >\n"
			+ "<!ENTITY uogon  \"&#x0173;\" >\n" + "<!ENTITY upsi  \"&#x03C5;\" >\n" + "<!ENTITY Upsi  \"&#x03D2;\" >\n" + "<!ENTITY urcrop  \"&#x230E;\" >\n" + "<!ENTITY Uring  \"&#x016E;\" >\n" + "<!ENTITY uring  \"&#x016F;\" >\n"
			+ "<!ENTITY Utilde  \"&#x0168;\" >\n" + "<!ENTITY utilde  \"&#x0169;\" >\n" + "<!ENTITY utri  \"&#x25B5;\" >\n" + "<!ENTITY utrif  \"&#x25B4;\" >\n" + "<!ENTITY Uuml  \"&#x00DC;\" >\n" + "<!ENTITY uuml  \"&#x00FC;\" >\n"
			+ "<!ENTITY Vcy  \"&#x0412;\" >\n" + "<!ENTITY vcy  \"&#x0432;\" >\n" + "<!ENTITY vellip  \"&#x22EE;\" >\n" + "<!ENTITY verbar  \"&#x007C;\" >\n" + "<!ENTITY Verbar  \"&#x2016;\" >\n" + "<!ENTITY Wcirc  \"&#x0174;\" >\n"
			+ "<!ENTITY wcirc  \"&#x0175;\" >\n" + "<!ENTITY wedgeq  \"&#x2259;\" >\n" + "<!ENTITY Xgr  \"&#x039E;\" >\n" + "<!ENTITY xgr  \"&#x03BE;\" >\n" + "<!ENTITY Xi  \"&#x039E;\" >\n" + "<!ENTITY xi  \"&#x03BE;\" >\n"
			+ "<!ENTITY Yacute  \"&#x00DD;\" >\n" + "<!ENTITY yacute  \"&#x00FD;\" >\n" + "<!ENTITY YAcy  \"&#x042F;\" >\n" + "<!ENTITY yacy  \"&#x044F;\" >\n" + "<!ENTITY Ycirc  \"&#x0176;\" >\n" + "<!ENTITY ycirc  \"&#x0177;\" >\n"
			+ "<!ENTITY Ycy  \"&#x042B;\" >\n" + "<!ENTITY ycy  \"&#x044B;\" >\n" + "<!ENTITY yen  \"&#x00A5;\" >\n" + "<!ENTITY YIcy  \"&#x0407;\" >\n" + "<!ENTITY yicy  \"&#x0457;\" >\n" + "<!ENTITY YUcy  \"&#x042E;\" >\n"
			+ "<!ENTITY yucy  \"&#x044E;\" >\n" + "<!ENTITY yuml  \"&#x00FF;\" >\n" + "<!ENTITY Yuml  \"&#x0178;\" >\n" + "<!ENTITY Zacute  \"&#x0179;\" >\n" + "<!ENTITY zacute  \"&#x017A;\" >\n" + "<!ENTITY Zcaron  \"&#x017D;\" >\n"
			+ "<!ENTITY zcaron  \"&#x017E;\" >\n" + "<!ENTITY Zcy  \"&#x0417;\" >\n" + "<!ENTITY zcy  \"&#x0437;\" >\n" + "<!ENTITY Zdot  \"&#x017B;\" >\n" + "<!ENTITY zdot  \"&#x017C;\" >\n" + "<!ENTITY zeta  \"&#x03B6;\" >\n"
			+ "<!ENTITY Zgr  \"&#x0396;\" >\n" + "<!ENTITY zgr  \"&#x03B6;\" >\n" + "<!ENTITY ZHcy  \"&#x0416;\" >\n" + "<!ENTITY zhcy  \"&#x0436;\" >\n" + "<!ENTITY zwj  \"&#x200D;\" >\n" + "<!ENTITY zwnj  \"&#x200C;\" >\n" + "]>$2<$3";

	public static void main(String[] args) {
		String test1 = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE livre SYSTEM \"DTD_LG_XMLV23.dtd\">\n<?verif code=CP1110 date=04/03/2020?>\n<livre compo=\"NordCompo\">";
		String test2 = "<?xml version=\"1.0\" encoding=\"utf-8\"?><!--Arbortext, Inc., 1988-2006, v.4002--><!DOCTYPE livre SYSTEM \"DTD_LG_NC_V5.1_style.dtd\">\n<livre compo=\"IGS-CP\">";
		String test3 = "<!-- < >-->\n\t<?test < > ?> <!DOCTYPE livre><!-- --> \n<?instruction ?> <!--test --><livre>";
		String test4 = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<livre>";
		//String test5 = "﻿<?xml version=\"1.0\" encoding=\"UTF-8\"?><!--Arbortext, Inc., 1988-2006, v.4002--><!DOCTYPE livre SYSTEM \"DTD_LG_NC_V5.1.DTD\"><livre compo=\"IGS-CP\">";
		String test5 = "﻿<?xml version=\"1.0\" encoding=\"UTF-8\"?><!--Arbortext, Inc., 1988-2006, v.4002--><!DOCTYPE livre SYSTEM \"DTD_LG_NC_V5.1.DTD\"><livre compo=\"IGS-CP\">";
		String test6 = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><!DOCTYPE livre[\n<!ENTITY laquo  \"«\" >\n]>" + "<livre compo=\"IGS-CP\" saisie=\"IGS-CP\">\n"
				+ "    <ident><auteur><rp folio=\"5\"/>Sébastien Spitzer</auteur><tit>La fièvre</tit><edit>ALBIN MICHEL</edit><copy><rp folio=\"6\"/>© Éditions Albin Michel, 2020</copy><ean>9782226441638</ean><coned>01</coned><isbn>978-2-226-44163-8</isbn><pagetitre><fig id=\"fig-0\"><img src=\"pageTitre.jpg\"/></fig></pagetitre><nbpages texte-interieur=\"320\"/><ftit><rp folio=\"3\"/>La fièvre</ftit>\n"
				+ "<type>roman</type>";
		String test7 = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><!DOCTYPE livre PUBLIC \"DTD LG GF Flammarion\" \"DTD_LG_Flammarion.dtd\"><?verif code=CP879 date=07/02/2020?><livre compo=\"NordCompo\">";
		Matcher matcher1 = doctype.matcher(test1);
		Matcher matcher2 = doctype.matcher(test2);
		Matcher matcher3 = doctype.matcher(test3);
		Matcher matcher4 = doctype.matcher(test4);
		Matcher matcher5 = doctype.matcher(test5);
		Matcher matcher6 = doctype.matcher(test6);
		Matcher matcher7 = doctype.matcher(test7);

		System.out.println("Test 1");
		System.out.println(matcher1.replaceFirst("$1[FOUND]$2<$3"));
		System.out.println("Test 2");
		System.out.println(matcher2.replaceFirst("$1[FOUND]$2<$3"));
		System.out.println("Test 3");
		System.out.println(matcher3.replaceFirst("$1[FOUND]$2<$3"));
		System.out.println("Test 4");
		System.out.println(matcher4.replaceFirst("$1[FOUND]$2<$3"));
		System.out.println("Test 5");
		System.out.println(matcher5.replaceFirst("$1[FOUND]$2<$3"));
		System.out.println("Test 6");
		System.out.println(matcher6.replaceFirst("$1[FOUND]$2<$3"));
		System.out.println("Test 7");


		System.out.println(matcher7.replaceFirst("$1[FOUND]$2<$3"));
	}

	@Override
	public boolean processStep(ICidMetasProvider pCidMetas, IPersistentMetas pPersistMetas, StoreSquareTask pTask) {
		if (pTask.getSessionDatas().containsKey(StoreSquareTask.KEY_isCatchUp)) return false;

		File file = (File) pTask.getSessionDatas().get(ICidTask.KEY_file);
		try {
			FileReader reader = new FileReader(file);
			String content = StreamUtils.buildString(reader);

			Matcher extract = extractDoctype.matcher(content);
			if (extract.find()) pPersistMetas.put("dtdDetail", extract.group(1));

			String sourceXMLDoctype = "dtbook";
			Matcher match = doctype.matcher(content);
			if (match.find() && match.group(3).equals("livre")) {
				sourceXMLDoctype = "lg";
				try (FileWriter writer = new FileWriter(file)) {
					writer.write(match.replaceFirst(entities));
				}
			}
			//ajout de la meta
			pPersistMetas.put("sourceXMLDoctype", sourceXMLDoctype);

		} catch (Exception e) {
			throw LogMgr.wrapMessage(e, "Unable to normalize input XML. The Xml should be in a dtbook or lg DTD");
		}

		return true;
	}

	@Override
	public IFragmentSaxHandler initFromXml(SvcStoreSquare pSvc, IDataResolver pDataResolver, IAdaptable pInitContext, Attributes pAtts) {
		return new StoreStepLoaderBase(pSvc, pDataResolver, pInitContext) {
			@Override
			protected boolean xStartElement(String pUri, String pLocalName, String pQName, Attributes pAttributes) throws Exception {
				return true;
			}

		};
	}
}
