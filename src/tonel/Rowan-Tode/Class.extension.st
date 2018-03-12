Extension { #name : 'Class' }

{ #category : '*rowan-tode' }
Class >> rowanPackageName [

	"answer the name of the package that the receiver is a member of. Answer '(NONE)' if 
		the receiver is not a member of any package"

	| loadedClass |
	loadedClass := Rowan image loadedClassForClass: self ifAbsent: [ ^ '(NONE)' ].
	^ loadedClass loadedPackage name
]

{ #category : '*rowan-tode' }
Class >> rowanProjectName [

	"answer the name of the project that the receiver is a member of. Answer '(NONE)' if 
		the receiver is not a member of any project"

	| loadedClass |
	loadedClass := Rowan image loadedClassForClass: self ifAbsent: [ ^ '(NONE)' ].
	^ loadedClass loadedProject name
]