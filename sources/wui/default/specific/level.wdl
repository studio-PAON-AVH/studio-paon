<?xml version="1.0"?>
<sm:compositionBoxWdl xmlns:sm="http://www.utc.fr/ics/scenari/v3/modeling" xmlns:sc="http://www.utc.fr/ics/scenari/v3/core">
	<sm:model sc:refUri="/model/structure/level1.model"/>
	<sm:model sc:refUri="/model/structure/level2.model"/>
	<sm:model sc:refUri="/model/structure/level3.model"/>
	<sm:model sc:refUri="/model/structure/level4.model"/>
	<sm:model sc:refUri="/model/structure/level5.model"/>
	<sm:model sc:refUri="/model/structure/level6.model"/>
	<sm:editPoints>
		<sm:tag refCodes="flow">
			<sm:skippedWidget/>
		</sm:tag>
		<sm:tag refCodes="level2">
			<sm:openEdtWidget>
				<sm:headBodyContentBox collapsed="allowed" collapsedMode="start-switch">
					<sm:head>
						<sm:call>
							<sm:meta axis="level2"/>
						</sm:call>
					</sm:head>
					<sm:body>
						<sm:call>
							<sm:subModel/>
						</sm:call>
					</sm:body>
				</sm:headBodyContentBox>
				<sm:ifAbsent>
					<sm:createButton/>
				</sm:ifAbsent>
			</sm:openEdtWidget>
		</sm:tag>
		<sm:tag refCodes="level3">
			<sm:openEdtWidget>
				<sm:headBodyContentBox collapsed="allowed" collapsedMode="start-switch">
					<sm:head>
						<sm:call>
							<sm:meta axis="level3"/>
						</sm:call>
					</sm:head>
					<sm:body>
						<sm:call>
							<sm:subModel/>
						</sm:call>
					</sm:body>
				</sm:headBodyContentBox>
				<sm:ifAbsent>
					<sm:createButton/>
				</sm:ifAbsent>
			</sm:openEdtWidget>
		</sm:tag>
		<sm:tag refCodes="level4">
			<sm:openEdtWidget>
				<sm:headBodyContentBox collapsed="allowed" collapsedMode="start-switch">
					<sm:head>
						<sm:call>
							<sm:meta axis="level4"/>
						</sm:call>
					</sm:head>
					<sm:body>
						<sm:call>
							<sm:subModel/>
						</sm:call>
					</sm:body>
				</sm:headBodyContentBox>
				<sm:ifAbsent>
					<sm:createButton/>
				</sm:ifAbsent>
			</sm:openEdtWidget>
		</sm:tag>
		<sm:tag refCodes="level5">
			<sm:openEdtWidget>
				<sm:headBodyContentBox collapsed="allowed" collapsedMode="start-switch">
					<sm:head>
						<sm:call>
							<sm:meta axis="level5"/>
						</sm:call>
					</sm:head>
					<sm:body>
						<sm:call>
							<sm:subModel/>
						</sm:call>
					</sm:body>
				</sm:headBodyContentBox>
				<sm:ifAbsent>
					<sm:createButton/>
				</sm:ifAbsent>
			</sm:openEdtWidget>
		</sm:tag>
		<sm:tag refCodes="level6">
			<sm:openEdtWidget>
				<sm:headBodyContentBox collapsed="allowed" collapsedMode="start-switch">
					<sm:head>
						<sm:call>
							<sm:meta axis="level6"/>
						</sm:call>
					</sm:head>
					<sm:body>
						<sm:call>
							<sm:subModel/>
						</sm:call>
					</sm:body>
				</sm:headBodyContentBox>
				<sm:ifAbsent>
					<sm:createButton/>
				</sm:ifAbsent>
			</sm:openEdtWidget>
		</sm:tag>
	</sm:editPoints>
</sm:compositionBoxWdl>