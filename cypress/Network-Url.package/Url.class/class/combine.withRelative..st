"
notice: Copyright 2013 GemTalk Systems, LLC. Open source under the MIT license.
category: parsing
"
combine: baseURL withRelative: relURL 
	"Take two URL as string form, combine them and return the corresponding URL in string form"

	^((self absoluteFromText: baseURL) newFromRelativeText: relURL) asString