Extension { #name : 'Object' }

{ #category : '*rowan-gemstone-kernel' }
Object >> rwPlatformAttributeMatchForGemStoneVersion: anRwGemStoneVersionConfigurationPlatformAttributeMatcher [
  ^ self
    error: 'Expected a String or a RwGemStoneVersion'

]

{ #category : '*rowan-gemstone-kernel' }
Object >> rwPlatformAttributeMatchForString: anRwStringConfigurationPlatformAttributeMatcher [
  ^ self
    error: 'Expected a String or a RwGemStoneVersion'

]

{ #category : '*rowan-gemstone-kernel' }
Object >> rwSemanticIntegerLessThanSelf: anInteger [
  ^ self
    error: 'Invalid semantic verson component - should be an Integer.'

]

{ #category : '*rowan-gemstone-kernel' }
Object >> rwSemanticStringLessThanSelf: aString [
  ^ self
    error: 'Invalid semantic verson component - should be String.'

]

{ #category : '*rowan-gemstone-kernel' }
Object >> rwSemanticVersionComponentLessThan: aRwSemanticVersonComponent [
  ^ self
    error: 'Invalid semantic verson component - should be String or Integer.'

]
