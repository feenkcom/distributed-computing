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
	#name : #DPMapReduceSimpleManager,
	#superclass : #Object,
	#instVars : [
		'processorCount',
		'processors',
		'basePortNumber',
		'file',
		'processorClass',
		'reducerClass',
		'runner',
		'completionSemaphore',
		'result',
		'startTime',
		'endTime'
	],
	#category : #'DistributedProcessing-Model'
}

{ #category : #private }
DPMapReduceSimpleManager >> commandFor: processorNumber of: count [

	^ String streamContents: [ :stream |
		stream
			<< processorClass name;
			<< ' map: ';
			print: file fullName;
			<< ' processor: ';
			print: processorNumber;
			<< ' of: ';
			print: count ]
]

{ #category : #accessing }
DPMapReduceSimpleManager >> elapsedTime [ 

	^ endTime - startTime
]

{ #category : #accessing }
DPMapReduceSimpleManager >> failedCount [
	"Answer the number of processors that have completed unsuccessfully"

	processors ifNil: [ ^ 0 ].

	^ processors count: [ :processor | processor isFinished and: [ processor isSuccess not ] ]
]

{ #category : #accessing }
DPMapReduceSimpleManager >> file [
	^ file
]

{ #category : #accessing }
DPMapReduceSimpleManager >> file: aFileReference [

	file := aFileReference asFileReference 
]

{ #category : #ui }
DPMapReduceSimpleManager >> gtStatusFor: aView [
	<gtView>

	^ aView textEditor 
		title: 'Status';
		priority: 10;
		look: BrGlamorousCodeEditorLook;
		text: [ self statusString asRopedText ]
]

{ #category : #initialization }
DPMapReduceSimpleManager >> initialize [

	super initialize.
	runner := TKTNewProcessTaskRunner new.
	completionSemaphore := Semaphore new.
	basePortNumber := 13000.
]

{ #category : #testing }
DPMapReduceSimpleManager >> isFinished [ 

	^ processors isNotNil and: [ processors allSatisfy: #isFinished ]
]

{ #category : #testing }
DPMapReduceSimpleManager >> isRunning [ 

	^ processors isNotNil and: [ self isFinished not ]
]

{ #category : #testing }
DPMapReduceSimpleManager >> isSuccess [

	^ processors isNotNil and: [ processors allSatisfy: #isSuccess ]
]

{ #category : #printing }
DPMapReduceSimpleManager >> printFailedOn: aStream [

	self failedCount = 0 ifTrue: [ ^ self ].

	processors
		select: [ :each | each isFinished and: [ each isSuccess not ]]
		thenDo: [ :processor | 
			processor statusOn: aStream.
			aStream cr; cr. ]
]

{ #category : #printing }
DPMapReduceSimpleManager >> printOn: aStream [

	aStream
		<< 'Simple Map/Reduce(';
		print: processorClass;
		<< ', ';
		print: reducerClass;
		<< ', '.
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
	aStream << ')'
]

{ #category : #accessing }
DPMapReduceSimpleManager >> processorClass [
	^ processorClass
]

{ #category : #accessing }
DPMapReduceSimpleManager >> processorClass: anObject [
	processorClass := anObject
]

{ #category : #accessing }
DPMapReduceSimpleManager >> processorCount [
	^ processorCount
]

{ #category : #accessing }
DPMapReduceSimpleManager >> processorCount: anObject [
	processorCount := anObject
]

{ #category : #private }
DPMapReduceSimpleManager >> reduceFutures [
	"This is called each time one of the processors completes.
	Check that all have completed and if so signal completion."

	(processors allSatisfy: [ :processor | processor isFinished ]) ifFalse:
		[ ^ self ].
	
	(processors allSatisfy: [ :processor | processor isSuccess ]) ifFalse:
		[ ^ self signalCompletion ].

	result := reducerClass reduce: (processors collect: #result).
	self signalCompletion.

]

{ #category : #accessing }
DPMapReduceSimpleManager >> reducerClass [
	^ reducerClass
]

{ #category : #accessing }
DPMapReduceSimpleManager >> reducerClass: anObject [
	reducerClass := anObject
]

{ #category : #accessing }
DPMapReduceSimpleManager >> result [
	^ result
]

{ #category : #running }
DPMapReduceSimpleManager >> run [ 
	| processor portNumber |

	startTime := DateAndTime now.
	processorCount = 0 ifTrue: 
		[ ^ self runInImage ].

	processors := Array new: processorCount.
	portNumber := basePortNumber.
	1 to: processorCount do: [ :i |
		processor := DPMapReduceSimpleProcessor new 
			portNumber: portNumber;
			command: (self commandFor: i of: processorCount).
		processor runIn: self.
		processors at: i put: processor.
		portNumber := portNumber + 1. ].

]

{ #category : #private }
DPMapReduceSimpleManager >> runInImage [

	result := reducerClass reduce: { self class compiler evaluate: (self commandFor: 1 of: 1) }.
	self signalCompletion.
]

{ #category : #accessing }
DPMapReduceSimpleManager >> runner [ 

	^ runner
]

{ #category : #private }
DPMapReduceSimpleManager >> signalCompletion [

	endTime := DateAndTime now.
	completionSemaphore signal.
]

{ #category : #printing }
DPMapReduceSimpleManager >> statusOn: aStream [
	"Print a long form summary of the receiver on the supplied stream"

	self isRunning ifTrue:
		[ aStream << 'In Progress' ]
	ifFalse: [ self isFinished ifTrue: 
		[ aStream 
			<< 'Completed in ';
			print: self elapsedTime ]
	ifFalse:
		[ aStream << 'Idle' ] ].
	aStream cr; cr.

	aStream
		<< 'Succeeded: ';
		print: self succeededCount; cr;
		<< 'Failed:    ';
		print: self failedCount; cr; cr.

	self failedCount > 0 ifTrue:
		[ self printFailedOn: aStream ].

	self isSuccess ifTrue: 
		[ aStream << 'Result:'; cr; cr.
		aStream print: self result ]
]

{ #category : #accessing }
DPMapReduceSimpleManager >> statusString [ 

	^ String streamContents: [ :s | self statusOn: s ]
]

{ #category : #accessing }
DPMapReduceSimpleManager >> succeededCount [
	"Answer the number of processors that have completed successfully"

	processors ifNil: [ ^ 0 ].

	^ processors count: [ :processor | processor isFinished and: [ processor isSuccess ] ]
]

{ #category : #running }
DPMapReduceSimpleManager >> waitForCompletion [ 

	completionSemaphore wait.
]
