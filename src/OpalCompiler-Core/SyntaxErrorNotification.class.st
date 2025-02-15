Class {
	#name : #SyntaxErrorNotification,
	#superclass : #Notification,
	#instVars : [
		'inClass',
		'code',
		'doitFlag',
		'location'
	],
	#category : #'OpalCompiler-Core-Exception'
}

{ #category : #exceptionInstantiator }
SyntaxErrorNotification class >> inClass: aClass withCode: codeString doitFlag: doitFlag errorMessage: errorString location: location [
	^ (self new
		setClass: aClass
		code: codeString
		doitFlag: doitFlag
		errorMessage: errorString
		location: location) signal
]

{ #category : #exceptiondescription }
SyntaxErrorNotification >> defaultAction [

	^ UIManager default syntaxErrorNotificationDefaultAction: self
]

{ #category : #accessing }
SyntaxErrorNotification >> doitFlag [
	^doitFlag
]

{ #category : #accessing }
SyntaxErrorNotification >> errorClass [
	^inClass
]

{ #category : #accessing }
SyntaxErrorNotification >> errorCode [
	^code
]

{ #category : #accessing }
SyntaxErrorNotification >> errorMessage [
	^messageText
]

{ #category : #accessing }
SyntaxErrorNotification >> location [
	^location
]

{ #category : #accessing }
SyntaxErrorNotification >> messageText [
	^ super messageText
		ifNil: [messageText := code]
]

{ #category : #accessing }
SyntaxErrorNotification >> setClass: aClass code: codeString doitFlag: aBoolean errorMessage: errorString location: anInteger [
	inClass := aClass.
	code := codeString.
	doitFlag := aBoolean.
	messageText := errorString.
	location := anInteger
]
