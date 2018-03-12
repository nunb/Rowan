Class {
	#name : 'RwGsPackageSymbolDictionary',
	#superclass : 'SymbolDictionary',
	#instVars : [
		'packageRegistry',
		'classRegistry',
		'classExtensionRegistry',
		'methodRegistry'
	],
	#category : 'Rowan-GemStone'
}

{ #category : 'accessing' }
RwGsPackageSymbolDictionary class >> _classAdditionPatchClass [

	^ RwGsClassAdditionSymbolDictPatch
]

{ #category : 'accessing' }
RwGsPackageSymbolDictionary class >> _classDeletionPatchClass [

	^ RwGsClassDeletionSymbolDictPatch 
]

{ #category : 'accessing' }
RwGsPackageSymbolDictionary class >> _classExtensionPatchClass [

	^ RwGsClassExtensionSymbolDictPatch
]

{ #category : 'accessing' }
RwGsPackageSymbolDictionary class >> _classPropertiesPatchClass [

	^ RwGsClassPropertiesSymDictPatch
]

{ #category : 'accessing' }
RwGsPackageSymbolDictionary class >> _classVariablePatchClass [

	^ RwGsClassVariableChangeSymbolDictPatch
]

{ #category : 'accessing' }
RwGsPackageSymbolDictionary class >> _classVersioningPatchClass [

	^ RwGsClassVersioningSymbolDictPatch
]

{ #category : 'accessing' }
RwGsPackageSymbolDictionary class >> _methodAdditionPatchClass [

	^ RwGsMethodAdditionSymbolDictPatch
]

{ #category : 'accessing' }
RwGsPackageSymbolDictionary class >> _methodDeletionPatchClass [

	^ RwGsMethodDeletionSymbolDictPatch
]

{ #category : 'accessing' }
RwGsPackageSymbolDictionary class >> _methodExtensionDeletionPatchClass [

	^ RwGsMethodDeletionSymbolDictPatch
]

{ #category : 'accessing' }
RwGsPackageSymbolDictionary class >> _methodExtensionPatchClass [

	^ RwGsMethodExtensionSymbolDictPatch
]

{ #category : 'accessing' }
RwGsPackageSymbolDictionary class >> _methodExtensionSessionMethodsDeletionPatchClass [

	^ RwGsMethodDeletionExtensionSessionMethodSymbolDictPatch
]

{ #category : 'accessing' }
RwGsPackageSymbolDictionary class >> _methodExtensionSessionMethodsPatchClass [

	^ RwGsMethodExtensionSessionMethodSymbolDictPatch
]

{ #category : 'accessing' }
RwGsPackageSymbolDictionary class >> _methodPropertiesPatchClass [

	^ RwGsMethodPropertiesSymDictPatch
]

{ #category : 'accessing' }
RwGsPackageSymbolDictionary class >> _methodSourcePatchClass [

	^ RwGsMethodSourceSymbolDictPatch
]

{ #category : 'accessing' }
RwGsPackageSymbolDictionary class >> _packageAdditionPatchClass [

	^ RwGsPackageAdditionSymbolDictPatch
]

{ #category : 'accessing' }
RwGsPackageSymbolDictionary class >> _packageDeletionPatchClass [

	^ RwGsPackageDeletionSymbolDictPatch
]

{ #category : 'accessing' }
RwGsPackageSymbolDictionary class >> defaultProtocolString [

	^ 'as yet unclassified'
]

{ #category : 'instance creation' }
RwGsPackageSymbolDictionary class >> newNamed: aSymbol [

	^ self new
		name: aSymbol;
		yourself
]

{ #category : 'method - private api' }
RwGsPackageSymbolDictionary >> _doDeleteCompiledMethod: compiledMethod from: behavior [

	"delete a compiled method from behavior"

	| selector |
	selector := compiledMethod selector.
	behavior removeSelector: selector asString environmentId: 0
]

{ #category : 'method - private api' }
RwGsPackageSymbolDictionary >> _doDeleteCompiledMethodFromLoadedThings: compiledMethod for: behavior [

	"remove a compiled method from loaded things"

	| loadedMethod loadedPackage loadedClassOrExtension |
	loadedMethod := methodRegistry
		at: compiledMethod
		ifAbsent: [ 
			self
				error:
					'Internal error -- no existing LoadedMethod found for deleted method.' ].

	methodRegistry removeKey: compiledMethod.

	loadedPackage := loadedMethod loadedPackage.
	loadedClassOrExtension := loadedPackage
		classOrExtensionForClass: behavior
		ifAbsent: [ 
			self
				error:
					'Internal error -- attempt to remove a method from a package in which its class is neither defined nor extended.' ].

	loadedClassOrExtension removeLoadedMethod: loadedMethod
]

{ #category : 'private' }
RwGsPackageSymbolDictionary >> _initializeWithoutClear: newSize [

	super _initializeWithoutClear: newSize.
	packageRegistry := KeyValueDictionary new.	"keyed by package name"
	classRegistry := IdentityKeyValueDictionary new.	"keyed by class classHistory"
	classExtensionRegistry := IdentityKeyValueDictionary new.	"keyed by class classHistory"
	methodRegistry := IdentityKeyValueDictionary new.	"keyed by compiledMethod"
	^ self
]

{ #category : 'private' }
RwGsPackageSymbolDictionary >> _loadedClassFor: class noNewVersion: noNewVersionBlock [

	self
		_loadedClassFor: class
		noNewVersion: noNewVersionBlock
		newVersion: [ :loadedClass | 
			self
				error:
					'internal error - the value associated with the key ' , class name printString
						, ' is not identical to the given class' ]
]

{ #category : 'private' }
RwGsPackageSymbolDictionary >> _loadedClassFor: class noNewVersion: noNewVersionBlock newVersion: newVersionBlock [

	| loadedClass classKey |
	(class isKindOf: Class)
		ifFalse: [ self error: 'internal error - expected a class' ].
	loadedClass := classRegistry
		at: class classHistory
		ifAbsent: [ 
			self
				error:
					'internal error - No package found for the class ' , class name printString ].
	classKey := loadedClass key asSymbol.
	self
		associationAt: classKey
		ifPresent: [ :assoc | 
			assoc value == class
				ifTrue: [ ^ noNewVersionBlock cull: loadedClass cull: assoc ]
				ifFalse: [ ^ newVersionBlock cull: loadedClass cull: assoc ] ].

	self
		error:
			'internal error - there is no assocation present in the receiver for the given class '
				, classKey asString printString
]

{ #category : 'class - patch api' }
RwGsPackageSymbolDictionary >> addClassAssociation: assoc forClass: class toPackageNamed: packageName [

	"Copy the name association to the correct 
        SymbolDictionary in the live SymbolList.
        Create a LoadedClass for the new class, add it to the defining LoadedPackage."

	| loadedPackage loadedClass |
	(class isKindOf: Class)
		ifFalse: [ self error: 'internal error - expected a class association' ].
	loadedPackage := self packageRegistry
		at: packageName
		ifAbsent: [ 
			self packageRegistry
				at: packageName
				put: (RwGsLoadedSymbolDictPackage newNamed: packageName) ].
	self
		at: assoc key
		ifPresent: [ 
			self
				error:
					'internal error - there is an existing assocition with the same key: '
						, assoc key printString ].
	classRegistry
		at: class classHistory
		ifAbsent: [ 
			loadedClass := RwGsLoadedSymbolDictClass newForClass: class.
			loadedPackage addLoadedClass: loadedClass.
			loadedClass updatePropertiesFromClassFor: self.
			classRegistry at: class classHistory put: loadedClass.
			loadedPackage loadedClassExtensions
				at: class name
				ifPresent: [ :loadedClassExtension | 
					"I think we need to subsume the loadedClassExtension methods into a loadedClass ..."
					self halt ] ].

	assoc value: class.
	self add: assoc
]

{ #category : 'method - patch api' }
RwGsPackageSymbolDictionary >> addExtensionCompiledMethod: compiledMethod for: behavior protocol: protocolString toPackageNamed: packageName [

	| methodDictionary selector protocolSymbol existing loadedMethod loadedPackage loadedClassExtension properties |
	methodDictionary := behavior persistentMethodDictForEnv: 0.
	selector := compiledMethod selector.
	methodDictionary at: selector put: compiledMethod.

	protocolSymbol := protocolString asSymbol.
	(behavior includesCategory: protocolSymbol)
		ifFalse: [ behavior addCategory: protocolSymbol ].
	behavior moveMethod: selector toCategory: protocolSymbol.

	existing := methodRegistry at: compiledMethod ifAbsent: [ nil ].
	existing
		ifNotNil: [ 
			self
				error:
					'Internal error -- existing LoadedMethod found for extension compiled method.' ].
	loadedMethod := RwGsLoadedSymbolDictMethod forMethod: compiledMethod.

	methodRegistry at: compiledMethod put: loadedMethod.

	loadedPackage := self packageRegistry
		at: packageName
		ifAbsent: [ 
			self packageRegistry
				at: packageName
				put: (RwGsLoadedSymbolDictPackage newNamed: packageName) ].

	loadedClassExtension := loadedPackage
		loadedClassExtensionForClass: behavior
		ifAbsent: [ 
			| class ext |
			class := behavior theNonMetaClass.
			ext := RwGsLoadedSymbolDictClassExtension
				newForClass: class
				inPackage: loadedPackage.
			(self classExtensionRegistry
				at: class classHistory
				ifAbsentPut: [ IdentitySet new ]) add: ext.
			ext ].
	loadedClassExtension addLoadedMethod: loadedMethod
]

{ #category : 'method - patch api' }
RwGsPackageSymbolDictionary >> addExtensionSessionMethods: methDict catDict: catDict for: behavior toPackageNamed: packageName [

	"expecting only a single method to be in methDict/catDict"

	| dictsArray mDict cDict existing loadedMethod loadedPackage loadedClassExtension compiledMethod |
	dictsArray := self homeSessionMethods methodAndCategoryDictionaryFor: behavior.
	mDict := dictsArray at: 1.
	cDict := dictsArray at: 2.
	catDict
		keysAndValuesDo: [ :protocolSymbol :selectors | 
			| symbolSet |
			symbolSet := cDict
				at: protocolSymbol
				ifAbsent: [ cDict at: protocolSymbol put: SymbolSet new ].
			symbolSet addAll: selectors ].
	methDict
		keysAndValuesDo: [ :sel :meth | 
			mDict at: sel put: meth.
			GsPackagePolicy current updateMethodLookupCacheFor: meth in: behavior.
			compiledMethod := meth ].

	existing := methodRegistry at: compiledMethod ifAbsent: [ nil ].
	existing
		ifNotNil: [ 
			self
				error:
					'Internal error -- existing LoadedMethod found for extension compiled method.' ].
	loadedMethod := RwGsLoadedSymbolDictMethod forMethod: compiledMethod.

	methodRegistry at: compiledMethod put: loadedMethod.

	loadedPackage := self packageRegistry
		at: packageName
		ifAbsent: [ 
			self packageRegistry
				at: packageName
				put: (RwGsLoadedSymbolDictPackage newNamed: packageName) ].

	loadedClassExtension := loadedPackage
		loadedClassExtensionForClass: behavior
		ifAbsent: [ 
			| class ext |
			class := behavior theNonMetaClass.
			ext := RwGsLoadedSymbolDictClassExtension
				newForClass: class
				inPackage: loadedPackage.
			(self classExtensionRegistry
				at: class classHistory
				ifAbsentPut: [ IdentitySet new ]) add: ext.
			ext ].
	loadedClassExtension addLoadedMethod: loadedMethod.

	^ compiledMethod
]

{ #category : 'class - patch api' }
RwGsPackageSymbolDictionary >> addNewClassVersionToAssociation: newClass [

	"a new class version is being added to the association in the receiver previously occupied by the original class"

	self
		_loadedClassFor: newClass
		noNewVersion: [ 
			"newClass is actually not a new class version of existing class, that's okay... update properties anyway"
			self updateClassProperties: newClass.
			^ self ]
		newVersion: [ :loadedClass :assoc | 
			"association for class is present, install in association and update the loadedthing"
			assoc value: newClass.
			loadedClass handleClassDeletionOrNewVersion
				ifTrue: [ loadedClass updatePropertiesFromClassFor: self ]
				ifFalse: [ self error: 'internal error - new version of class not properly installed' ] ]
]

{ #category : 'method - patch api' }
RwGsPackageSymbolDictionary >> addNewCompiledMethod: compiledMethod for: behavior protocol: protocolString toPackageNamed: packageName [

	| methodDictionary selector protocolSymbol existing loadedMethod loadedPackage loadedClassOrExtension properties |
	methodDictionary := behavior persistentMethodDictForEnv: 0.
	selector := compiledMethod selector.
	methodDictionary
		at: selector
		ifPresent: [ :oldCompiledMethod | 
			"there is an existing compiled method ... that means we're adding a recompiled methoded and moving it to the (possibly new) protocol"
			^ self
				addRecompiledMethod: compiledMethod;
				moveCompiledMethod: compiledMethod toProtocol: protocolString;
				yourself ].
	methodDictionary at: selector put: compiledMethod.

	protocolSymbol := protocolString asSymbol.
	(behavior includesCategory: protocolSymbol)
		ifFalse: [ behavior addCategory: protocolSymbol ].
	behavior moveMethod: selector toCategory: protocolSymbol.

	existing := methodRegistry at: compiledMethod ifAbsent: [ nil ].
	existing
		ifNotNil: [ self error: 'Internal error -- existing LoadedMethod found for compiled method.' ].
	loadedMethod := RwGsLoadedSymbolDictMethod forMethod: compiledMethod.

	methodRegistry at: compiledMethod put: loadedMethod.

	loadedPackage := self
		loadedPackageNamed: packageName
		ifAbsent: [ 
			self
				error: 'Internal error -- attempt to add a method to a nonexistent package.' ].

	loadedClassOrExtension := loadedPackage
		loadedClassOrClassExtensionForClass: behavior
		ifAbsent: [ 
			self
				error:
					'Internal error -- attempt to add a method to a package in which its class is neither defined nor extended.' ].
	loadedClassOrExtension addLoadedMethod: loadedMethod
]

{ #category : 'method - patch api' }
RwGsPackageSymbolDictionary >> addRecompiledMethod: newCompiledMethod [

	"add a recompiled compiled method to behavior and update the loaded things"

	| selector behavior methodDictionary oldCompiledMethod loadedMethod |
	selector := newCompiledMethod selector.
	behavior := newCompiledMethod inClass.
	methodDictionary := behavior persistentMethodDictForEnv: 0.
	oldCompiledMethod := methodDictionary
		at: selector
		ifAbsent: [ 
			| loadedClass |
			loadedClass := classRegistry
				at: behavior theNonMetaClass classHistory
				ifAbsent: [ 
					self
						error:
							'Internal error -- The class is not in any known package and no package has been specified' ].
			^ self
				addNewCompiledMethod: newCompiledMethod
				for: behavior
				protocol: self class defaultProtocolString
				toPackageNamed: loadedClass packageName ].

	oldCompiledMethod == newCompiledMethod
		ifTrue: [ 
			"exit early, no more work to be done"
			^ self ].
	methodDictionary at: selector put: newCompiledMethod.

	loadedMethod := methodRegistry
		at: oldCompiledMethod
		ifAbsent: [ 
			self
				error:
					'Internal error -- no existing LoadedMethod found for the old compiledMethod.' ].
	methodRegistry removeKey: oldCompiledMethod.
	loadedMethod handle: newCompiledMethod.
	methodRegistry at: newCompiledMethod put: loadedMethod
]

{ #category : 'accessing' }
RwGsPackageSymbolDictionary >> associationAt: aKey ifPresent: oneArgBlock [

	"Lookup the given key in the receiver. If it is present, answer the value of evaluating the oneArgBlock with the symbol association associated with the key, otherwise answer nil."

	| anAssoc |
	anAssoc := self associationAt: aKey otherwise: nil.
	anAssoc ifNotNil: [ ^ oneArgBlock value: anAssoc ].
	^ nil
]

{ #category : 'accessing' }
RwGsPackageSymbolDictionary >> associationAt: key ifPresent: oneArgBlock ifAbsent: absentBlock [

	"Lookup the given key in the receiver. If it is present, answer the value of evaluating the oneArgBlock with the symbol association associated with the key, otherwise answer the value of absentBlock."

	self associationAt: key ifPresent: [ :v | ^ oneArgBlock value: v ].
	^ absentBlock value
]

{ #category : 'accessing' }
RwGsPackageSymbolDictionary >> at: key ifPresent: aBlock [

	"Lookup the given key in the receiver. If it is present, answer the value of evaluating the given block with the value associated with the key. Otherwise, answer nil."

	| v |
	v := self at: key ifAbsent: [ ^ nil ].
	^ aBlock value: v
]

{ #category : 'accessing' }
RwGsPackageSymbolDictionary >> at: key ifPresent: oneArgBlock ifAbsent: absentBlock [

	"Lookup the given key in the receiver. If it is present, answer the value of evaluating the oneArgBlock with the value associated with the key, otherwise answer the value of absentBlock."

	self at: key ifPresent: [ :v | ^ oneArgBlock value: v ].
	^ absentBlock value
]

{ #category : 'private - migration avoidance' }
RwGsPackageSymbolDictionary >> become: ignored [

	"skip migration until the class definition settles down a bit"

	
]

{ #category : 'accessing' }
RwGsPackageSymbolDictionary >> classExtensionRegistry [

	^ classExtensionRegistry
]

{ #category : 'accessing' }
RwGsPackageSymbolDictionary >> classRegistry [

   ^classRegistry

]

{ #category : 'package - patch api' }
RwGsPackageSymbolDictionary >> createLoadedPackageFromDefinition: packageDefinition [

	^ self
		createLoadedPackageNamed: packageDefinition key
		properties: packageDefinition properties
]

{ #category : 'package - patch api' }
RwGsPackageSymbolDictionary >> createLoadedPackageNamed: packageName properties: properties [

	| existingLoadedPackage newLoadedPackage |
	existingLoadedPackage := packageRegistry at: packageName ifAbsent: [ nil ].
	existingLoadedPackage
		ifNotNil: [ self error: 'Internal error -- Attempt to add a package that exists.' ].
	newLoadedPackage := RwGsLoadedSymbolDictPackage newNamed: packageName.
	newLoadedPackage setPropertiesTo: properties.
	packageRegistry at: packageName put: newLoadedPackage.
	^ newLoadedPackage
]

{ #category : 'class - patch api' }
RwGsPackageSymbolDictionary >> deleteClassFromPackage: class [

	"a class association is being deleted from the receiver remove it from the loaded things"

	self
		_loadedClassFor: class
		noNewVersion: [ :loadedClass | 
			"association for class is present, finish delete operation"
			loadedClass removeFromLoaded: self.
			classRegistry removeKey: class classHistory.
			self removeKey: loadedClass key asSymbol ]
]

{ #category : 'class - patch api' }
RwGsPackageSymbolDictionary >> deleteClassNamedFromPackage: className [

	"a class association is being deleted from the receiver remove it from the loaded things"

	| class |
	class := self 
		at: className asSymbol
		ifAbsent: [ self error: 'No class found for the given class name: ', className printString ].
	self deleteClassFromPackage: class
]

{ #category : 'method - patch api' }
RwGsPackageSymbolDictionary >> deleteCompiledMethod: compiledMethod from: behavior [

	"delete a compiled method from behavior and remove it from the loaded things"

	self _doDeleteCompiledMethod: compiledMethod from: behavior.

	self _doDeleteCompiledMethodFromLoadedThings: compiledMethod for: behavior
]

{ #category : 'method - patch api' }
RwGsPackageSymbolDictionary >> deleteMethod: selector for: behavior [

	| compiledMethod |

	compiledMethod := behavior compiledMethodAt: selector.
	self deleteCompiledMethod: compiledMethod from: behavior

]

{ #category : 'method - patch api' }
RwGsPackageSymbolDictionary >> deletePackage: packageName [

	| loadedPackage |
	loadedPackage := packageRegistry
		removeKey: packageName
		ifAbsent: [ self error: 'package ' , packageName printString , ' not found' ].
	loadedPackage loadedProject removeLoadedPackage: loadedPackage
]

{ #category : 'class - patch api' }
RwGsPackageSymbolDictionary >> ensureExtensionClassNamed: className existsForPackageNamed: packageName [

	| extensionClass loadedPackage loadedClassExtension |
	extensionClass := self
		at: className asSymbol
		ifAbsent: [ 
			self
				error:
					'The extension class named ' , className printString
						, ' cannot be foud in this symbol dictionary (' , self name printString
						,
							'). Packages that extend a class must be loaded into the symbol dictionary in which the class is installed.' ].
	loadedPackage := self packageRegistry
		at: packageName
		ifAbsent: [ 
			self packageRegistry
				at: packageName
				put: (RwGsLoadedSymbolDictPackage newNamed: packageName) ].

	loadedPackage
		loadedClassExtensionForClass: extensionClass
		ifAbsent: [ 
			loadedClassExtension := RwGsLoadedSymbolDictClassExtension
				newForClass: extensionClass
				inPackage: loadedPackage.
			(self classExtensionRegistry
				at: extensionClass classHistory
				ifAbsentPut: [ IdentitySet new ]) add: loadedClassExtension ]
]

{ #category : 'loaded queries' }
RwGsPackageSymbolDictionary >> existingForClass: aClass [

	"Answer the registered LoadedClass for the given class."

	^ self
		existingForClass: aClass
		ifAbsent: [ self error: 'no loaded class found for ' , aClass name printString ]
]

{ #category : 'loaded queries' }
RwGsPackageSymbolDictionary >> existingForClass: aClass ifAbsent: absentBlock [

	"Answer the registered LoadedClass for the given class."

	^ classRegistry at: aClass classHistory ifAbsent: absentBlock
]

{ #category : 'session methods' }
RwGsPackageSymbolDictionary >> homeSessionMethods [

	| package |
	package := self at: GsPackage globalName otherwise: nil.
	package ifNil: [ package := GsPackage installIn: self ].
	^ package
]

{ #category : 'loaded queries' }
RwGsPackageSymbolDictionary >> loadedPackageDefinitionNamed: packageName ifAbsent: absentBlock [

	^ (self loadedPackageNamed: packageName ifAbsent: absentBlock) asDefinition
]

{ #category : 'loaded queries' }
RwGsPackageSymbolDictionary >> loadedPackageDefinitionsNamed: someNames [

	"Answer a PackageSetDefinition containing packages with the given names in the image.
 	If any name is not a loaded package, that name is ignored."

	^ (self loadedPackagesNamed: someNames) asDefinition
]

{ #category : 'loaded queries' }
RwGsPackageSymbolDictionary >> loadedPackageNamed: packageName ifAbsent: absentBlock [

	^ packageRegistry at: packageName ifAbsent: absentBlock
]

{ #category : 'loaded queries' }
RwGsPackageSymbolDictionary >> loadedPackagesNamed: someNames [

	"Answer a PackageSet containing packages with the given names in the image.
 	If any name is not a loaded package, that name is ignored."

	"very likely we should be dealing with a project name 
at this point ... unless there is a use case for loading a collection of packages without directly using the project interface --- loaded packages do know what project they belong to ... so there might be something done behind the scenes"

	| loadedPackages |
	loadedPackages := someNames
		collect: [ :aName | self loadedPackageNamed: aName ifAbsent: [ nil ] ].
	self
		halt:
			'are someNames allowed to cross project lines if not , then we should allow this method to be used'.
	^ RwEntitySet withAll: (loadedPackages select: [ :each | each notNil ])
]

{ #category : 'accessing' }
RwGsPackageSymbolDictionary >> methodRegistry [

   ^methodRegistry

]

{ #category : 'private - migration avoidance' }
RwGsPackageSymbolDictionary >> migrateFrom: anotherObject instVarMap: otherivi [

	"skip migration until the class definition settles down a bit"

	
]

{ #category : 'private - migration avoidance' }
RwGsPackageSymbolDictionary >> migrateInstances: instances to: anotherClass [

	"skip migration until the class definition settles down a bit"

	
]

{ #category : 'method - patch api' }
RwGsPackageSymbolDictionary >> moveCompiledMethod: compiledMethod toProtocol: newProtocol [

	"move a compiled method into a different protocol and update loaded things"

	| behavior selector loadedMethod oldCat catSym catDict methodDictionary existingCompiledMethod |
	selector := compiledMethod selector.
	behavior := compiledMethod inClass.

	methodDictionary := behavior persistentMethodDictForEnv: 0.
	existingCompiledMethod := methodDictionary
		at: selector
		ifAbsent: [ 
			self
				error:
					'Internal error -- no existing CompileMethod found for patched method.' ].
	existingCompiledMethod == compiledMethod
		ifFalse: [ 
			self
				error:
					'Internal error - the existingCompiledMethod is not identical to the compiled method arg' ].

	oldCat := behavior categoryOfSelector: selector environmentId: 0.
	catSym := newProtocol asSymbol.
	catDict := behavior _baseCategorysForStore: 0.
	oldCat ifNotNil: [ (catDict at: oldCat) remove: selector ].
	catDict
		at: catSym
		ifAbsent: [ behavior addCategory: newProtocol environmentId: 0 ].
	(catDict at: catSym) add: selector.

	behavior moveMethod: selector toCategory: newProtocol environmentId: 0.

	loadedMethod := methodRegistry
		at: compiledMethod
		ifAbsent: [ 
			self
				error:
					'Internal error -- no existing LoadedMethod found for the compiledMethod.' ].

	loadedMethod updateForProtocolChange
]

{ #category : 'accessing' }
RwGsPackageSymbolDictionary >> packageRegistry [

   ^packageRegistry

]

{ #category : 'class - patch api' }
RwGsPackageSymbolDictionary >> updateClassProperties: class [

	"class properties have changed, update the clas properties of the loaded things"

	(class isKindOf: Class)
		ifFalse: [ self error: 'internal error - expected a class' ].
	self
		_loadedClassFor: class
		noNewVersion: [ :loadedClass | 
			"association for class is present, update the loaded thing"
			loadedClass updatePropertiesFromClassFor: self ]
]