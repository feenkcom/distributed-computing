"
A DPMapReduceSimpleProcessor is created by DPMapReduceSimpleManager for each external process used to process the data.

DPMapReduceSimpleProcessor is responsible for starting and stopping a PharoLinkApplication server and running the task in the server.

 
!!Internal Representation and Key Implementation Points.

!!!Instance Variables

	application:		<PharoLinkApplication>
	command:			<String>
	future:			<TKTFuture>
	host:				<String>
	portNumber:		<Integer>
	result:			<Object | Error>


!!!Implementation Points
"
Class {
	#name : #DPTaskProcessor,
	#superclass : #Object,
	#instVars : [
		'host',
		'portNumber',
		'application',
		'command',
		'future',
		'result'
	],
	#category : #'DistributedProcessing-Model'
}

{ #category : #accessing }
DPTaskProcessor >> command [
	^ command
]

{ #category : #accessing }
DPTaskProcessor >> command: anObject [
	command := anObject
]

{ #category : #accessing }
DPTaskProcessor >> future [
	^ future
]

{ #category : #ui }
DPTaskProcessor >> gtStatusFor: aView [
	<gtView>

	^ aView textEditor 
		title: 'Status';
		priority: 10;
		look: BrGlamorousCodeEditorLook;
		text: [ self statusString asRopedText ]
]

{ #category : #accessing }
DPTaskProcessor >> host [

	^ host ifNil: [ host := 'localhost' ]
]

{ #category : #accessing }
DPTaskProcessor >> host: anObject [
	host := anObject
]

{ #category : #testing }
DPTaskProcessor >> isFinished [ 

	^ future isFinished
]

{ #category : #testing }
DPTaskProcessor >> isSuccess [

	^ future isSuccess
]

{ #category : #accessing }
DPTaskProcessor >> portNumber [
	^ portNumber
]

{ #category : #accessing }
DPTaskProcessor >> portNumber: anObject [
	portNumber := anObject
]

{ #category : #printing }
DPTaskProcessor >> printOn: aStream [

	super printOn: aStream.
	aStream
		<< '(';
		<< self stateString;
		<< ')'
]

{ #category : #accessing }
DPTaskProcessor >> result [
	^ result
]

{ #category : #executing }
DPTaskProcessor >> runIn: anExecutionManager [
	"Schedule execution of the receiver in the supplied execution manager and set up handling of the future"

	future := anExecutionManager runner future: (TKTTask valuable: self).
	future onSuccessDo: [ :value |
		anExecutionManager noteProcessCompletion ].
	future onFailureDo: [ :value |
		anExecutionManager noteProcessCompletion ].

]

{ #category : #printing }
DPTaskProcessor >> stateString [

	^ self isFinished ifFalse: 
		[ 'Not Finished' ]
	ifTrue: [ self isSuccess ifTrue:
		[ 'Succeeded' ]
	ifFalse:
		[ 'Failed' ] ]
]

{ #category : #printing }
DPTaskProcessor >> statusOn: aStream [

	aStream
		<< 'Status: ';
		<< self stateString; cr;
		<< 'Host / Port: ';
		<< (host ifNil: [ '<none>' ]);
		<< ':';
		print: portNumber; cr;
		<< 'Command:'; cr; cr;
		<< (command ifNil: [ '<none>' ]); cr.

	(self isFinished not or: [ self isSuccess ]) ifTrue: [ ^ self ].

	aStream cr.
	aStream print: result; cr.
]

{ #category : #printing }
DPTaskProcessor >> statusString [ 

	^ String streamContents: [ :s | self statusOn: s ]
]

{ #category : #accessing }
DPTaskProcessor >> stop [ 

	application stop
]

{ #category : #evaluating }
DPTaskProcessor >> value [ 
	| settings haveError |

	settings := LanguageLinkSettings pharoDefaultSettings.
	settings 
		debugMode: true;
		clientSocketAddress: (LanguageLinkSocketAddress ipOrName: self host port: self portNumber);
		serverSocketAddress: (LanguageLinkSocketAddress ipOrName: self host port: self portNumber + 1000).
	application := PharoLinkApplication newWith: settings.
	application start.
	haveError := false.
	result := [ application newCommandFactory 
		<< self command;
		sendAndWait ]
			on: PharoLinkRemoteError
			do: [ :ex | haveError := true. ex ].
	application stop.
	haveError ifTrue: [ self error: 'Remote execution error' ].
	^ result
]
