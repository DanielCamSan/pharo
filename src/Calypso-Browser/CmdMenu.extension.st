Extension { #name : #CmdMenu }

{ #category : #'*Calypso-Browser' }
CmdMenu >> buildBrowserNotebookActions [

	^ rootGroup buildBrowserNotebookActions
]

{ #category : #'*Calypso-Browser' }
CmdMenu >> buildBrowserTabActions [

	^rootGroup buildBrowserTabActions
]

{ #category : #'*Calypso-Browser' }
CmdMenu >> buildBrowserToolbar: aToolbar [

	rootGroup buildBrowserToolbar: aToolbar
]
