instance creation
fileOutsForPackagesNamed: someNames

	^someNames inject: Dictionary new
		into: 
			[:result :each |
			result
				at: each
					put: (String streamContents: 
								[:stream |
								(self fromPackage: (CypressPackageDefinition named: each))
									fileOutOn: stream]);
				yourself]