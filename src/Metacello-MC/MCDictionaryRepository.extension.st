Extension { #name : #MCDictionaryRepository }

{ #category : #'*Metacello-MC' }
MCDictionaryRepository >> asRepositorySpecFor: aMetacelloMCProject [

	| desc |
	desc := self description.
	desc ifNil: [ desc := 'dictionary://Metacello_Dictionary' ].
	^(aMetacelloMCProject repositorySpec)
		description:  desc;
	 	type: 'dictionary';
		yourself
]

{ #category : #'*Metacello-MC' }
MCDictionaryRepository class >> createRepositoryFromSpec: aRepositorySpec on: aPlatform [
	^ aPlatform createDictionaryRepository: aRepositorySpec
]

{ #category : #'*Metacello-MC' }
MCDictionaryRepository class >> isAvailableFor: type [
	^ type = 'dictionary'
]

{ #category : #'*Metacello-MC' }
MCDictionaryRepository >> versionInfoFromVersionNamed: aString [

	| versions |
	versions := self dictionary values select: [:version | version info name beginsWith: aString ].
	versions isEmpty ifTrue: [ ^ nil ].
	versions := versions asSortedCollection: [ :a :b |
		([ (a info name copyAfterLast: $.) asNumber ] on: Error do: [:ex | ex return: 0 ]) <= 
			([ (b info name copyAfterLast: $.) asNumber ] on: Error do: [:ex | ex return: 0 ]) ].
	^ versions last info
]
