"
ReSmallintChecker is responsible for running a set of rules on a given subsystem.


```
| rules checker | 
rules := ReRuleManager defaultRules.

checker := ReSmalllintChecker new
	runRules: rules onPackage: (RPackageOrganizer default packageNamed: #'Manifest-Core').

```
"
Class {
	#name : #ReSmalllintChecker,
	#superclass : #RBSmalllintChecker,
	#instVars : [
		'manifestClassCache',
		'methodRules',
		'nodeRules',
		'classRules',
		'packageRules',
		'critiques'
	],
	#category : #'Renraku-CriticBrowser'
}

{ #category : #adding }
ReSmalllintChecker >> addCritique: aCritique [
		^ critiques add: aCritique
]

{ #category : #accessing }
ReSmalllintChecker >> builderManifestClass [
	^ TheManifestBuilder
]

{ #category : #private }
ReSmalllintChecker >> checkClass: aClass [

	(environment includesClass: aClass) ifFalse: [ ^ self ].

	self getCritiquesAbout: aClass by: classRules
]

{ #category : #private }
ReSmalllintChecker >> checkMethodsForClass: aClass [
	
	environment
		selectorsForClass: aClass
		do: [ :selector | | method ast |
			method := aClass>>selector.
			self getCritiquesAbout: method by: methodRules.
			nodeRules do: [ :r |
				ast := method ast.
				"for rewrite rules, we run every rule on a copy of the ast"
				r isRewriteRule ifTrue: [ ast := ast copy  ].
				ast nodesDo: [ :node |
						r
							check: node
							forCritiquesDo: [ :crit |
								crit sourceAnchor initializeEnitity: method.
								self addCritique: crit ] ] ]]
]

{ #category : #private }
ReSmalllintChecker >> checkPackage: aPackage [

	(environment includesPackage: aPackage) ifTrue: [
		self getCritiquesAbout: aPackage by: packageRules ]
]

{ #category : #manifest }
ReSmalllintChecker >> cleanAllManifest [
	| manifests |
	manifests := environment packages collect: [ :cl | self builderManifestClass of: cl ] as: Set.
	manifests do: [ :each | each cleanUp ]
]

{ #category : #accessing }
ReSmalllintChecker >> criticsOf: aRule [

	^ critiques
		select: [ :c | c rule class = aRule class ]
]

{ #category : #manifest }
ReSmalllintChecker >> falsePositiveOf: aRule [

	| ruleCritiques rId rV mb |

	ruleCritiques := self criticsOf: aRule.
	rId := aRule class uniqueIdentifierName.
	rV := aRule class identifierMinorVersionNumber.
	^ ruleCritiques
		select: [ :critique | 
			| entity |

			entity := critique sourceAnchor entity.
			mb := self manifestBuilderOf: entity.
			mb ifNil: [ false ] ifNotNil: [ mb isFalsePositive: entity onRule: rId version: rV ]
			]
]

{ #category : #private }
ReSmalllintChecker >> getCritiquesAbout: anEntity by: rules [

	rules do: [ :r |
		[ r
			check: anEntity
			forCritiquesDo: [ :crit |
				self addCritique: crit ] ]
			
			on: Error
			do: [ :er | ReSettings showErrors ifTrue: [ er pass ]  ] ]
]

{ #category : #initialization }
ReSmalllintChecker >> initialize [
	super initialize.
	manifestClassCache := Dictionary new.
	self resetResult
]

{ #category : #manifest }
ReSmalllintChecker >> isFalsePositive: aCritic forRuleId: ruleId versionId: versionId [

	| mb |

	mb := self manifestBuilderOf: aCritic.
	^ mb ifNil: [ false ] ifNotNil: [ mb isFalsePositive: aCritic onRule: ruleId version: versionId ]
]

{ #category : #manifest }
ReSmalllintChecker >> isToDo: aCritic forRuleId: ruleId versionId: versionId [

	| mb |

	mb := self manifestBuilderOf: aCritic.
	^ mb ifNil: [ false ] ifNotNil: [ mb containsToDo: aCritic onRule: ruleId version: versionId ]
]

{ #category : #manifest }
ReSmalllintChecker >> isTruePositive: aCritic forRuleId: ruleId versionId: versionId [ 
	
	^ (self manifestBuilderOf: aCritic)
			containsTruePositive: aCritic onRule:  ruleId version: versionId
]

{ #category : #accessing }
ReSmalllintChecker >> manifestBuilderOf: aPackage [

	^ aPackage manifestBuilderForRuleChecker: self
]

{ #category : #accessing }
ReSmalllintChecker >> manifestBuilderOfClass: aClass [
	| key |
	key := aClass instanceSide category.
	^ manifestClassCache
		at: key
		ifAbsentPut: [ 
			(self builderManifestClass hasManifestFor: aClass)
				ifTrue: [ self builderManifestClass of: aClass ]
				ifFalse: [ nil ] ]
]

{ #category : #accessing }
ReSmalllintChecker >> manifestBuilderOfMethod: aMethod [
	| key cl |
	cl := aMethod methodClass.
	key := cl name , aMethod category asString.
	^ manifestClassCache
		at: key
		ifAbsentPut: [ 
			(self builderManifestClass hasManifestFor: aMethod)
				ifTrue: [ self builderManifestClass of: aMethod ]
				ifFalse: [ nil ] ]
]

{ #category : #accessing }
ReSmalllintChecker >> manifestBuilderOfPackage: aPackage [
	| key |
	key := aPackage packageName.
	^ manifestClassCache
		at: key
		ifAbsentPut: [ 
			(self builderManifestClass hasPackageNamed: key)
				ifTrue: [ self builderManifestClass ofPackageNamed: key ]
				ifFalse: [ nil ] ]
]

{ #category : #private }
ReSmalllintChecker >> reParseRule [

	methodRules := Set new.
	nodeRules := Set new.
	classRules := Set new.
	packageRules := Set new.

	self rule do: [ :r | 
		r class checksMethod ifTrue: [ methodRules add: r ].
		r class checksNode ifTrue: [ nodeRules add: r ].
		r class checksClass ifTrue: [ classRules add: r ] ]
]

{ #category : #manifest }
ReSmalllintChecker >> rejectClassesOf: aPackage [

	| mb |

	mb := self manifestBuilderOf: aPackage.
	^ mb ifNil: [ {} ] ifNotNil: [ mb rejectClasses ]
]

{ #category : #manifest }
ReSmalllintChecker >> rejectRulesOf: aPackage [

	| mb |

	mb := self manifestBuilderOf: aPackage.
	^ mb ifNil: [ {} ] ifNotNil: [ mb rejectRules ]
]

{ #category : #running }
ReSmalllintChecker >> resetResult [

	critiques := Set new
]

{ #category : #accessing }
ReSmalllintChecker >> rule [
	
	^ (rule isKindOf: RBCompositeLintRule)
		ifTrue: [ rule leaves ]
		ifFalse: [ rule ]
]

{ #category : #actions }
ReSmalllintChecker >> run [
	self reParseRule.
	super run
]

{ #category : #actions }
ReSmalllintChecker >> runRules: aCompositeRule onPackage: aPackage [

	rule := aCompositeRule.
	environment := RBPackageEnvironment package: aPackage.
	self run.
]

{ #category : #actions }
ReSmalllintChecker >> runRules: aCompositeRule onPackage: aPackage withoutTestCase: avoidTestCases [
	rule := aCompositeRule.
	environment := RBPackageEnvironment package: aPackage.
	
	environment := environment withoutClasses: (environment classes select: #isManifest).
	avoidTestCases 
		ifTrue: [ environment := environment withoutClasses: (environment classes select: #isTestCase) ].
	self run
]

{ #category : #manifest }
ReSmalllintChecker >> toDoOf: aRule [

	| ruleCritiques rId rV mb |

	ruleCritiques := self criticsOf: aRule.
	rId := aRule class uniqueIdentifierName.
	rV := aRule class identifierMinorVersionNumber.
	^ ruleCritiques
		select: [ :critique | 
			| entity |

			entity := critique sourceAnchor entity.
			mb := self manifestBuilderOf: entity.
			mb ifNil: [ false ] ifNotNil: [ mb containsToDo: entity onRule: rId version: rV ]
			]
]
