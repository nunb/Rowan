instance creation
createOn: aUrl alias: aString withGemStoneFileouts: fileoutBoolean

	^(aUrl repositoryClass new)
		initializeCreationOn: aUrl
			alias: aString
			withGemStoneFileouts: fileoutBoolean;
		yourself