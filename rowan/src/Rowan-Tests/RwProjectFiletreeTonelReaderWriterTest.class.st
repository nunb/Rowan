Class {
	#name : 'RwProjectFiletreeTonelReaderWriterTest',
	#superclass : 'RwProjectReaderWriterTest',
	#category : 'Rowan-Tests'
}

{ #category : 'testing' }
RwProjectFiletreeTonelReaderWriterTest class >> isAbstract [
  "Override to true if a TestCase subclass is Abstract and should not have
	TestCase instances built from it"

  ^ self sunitName = #'RwProjectFiletreeTonelReaderWriterTest'
]

{ #category : 'private' }
RwProjectFiletreeTonelReaderWriterTest >> _projectSetDefinitionForStructureWriters_A [

	"multiple class extensions from multiple packages for multiple classes"

	|  projectName packageName1 packageName2 projectDefinition classDefinition packageDefinition className1 className2 className3
		classExtensionDefinition projectSetDefinition projectSetModification visitor repositoryRootPath packageName3 |

	projectName := 'Issue361'.
	self _markForProjectCleanup: projectName.
	packageName1 := 'Issue361-Core'.
	packageName2 := 'Issue361-Extension1'.
	packageName3 := 'Issue361-Extension2'.
	className1 := 'Issue361Class1'. 
	className2 := 'Issue361Class2'. 
	className3 := 'Issue361Class3'. 

"create definitions"
	projectDefinition := (RwProjectDefinition
		newForDiskBasedProjectNamed: projectName)
		addPackageNamed: packageName1;
		addPackageNamed: packageName2;
		addPackageNamed: packageName3;
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
	packageDefinition addClassExtensionDefinition: classExtensionDefinition.

	packageDefinition := projectDefinition packageNamed: packageName3.

	classExtensionDefinition := RwClassExtensionDefinition newForClassNamed: className1.
	classExtensionDefinition
		addInstanceMethodDefinition:
			(RwMethodDefinition
					newForSelector: #'method5'
					protocol: '*', packageName3 asLowercase
					source: 'method5 ^5').
	packageDefinition addClassExtensionDefinition: classExtensionDefinition.

"project set"
	projectSetDefinition := RwProjectSetDefinition new.
	projectSetDefinition addDefinition: projectDefinition.

	^ projectSetDefinition
]

{ #category : 'private' }
RwProjectFiletreeTonelReaderWriterTest >> _readProjectDefinition: projectDefinition [

	| repoDir packageNames propertyDict format |
	repoDir := filesystem referenceTo: projectDefinition repositoryUrl asRwUrl pathForDirectory.
	propertyDict := self _repositoryPropertyDictFor: projectDefinition repositoryRootPath: repoDir.
	format := propertyDict at: 'format' ifAbsent: [ 'filetree' ].
self error: 'switch readers at this point .. time to rename the Modification visitors or something so that the structure logic can be shared ...'.
	packageNames := repoDir packageNames.
	^ self 
		_readProjectDefinition: projectDefinition 
		packageNames: packageNames
		from: repoDir
]

{ #category : 'private' }
RwProjectFiletreeTonelReaderWriterTest >> _readProjectSetDefinition: projectSetDefinition [

	projectSetDefinition do: [:projectDefinition |
		self _readProjectDefinition: projectDefinition ].
]

{ #category : 'private' }
RwProjectFiletreeTonelReaderWriterTest >> _repositoryFormat [

	^ self subclassResponsibility: #_repositoryFormat
]

{ #category : 'private' }
RwProjectFiletreeTonelReaderWriterTest >> _repositoryPropertyDictFor: aProjectDefinition repositoryRootPath: repositoryRootPath [

	| propertiesFile |
	propertiesFile := repositoryRootPath / '.filetree'.
	propertiesFile exists
		ifFalse: [ propertiesFile := repositoryRootPath / '.cypress' ].
	^ STON fromStream: (ZnBufferedReadStream on: propertiesFile  readStream)
]

{ #category : 'private' }
RwProjectFiletreeTonelReaderWriterTest >> _writerVisitorClass [

	^ self subclassResponsibility: #_writerVisitorClass
]

{ #category : 'tests' }
RwProjectFiletreeTonelReaderWriterTest >> testWriterReader_A [

	"multiple class extensions from multiple packages for multiple classes"

	|  writtenProjectSetDefinition readProjectSetDefinition projectSetModification |
"write projectSetDefinition to disk"
	writtenProjectSetDefinition := self _projectSetDefinitionForStructureWriters_A.
	self _writeProjectSetDefinition: writtenProjectSetDefinition 
		writerVisitorClass: self _writerVisitorClass 
		format: self _repositoryFormat.

	readProjectSetDefinition := self _readProjectSetDefinition: writtenProjectSetDefinition.

"validation"
	projectSetModification := readProjectSetDefinition compareAgainstBase: writtenProjectSetDefinition.
	self assert: projectSetModification isEmpty.
]