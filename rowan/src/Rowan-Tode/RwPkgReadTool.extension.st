Extension { #name : 'RwPkgReadTool' }

{ #category : '*rowan-tode' }
RwPkgReadTool >> manPage [
  ^ TDManPage
    commandName: 'xxx'
    sourceMethod: self class name asString , '>>manPage'
    fromString:
      'NAME
  pkg xxx - xxx
SYNOPSIS
  pkg xxx
DESCRIPTION
EXAMPLES
  pkg xxx 
'
]
