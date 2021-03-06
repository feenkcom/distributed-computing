Class {
	#name : #DPTask,
	#superclass : #Object,
	#instVars : [
		'taskIndex',
		'taskCount',
		'resultPrefix',
		'resultSuffix'
	],
	#category : #'DistributedProcessing-Model'
}

{ #category : #private }
DPTask >> assertSingleTask [

	self assert: taskIndex equals: 1.
	self assert: taskCount equals: 1.
]

{ #category : #accessing }
DPTask >> result [ 

	^ self subclassResponsibility 
]

{ #category : #private }
DPTask >> resultFile [ 

	resultPrefix ifNil: [ ^ nil ].
	^ (String streamContents: [ :stream |
		stream 
			<< self resultPrefix;
			<< '.';
			print: taskIndex;
			<< '.';
			<< self resultSuffix ]) asFileReference 
]

{ #category : #configuration }
DPTask >> resultPrefix [
	^ resultPrefix
]

{ #category : #configuration }
DPTask >> resultPrefix: anObject [
	resultPrefix := anObject
]

{ #category : #configuration }
DPTask >> resultSuffix [

	^ resultSuffix ifNil: [ 'fuel' ]
]

{ #category : #configuration }
DPTask >> resultSuffix: anObject [
	resultSuffix := anObject
]

{ #category : #running }
DPTask >> run [ 

	self runTask.
	^ self resultFile ifNil:
		[ self result ]
	ifNotNil: [ :resultFile |
		self serializeToFileNamed: resultFile.
		nil ].
]

{ #category : #running }
DPTask >> runImmediateSingleTask [
	"Run the receiver as a single task in the calling process"

	^ self
		taskIndex: 1;
		taskCount: 1;
		run
]

{ #category : #private }
DPTask >> runTask [

	^ self subclassResponsibility 
]

{ #category : #private }
DPTask >> serializeToFileNamed: aFileReference [
	| fileReference |

	fileReference := aFileReference asFileReference.
	fileReference extension = #fuel ifTrue: 
		[ ^ FLSerializer serialize: self result toFileNamed: fileReference fullName ]
	ifFalse: [ fileReference extension = #ston ifTrue: 
		[ ^ fileReference writeStreamDo: [ :stream |
			STON put: self result onStreamPretty: stream ]. ] ].

	self error: 'Unknown file format: ', fileReference extension printString.
]

{ #category : #accessing }
DPTask >> taskCount [
	^ taskCount
]

{ #category : #accessing }
DPTask >> taskCount: anObject [
	taskCount := anObject
]

{ #category : #accessing }
DPTask >> taskIndex [
	^ taskIndex
]

{ #category : #accessing }
DPTask >> taskIndex: anObject [
	taskIndex := anObject
]
