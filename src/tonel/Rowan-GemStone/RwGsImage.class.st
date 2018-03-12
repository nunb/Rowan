"
Keeps track of what LoadedPackages are in the GemStone repository, and is the gateway for operations to query or change the image.
"
Class {
	#name : 'RwGsImage',
	#superclass : 'Object',
	#category : 'Rowan-GemStone'
}

{ #category : 'private' }
RwGsImage class >> _loadedProjectRegistry [

	^ self _loadedProjectRegistryForUserId: self currentUserId
]

{ #category : 'private' }
RwGsImage class >> _loadedProjectRegistryForUserId: aUserId [

	| ug |
	ug := (AllUsers userWithId: aUserId) objectNamed: #'UserGlobals'.
	^ ug
		at: #'RwGsLoadedProjectRegistry'
		ifAbsent: [ 
			(self canWrite: ug)
				ifFalse: [ ^ nil ].
			ug at: #'RwGsLoadedProjectRegistry' put: StringKeyValueDictionary new ]
]

{ #category : 'private' }
RwGsImage class >> _projectRegistry [

	^ self _projectRegistryForUserId: self currentUserId
]

{ #category : 'private' }
RwGsImage class >> _projectRegistryForUserId: aUserId [

	"this is being left as is, because I am using Rowan to develop Rowan and eventually this guy should be deleted in favor of the _loadedProjectRegistryForUserId:"

	| ug |
	Transcript
		cr;
		show: 'remove me when Rowan spec is moved to loaded project registry'.
	ug := (AllUsers userWithId: aUserId) objectNamed: #'UserGlobals'.
	^ ug
		at: #'RwGsProjectRegistry'
		ifAbsent: [ 
			(self canWrite: ug)
				ifFalse: [ ^ nil ].
			ug at: #'RwGsProjectRegistry' put: StringKeyValueDictionary new ]
]

{ #category : 'querying' }
RwGsImage class >> _removeLoadedProject: aRwLoadedProject [

	"note that it is not safe to just remove a loaded project from the registry, however this method is supplied as a convenience for tests"

	| projectName projectRegistry |
	projectName := aRwLoadedProject name.
	projectRegistry := self
		_loadedProjectRegistryForUserId: aRwLoadedProject projectOwnerId.
	projectRegistry
		at: projectName
		ifPresent: [ :aLoadedProject | 
			aLoadedProject == aRwLoadedProject
				ifFalse: [ 
					self
						error:
							'The specified project is not identical to the loaded project in the registry ... this is not expected' ].
			projectRegistry removeKey: projectName ]
]

{ #category : 'querying' }
RwGsImage class >> addLoadedProject: aRwLoadedProject [

	"Register a project"

	| projectName projectRegistry |
	projectName := aRwLoadedProject name.
	projectRegistry := self
		_loadedProjectRegistryForUserId: aRwLoadedProject projectOwnerId.
	projectRegistry
		at: projectName
		ifPresent: [ :aLoadedProject | 
			self
				error:
					'There is already a project named ' , projectName printString , ' registered' ].
	^ projectRegistry at: projectName put: aRwLoadedProject
]

{ #category : 'querying' }
RwGsImage class >> addProject: aRwProjectSpecification [

	"Register a project"

	| projectName projectRegistry |
	projectName := aRwProjectSpecification specName.
	projectRegistry := self
		_projectRegistryForUserId:
			(aRwProjectSpecification platformSpec at: 'gemstone') projectOwnerId.
	projectRegistry
		at: projectName
		ifPresent: [ :aLoadedProject | 
			self
				error:
					'There is already a project named ' , projectName printString , ' registered' ].
	^ projectRegistry at: projectName put: aRwProjectSpecification
]

{ #category : 'modifying image' }
RwGsImage class >> applyModification: aProjectSetModification [

	| visitor patchSet |
	visitor := RwGsImagePatchVisitor new.
	visitor visit: aProjectSetModification.
	patchSet := visitor patchSet.
	patchSet classesWithNewVersions isEmpty
		ifTrue: [ 
			patchSet apply.
			^ self ].
	patchSet classesWithNewVersions
		do: [ :each | 
			each
				updatePatchesForNewClassVersion: aProjectSetModification;
				updateNewClassVersionPatchesForExtensionsIn: aProjectSetModification
					patchSet: patchSet ].
	visitor := RwGsImagePatchVisitor new.
	visitor visit: aProjectSetModification.
	patchSet := visitor patchSet.
	patchSet applyForNewClassVersions
]

{ #category : 'testing' }
RwGsImage class >> canWrite: anObject [

	^ System canWrite: anObject
]

{ #category : 'querying' }
RwGsImage class >> currentUserId [

	^ GsCurrentSession currentSession userProfile userId
]

{ #category : 'querying' }
RwGsImage class >> existingSymbolDictionaryNamed: dictName [

	"If the current session's transient symbol list includes a dictionary with the given name, answer it. "

	| symbolName |
	symbolName := dictName asSymbol.
	^ self symbolList
		detect: [ :each | (each at: symbolName ifAbsent: [ nil ]) == each ]
		ifNone: [ nil ]
]

{ #category : 'querying' }
RwGsImage class >> loadedClassExtensionsForClass: class [

	"lookup the loadedClassExtensions for the given class"

	| history found |
	history := class classHistory.
	found := IdentitySet new.
	self symbolList
		do: [ :symbolDict | 
			(symbolDict isKindOf: RwGsPackageSymbolDictionary)
				ifTrue: [ 
					(symbolDict classExtensionRegistry at: history ifAbsent: [  ])
						ifNotNil: [ :loadedClassExtensionSet | found addAll: loadedClassExtensionSet ] ] ].
	^ found
]

{ #category : 'querying' }
RwGsImage class >> loadedClassExtensionsNamed: className ifFound: foundBlock ifAbsent: absentBlock [

	"scan the symbol list for a RwLoadedClassExtension instances of the given name"

	| class found |
	class := self objectNamed: className.
	class ifNil: [ ^ absentBlock value ].
	found := self loadedClassExtensionsForClass: class.
	found isEmpty
		ifFalse: [ ^ foundBlock value: found ].
	^ absentBlock value
]

{ #category : 'querying' }
RwGsImage class >> loadedClassForClass: class ifAbsent: absentBlock [

	"Lookup the given class in the classRegistry"

	| history |
	history := class classHistory.
	self symbolList
		do: [ :symbolDict | 
			(symbolDict isKindOf: RwGsPackageSymbolDictionary)
				ifTrue: [ 
					(symbolDict classRegistry at: history ifAbsent: [  ])
						ifNotNil: [ :loadedClass | ^ loadedClass ] ] ].
	^ absentBlock value
]

{ #category : 'querying' }
RwGsImage class >> loadedClassNamed: className ifFound: foundBlock ifAbsent: absentBlock [

	"scan the symbol list for a RwLoadedClass instance of the given name"

	| class loadedClass |
	class := self objectNamed: className.
	class ifNil: [ ^ absentBlock value ].
	loadedClass := self
		loadedClassForClass: class
		ifAbsent: [ ^ absentBlock value ].
	^ foundBlock value: loadedClass
]

{ #category : 'querying' }
RwGsImage class >> loadedMethod: selector inClassNamed: className isMeta: isMeta ifFound: foundBlock ifAbsent: absentBlock [

	"scan the symbol list for a RwLoadedMethod instances for the given selector in the named class"

	| behavior compiledMethod |
	behavior := self objectNamed: className.
	behavior ifNil: [ ^ absentBlock value ].
	isMeta
		ifTrue: [ behavior := behavior class ].
	compiledMethod := behavior
		compiledMethodAt: selector asSymbol
		environmentId: 0
		otherwise: nil.
	compiledMethod ifNil: [ ^ absentBlock value ].
	self symbolList
		do: [ :symbolDict | 
			(symbolDict isKindOf: RwGsPackageSymbolDictionary)
				ifTrue: [ 
					(symbolDict methodRegistry at: compiledMethod ifAbsent: [  ])
						ifNotNil: [ :loadedMethod | ^ foundBlock value: loadedMethod ] ] ].
	^ absentBlock value
]

{ #category : 'querying' }
RwGsImage class >> loadedMethodForMethod: compiledMethod ifAbsent: absentBlock [

	"scan the symbol list for a RwLoadedMethod instances for the given compiled method"

	self symbolList
		do: [ :symbolDict | 
			(symbolDict isKindOf: RwGsPackageSymbolDictionary)
				ifTrue: [ 
					(symbolDict methodRegistry at: compiledMethod ifAbsent: [  ])
						ifNotNil: [ :loadedMethod | ^ loadedMethod ] ] ].
	^ absentBlock value
]

{ #category : 'querying' }
RwGsImage class >> loadedPackageNamed: aString [

	^ self
		loadedPackageNamed: aString
		ifAbsent: [ self error: 'No loaded package named ' , aString printString , ' found' ]
]

{ #category : 'querying' }
RwGsImage class >> loadedPackageNamed: aName ifAbsent: absentBlock [

	"scan the symbol list a RwLoadedPackage instance of the given name"

	self symbolList
		do: [ :symbolDict | 
			(symbolDict isKindOf: RwGsPackageSymbolDictionary)
				ifTrue: [ 
					(symbolDict loadedPackageNamed: aName ifAbsent: [  ])
						ifNotNil: [ :loadedPackage | ^ loadedPackage ] ] ].
	^ absentBlock value
]

{ #category : 'querying' }
RwGsImage class >> loadedProjectNamed: aString [

	^ self
		loadedProjectNamed: aString
		ifAbsent: [ self error: 'No loaded project named ' , aString printString , ' found' ]
]

{ #category : 'querying' }
RwGsImage class >> loadedProjectNamed: aString ifAbsent: absentBlock [

	"Look up a loaded project. First in current users project registry, then scan AllUsers for the project ... note that the user needs to be the project owner."

	| currentUserId |
	currentUserId := self currentUserId.
	^ self _loadedProjectRegistry
		at: aString
		ifAbsent: [ 
			AllUsers
				do: [ :userProfile | 
					| userId |
					userId := userProfile userId.
					userId ~= currentUserId
						ifTrue: [ 
							(self _loadedProjectRegistryForUserId: userId)
								ifNotNil: [ :projectRegistry | 
									projectRegistry
										at: aString
										ifPresent: [ :loadedProject | 
											(loadedProject specification platformSpect at: 'gemstone') projectOwnerId
												= userId
												ifTrue: [ ^ loadedProject ] ] ] ] ].
			^ absentBlock value ]
]

{ #category : 'querying' }
RwGsImage class >> newOrExistingSymbolDictionaryNamed: dictName [

	"If the current session's transient symbol list includes a dictionary with the given name, answer it.
	Otherwise, create one, add it to the beginning of both transient and persistent symbol lists, and 
	answer it."

	| symbolName session symbolList association |
	symbolName := dictName asSymbol.
	session := GsCurrentSession currentSession.
	symbolList := session symbolList.
	^ symbolList
		detect: [ :each | (each at: symbolName ifAbsent: [ nil ]) == each ]
		ifNone: [ 
			| newDict |
			newDict := RwGsPackageSymbolDictionary new
				name: symbolName;
				objectSecurityPolicy: symbolList objectSecurityPolicy;
				yourself.
			symbolList insertObject: newDict at: 1.
			session userProfile symbolList addLast: newDict.
			newDict ]
]

{ #category : 'querying' }
RwGsImage class >> objectNamed: aSymbol [

	"Returns the first object in the current session's symbol list that has the given
 name.  If no object with the given name is found, returns nil."

	^ GsCurrentSession currentSession symbolList objectNamed: aSymbol
]

{ #category : 'querying' }
RwGsImage class >> projectNamed: aString ifAbsent: absentBlock [

	"Look up a project. First in current users project registry, then scan AllUsers for the project ... note that the user needs to be the project owner."

	| currentUserId |
	currentUserId = self currentUserId.
	^ self _projectRegistry
		at: aString
		ifAbsent: [ 
			AllUsers
				do: [ :userProfile | 
					| userId |
					userId := userProfile userId.
					userId ~= currentUserId
						ifTrue: [ 
							(self _projectRegistryForUserId: userId)
								ifNotNil: [ :projectRegistry | 
									projectRegistry
										at: aString
										ifPresent: [ :projectSpec | 
											(projectSpec platformSpec at: 'gemstone') projectOwnerId = userId
												ifTrue: [ ^ projectSpec ] ] ] ] ].
			^ absentBlock value ]
]

{ #category : 'querying' }
RwGsImage class >> projectNames [

	"Return list of project names"

	| currentUserId projectNames |
	currentUserId = self currentUserId.
	projectNames := Set new.
	projectNames addAll: self _projectRegistry keys.
	AllUsers
		do: [ :userProfile | 
			| userId |
			userId := userProfile userId.
			userId ~= currentUserId
				ifTrue: [ 
					(self _projectRegistryForUserId: userId)
						ifNotNil: [ :projectRegistry | projectNames addAll: projectRegistry keys ] ] ].
	^ projectNames
]

{ #category : 'querying' }
RwGsImage class >> removeLoadedClassExtensionsForClass: class [

	"The class has or will be deleted from the system, remove the loadedClassExtensions that refer
		to the given class"

	| history |
	history := class classHistory.
	self symbolList
		do: [ :symbolDict | 
			(symbolDict isKindOf: RwGsPackageSymbolDictionary)
				ifTrue: [ symbolDict classExtensionRegistry removeKey: history ifAbsent: [  ] ] ]
]

{ #category : 'querying' }
RwGsImage class >> removeLoadedMethodForCompileMethod: compiledMethod [

	"The given compiled method is being removed from the system, remove the loadedMethod associated 
		with the compiled method."

	self symbolList
		do: [ :symbolDict | 
			(symbolDict isKindOf: RwGsPackageSymbolDictionary)
				ifTrue: [ symbolDict methodRegistry removeKey: compiledMethod ifAbsent: [  ] ] ]
]

{ #category : 'querying' }
RwGsImage class >> removeProject: aRwProjectSpecification [

	"remove a project"

	| projectName |
	projectName := aRwProjectSpecification specName.
	(self
		_projectRegistryForUserId:
			(aRwProjectSpecification platformSpec at: 'gemstone') projectOwnerId)
		removeKey: projectName
		ifAbsent: [  ]
]

{ #category : 'querying' }
RwGsImage class >> resolveClassNamed: aName [

	"If the given name is bound to a class in the environment of the current session, 
	answer that class. Otherwise, answer nil."

	| resolved |
	resolved := self objectNamed: aName.
	^ (resolved isBehavior and: [ resolved isMeta not ])
		ifTrue: [ resolved ]
		ifFalse: [ nil ]
]

{ #category : 'querying' }
RwGsImage class >> resolveName: aName [

	"Searches the current session's symbol list for an Association whose key is equal to
 aString, and returns that Association.  If no such Association is found in the
 symbol list, returns nil. Uses the current session's transient copy of the symbol list."

	^ GsCurrentSession currentSession resolveSymbol: aName asSymbol
]

{ #category : 'querying' }
RwGsImage class >> symbolList [

	"Answer the current session (transient) symbol list"

	^ GsCurrentSession currentSession symbolList
]