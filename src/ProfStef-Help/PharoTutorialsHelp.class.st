"
I'm a HelpSystem book which list all Pharo tutorials
"
Class {
	#name : #PharoTutorialsHelp,
	#superclass : #PharoTutorialHelp,
	#category : #'ProfStef-Help'
}

{ #category : #accessing }
PharoTutorialsHelp class >> bookName [ 
	^ 'Browse tutorials'
]

{ #category : #defaults }
PharoTutorialsHelp class >> builder [
	^ PharoTutorialHelpTutorialBuilder
]

{ #category : #menu }
PharoTutorialsHelp class >> menuCommandOn: aBuilder [ 
	<worldMenu> 
	(aBuilder item: #'Pharo Tutorials')
			parent: #PharoHelp;
			order: 2;
			action:[ HelpBrowser openOn: self ]; 
			icon: ((self iconNamed: #pharo) scaledToSize: 16@16);
			help: 'Browse and create Pharo tutorials.'.
]
