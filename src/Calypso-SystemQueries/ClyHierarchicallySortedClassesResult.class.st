"
I am a class query result which represent retrieved classes as hierarchically sorted list.

I do not implement hierarchy building logic by myself. Instead I delegate it to the hierarchy variable, a kind of ClyClassHierarchy.
And I use built map to enumerate classes in hierarchical order and convert them to ClyBrowserItem instances.

You can create my instances directly from hierarchy: 

	ClySubcalssHierarchy new asQueryResult
	
Or use explicit class side method: 
	
	ClyHierarchicallySortedClasses with: ClySubcalssHierarchy new.
	
I also provide converting methods to get inverse hierarchy result or sorted by another function: 

	aQueryResult withInverseHierarchy.
	aQueryResult sortedBy: aSortFunction.

"
Class {
	#name : #ClyHierarchicallySortedClassesResult,
	#superclass : #ClyBrowserQueryResult,
	#instVars : [
		'hierarchy'
	],
	#category : #'Calypso-SystemQueries-Results'
}

{ #category : #'building items' }
ClyHierarchicallySortedClassesResult class >> buildItemsFrom: classes [

	| classesHierarchy |
	classesHierarchy := self new.
	classesHierarchy items: (OrderedCollection new: classes size).
	classesHierarchy fillWith: classes.
	^classesHierarchy items
]

{ #category : #testing }
ClyHierarchicallySortedClassesResult class >> isExpandedHierarchy [
	^true
]

{ #category : #'instance creation' }
ClyHierarchicallySortedClassesResult class >> with: aClassHierarchy [
	^self new 
		hierarchy: aClassHierarchy
]

{ #category : #comparing }
ClyHierarchicallySortedClassesResult >> = anObject [
	"Answer whether the receiver and anObject represent the same object."

	self == anObject ifTrue: [ ^ true ].
	super = anObject ifFalse: [ ^ false ].
	^ hierarchy = anObject hierarchy
]

{ #category : #building }
ClyHierarchicallySortedClassesResult >> buildItemFor: aClass from: aHierarchyMap depth: currentDepth [

	| item childDepth children subTreeSize childItem |
	item := ClyBrowserItem named: aClass name with: aClass. 
	item depth: currentDepth.
	items add: item.
	childDepth := currentDepth + 1.
	children := aHierarchyMap childrenOf: aClass.
	subTreeSize := children size.
	children do: [ :child | 
		childItem := self buildItemFor: child from: aHierarchyMap depth: childDepth.
		subTreeSize := subTreeSize + childItem localHierarchySize].
	item localHierarchySize: subTreeSize.
	^item
]

{ #category : #building }
ClyHierarchicallySortedClassesResult >> fillWith: classes [

	| hierarchyMap |
	items := OrderedCollection new: classes size.
	hierarchyMap := hierarchy buildFrom: classes.
	
	hierarchyMap rootsDo: [ :root | 
		self buildItemFor: root from: hierarchyMap depth: 0]
]

{ #category : #comparing }
ClyHierarchicallySortedClassesResult >> hash [
	"Answer an integer value that is related to the identity of the receiver."

	^super hash bitXor: hierarchy hash
]

{ #category : #accessing }
ClyHierarchicallySortedClassesResult >> hierarchy [
	^ hierarchy
]

{ #category : #accessing }
ClyHierarchicallySortedClassesResult >> hierarchy: anObject [
	hierarchy := anObject
]

{ #category : #initialization }
ClyHierarchicallySortedClassesResult >> initialize [
	super initialize.
	
	hierarchy := ClySubclassHierarchy new
]

{ #category : #converting }
ClyHierarchicallySortedClassesResult >> sortedBy: aSortFunction [
	^self copy 
		hierarchy: (hierarchy sortedBy: aSortFunction)
]

{ #category : #converting }
ClyHierarchicallySortedClassesResult >> withInverseHierarchy [
	^self copy 
		hierarchy: hierarchy inverted
]
