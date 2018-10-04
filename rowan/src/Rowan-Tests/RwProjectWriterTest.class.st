Class {
	#name : 'RwProjectWriterTest',
	#superclass : 'RwBrowserToolTest',
	#instVars : [
		'filesystem',
		'toDelete'
	],
	#category : 'Rowan-Tests'
}

{ #category : 'private' }
RwProjectWriterTest >> _createFileSystem [
	^ FileSystem memory
]

{ #category : 'private' }
RwProjectWriterTest >> _expectedGsTopazWriterFileContents [

	^ '! Class Declarations

doit
(Array
	subclass: ''Issue361Class2''
	instVarNames: #(  )
	classVars: #(  )
	classInstVars: #(  )
	poolDictionaries: #()
	inDictionary: UserGlobals
	options: #())
		category: ''Issue361-Core'';
		comment: '''';
		immediateInvariant.
true.
%

doit
(Object
	subclass: ''Issue361Class1''
	instVarNames: #(  )
	classVars: #(  )
	classInstVars: #(  )
	poolDictionaries: #()
	inDictionary: UserGlobals
	options: #())
		category: ''Issue361-Core'';
		comment: '''';
		immediateInvariant.
true.
%

doit
(Issue361Class1
	subclass: ''Issue361Class3''
	instVarNames: #(  )
	classVars: #(  )
	classInstVars: #(  )
	poolDictionaries: #()
	inDictionary: UserGlobals
	options: #())
		category: ''Issue361-Core'';
		comment: '''';
		immediateInvariant.
true.
%

! Class implementation for ''Issue361Class2''

!		Instance methods for ''Issue361Class2''

category: ''accessing''
method: Issue361Class2
method3 ^3
%

! Class implementation for ''Issue361Class1''

!		Class methods for ''Issue361Class1''

category: ''accessing''
classmethod: Issue361Class1
method2 ^2
%

! Class implementation for ''Issue361Class3''

!		Class methods for ''Issue361Class3''

category: ''accessing''
classmethod: Issue361Class3
method4 ^4
%

! Class extensions for ''Issue361Class1''

!		Instance methods for ''Issue361Class1''

category: ''*issue361-extension''
method: Issue361Class1
method1 ^1
%

'
]

{ #category : 'private' }
RwProjectWriterTest >> _markForCleanup: anObject [
	toDelete add: (filesystem resolve: anObject)
]

{ #category : 'running' }
RwProjectWriterTest >> setUp [
	super setUp.
	filesystem := self _createFileSystem.
	toDelete := OrderedCollection new.
]

{ #category : 'running' }
RwProjectWriterTest >> tearDown [
	toDelete
		select: [ :path | filesystem exists: path ]
		thenDo: [ :path | filesystem delete: path ].
	super tearDown
]

{ #category : 'tests' }
RwProjectWriterTest >> testGsTopazWriter [
	|  projectName packageName1 packageName2 projectDefinition classDefinition packageDefinition className1 className2 className3
		classExtensionDefinition projectSetDefinition projectSetModification visitor repositoryRootPath x stream y a b |

	projectName := 'Issue361'.
	packageName1 := 'Issue361-Core'.
	packageName2 := 'Issue361-Extension'.
	className1 := 'Issue361Class1'. 
	className2 := 'Issue361Class2'. 
	className3 := 'Issue361Class3'. 

"create definitions"
	projectDefinition := (RwProjectDefinition
		newForGitBasedProjectNamed: projectName)
		addPackageNamed: packageName1;
		addPackageNamed: packageName2;
		setSymbolDictName: self _symbolDictionaryName forPackageNamed: packageName1;
		setSymbolDictName: self _symbolDictionaryName forPackageNamed: packageName2;
		yourself.

	packageDefinition := projectDefinition packageNamed: packageName1.

	classDefinition := RwClassDefinition
		newForClassNamed: className1
		super: 'Object'
		instvars: #()
		classinstvars: #()
		classvars: #()
		category: packageName1
		comment: ''
		pools: #()
		type: 'normal'.
	classDefinition
		addClassMethodDefinition:
			(RwMethodDefinition
					newForSelector: #'method2'
					protocol: 'accessing'
					source: 'method2 ^2').
	packageDefinition addClassDefinition: classDefinition.

	classDefinition := RwClassDefinition
		newForClassNamed: className2
		super: 'Array'
		instvars: #()
		classinstvars: #()
		classvars: #()
		category: packageName1
		comment: ''
		pools: #()
		type: 'normal'.
	classDefinition
		addInstanceMethodDefinition:
			(RwMethodDefinition
					newForSelector: #'method3'
					protocol: 'accessing'
					source: 'method3 ^3').
	packageDefinition addClassDefinition: classDefinition.

	classDefinition := RwClassDefinition
		newForClassNamed: className3
		super: className1
		instvars: #()
		classinstvars: #()
		classvars: #()
		category: packageName1
		comment: ''
		pools: #()
		type: 'normal'.
	classDefinition
		addClassMethodDefinition:
			(RwMethodDefinition
					newForSelector: #'method4'
					protocol: 'accessing'
					source: 'method4 ^4').
	packageDefinition addClassDefinition: classDefinition.

	classExtensionDefinition := RwClassExtensionDefinition newForClassNamed: className1.
	classExtensionDefinition
		addInstanceMethodDefinition:
			(RwMethodDefinition
					newForSelector: #'method1'
					protocol: '*', packageName2 asLowercase
					source: 'method1 ^1').
	packageDefinition := projectDefinition packageNamed: packageName2.
	packageDefinition addClassExtension: classExtensionDefinition.

"diff"
	projectSetDefinition := RwProjectSetDefinition new.
	projectSetDefinition addDefinition: projectDefinition.

"write"
	repositoryRootPath := filesystem workingDirectory / projectName / 'topaz'.
	self _markForCleanup: repositoryRootPath.
	repositoryRootPath ensureCreateDirectory.

	projectSetModification := projectSetDefinition compareAgainstBase: RwProjectSetDefinition new.
	visitor := RwGsModificationTopazWriterVisitor new
		repositoryRootPath: repositoryRootPath;
		topazFilename: projectName;
		yourself.
	visitor visit: projectSetModification.
	visitor export.

	stream := ZnBufferedReadStream on: visitor topazFileReference readStream.
	x := stream contents.
	y := self _expectedGsTopazWriterFileContents.
	self assert: (a := x size) = (b := y size).
	1 to: x size do: [:i |
		self assert: (a := x at: i) = (b := y at: i) ].
	self assert: x = y
]