Class {
	#name : #RBInlineParameterParametrizedTest,
	#superclass : #RBAbstractRefactoringTest,
	#category : #'Refactoring2-Transformations-Tests-SingleParametrized'
}

{ #category : #tests }
RBInlineParameterParametrizedTest class >> testParameters [
	^ ParametrizedTestMatrix new
		addCase: { #rbClass -> RBInlineParameterRefactoring };
		yourself
]

{ #category : #accessing }
RBInlineParameterParametrizedTest >> constructor [ 
	^ #inlineParameter:in:selector:
]

{ #category : #'failure tests' }
RBInlineParameterParametrizedTest >> testInlineArgsWhitoutSameLiteral [
	self shouldFail: (self createRefactoringWithArguments:  
		{ 'aSymbol' . RBRefactoryTestDataApp . ('inline' , 'Bar:') asSymbol })
]

{ #category : #'failure tests' }
RBInlineParameterParametrizedTest >> testInlineBlockFailure [
	self shouldFail: (self createRefactoringWithArguments: 
		{ 'aBlock' . RBRefactoryTestDataApp . ('inline' , 'Foo:') asSymbol })
]

{ #category : #tests }
RBInlineParameterParametrizedTest >> testInlineLiteralArray [
	| refactoring class |
	refactoring := self createRefactoringWithArguments: 
		{ 'aSymbol' . RBRefactoryTestDataApp . ('inline' , 'ParameterMethod:') asSymbol }.
	
	self proceedThroughWarning: [ self executeRefactoring: refactoring ].
	
	class := refactoring model classNamed: #RBRefactoryTestDataApp.
	self assert: (class parseTreeFor: #inlineParameterMethod) equals: (self parseMethod: 'inlineParameterMethod | aSymbol | aSymbol := #(asdf). ^aSymbol isSymbol').
	self assert: (class parseTreeFor: #sendInlineParameterMethod) equals: (self parseMethod: 'sendInlineParameterMethod ^self inlineParameterMethod').
	self deny: (class directlyDefinesMethod: ('inline' , 'ParameterMethod:') asSymbol)
]
