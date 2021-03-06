"
RowanServicesTest subclasses require RowanSample1 project to be loaded.
"
Class {
	#name : 'RowanServicesTest',
	#superclass : 'TestCase',
	#instVars : [
		'defaultProjectDefinition'
	],
	#category : 'Rowan-Services-Tests'
}

{ #category : 'support' }
RowanServicesTest >> createClassDefinitionNamed: className [

	| classDefinition |
	classDefinition := RwClassDefinition
		newForClassNamed: className
			super: 'Object'
			instvars: #()
			classinstvars: #()
			classvars: #()
			category: 'services test'
			comment: String new
			pools: #()
			type: 'normal'.
	^classDefinition
]

{ #category : 'support' }
RowanServicesTest >> createDefaultClass [

	| packageDefinition classDefinition |
	packageDefinition := self createDefaultPackage.
	classDefinition := self createClassDefinitionNamed: self defaultClassName. 
	packageDefinition addClassDefinition: classDefinition. 
	^classDefinition
]

{ #category : 'support' }
RowanServicesTest >> createDefaultPackage [

	| projectDefinition |
	projectDefinition := self createDefaultProject. 
	projectDefinition addPackageNamed: self defaultPackageName.
	^projectDefinition packageNamed: self defaultPackageName
]

{ #category : 'support' }
RowanServicesTest >> createDefaultProject [

	defaultProjectDefinition := self createProjectDefinitionNamed: self defaultProjectName.
	^defaultProjectDefinition
]

{ #category : 'support' }
RowanServicesTest >> createJadeiteTestPackage [
	| proj pkg |
	proj := self createJadeiteTestProject. 
	pkg := RwPackageDefinition newNamed: self jadeiteTestPackageName.
	proj addPackage: pkg.
	Rowan projectTools load loadProjectDefinition: proj.
	^pkg.
]

{ #category : 'support' }
RowanServicesTest >> createJadeiteTestProject [
	| proj |
	proj := RwProjectDefinition newForGitBasedProjectNamed: self jadeiteTestProjectName. 
	proj repositoryRootPath: '$ROWAN_PROJECTS_HOME/', self jadeiteTestProjectName. 
	Rowan projectTools create createProjectFor: proj.
	^proj
]

{ #category : 'support' }
RowanServicesTest >> createProjectDefinitionNamed: projectName [

	| projectDefinition |

	projectDefinition := (RwProjectDefinition
		newForGitBasedProjectNamed: projectName)
		defaultSymbolDictName: self defaultSymbolDictionaryName;
		yourself.
	^projectDefinition
]

{ #category : 'constants' }
RowanServicesTest >> defaultClassName [

	^'ServicesTestClass'
]

{ #category : 'constants' }
RowanServicesTest >> defaultPackageName [

	^'ServicesTestPackage'
]

{ #category : 'support' }
RowanServicesTest >> defaultProjectDefinition [

	^defaultProjectDefinition ifNil:[defaultProjectDefinition := self createDefaultProject]
]

{ #category : 'constants' }
RowanServicesTest >> defaultProjectName [

	^'ServicesTestProject'
]

{ #category : 'support' }
RowanServicesTest >> defaultSymbolDictionaryName [

	^'ServicesTestDictionary'
]

{ #category : 'support' }
RowanServicesTest >> jadeiteIssueTested: aSymbol withTitle: anObject [
	"send this to help identify which tests test which issues
	format: #issue<issueNumber>
	Example self issueTested: #issue235 withTitle: 'Need Find Class/Method from console'

	Issues currently reside in: 
		https://github.com/GemTalk/Jadeite/issues/"
]

{ #category : 'constants' }
RowanServicesTest >> jadeiteTestPackageName [

	^'JadeitePackage'
]

{ #category : 'constants' }
RowanServicesTest >> jadeiteTestProjectName [

	^'JadeiteProject'
]

{ #category : 'support' }
RowanServicesTest >> loadDefaultProject [
	
	| projectSetDefinition |

	projectSetDefinition:= RwProjectSetDefinition new.
	projectSetDefinition addDefinition: self defaultProjectDefinition.
	Rowan projectTools load loadProjectSetDefinition: projectSetDefinition.
]

{ #category : 'setup teardown' }
RowanServicesTest >> setUp [
	"ensure results are clean as service requests not coming through #updateFromSton: like the client"

	RowanCommandResult initializeResults.
]

{ #category : 'setup teardown' }
RowanServicesTest >> tearDown [

	RowanCommandResult initializeResults.  "squash the gui updates"
]

{ #category : 'support' }
RowanServicesTest >> unloadDefaultProject [

	Rowan projectTools delete deleteProjectNamed: self defaultProjectName
]
