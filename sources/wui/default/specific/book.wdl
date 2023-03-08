<?xml version="1.0"?>
<sm:compositionBoxWdl xmlns:sm="http://www.utc.fr/ics/scenari/v3/modeling" xmlns:sc="http://www.utc.fr/ics/scenari/v3/core">
	<sm:model sc:refUri="/model/structure/book.model"/>
	<sm:editPoints>
		<sm:tag refCodes="frontmatter backcover sameAuthor inscription citation backmatter">
			<sm:headBodyWidget collapsed="allowed" collapsedMode="start-switch">
				<sm:ifAbsent>
					<sm:createButton/>
				</sm:ifAbsent>
			</sm:headBodyWidget>
		</sm:tag>
		<sm:tag refCodes="level1">
			<sm:openEdtWidget>
				<sm:headBodyContentBox collapsed="allowed" collapsedMode="start-switch">
					<sm:head>
						<sm:call>
							<sm:meta axis="level1"/>
						</sm:call>
					</sm:head>
					<sm:body>
						<sm:call>
							<sm:subModel/>
						</sm:call>
					</sm:body>
				</sm:headBodyContentBox>
			</sm:openEdtWidget>
		</sm:tag>
	</sm:editPoints>
</sm:compositionBoxWdl>