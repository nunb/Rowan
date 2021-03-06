"
This class implements the tonel: scheme:

  tonel:/opt/git/shared/repos/rowan/sample/repository

The scheme is supported for backward compatibility with the tonel disk format[1]. Not sure whether it's use has made it into the wild, but it _is_ currently being used in the Rowan implementation.

[1] https://github.com/pharo-vcs/tonel
"
Class {
	#name : 'RwTonelUrl',
	#superclass : 'RwCypressUrl',
	#category : 'Rowan-Url-Core'
}

{ #category : 'constants' }
RwTonelUrl class >> schemeName [
	^'tonel'

]

{ #category : 'converting' }
RwTonelUrl >> asRwRepository [
  "return a platform appropriate repository for the repository located in the directory referenced by the receiver"

  ^ self createRwTonelRepositoryForPath: self pathForDirectory

]
