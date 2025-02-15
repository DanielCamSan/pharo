Class {
	#name : #ClyClassSideScopeTest,
	#superclass : #ClyLocalClassScopeTest,
	#category : #'Calypso-SystemQueries-Tests-Scopes'
}

{ #category : #running }
ClyClassSideScopeTest >> extraBasisSample [ 	
	^super extraBasisSample classSide
]

{ #category : #running }
ClyClassSideScopeTest >> scopeClass [

	^ClyClassSideScope
]

{ #category : #running }
ClyClassSideScopeTest >> singleBasisSample [ 	
	^super singleBasisSample classSide
]

{ #category : #tests }
ClyClassSideScopeTest >> testClassEnumeration [
	scope := ClyClassSideScope ofAll: {ClyClass1FromP1Mock classSide. ClyClass2FromP1Mock}.
	
	scope classesDo: [ :each | result add: each ].
	
	self
		assertCollection: result asArray
		hasSameElements: {ClyClass1FromP1Mock classSide. ClyClass2FromP1Mock classSide}
]

{ #category : #tests }
ClyClassSideScopeTest >> testConvertingToIncreasedScopeByExtraClassScope [
	| convertedScope extraClassScope |
	scope := self singleScopeSample.
	
	extraClassScope := ClySuperclassScope of: self class localScope: self scopeClass.
	convertedScope := scope increasedByClassesFrom: extraClassScope.
	
	self assert: convertedScope class equals: scope class.
	self assert: convertedScope basisObjects equals: scope basisObjects, extraClassScope collectAllClasses.
]

{ #category : #tests }
ClyClassSideScopeTest >> testMethodsEnumerationWhenBasisIsClass [

	| expected |
	scope := ClyClassSideScope of: ClyClass1FromP1Mock.
	scope methodsDo: [ :each | result add: each selector ].
	expected := ClyClass1FromP1Mock classSide localMethods collect: [:each | each selector].
	self assertCollection: result sorted asArray equals: expected sorted
]

{ #category : #tests }
ClyClassSideScopeTest >> testMethodsEnumerationWhenBasisIsMetaclass [

	| expected |
	scope := ClyClassSideScope of: ClyClass1FromP1Mock classSide.	
	scope methodsDo: [ :each | result add: each selector ].
	expected := ClyClass1FromP1Mock classSide localMethods collect: [:each | each selector].
	self assert: result sorted asArray equals: expected sorted asArray
]

{ #category : #tests }
ClyClassSideScopeTest >> testMethodsEnumerationWhenBasisIsTraitedClass [
	| expected |
	scope := ClyClassSideScope of: ClyClassWithTraits.
	
	scope methodsDo: [ :each | result add: each selector ].
	
	expected := ClyClassWithTraits class methods reject: [ :e | e origin = TraitedClass ] thenCollect: #selector.
	self assert: result sorted asArray equals: expected sorted asArray
]

{ #category : #tests }
ClyClassSideScopeTest >> testMethodsEnumerationWhenBasisIsTraitedClassClassSide [
	| expected |
	scope := ClyClassSideScope of: ClyClassWithTraits classSide.
	
	scope methodsDo: [ :each | result add: each selector ].
	
	expected := ClyClassWithTraits class methods reject: [ :e | e origin = TraitedClass ] thenCollect: #selector.
	self assert: result sorted asArray equals: expected sorted asArray
]
