"
notice: Copyright 2013 GemTalk Systems, LLC. Open source under the MIT license.
category: Instance Creation
"
fromUnknown: unknownPackageInformation eclipsedBy: knownPackageInformation

	^(self named: unknownPackageInformation name)
		eclipsedBy: knownPackageInformation;
		yourself.