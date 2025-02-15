Class {
	#name : #FLPlatform,
	#superclass : #Object,
	#classVars : [
		'Current'
	],
	#category : #'Fuel-Platform-Core'
}

{ #category : #'private-extensions' }
FLPlatform class >> addExtensions [
	self extensionPragmas do: [ :pragma |
		(FLExtensionWrapper fromPragma: pragma) install ]
]

{ #category : #operations }
FLPlatform class >> addHacks [
	self current
		useAuthor: 'Fuel'
		during: [ self basicAddHacks ]
]

{ #category : #'private-hacks' }
FLPlatform class >> basicAddHacks [
	self
		fixMetacello;
		addExtensions
]

{ #category : #accessing }
FLPlatform class >> current [
	^ Current ifNil: [ Current := self detectPlatform ]
]

{ #category : #private }
FLPlatform class >> detectPlatform [
	| matches mostSpecific |
	matches := self allSubclasses 
		select: [ :class | class isResponsibleForCurrentPlatform ].
	mostSpecific := matches first.
	matches do: [ :class |
		class allSubclasses size < mostSpecific allSubclasses size ifTrue: [
			mostSpecific := class ] ].
	
	^ mostSpecific new
]

{ #category : #accessing }
FLPlatform class >> extensionCategoryName [
	^ 'FuelPlatformExtensions'
]

{ #category : #'private-extensions' }
FLPlatform class >> extensionPragmaSelectors [
	^ #(
		flExtensionOf:
		flExtensionOf:selector:
		flExtensionOf:selector:isSource:
		flExtensionOf:isSource:
		flExtensionOf:isClassSide:
		flExtensionOf:isClassSide:selector:
		flExtensionOf:isClassSide:selector:isSource:
		flExtensionOf:isClassSide:isSource:)
]

{ #category : #'private-extensions' }
FLPlatform class >> extensionPragmas [
	| pragmas |
	pragmas := Dictionary new.
	self extensionPragmaSelectors do: [ :selector |
			| stop |
			stop := false.
			self class withAllSuperclassesDo: [ :class |
				stop ifFalse: [
					self current
						withPragmasIn: class
						do: [ :pragma |
							(pragma selector = selector and: [
								"don't collect overridden methods"
								(pragmas includesKey: pragma methodSelector) not ]) ifTrue: [
									pragmas
										at: pragma methodSelector
										put: pragma ] ].
							FLPlatform class = class ifTrue: [ stop := true ] ] ] ].
			
	^ pragmas values
]

{ #category : #accessing }
FLPlatform class >> extensionProtocolName [
	^ '*', self extensionCategoryName
]

{ #category : #'private-hacks-metacello' }
FLPlatform class >> fixMetacello [
]

{ #category : #accessing }
FLPlatform class >> hacksCategoryName [
	^ 'FuelPlatformHacks'
]

{ #category : #testing }
FLPlatform class >> isResponsibleForCurrentPlatform [
	^ self subclassResponsibility
]

{ #category : #'private-convenience' }
FLPlatform class >> removeModifications [
	((Smalltalk globals at: #(Smalltalk globals at: #PackageInfo)) named: self extensionProtocolName) extensionMethods do: [ :methodReference |
		methodReference actualClass removeSelector: methodReference selector ].
	((Smalltalk globals at: #(Smalltalk globals at: #PackageInfo)) named: self hacksCategoryName) in: [ :hacks |
		hacks classes do: [ :classOrTrait |
			classOrTrait removeFromSystem ].
		(Smalltalk globals at: #PackageOrganizer) default  unregisterPackage: hacks ].
	SystemOrganizer default removeCategory: self hacksCategoryName
]

{ #category : #'class initialization' }
FLPlatform class >> reset [
	Current := nil
]

{ #category : #'accessing-system' }
FLPlatform >> absolutePathOf: aString [
	^ self subclassResponsibility
]

{ #category : #'accessing-compiler' }
FLPlatform >> addAndClassifySelector: aSymbol inClass: aClass withMethod: aCompiledMethod inProtocol: aString [
	self subclassResponsibility
]

{ #category : #operations }
FLPlatform >> addHacks [
	self class addHacks
]

{ #category : #'accessing-tests' }
FLPlatform >> classFactoryForTestCaseClass [
	^ FLClassFactoryForTestCase
]

{ #category : #'accessing-files' }
FLPlatform >> createTemporaryDirectoryPathNamed: aString [
	^ self subclassResponsibility
]

{ #category : #'accessing-files' }
FLPlatform >> deleteAllInDirectoryPath: aPathString [
	self subclassResponsibility
]

{ #category : #'accessing-files' }
FLPlatform >> deleteFilePath: aFilename [
	self subclassResponsibility
]

{ #category : #'tests-testing' }
FLPlatform >> expectedFailuresOf: aClass [
	^ OrderedCollection new
]

{ #category : #'accessing-files' }
FLPlatform >> filePathExists: aPathString [
	^ self subclassResponsibility
]

{ #category : #testing }
FLPlatform >> hasStatefulTraits [
	^ self subclassResponsibility
]

{ #category : #'accessing-system' }
FLPlatform >> imageName [
	^ self subclassResponsibility
]

{ #category : #testing }
FLPlatform >> isBigEndian [
	^ self subclassResponsibility
]

{ #category : #testing }
FLPlatform >> isPharo [
	^ false
]

{ #category : #testing }
FLPlatform >> isSpur [
	^ true
]

{ #category : #testing }
FLPlatform >> isSqueak [
	^ false
]

{ #category : #'accessing-files' }
FLPlatform >> joinPath: aPathString with: anotherPathString [
	^ self subclassResponsibility
]

{ #category : #'tests-compilation' }
FLPlatform >> newAnonymousSubclassOf: aClass named: aString [
	^ self subclassResponsibility
]

{ #category : #'tests-compilation' }
FLPlatform >> newAnonymousTraitNamed: aString [
	^ self subclassResponsibility
]

{ #category : #'tests-compilation' }
FLPlatform >> newSubclassOf: aClass named: className uses: aTraitComposition instanceVariableNames: ivNamesString classVariableNames: classVarsString poolDictionaries: poolNamesString environment: anEnvironment package: packageName [
	^ self subclassResponsibility
]

{ #category : #'tests-compilation' }
FLPlatform >> newTraitNamed: aString uses: aTraitComposition instanceVariableNames: iVarString environment: anEnvironment package: packageName [
	^ self subclassResponsibility
]

{ #category : #'accessing-files' }
FLPlatform >> readStreamForFilePath: aString [
	^ self subclassResponsibility
]

{ #category : #'accessing-compiler' }
FLPlatform >> renamedMethodCopyOf: aMethod selector: aSymbol [
	^ self subclassResponsibility
]

{ #category : #'accessing-tests' }
FLPlatform >> setTestTimeLimitFor: aTest to: aDuration [
	self subclassResponsibility
]

{ #category : #'accessing-compiler' }
FLPlatform >> silentlyAddAndClassifySelector: aSymbol inClass: aClass withMethod: aCompiledMethod inProtocol: aString [
	self subclassResponsibility
]

{ #category : #'accessing-system' }
FLPlatform >> silentlyDo: aBlock [
	self subclassResponsibility
]

{ #category : #'accessing-system' }
FLPlatform >> useAuthor: aString during: aBlock [
	self subclassResponsibility
]

{ #category : #accessing }
FLPlatform >> versionNumber [
	^ ('\d+' asRegex matchesIn: self className) first asInteger
]

{ #category : #'accessing-kernel' }
FLPlatform >> withPragmasIn: aClass do: aBlock [
	self subclassResponsibility
]

{ #category : #'accessing-files' }
FLPlatform >> writeStreamForFilePath: aString [
	^ self subclassResponsibility
]
