"
I'm an abstract class grouping generic methods for managing packages/classes/groups/methods from a browser
"
Class {
	#name : #AbstractTool,
	#superclass : #Model,
	#category : #'Tool-Base-Utilities'
}

{ #category : #private }
AbstractTool class >> protocolSuggestionsFor: aClass [

	| classProtocols reject allExistingProtocols interestingProtocols |
	classProtocols := aClass organization allCategories.
	reject := Set new.
	reject
		add: AllProtocol defaultName;
		add: Protocol nullCategory;
		add: Protocol unclassified.
	allExistingProtocols := (SystemNavigation default 
		                         allExistingProtocolsFor: aClass isMeta not) 
		                        reject: [ :p | classProtocols includes: p ].
	interestingProtocols := classProtocols
	                        ,
		                        (allExistingProtocols asOrderedCollection 
			                         sort: [ :a :b | 
			                         a asLowercase < b asLowercase ]).
	^ interestingProtocols reject: [ :e | reject includes: e ]
]

{ #category : #method }
AbstractTool >> browseAllStoresInto: aVariableName from: aClass [ 
	^self systemNavigation browseAllStoresInto: aVariableName from: aClass 
]

{ #category : #class }
AbstractTool >> browseClassRefsOf: aClass [

	| class |
	aClass ifNil: [ ^self ].
	class := aClass instanceSide ifNil: [^self].
	class isTrait 
		ifTrue: [self systemNavigation browseAllUsersOfTrait: class]
		ifFalse: [self systemNavigation browseAllCallsOnClass: class]

]

{ #category : #method }
AbstractTool >> browseMessagesFrom: aSelector [
	" badly named, it browses implementors "

	self getSelectorAndSendQuery: #browseAllImplementorsOf: to: self systemNavigation with: {} selector: aSelector
]

{ #category : #method }
AbstractTool >> browseSendersOfMessagesFrom: aSelector [
	"Present a menu of the currently selected message, as well as all messages sent by it.  Open a message set browser of all senders of the selector chosen."

	self getSelectorAndSendQuery: #browseAllSendersOf: to: self systemNavigation with: {} selector: aSelector
]

{ #category : #method }
AbstractTool >> browseVersionsFrom: aMethod [
	"Create and schedule a Versions Browser, showing all versions of the 
	currently selected message. Answer the browser or nil."

	aMethod selector
		ifNil: [ self inform: 'Sorry, only actual methods have retrievable versions.'. ^nil ]
		ifNotNil: [:selector |
			Smalltalk tools versionBrowser browseVersionsForMethod: aMethod ]
				
]

{ #category : #method }
AbstractTool >> defaultGetSelectorAndSendQuery: array to: queryPerformer with: querySelector [
	| selector |
	
	selector := UIManager default request: 'Type selector:' initialAnswer: 'flag:'.
	selector ifNil: [ selector := String new ].
	selector := selector copyWithout: Character space.
	^ selector isEmptyOrNil
		ifFalse: [ 
			(Symbol
				hasInterned: selector
				ifTrue: [ :aSymbol | 
					array at: 1 put: aSymbol.
					queryPerformer perform: querySelector withArguments: array ])
				ifFalse: [ self inform: 'no such selector' ] ]
]

{ #category : #method }
AbstractTool >> getSelectorAndSendQuery: querySelector to: queryPerformer with: queryArgs selector: aSelector [
	"Obtain a selector relevant to the current context, and then send the querySelector to the queryPerformer with the selector obtained and queryArgs as its arguments.  If no message is currently selected, then obtain a method name from a user type-in"
	| strm array |
	
	array := Array new: queryArgs size + 1.
	strm := array writeStream.
	strm nextPut: nil.
	strm nextPutAll: queryArgs.
	
	aSelector ifNil: [ ^ self 
						defaultGetSelectorAndSendQuery: querySelector
						to: queryPerformer
						with: array ].
	
	array at: 1 put: aSelector.
	queryPerformer perform: querySelector withArguments: array.
]

{ #category : #class }
AbstractTool >> removeClass: aClass [
	"Remove the selected class from the system, at interactive user request.  Make certain the user really wants to do this, since it is not reversible.  Answer true if removal actually happened."

	| message className classToRemove result |
	aClass ifNil: [ ^ false ].
	classToRemove := aClass instanceSide.
	className := classToRemove name.
	message := self removeClassMessageFor: className.
	(result := self confirm: message)
		ifTrue: [ 
			classToRemove subclasses notEmpty
				ifTrue: [ 
					(self confirm: 'class has subclasses: ' , message)
						ifFalse: [ ^ false ] ].
			classToRemove removeFromSystem ].
	^ result
]

{ #category : #class }
AbstractTool >> removeClassMessageFor: className [
	^ 'Are you certain that you
want to REMOVE the class ' , className
		,
			'
from the system?'
]

{ #category : #class }
AbstractTool >> removeClasses: aCollection [
	"Remove the selected classes from the system.  Check that the user really wants to do this, since it is not reversible.  Answer true if removal actually happened."

	| classNames classesToRemove result |
	aCollection isEmptyOrNil
		ifTrue: [ ^ false ].
	classesToRemove := aCollection collect: [:each | each instanceSide].
	classNames := (classesToRemove collect: [:each | each name]) joinUsing: ', '.
	(result := self confirm: (self removeClassesMessageFor: classNames))
		ifTrue: [ 
			classesToRemove
				do: [ :classToRemove | 
					classToRemove subclasses notEmpty
						ifTrue: [ 
							(self confirm: (self removedClassHasSubclassesMessageFor: classToRemove name))
								ifTrue: [ classToRemove removeFromSystem ] ]
						ifFalse: [ classToRemove removeFromSystem ] ] ].
	^ result
]

{ #category : #class }
AbstractTool >> removeClassesMessageFor: classNames [
	^ 'Are you certain that you
want to REMOVE the classes ' , classNames
		,
			'
from the system?'
]

{ #category : #method }
AbstractTool >> removeMethod: aMethod inClass: aClass [
	"If a message is selected, create a Confirmer so the user can verify that  
	the currently selected message should be removed from the system. If 
	so, remove it. "
	| messageName confirmation |
	
	aMethod ifNil: [^ false].
	messageName := aMethod selector.
	confirmation := self systemNavigation confirmRemovalOf: messageName on: aClass.
	confirmation = 3
		ifTrue: [^ false].
	(aClass includesLocalSelector: messageName)
		ifTrue: [ aClass removeSelector: messageName ]
		ifFalse: [ self removeNonLocalSelector: messageName ].

	"In case organization not cached"
	confirmation = 2
		ifTrue: [self systemNavigation browseAllSendersOf: messageName].
		
	self removeEmptyUnclassifiedCategoryFrom: aClass.
	^ true
]

{ #category : #class }
AbstractTool >> removedClassHasSubclassesMessageFor: className [

	^ className, ' has subclasses.
Do you really want to REMOVE it from the system ?'
]

{ #category : #class }
AbstractTool >> renameClass: aClass [
	| oldName newName obs |

	aClass ifNil: [ ^ self ].
	
	oldName := aClass name.
	newName := UIManager default  request: 'Please type new class name' initialAnswer: oldName.
	newName isEmptyOrNil ifTrue: [ ^ self ].	"Cancel returns"
	newName := newName asSymbol.
	newName = oldName ifTrue: [ ^ self ].
	(self class environment includesKey: newName)
		ifTrue: [ ^ self error: newName , ' already exists' ].
	aClass rename: newName.

	obs := self systemNavigation allReferencesTo: (aClass environment associationAt: newName).
	obs isEmpty
		ifFalse: [ self systemNavigation browseMessageList: obs name: 'Obsolete References to ' , oldName autoSelect: oldName ].
	^ newName
]
