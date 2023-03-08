<?xml version="1.0"?>
<sm:textWdl xmlns:sm="http://www.utc.fr/ics/scenari/v3/modeling" xmlns:sc="http://www.utc.fr/ics/scenari/v3/core">
	<sm:anyTextPrim/>
	<sm:editPoints>
		<sm:root/>
		<sm:blockTag tag="para">
			<sm:htmlStyle>
				<sm:entryStyle key="margin-top" value="2px"/>
				<sm:entryStyle key="margin-bottom" value="4px"/>
				<sm:entryStyle key="line-height" value="1.25em"/>
			</sm:htmlStyle>
		</sm:blockTag>
		<sm:blockTag tag="div" role="citation">
			<sm:behaviors>
				<sm:keyBinding char=">"/>
			</sm:behaviors>
			<sm:toolbar>
				<sm:button refMenuId="mnBlockDiv">
					<sm:icon sc:refUri="/wui/_res/txtBlock/quoteIn.svg"/>
				</sm:button>
			</sm:toolbar>
			<sm:htmlStyle>
				<sm:entryStyle key="position" value="relative"/>
				<sm:entryStyle key="padding" value="0 2.5em"/>
				<sm:entryStyle key="margin" value="1em 0"/>
			</sm:htmlStyle>
			<sm:htmlStyle pseudoClass="before">
				<sm:entryStyle key="content" value="&quot;&quot;"/>
				<sm:entryImgStyle key="background-image" sc:refUri="/wui/_res/txtBlock/quoteIn.svg"/>
				<sm:entryStyle key="background-repeat" value="no-repeat"/>
				<sm:entryStyle key="position" value="absolute"/>
				<sm:entryStyle key="left" value=".5em"/>
				<sm:entryStyle key="width" value="16px"/>
				<sm:entryStyle key="height" value="16px"/>
			</sm:htmlStyle>
			<sm:htmlStyle pseudoClass="after">
				<sm:entryStyle key="content" value="&quot;&quot;"/>
				<sm:entryImgStyle key="background-image" sc:refUri="/wui/_res/txtBlock/quoteOut.svg"/>
				<sm:entryStyle key="background-repeat" value="no-repeat"/>
				<sm:entryStyle key="position" value="absolute"/>
				<sm:entryStyle key="bottom" value="0"/>
				<sm:entryStyle key="right" value=".5em"/>
				<sm:entryStyle key="width" value="16px"/>
				<sm:entryStyle key="height" value="16px"/>
			</sm:htmlStyle>
		</sm:blockTag>
		<sm:blockTag tag="div" role="poem">
			<sm:behaviors>
				<sm:keyBinding char="P"/>
			</sm:behaviors>
			<sm:toolbar>
				<sm:button refMenuId="mnBlockDiv">
					<sm:icon sc:refUri="/wui/_res/txtBlock/poem.svg"/>
				</sm:button>
			</sm:toolbar>
			<sm:htmlStyle>
				<sm:entryStyle key="position" value="relative"/>
				<sm:entryStyle key="padding" value=".5em"/>
				<sm:entryStyle key="margin" value="1em 0 1em 2.5em;"/>
				<sm:entryStyle key="border-left" value="1px solid var(--alt1-border-color)"/>
				<sm:entryStyle key="border-radius" value=".5em"/>
			</sm:htmlStyle>
			<sm:htmlStyle pseudoClass="before">
				<sm:entryStyle key="content" value="&quot;&quot;"/>
				<sm:entryImgStyle key="background-image" sc:refUri="/wui/_res/txtBlock/poem.svg"/>
				<sm:entryStyle key="background-repeat" value="no-repeat"/>
				<sm:entryStyle key="position" value="absolute"/>
				<sm:entryStyle key="left" value="-2em"/>
				<sm:entryStyle key="width" value="16px"/>
				<sm:entryStyle key="height" value="16px"/>
			</sm:htmlStyle>
		</sm:blockTag>
		<sm:blockTag tag="div" role="side">
			<sm:behaviors>
				<sm:keyBinding char="&amp;"/>
			</sm:behaviors>
			<sm:toolbar>
				<sm:button refMenuId="mnBlockDiv">
					<sm:icon sc:refUri="/wui/_res/txtBlock/sidebar.svg"/>
				</sm:button>
			</sm:toolbar>
			<sm:htmlStyle>
				<sm:entryStyle key="position" value="relative"/>
				<sm:entryStyle key="padding" value=".5em"/>
				<sm:entryStyle key="margin" value="1em 0 1em 2.5em;"/>
				<sm:entryStyle key="border-left" value="1px solid var(--alt1-border-color)"/>
				<sm:entryStyle key="border-radius" value=".5em"/>
			</sm:htmlStyle>
			<sm:htmlStyle pseudoClass="before">
				<sm:entryStyle key="content" value="&quot;&quot;"/>
				<sm:entryImgStyle key="background-image" sc:refUri="/wui/_res/txtBlock/sidebar.svg"/>
				<sm:entryStyle key="background-repeat" value="no-repeat"/>
				<sm:entryStyle key="position" value="absolute"/>
				<sm:entryStyle key="left" value="-2em"/>
				<sm:entryStyle key="width" value="16px"/>
				<sm:entryStyle key="height" value="16px"/>
			</sm:htmlStyle>
		</sm:blockTag>
		<sm:blockTag tag="div" role="epigraph">
			<sm:behaviors>
				<sm:keyBinding char="3"/>
			</sm:behaviors>
			<sm:toolbar>
				<sm:button refMenuId="mnBlockDiv">
					<sm:icon sc:refUri="/wui/_res/txtBlock/epigraph.svg"/>
				</sm:button>
			</sm:toolbar>
			<sm:htmlStyle>
				<sm:entryStyle key="position" value="relative"/>
				<sm:entryStyle key="padding" value=".5em"/>
				<sm:entryStyle key="margin" value="1em 0 1em 2.5em;"/>
				<sm:entryStyle key="border-left" value="1px solid var(--alt1-border-color)"/>
				<sm:entryStyle key="border-radius" value=".5em"/>
			</sm:htmlStyle>
			<sm:htmlStyle pseudoClass="before">
				<sm:entryStyle key="content" value="&quot;&quot;"/>
				<sm:entryImgStyle key="background-image" sc:refUri="/wui/_res/txtBlock/epigraph.svg"/>
				<sm:entryStyle key="background-repeat" value="no-repeat"/>
				<sm:entryStyle key="position" value="absolute"/>
				<sm:entryStyle key="left" value="-2em"/>
				<sm:entryStyle key="width" value="16px"/>
				<sm:entryStyle key="height" value="16px"/>
			</sm:htmlStyle>
		</sm:blockTag>
		<sm:blockTag tag="itemizedList">
			<sm:behaviors>
				<sm:keyBinding char="L"/>
			</sm:behaviors>
			<sm:subBlockTag tag="listItem">
				<sm:htmlStyle>
					<sm:entryStyle key="margin-left" value="1.2em"/>
				</sm:htmlStyle>
			</sm:subBlockTag>
			<sm:htmlStyle>
				<sm:entryStyle key="margin-left" value="15px"/>
				<sm:entryStyle key="list-style" value="disc"/>
			</sm:htmlStyle>
		</sm:blockTag>
		<sm:blockTag tag="orderedList">
			<sm:behaviors>
				<sm:keyBinding char="D"/>
			</sm:behaviors>
			<sm:subBlockTag tag="listItem">
				<sm:htmlStyle>
					<sm:entryStyle key="margin-left" value="1.2em"/>
				</sm:htmlStyle>
			</sm:subBlockTag>
			<sm:htmlStyle>
				<sm:entryStyle key="margin-left" value="12px"/>
				<sm:entryStyle key="list-style" value="decimal"/>
			</sm:htmlStyle>
		</sm:blockTag>
		<sm:blockTag tag="table">
			<sm:subBlockTag tag="cell">
				<sm:htmlStyle>
					<sm:entryStyle key="border" value="1px solid var(--edit-color)"/>
					<sm:entryStyle key="color" value="var(--edit-color)"/>
				</sm:htmlStyle>
			</sm:subBlockTag>
			<sm:subBlockTag tag="row" role="head">
				<sm:htmlStyle>
					<sm:entryStyle key="font-weight" value="bold"/>
					<sm:entryStyle key="background-color" value="var(--alt1-bgcolor)"/>
					<sm:entryStyle key="text-align" value="center"/>
				</sm:htmlStyle>
			</sm:subBlockTag>
			<sm:subBlockTag tag="caption">
				<sm:htmlStyle>
					<sm:entryStyle key="color" value="gray"/>
					<sm:entryStyle key="text-align" value="center"/>
				</sm:htmlStyle>
			</sm:subBlockTag>
		</sm:blockTag>
	</sm:editPoints>
</sm:textWdl>