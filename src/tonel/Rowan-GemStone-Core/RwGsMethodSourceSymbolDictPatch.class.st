Class {
	#name : 'RwGsMethodSourceSymbolDictPatch',
	#superclass : 'RwGsMethodPatch',
	#category : 'Rowan-GemStone'
}

{ #category : 'installing' }
RwGsMethodSourceSymbolDictPatch >> installSourcePatch [

	" update methodDictionary and update loadedMethod with new compiled method"

	self symbolDictionaryRegistry addRecompiledMethod: compiledMethod.
	selector := compiledMethod selector
]