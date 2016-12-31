"
notice: Copyright 2013,2016 GemTalk Systems, LLC. Open source under the MIT license.
category: private-updating
"
updateSuperclassNameFromClass

	| oldName newName |
	oldName := self propertiesAt: 'super'.
	newName := handle superclass ifNotNil: [:super | super name asString].
	oldName = newName
		ifFalse: 
			[self markPackageDirty.
			self propertiesAt: 'super' put: newName]