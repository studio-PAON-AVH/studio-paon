import {RibbonLc} from "¤builder;prt#fr-FR#back.url¤/wsp/widgets/ribbon/ribbon.js";

export default async function (authCtxReg, chainReg) {
	chainReg.reg.overlaySkin('wsp-doc-app', 10, /* language=CSS */ `c-appheader,#docHeader.headPanel,.countPanel{display: none;}`);
	chainReg.reg.overlaySkin('wsp-itemmain', 10, /* language=CSS */ `#ribbons > c-action{display: none;}`);
	chainReg.reg.overlaySkin('wsp-rib-refs', 10, /* language=CSS */ `:host{display: none;}`);
	chainReg.reg.overlaySkin('wsp-rib-info', 10, /* language=CSS */ `#itModel,img[align="center"],#srcCd{display: none;} #itTi{font-size: 2em}`);

	chainReg.addToList("wspDocApp:init", "initWspPaon", 100, async function (wspApp) {
		if (wspApp.wsp.hasFeature("liveCycle") && wspApp.wsp.wspMetaUi.getLcTransitions() !== null)
			chainReg.reg.addToList("ribbon:item", "lc", 1, RibbonLc, 20);
	});
}
