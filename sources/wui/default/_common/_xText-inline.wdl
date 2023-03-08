<?xml version="1.0"?>
<sm:textWdl xmlns:sm="http://www.utc.fr/ics/scenari/v3/modeling" xmlns:sc="http://www.utc.fr/ics/scenari/v3/core">
	<sm:anyTextPrim/>
	<sm:toolbar>
		<sm:menu idInToolbar="expInd" title="￼;Exposant/Inférieur￼" sortKey="60" group="gpInline">
			<sm:icon sc:refUri="/wui/_res/txtInline/expInd.svg"/>
		</sm:menu>
	</sm:toolbar>
	<sm:editPoints>
		<sm:root>
			<sm:freeHtmlStyle xml:space="preserve">/* Permet d'afficher les titrs longs des liens internes sur plusieurs lignes. A expérimenter avec cette config */
*[txt-role="refSheet"] &gt; inl-ptritem, *[txt-role="refPara"] &gt; inl-ptritem, *[txt-role="refBin"] &gt; inl-ptritem {
   white-space: normal !important;
}</sm:freeHtmlStyle>
		</sm:root>
		<sm:inlineTag tag="phrase" role="alternative">
			<sm:behaviors>
				<sm:keyBinding char="7"/>
			</sm:behaviors>
			<sm:toolbar>
				<sm:button sortKey="50" group="gpInline">
					<sm:icon sc:refUri="/wui/_res/txtInline/alternative.svg"/>
				</sm:button>
			</sm:toolbar>
			<sm:htmlStyle pseudoElement="before">
				<sm:entryStyle key="content" value="&quot;/&quot;"/>
				<sm:entryStyle key="font-weight" value="bold"/>
				<sm:entryStyle key="color" value="#6288b8"/>
				<sm:entryStyle key="margin-right" value=".2em"/>
			</sm:htmlStyle>
			<sm:htmlStyle>
				<sm:entryStyle key="border-bottom" value="2px solid #6288b8"/>
			</sm:htmlStyle>
		</sm:inlineTag>
		<sm:inlineTag tag="phrase" role="cite">
			<sm:behaviors>
				<sm:keyBinding char="&lt;"/>
			</sm:behaviors>
			<sm:toolbar>
				<sm:button refMenuId="mnInline">
					<sm:icon sc:refUri="/wui/_res/txtInline/cite.svg"/>
				</sm:button>
			</sm:toolbar>
			<sm:htmlStyle>
				<sm:entryStyle key="font-family" value="&quot;Times New Roman&quot;, Times, serif"/>
			</sm:htmlStyle>
			<sm:htmlStyle pseudoClass="before">
				<sm:entryStyle key="font-weight" value="bold"/>
				<sm:entryStyle key="content" value="&quot;« &quot;"/>
				<sm:entryStyle key="color" value="#6288b8"/>
			</sm:htmlStyle>
			<sm:htmlStyle pseudoClass="after">
				<sm:entryStyle key="font-weight" value="bold"/>
				<sm:entryStyle key="content" value="&quot; »&quot;"/>
				<sm:entryStyle key="color" value="#6288b8"/>
			</sm:htmlStyle>
		</sm:inlineTag>
		<sm:inlineTag tag="inlineStyle" role="titleCite">
			<sm:toolbar>
				<sm:button refMenuId="mnInline">
					<sm:icon sc:refUri="/wui/_res/txtInline/titleCite.svg"/>
				</sm:button>
			</sm:toolbar>
			<sm:htmlStyle>
				<sm:entryStyle key="background-color" value="var(--alt1-bgcolor)"/>
			</sm:htmlStyle>
			<sm:htmlStyle pseudoClass="before">
				<sm:entryStyle key="font-weight" value="bold"/>
				<sm:entryStyle key="content" value="&quot;«T &quot;"/>
				<sm:entryStyle key="color" value="#6288b8"/>
			</sm:htmlStyle>
		</sm:inlineTag>
		<sm:inlineTag tag="inlineStyle" role="strong">
			<sm:behaviors>
				<sm:keyBinding char="B"/>
			</sm:behaviors>
			<sm:toolbar>
				<sm:button sortKey="10" group="gpInline">
					<sm:icon sc:refUri="/wui/_res/txtInline/strong.svg"/>
				</sm:button>
			</sm:toolbar>
			<sm:htmlStyle>
				<sm:entryStyle key="font-weight" value="bold"/>
			</sm:htmlStyle>
		</sm:inlineTag>
		<sm:inlineTag tag="inlineStyle" role="emphase">
			<sm:behaviors>
				<sm:keyBinding char="I"/>
			</sm:behaviors>
			<sm:toolbar>
				<sm:button sortKey="20" group="gpInline">
					<sm:icon sc:refUri="/wui/_res/txtInline/emphase.svg"/>
				</sm:button>
			</sm:toolbar>
			<sm:htmlStyle>
				<sm:entryStyle key="font-style" value="italic"/>
			</sm:htmlStyle>
		</sm:inlineTag>
		<sm:inlineTag tag="inlineStyle" role="exposant">
			<sm:behaviors>
				<sm:keyBinding char="E"/>
			</sm:behaviors>
			<sm:toolbar>
				<sm:button refMenuId="expInd"/>
			</sm:toolbar>
			<sm:htmlStyle>
				<sm:entryStyle key="font-size" value="70%"/>
				<sm:entryStyle key="vertical-align" value="4px"/>
			</sm:htmlStyle>
		</sm:inlineTag>
		<sm:inlineTag tag="inlineStyle" role="inferieur">
			<sm:behaviors>
				<sm:keyBinding char="-"/>
			</sm:behaviors>
			<sm:toolbar>
				<sm:button refMenuId="expInd"/>
			</sm:toolbar>
			<sm:htmlStyle>
				<sm:entryStyle key="font-size" value="70%"/>
				<sm:entryStyle key="vertical-align" value="-4px"/>
			</sm:htmlStyle>
		</sm:inlineTag>
		<sm:inlineTag tag="inlineStyle" role="abreviation">
			<sm:toolbar>
				<sm:button sortKey="30" group="gpInline">
					<sm:icon sc:refUri="/wui/_res/txtInline/abreviation.svg"/>
				</sm:button>
			</sm:toolbar>
			<sm:htmlStyle>
				<sm:entryStyle key="background-color" value="var(--alt1-bgcolor)"/>
			</sm:htmlStyle>
			<sm:htmlStyle pseudoClass="before">
				<sm:entryStyle key="font-weight" value="bold"/>
				<sm:entryStyle key="content" value="&quot;Abr. &quot;"/>
				<sm:entryStyle key="color" value="#6288b8"/>
			</sm:htmlStyle>
		</sm:inlineTag>
		<sm:inlineTag tag="inlineStyle" role="acronym">
			<sm:toolbar>
				<sm:button sortKey="40" group="gpInline">
					<sm:icon sc:refUri="/wui/_res/txtInline/acronym.svg"/>
				</sm:button>
			</sm:toolbar>
			<sm:htmlStyle>
				<sm:entryStyle key="background-color" value="var(--alt1-bgcolor)"/>
			</sm:htmlStyle>
			<sm:htmlStyle pseudoClass="before">
				<sm:entryStyle key="font-weight" value="bold"/>
				<sm:entryStyle key="content" value="&quot;A. &quot;"/>
				<sm:entryStyle key="color" value="#6288b8"/>
			</sm:htmlStyle>
		</sm:inlineTag>
		<sm:inlineTag tag="inlineStyle" role="author">
			<sm:toolbar>
				<sm:button refMenuId="mnInline">
					<sm:icon sc:refUri="/wui/_res/txtInline/author.svg"/>
				</sm:button>
			</sm:toolbar>
			<sm:htmlStyle>
				<sm:entryImgStyle key="background-image" sc:refUri="/wui/_res/txtInline/author.svg"/>
				<sm:entryStyle key="background-repeat" value="no-repeat"/>
				<sm:entryStyle key="background-position" value="left center"/>
				<sm:entryStyle key="background-color" value="var(--alt1-bgcolor)"/>
				<sm:entryStyle key="padding-left" value="20px"/>
			</sm:htmlStyle>
		</sm:inlineTag>
		<sm:inlineTag tag="inlineStyle" role="url">
			<sm:toolbar>
				<sm:button refMenuId="mnInline">
					<sm:icon sc:refUri="/wui/_res/txtInline/url.svg"/>
				</sm:button>
			</sm:toolbar>
			<sm:htmlStyle>
				<sm:entryStyle key="color" value="#6288b8"/>
				<sm:entryStyle key="text-decoration" value="underline"/>
			</sm:htmlStyle>
		</sm:inlineTag>
		<sm:inlineTag tag="inlineStyle" role="lang">
			<sm:toolbar>
				<sm:button refMenuId="mnInline">
					<sm:icon sc:refUri="/wui/_res/txtInline/lang.svg"/>
				</sm:button>
			</sm:toolbar>
			<sm:htmlStyle>
				<sm:entryImgStyle key="background-image" sc:refUri="/wui/_res/txtInline/lang.svg"/>
				<sm:entryStyle key="background-repeat" value="no-repeat"/>
				<sm:entryStyle key="background-position" value="left center"/>
				<sm:entryStyle key="background-color" value="var(--alt1-bgcolor)"/>
				<sm:entryStyle key="padding-left" value="17px"/>
			</sm:htmlStyle>
		</sm:inlineTag>
		<sm:inlineTag tag="inlineStyle" role="error">
			<sm:toolbar>
				<sm:hidden/>
			</sm:toolbar>
			<sm:htmlStyle>
				<sm:entryImgStyle key="background-image" sc:refUri="/wui/_res/txtInline/error.svg"/>
				<sm:entryStyle key="background-repeat" value="no-repeat"/>
				<sm:entryStyle key="padding-left" value="17px"/>
				<sm:entryStyle key="color" value="#b86262"/>
			</sm:htmlStyle>
		</sm:inlineTag>
		<sm:inlineTag tag="emptyLeaf" role="note">
			<sm:toolbar>
				<sm:button refMenuId="mnInline">
					<sm:icon sc:refUri="/wui/_res/txtInline/note.svg"/>
				</sm:button>
			</sm:toolbar>
			<sm:htmlStyle>
				<sm:entryImgStyle key="background-image" sc:refUri="/wui/_res/txtInline/note.svg"/>
				<sm:entryStyle key="background-repeat" value="no-repeat"/>
				<sm:entryStyle key="padding-left" value="20px"/>
				<sm:entryStyle key="cursor" value="default"/>
			</sm:htmlStyle>
		</sm:inlineTag>
		<sm:inlineTag tag="emptyLeaf" role="pageNumber">
			<sm:behaviors>
				<sm:keyBinding char="#"/>
			</sm:behaviors>
			<sm:toolbar>
				<sm:button refMenuId="mnInline">
					<sm:icon sc:refUri="/wui/_res/txtInline/pageNumber.svg"/>
				</sm:button>
			</sm:toolbar>
			<sm:htmlStyle>
				<sm:entryImgStyle key="background-image" sc:refUri="/wui/_res/txtInline/pageNumber.svg"/>
				<sm:entryStyle key="background-repeat" value="no-repeat"/>
				<sm:entryStyle key="padding-left" value="20px"/>
				<sm:entryStyle key="cursor" value="default"/>
			</sm:htmlStyle>
		</sm:inlineTag>
		<sm:inlineTag tag="emptyLeaf" role="acapelaCmd">
			<sm:toolbar>
				<sm:button refMenuId="mnInline">
					<sm:icon sc:refUri="/wui/_res/txtInline/acapela.svg"/>
				</sm:button>
			</sm:toolbar>
			<sm:htmlStyle>
				<sm:entryImgStyle key="background-image" sc:refUri="/wui/_res/txtInline/acapela.svg"/>
				<sm:entryStyle key="background-repeat" value="no-repeat"/>
				<sm:entryStyle key="padding-left" value="20px"/>
				<sm:entryStyle key="cursor" value="default"/>
			</sm:htmlStyle>
		</sm:inlineTag>
	</sm:editPoints>
</sm:textWdl>