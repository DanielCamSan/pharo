"
I am a refactoring condition for doing a precondition check for refactoring operations.

A precondition check returns true or false and is used by refactoring operations to check whether the operation is applicable to the target entity (class or method refactoring).

You can set the block code used for testing the condition (#withBlock:).
And I define some factory methods on my class side for creating instances of me, for some typically usage. 

For example: 
This creates a condition checking if the class named #Morph implements a selector named #drawOn:
(RBCondition definesSelector:#drawOn: in: (RBClass existingNamed:#Morph)).

Most users of me are refactoring operations and use my methods on the class side for creating instances.

"
Class {
	#name : #RBCondition,
	#superclass : #RBAbstractCondition,
	#instVars : [
		'block',
		'errorBlock'
	],
	#category : #'Refactoring-Core-Conditions'
}

{ #category : #'variable accessing' }
RBCondition class >> accessesClassVariable: variableName in: aClass showIn: aTransformation [

	^ RBCondition withBlock: [ | block |
		block := 	[ :each | 
			(each whichSelectorsReferToClassVariable: variableName)
				ifNotEmpty: [ aClass realClass
					ifNil: [ RBRefactoring new
						refactoringError: ('<1s> is referenced.' expandMacrosWith: variableName) ]
					ifNotNil: [ RBRefactoring new
						refactoringError: ('<1s> is referenced.<n>Browse references?' expandMacrosWith: variableName)
						with: [ aTransformation openBrowserOn: (RBVariableEnvironment 
									referencesToClassVariable: variableName
									in: aClass realClass) ] ] ] ].
			aClass withAllSubclasses do: block.
			aClass classSide withAllSubclasses do: block.
			true ]
]

{ #category : #'variable accessing' }
RBCondition class >> accessesInstanceVariable: variableName in: aClass showIn: aTransformation [

	| references |
	references := RBCondition referencesInstanceVariable: variableName in: aClass.
	aClass realClass 
		ifNil: [ references errorMacro: ('<1s> is referenced.' expandMacrosWith: variableName) ]
		ifNotNil: [ references
			errorMacro: ('<1s> is referenced.<n>Browse references?' expandMacrosWith: variableName);
			errorBlock: [ aTransformation openBrowserOn: 
				(RBBrowserEnvironment new instVarRefsTo: variableName in: aClass realClass)]].
	^ references not
]

{ #category : #'instance creation' }
RBCondition class >> canUnderstand: aSelector in: aClass [

	^self new
		block: [aClass definesMethod: aSelector]
		errorString: aClass printString , ' <1?:does not >understand<1?s:> ' , aSelector printString
]

{ #category : #utilities }
RBCondition class >> checkClassVarName: aName in: aClass [ 
	| string |
	aName isString ifFalse: [^false].
	string := aName asString.
	(self reservedNames includes: string) ifTrue: [^false].
	string isEmpty ifTrue: [^false].
	string first isUppercase ifFalse: [^false].
	^RBScanner isVariable: string
]

{ #category : #utilities }
RBCondition class >> checkInstanceVariableName: aName in: aClass [ 
	| string |
	aName isString ifFalse: [^false].
	string := aName asString.
	string isEmpty ifTrue: [^false].
	(self reservedNames includes: string) ifTrue: [^false].
	string first isUppercase ifTrue: [^false].
	^RBScanner isVariable: string
]

{ #category : #utilities }
RBCondition class >> checkMethodName: aString [
	"Return whether the argument aName is can represent a selector"
	
	^ aString isString and: [ aString isValidSelector ]
]

{ #category : #utilities }
RBCondition class >> checkMethodName: aString in: aClass [ 
	"Return whether the argument aName is can represent a selector"
	"You probably look for checkMethodName: since the second argument is ignored"
	
	^aString isString and: [ aString isValidSelector ]
]

{ #category : #'instance creation' }
RBCondition class >> definesClassVariable: aString in: aClass [ 
	^self new 
		block: [aClass definesClassVariable: aString]
		errorString: aClass printString 
				, ' <1?:does not >define<1?s:> class variable ' , aString
]

{ #category : #'instance creation' }
RBCondition class >> definesInstanceVariable: aString in: aClass [ 
	^self new 
		block: [aClass definesInstanceVariable: aString]
		errorString: aClass printString 
				, ' <1?:does not >define<1?s:> instance variable ' , aString
]

{ #category : #'instance creation' }
RBCondition class >> definesSelector: aSelector in: aClass [ 
	^self new
		block: [aClass directlyDefinesMethod: aSelector]
		errorString: aClass printString , ' <1?:does not >define<1?s:> ' , aSelector printString
]

{ #category : #'instance creation' }
RBCondition class >> definesSelector: aSelector in: aClass orIsSimilarTo: rbMethod [
	^self new
		block: [(aClass directlyDefinesMethod: aSelector)
			ifTrue: [ (aClass parseTreeFor: aSelector) ~= rbMethod parseTree ]
			ifFalse: [ false ]
			]
		errorString: aClass printString , ' <1?:does not >define<1?s:> ' , aSelector printString
]

{ #category : #'instance creation' }
RBCondition class >> definesTempVar: aString in: aClass ignoreClass: subclass [ 
	| condition |
	condition := self new.
	condition 
		block: 
			[| method |
			method := self 
						methodDefiningTemporary: aString
						in: aClass
						ignore: [:class :aSelector | class includesClass: subclass].
			method notNil 
				ifTrue: 
					[condition errorMacro: method printString , ' defines variable ' , aString].
			method notNil]
		errorString: aClass printString 
				, ' <1?:does not >define<1?s:> temporary variable ' , aString.
	^condition
]

{ #category : #'instance creation' }
RBCondition class >> definesTemporaryVariable: aString in: aClass [ 
	| condition |
	condition := self new.
	condition 
		block: 
			[| method |
			method := self 
						methodDefiningTemporary: aString
						in: aClass
						ignore: [:class :selector | false].
			method notNil 
				ifTrue: 
					[condition errorMacro: method printString , ' defines variable ' , aString].
			method notNil]
		errorString: aClass printString 
				, ' <1?:does not >define<1?s:> temporary variable ' , aString.
	^condition
]

{ #category : #'instance creation' }
RBCondition class >> directlyDefinesClassVariable: aString in: aClass [ 
	^self new 
		block: [aClass directlyDefinesClassVariable: aString]
		errorString: aClass printString 
				, ' <1?:does not >directly define<1?s:> class variable ' , aString
]

{ #category : #'instance creation' }
RBCondition class >> directlyDefinesInstanceVariable: aString in: aClass [ 
	^self new 
		block: [aClass directlyDefinesInstanceVariable: aString]
		errorString: aClass printString 
				, ' <1?:does not >directly define<1?s:> instance variable ' , aString
]

{ #category : #'variable accessing' }
RBCondition class >> doesNotAccessInstanceVariable: variableName inHierarchyOf: aClass showIn: aTransformation [

	| references |
	references := RBCondition hierarchyOf: aClass referencesInstanceVariable: variableName.
	aClass realClass 
		ifNil: [ references errorMacro: ('<1s> is referenced.' expandMacrosWith: variableName) ]
		ifNotNil: [ references
			errorMacro: ('<1s> is referenced.<n>Browse references?' expandMacrosWith: variableName);
			errorBlock: [ aTransformation openBrowserOn: 
				(RBBrowserEnvironment new instVarRefsTo: variableName in: aClass realClass)]].
	^ references not
]

{ #category : #'instance creation' }
RBCondition class >> empty [
	"Returns an empty condition"

	^self new 
		block: [true]
		errorString: 'Empty'
]

{ #category : #'instance creation' }
RBCondition class >> hasSubclasses: aClass [
	^self new
		block: [aClass subclasses isNotEmpty ]
		errorString: aClass printString , ' has <1?:no >subclasses'
]

{ #category : #'instance creation' }
RBCondition class >> hasSubclasses: aClass excluding: classList [ 
	^self new
		block: [ ((aClass subclasses collect: [:each | each name]) copyWithoutAll: classList) isNotEmpty ]
		errorString: aClass printString , ' has <1?:no >subclasses'
]

{ #category : #'instance creation' }
RBCondition class >> hasSuperclass: aClass [ 
	^self new 
		block: [aClass superclass isNil not]
		errorString: aClass printString , ' has <1?a:no> superclass'
]

{ #category : #'instance creation' }
RBCondition class >> hierarchyOf: aClass canUnderstand: aSelector [
	^self new
		block: [aClass hierarchyDefinesMethod: aSelector]
		errorString: aClass printString , ' <1? and/or part of it''s Hierarchy already: and/or part of it''s Hierarchy do not> understand<1?s:> ' , aSelector printString
]

{ #category : #'instance creation' }
RBCondition class >> hierarchyOf: aClass definesVariable: aString [ 
	^self new 
		block: [aClass hierarchyDefinesVariable: aString]
		errorString: aClass printString 
				, ' or one of its subclasses <1?:does not >define<1?s:> variable ' 
					, aString
]

{ #category : #'instance creation' }
RBCondition class >> hierarchyOf: aClass referencesInstanceVariable: aString [

	^ self new
		  block: [ 
			  (aClass withAllSubclasses
				   detect: [ :each | 
					   (each whichSelectorsReferToInstanceVariable: aString)
						   isNotEmpty ]
				   ifNone: [ nil ]) notNil ]
		  errorString: aClass printString
			  , ' or subclass <1?:does not >reference<1?s:> instance variable '
			  , aString
]

{ #category : #'instance creation' }
RBCondition class >> isAbstractClass: aClass [

	^ self new
		  block: [ aClass isAbstract ]
		  errorString: aClass printString , ' is <1?:not >an abstract class'
]

{ #category : #'instance creation' }
RBCondition class >> isClass: anObject [
	^self new
		block: [anObject isBehavior]
		errorString: anObject printString , ' is <1?:not >a behavior'
]

{ #category : #'instance creation' }
RBCondition class >> isEmptyClass: anObject [

	^ self new
		  block: [ 
			  anObject classVariableNames isEmpty and: [ 
				  anObject instanceVariableNames isEmpty and: [ 
					  anObject selectors isEmpty ] ] ]
		  errorString: anObject printString , ' is <1?:not > empty'
]

{ #category : #'instance creation' }
RBCondition class >> isGlobal: aString in: aRBSmalltalk [

	^ self new
		  block: [ aRBSmalltalk includesGlobal: aString asSymbol ]
		  errorString: aString , ' is <1?:not >a class or global variable'
]

{ #category : #'instance creation' }
RBCondition class >> isImmediateSubclass: subclass of: superClass [

	^ self new
		  block: [ subclass superclass = superClass ]
		  errorString:
			  subclass printString , ' is <1?:not >an immediate subclass of '
			  , superClass printString
]

{ #category : #'instance creation' }
RBCondition class >> isMetaclass: anObject [

	^ self new
		  block: [ anObject isMeta ]
		  errorString: anObject printString , ' is <1?:not >a metaclass'
]

{ #category : #'instance creation' }
RBCondition class >> isSubclass: subclass of: superClass [

	^ self new
		  block: [ subclass includesClass: superClass ]
		  errorString: subclass printString , ' is <1?:not >a subclass of '
			  , superClass printString
]

{ #category : #'instance creation' }
RBCondition class >> isSymbol: aString [

	^ self new
		  block: [ aString isSymbol ]
		  errorString: aString , ' is <1?:not >a symbol'
]

{ #category : #'instance creation' }
RBCondition class >> isValidClassName: aString [

	^ self new
		  block: [ self validClassName: aString ]
		  errorString: aString , ' is <1?:not >a valid class name'
]

{ #category : #'instance creation' }
RBCondition class >> isValidClassVarName: aString for: aClass [

	^ self new
		  block: [ self checkClassVarName: aString in: aClass ]
		  errorString: aString , ' is <1?:not >a valid class variable name'
]

{ #category : #'instance creation' }
RBCondition class >> isValidInstanceVariableName: aString for: aClass [

	^ self new
		  block: [ self checkInstanceVariableName: aString in: aClass ]
		  errorString:
		  aString , ' is <1?:not >a valid instance variable name'
]

{ #category : #'instance creation' }
RBCondition class >> isValidMethodName: aString for: aClass [

	^ self new
		  block: [ self checkMethodName: aString in: aClass ]
		  errorString:
		  aString printString , ' is <1?:not >a valid method name'
]

{ #category : #utilities }
RBCondition class >> methodDefiningTemporary: aString in: aClass ignore: aBlock [ 
	| searcher method |
	searcher := RBParseTreeSearcher new.
	method := nil.	"Shut-up the warning"
	searcher matches: aString do: [:aNode :answer | ^method].
	aClass withAllSubclasses do: 
			[:class | 
			class selectors do: 
					[:each | 
					(aBlock value: class value: each) 
						ifFalse: 
							[| parseTree |
							method := class methodFor: each.
							parseTree := class parseTreeFor: each.
							parseTree notNil ifTrue: [searcher executeTree: parseTree]]]].
	^nil
]

{ #category : #'instance creation' }
RBCondition class >> referencesInstanceVariable: aString in: aClass [

	^ self new
		  block: [ 
		  (aClass whichSelectorsReferToInstanceVariable: aString) isNotEmpty ]
		  errorString: aClass printString
			  , ' <1?:does not >reference<1?s:> instance variable ' , aString
]

{ #category : #utilities }
RBCondition class >> reservedNames [
	^#('self' 'true' 'false' 'nil' 'thisContext' 'super')
]

{ #category : #'instance creation' }
RBCondition class >> subclassesOf: aClass referToSelector: aSelector [

	^ self new
		  block: [ 
			  (aClass subclasses
				   detect: [ :each | 
					   (each selectors
						    detect: [ :sel | 
							    | tree |
							    tree := each parseTreeFor: sel.
							    tree notNil and: [ tree superMessages includes: aSelector ] ]
						    ifNone: [ nil ]) notNil ]
				   ifNone: [ nil ]) notNil ]
		  errorString:
			  '<1?:no:a> subclass of ' , aClass printString , ' refers to '
			  , aSelector printString
]

{ #category : #utilities }
RBCondition class >> validClassName: aString [ 
	"Class names and class variable names have the same restrictions"

	^self checkClassVarName: aString in: self
]

{ #category : #'instance creation' }
RBCondition class >> withBlock: aBlock [
	^self new withBlock: aBlock
]

{ #category : #'instance creation' }
RBCondition class >> withBlock: aBlock errorString: aString [

	^ self new block: aBlock errorString: aString
]

{ #category : #initialization }
RBCondition >> block: aBlock errorString: aString [ 

	block := aBlock.
	self errorMacro: aString
]

{ #category : #checking }
RBCondition >> check [
	^block value
]

{ #category : #initialization }
RBCondition >> errorBlock: anObject [
	errorBlock := anObject
]

{ #category : #accessing }
RBCondition >> errorBlockFor: aBoolean [
	^errorBlock
]

{ #category : #initialization }
RBCondition >> withBlock: aBlock [ 
	block := aBlock
]
