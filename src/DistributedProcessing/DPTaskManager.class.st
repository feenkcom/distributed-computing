"
DPMapReduceSimpleManager provides a simple mechanism to run the specified number of mapping operations in separate worker processes, collect the results and process with the supplied reducer.

DPMapReduceSimpleManager currently assumes that there is a single reduction operation, which is run in the host image.

The elapsed run time is measured.  Once the receiver #isFinished, it can be retrieved with #elapsedTime.

To run the supplied CSV example (after producing the source data):

[[[ 
mgr := DPMapReduceSimpleManager new
	processorClass: DPSumLargeCSV;
	reducerClass: DPReduceLargeCSV;
	processorCount: 8;
	file: 'input.csv';
	run.
]]]

To wait for the operation to complete, and return the results: 

[[[
mgr 
	waitForCompletion;
	result.
]]]


!!Internal Representation and Key Implementation Points.

!!!Instance Variables

	basePortNumber:			<Integer>
	completionSemaphore:	<Semaphore>
	endTime:					<DateAndTime>
	file:						<FileReference>
	processorClass:			<Behavior>
	processorCount:			<Integer>
	processors:				<Array of DPMapReduceSimpleProcessor>
	reducerClass:			<Behvaior>
	result:					<Object>
	runner:					<TKTNewProcessTaskRunner>
	startTime:				<DateAndTime>


!!!Implementation Points
"
Class {
	#name : #DPTaskManager,
	#superclass : #Object,
	#instVars : [
		'processorCount',
		'processors',
		'basePortNumber',
		'taskSpec',
		'runner',
		'completionSemaphore',
		'result',
		'startTime',
		'endTime'
	],
	#category : #'DistributedProcessing-Model'
}

{ #category : #configuration }
DPTaskManager >> basePortNumber [
	^ basePortNumber
]

{ #category : #configuration }
DPTaskManager >> basePortNumber: anObject [
	basePortNumber := anObject
]

{ #category : #private }
DPTaskManager >> commandFor: processorNumber of: count [

	^ String streamContents: [ :stream |
		stream
			<< '(';
			<< taskSpec;
			<< ') taskIndex: ';
			print: processorNumber;
			<< '; taskCount: ';
			print: count;
			<< '; run.' ].
]

{ #category : #accessing }
DPTaskManager >> elapsedTime [ 

	^ endTime - startTime
]

{ #category : #accessing }
DPTaskManager >> failedCount [
	"Answer the number of processors that have completed unsuccessfully"

	processors ifNil: [ ^ 0 ].

	^ processors count: [ :processor | processor isFinished and: [ processor isSuccess not ] ]
]

{ #category : #ui }
DPTaskManager >> gtStatusFor: aView [
	<gtView>

	^ aView textEditor 
		title: 'Status';
		priority: 10;
		look: BrGlamorousCodeEditorLook;
		text: [ self statusString asRopedText ]
]

{ #category : #initialization }
DPTaskManager >> initialize [

	super initialize.
	runner := TKTCommonQueueWorkerPool new.
	runner poolMaxSize: 2.
	runner start.
	completionSemaphore := Semaphore new.
	basePortNumber := 13000.
]

{ #category : #testing }
DPTaskManager >> isFinished [ 

	^ processors isNotNil and: [ processors allSatisfy: #isFinished ]
]

{ #category : #testing }
DPTaskManager >> isRunning [ 

	^ processors isNotNil and: [ self isFinished not ]
]

{ #category : #testing }
DPTaskManager >> isSuccess [

	^ processors isNotNil and: [ processors allSatisfy: #isSuccess ]
]

{ #category : #private }
DPTaskManager >> noteProcessCompletion [
	"This is called each time one of the processors completes.
	Check that all have completed and if so signal completion."

	(processors allSatisfy: [ :processor | processor isFinished ]) ifFalse:
		[ ^ self ].
	
	self signalCompletion.

]

{ #category : #printing }
DPTaskManager >> printFailedOn: aStream [

	self failedCount = 0 ifTrue: [ ^ self ].

	processors
		select: [ :each | each isFinished and: [ each isSuccess not ]]
		thenDo: [ :processor | 
			processor statusOn: aStream.
			aStream cr; cr. ]
]

{ #category : #printing }
DPTaskManager >> printOn: aStream [

	aStream
		<< 'Task Manager ('.
	self isFinished ifTrue: 
		[ self isSuccess ifTrue: 
			[ aStream << 'success' ]
		ifFalse:
			[ aStream << 'error' ] ]
	ifFalse:
		[ processors ifNil:
			[ aStream << 'not started' ]
		ifNotNil:
			[ aStream << 'in progress' ] ].
	aStream
		<< ') for: ';
		<< (taskSpec ifNil: [ '<none>' ]).

]

{ #category : #configuration }
DPTaskManager >> processorCount [
	^ processorCount
]

{ #category : #configuration }
DPTaskManager >> processorCount: anObject [
	processorCount := anObject
]

{ #category : #running }
DPTaskManager >> run [ 
	| processor portNumber |

	startTime := DateAndTime now.
	processorCount = 0 ifTrue: 
		[ ^ self runInImage ].

	processors := Array new: processorCount.
	portNumber := basePortNumber.
	1 to: processorCount do: [ :i |
		processor := DPTaskProcessor new 
			portNumber: portNumber;
			command: (self commandFor: i of: processorCount).
		processor runIn: self.
		processors at: i put: processor.
		portNumber := portNumber + 1. ].

]

{ #category : #private }
DPTaskManager >> runInImage [

	self class compiler evaluate: (self commandFor: 1 of: 1).
	self signalCompletion.
]

{ #category : #accessing }
DPTaskManager >> runner [ 

	^ runner
]

{ #category : #private }
DPTaskManager >> signalCompletion [

	endTime := DateAndTime now.
	completionSemaphore signal.
]

{ #category : #printing }
DPTaskManager >> stateString [

	^ processors ifNil: 
		[ 'Idle' ]
	ifNotNil: [ self isFinished ifFalse: 
		[ 'Not Finished' ]
	ifTrue: [ self isSuccess ifTrue:
		[ 'Succeeded' ]
	ifFalse:
		[ 'Failed' ] ] ]
]

{ #category : #printing }
DPTaskManager >> statusOn: aStream [
	"Print a long form summary of the receiver on the supplied stream"

	aStream << self stateString; cr.
	self isSuccess ifTrue: 
		[ aStream 
			<< 'Completed in ';
			print: self elapsedTime;
			cr.
		^ self ].
	aStream cr.

	aStream
		<< 'Succeeded: ';
		print: self succeededCount; cr;
		<< 'Failed:    ';
		print: self failedCount; cr; cr.

	self failedCount > 0 ifTrue:
		[ self printFailedOn: aStream ].

]

{ #category : #accessing }
DPTaskManager >> statusString [ 

	^ String streamContents: [ :s | self statusOn: s ]
]

{ #category : #accessing }
DPTaskManager >> succeededCount [
	"Answer the number of processors that have completed successfully"

	processors ifNil: [ ^ 0 ].

	^ processors count: [ :processor | processor isFinished and: [ processor isSuccess ] ]
]

{ #category : #configuration }
DPTaskManager >> taskSpec [
	^ taskSpec
]

{ #category : #configuration }
DPTaskManager >> taskSpec: anObject [
	taskSpec := anObject
]

{ #category : #running }
DPTaskManager >> waitForCompletion [ 

	completionSemaphore wait.
]
