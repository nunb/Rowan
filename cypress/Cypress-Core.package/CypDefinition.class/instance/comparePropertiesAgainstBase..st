"
notice: Copyright 2013,2016 GemTalk Systems, LLC. Open source under the MIT license.
category: comparing
"
comparePropertiesAgainstBase: aDefinition

	| keys modification |
	modification := CypPropertiesModification new.
	keys := properties keys copy addAll: aDefinition properties keys.
	keys do: 
			[:key |
			| before after |
			before := self propertyAt: key ifAbsent: [nil].
			after := aDefinition propertyAt: key ifAbsent: [nil].
			before = nil
				ifTrue: [modification elementAdded: key -> after]
				ifFalse: 
					[after = nil
						ifTrue: [modification elementRemoved: key -> before]
						ifFalse: 
							[before = after
								ifFalse: 
									[modification add: (CypPropertyModification
												addElementModification: (CypPropertyModification
														key: key
														before: before
														after: after))]]]].
	^modification