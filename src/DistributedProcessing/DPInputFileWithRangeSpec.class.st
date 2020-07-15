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
	^ endIndex
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
	^ startIndex
]

{ #category : #accessing }
DPInputFileWithRangeSpec >> startIndex: anObject [
	startIndex := anObject
]
