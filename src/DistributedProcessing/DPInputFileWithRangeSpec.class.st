Class {
	#name : #DPInputFileWithRangeSpec,
	#superclass : #DPInputFileSpec,
	#instVars : [
		'filename',
		'startIndex',
		'endIndex'
	],
	#category : #'DistributedProcessing-Model'
}

{ #category : #accessing }
DPInputFileWithRangeSpec >> endIndex [

	^ endIndex ifNil: [ self getIndexFromTask. endIndex ]
]

{ #category : #accessing }
DPInputFileWithRangeSpec >> endIndex: anObject [
	endIndex := anObject
]

{ #category : #accessing }
DPInputFileWithRangeSpec >> filename [
	^ filename
]

{ #category : #accessing }
DPInputFileWithRangeSpec >> filename: aFileReference [ 

	filename := aFileReference asFileReference 
]

{ #category : #private }
DPInputFileWithRangeSpec >> getIndexFromTask [
	"Set the startIndex and endIndex based on the file size, taskIndex and taskCount"
	| dataFileSize |

	dataFileSize := self filename size.
	taskIndex = 1 ifTrue: 
		[ startIndex := 0.
		endIndex := (dataFileSize / taskCount) rounded ]
	ifFalse: [ taskIndex = taskCount ifTrue: 
		[ startIndex := (dataFileSize * (taskCount - 1) / taskCount) rounded.
		endIndex := dataFileSize. ]
	ifFalse: 
		[ startIndex := (dataFileSize * (taskIndex - 1) / taskCount) rounded.
		endIndex := (dataFileSize * taskIndex / taskCount) rounded. ] ].

]

{ #category : #accessing }
DPInputFileWithRangeSpec >> readStream [ 
	"Answer a batchLineReaderByPosition configured for the receiver's portion of the file"

	^ DPLineLimitedReadStream new 
		filename: filename;
		startIndex: self startIndex;
		endIndex: self endIndex;
		encoding: self encoding;
		resetStreams.
]

{ #category : #accessing }
DPInputFileWithRangeSpec >> startIndex [

	^ startIndex ifNil: [ self getIndexFromTask. startIndex ]
]

{ #category : #accessing }
DPInputFileWithRangeSpec >> startIndex: anObject [
	startIndex := anObject
]
