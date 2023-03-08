<?xml version="1.0"?>
<sm:dataFormBoxWdl xmlns:sm="http://www.utc.fr/ics/scenari/v3/modeling">
	<sm:anyDataFormPrim/>
	<sm:editPoints>
		<sm:tag refCodes="content bridgehead">
			<sm:skippedWidget/>
		</sm:tag>
		<sm:tag refCodes="altAUDIO">
			<sm:headBodyWidget>
				<sm:container>
					<sm:body style="flex-direction:row !important;"/>
				</sm:container>
			</sm:headBodyWidget>
		</sm:tag>
		<sm:tag refCodes="phonem">
			<sm:openEdtWidget>
				<sm:contentBox draggable="true" orientation="horizontal">
					<sm:cssRules xml:space="preserve">:host{
    margin: .3em 1em 0 0;
border: 1px solid var(--border-color);
background-color: var(--row-bgcolor);
padding:0;
}
:host([annot=error]) ::slotted(*), :host([annot=error]) txt-root-str {
    min-width: 50px !important;
}
:host ::slotted(*) {
border:none;
min-width:auto;
}</sm:cssRules>
					<sm:addAttribute name="sc-comment">no</sm:addAttribute>
					<sm:call>
						<sm:inputEnumField textStyle="margin:.1em;"/>
					</sm:call>
				</sm:contentBox>
				<sm:ifAbsent>
					<sm:createButton/>
				</sm:ifAbsent>
			</sm:openEdtWidget>
		</sm:tag>
	</sm:editPoints>
</sm:dataFormBoxWdl>
