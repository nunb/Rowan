Extension { #name : 'RwGsPlatform' }

{ #category : '*rowan-tools' }
RwGsPlatform >> packageTools [
	"Answer the platform-specific class for package tools"

	^RwPackageTool
]

{ #category : '*rowan-tools' }
RwGsPlatform >> projectTools [
	"Answer the platform-specific class for project tools"

	^RwProjectTool
]

{ #category : '*rowan-tools' }
RwGsPlatform >> repositoryTools [
	"Answer the platform-specific class for repository tools"

	^RwRepositoryTool
]