"
I am a refactoring operation for creating accessors for all variables.

Example:
Create accessors for all instance variables:

```
RBAccessorClassRefactoring 
	model: RBNamespace new className: 'Morph' .
```
Create accessors for all class instance variables:

```
RBAccessorClassRefactoring 
	model: RBNamespace new className: 'Morph class' .
```
If the class already contains that accessor, I will create another one with a numbered suffix.

"
Class {
	#name : #RBAccessorClassRefactoring,
	#superclass : #RBClassRefactoring,
	#category : #'Refactoring-Core-Transformation'
}

{ #category : #accessing }
RBAccessorClassRefactoring class >> kind [
	^ 'Transformation'
]

{ #category : #preconditions }
RBAccessorClassRefactoring >> preconditions [

	^ self refactorings
		  inject: self emptyCondition
		  into: [ :result :each | result & each preconditions ]
]

{ #category : #accessing }
RBAccessorClassRefactoring >> refactorings [
	| class |
	class := self classObjectFor: className asSymbol.
	^  class instanceVariableNames collect: [ :each | 
		RBCreateAccessorsForVariableRefactoring
			variable: each class: class classVariable: false ]
]

{ #category : #transforming }
RBAccessorClassRefactoring >> transform [
	self refactorings do: [ :each | self performCompositeRefactoring: each ]
]
