Class {
	#name : 'RwGitTool',
	#superclass : 'RwTool',
	#instVars : [
		'tdGitTool'
	],
	#category : 'Rowan-Tode'
}

{ #category : 'smalltalk api' }
RwGitTool >> createTmpFileWith: fileContents [
  ^ self tdGitTool createTmpFileWith: fileContents
]

{ #category : 'smalltalk api' }
RwGitTool >> gitaddIn: gitRepoDir with: args [
  ^ self tdGitTool gitaddIn: gitRepoDir with: args
]

{ #category : 'smalltalk api' }
RwGitTool >> gitcheckoutIn: gitRepoDir with: args [
  ^ self tdGitTool gitcheckoutIn: gitRepoDir with: args
]

{ #category : 'smalltalk api' }
RwGitTool >> gitcloneIn: gitRootDirectory with: args [
  ^ self tdGitTool gitcloneIn: gitRootDirectory with: args
]

{ #category : 'smalltalk api' }
RwGitTool >> gitcommitIn: gitRepoDir with: args [
  ^ self tdGitTool gitcommitIn: gitRepoDir with: args
]

{ #category : 'smalltalk api' }
RwGitTool >> gitcommitShaIn: gitRepoDir [
  | result |
  result := self gitlogIn: gitRepoDir with: ' 1 --pretty=format:%h '.
  (result beginsWith: 'fatal:')
    ifTrue: [ ^ nil ].
  ^ result trimWhiteSpace
]

{ #category : 'smalltalk api' }
RwGitTool >> gitlogIn: gitRepoDir with: args [
  ^ self tdGitTool gitlogIn: gitRepoDir with: args
]

{ #category : 'smalltalk api' }
RwGitTool >> gitrevparseShowTopLevelIn: aDirectory [
  ^ self tdGitTool gitrevparseShowTopLevelIn: aDirectory
]

{ #category : 'smalltalk api' }
RwGitTool >> performOnServer: command logging: logging [
  ^ self tdGitTool performOnServer: command logging: logging
]

{ #category : 'accessing' }
RwGitTool >> tdGitTool [
  ^ tdGitTool ifNil: [ tdGitTool := TDGitTool new ]
]