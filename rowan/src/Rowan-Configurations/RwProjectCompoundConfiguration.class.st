Class {
	#name : 'RwProjectCompoundConfiguration',
	#superclass : 'RwAbstractProjectConfiguration',
	#instVars : [
		'packageNames'
	],
	#category : 'Rowan-Configurations'
}

{ #category : 'private' }
RwProjectCompoundConfiguration >> _configurations [

	| spec urlBase |
	self configurationNames isEmpty ifTrue: [ ^ #() ].
	spec := self _specification.
	urlBase := 'file:' , spec repositoryRootPath , '/' , spec configsPath , '/'.
	^ self configurationNames
		collect: [ :configName | 
			| url |
			url := urlBase , configName , '.ston'.
			(RwAbstractProjectConfiguration fromUrl: url)
				projectName: self projectName;
				yourself ]

]

{ #category : 'visiting' }
RwProjectCompoundConfiguration >> acceptCompoundVisitor: aVisitor [

	^aVisitor visitProjectCompoundConfiguration: self

]

{ #category : 'visiting' }
RwProjectCompoundConfiguration >> acceptVisitor: aVisitor [

	^self acceptCompoundVisitor: aVisitor

]

{ #category : 'initialization' }
RwProjectCompoundConfiguration >> initialize [

	super initialize.
	packageNames := Set new.

]

{ #category : 'accessing' }
RwProjectCompoundConfiguration >> packageNames [

   ^packageNames

]

{ #category : 'accessing' }
RwProjectCompoundConfiguration >> packageNames: anObject [

   packageNames := anObject

]

{ #category : 'load support' }
RwProjectCompoundConfiguration >> resolvePackageNames [

	"return the list of package names that is the result of resolving all of the receiver's references"

	"resolve each of the configurations in configurationNames to a list of package names and combine
		with the receiver's package names"

	| visitedConfigurationNames |
	visitedConfigurationNames := Set new.
	^ self resolvePackageNames: visitedConfigurationNames
]

{ #category : 'load support' }
RwProjectCompoundConfiguration >> resolvePackageNames: visitedConfigurationNames [

	| thePackageNames |
	(visitedConfigurationNames includes: self name)
		ifTrue: [ ^ #() ].
	visitedConfigurationNames add: self name.
	thePackageNames := self packageNames copy.
	self _configurations
		do: [ :config | thePackageNames addAll: (config resolvePackageNames: visitedConfigurationNames) ].
	^ thePackageNames
]
