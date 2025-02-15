Extension { #name : #ChangesBrowser }

{ #category : #'*Epicea-Triggering' }
ChangesBrowser >> asEpiceaEvent [

	self flag: #pharoTodo. "This is a workaround for a problem found by RewriteTool"
	(self changes allSatisfy: [ :each | each respondsTo: #asEpiceaEvent ]) 
		ifFalse: [ ^ EpCompositeRefactoring withAll: #(  ) ].

	^ self changes size > 1
		  ifTrue: [ EpCompositeRefactoring withAll: self changes ]
		  ifFalse: [ self changes anyOne asEpiceaEvent ]
]

{ #category : #'*Epicea-Triggering' }
ChangesBrowser >> isEpiceaInterestingJobOwner [

	^ true
]
