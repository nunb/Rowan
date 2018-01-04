Class {
	#name : 'RwMethodDefinition',
	#superclass : 'RwDefinition',
	#instVars : [
		'source'
	],
	#category : 'Rowan-Core'
}

{ #category : 'instance creation' }
RwMethodDefinition class >> withProperties: propertiesDictionary source: sourceString [ 

	^(self basicNew)
		properties: propertiesDictionary;
		source: sourceString;
		yourself

]

{ #category : 'comparing' }
RwMethodDefinition >> compareAgainstBase: aDefinition [ 

	| modification |
	modification := RwMethodModification before: aDefinition after: self.
	modification
		propertiesModification: (self comparePropertiesAgainstBase: aDefinition);
		sourceModification: (self compareSourceAgainstBase: aDefinition).
	^modification

]

{ #category : 'comparing' }
RwMethodDefinition >> compareSourceAgainstBase: aDefinition [

	| modification |
	modification := RwSourceModification new.
	aDefinition source ~= self source
		ifTrue: [
			| before after |
			before := aDefinition source.
			after := self source.
			modification addElementModification: (RwPropertyModification
								key: 'source'
								oldValue: before
								newValue: after) ].
	^modification
]

{ #category : 'testing' }
RwMethodDefinition >> isEmpty [
	"Answer true if this definition does not actually define anything."

	^super isEmpty & source isNil

]

{ #category : 'private' }
RwMethodDefinition >> key [

	^properties at: 'selector' ifAbsent: [nil]

]

{ #category : 'accessing' }
RwMethodDefinition >> selector [

	^properties at: 'selector'
]

{ #category : 'accessing' }
RwMethodDefinition >> source [

	^source

]

{ #category : 'accessing' }
RwMethodDefinition >> source: sourceString [

	source := sourceString

]