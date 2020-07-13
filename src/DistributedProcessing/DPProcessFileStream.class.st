"
DPProcessFileStream provides a framework for processing files by multiple processors.

This assumes that the any group of lines within the file can be processed independently (is embarrasingly parallel).

DPProcessFileStream takes a startIndex and endIndex (byte offsets within the CSV file) to specify the portion of the input file to be processed.  The read stream takes care of line-aligning the indexes to ensure every row is processed.

Subclasses are responsible for implementing #map or #mapToSton and answering the result.


Public API and Key Messages

- startIndex:  The byte offset in the source data file to begin at (0 for the start of file).
- endIndex: 		The byte offset in the source data file to end at (file size for the end of file).
- #mapRecord: 	Process a single record from the source data.
- #result 		Answer the mapped data

DPProcessCSVByRow keeps the first and last records processed for optional validation.

!!Internal Representation and Key Implementation Points.

!!!Instance Variables

	endIndex:			<Integer>
	filename:			<FileReference>
	startIndex:		<Integer>


!!!Implementation Points
"
Class {
	#name : #DPProcessFileStream,
	#superclass : #DPAbstractMapper,
	#instVars : [
		'filename',
		'startIndex',
		'endIndex'
	],
	#category : #'DistributedProcessing-Model'
}

{ #category : #private }
DPProcessFileStream class >> indexesFor: filename processor: processorNumber of: numberOfProcessors [
	| dataFileSize startIndex endIndex |

	dataFileSize := filename asFileReference size.
	processorNumber = 1 ifTrue: 
		[ startIndex := 0.
		endIndex := (dataFileSize / numberOfProcessors) rounded ]
	ifFalse: [ processorNumber = numberOfProcessors ifTrue: 
		[ startIndex := (dataFileSize * (numberOfProcessors - 1) / numberOfProcessors) rounded.
		endIndex := dataFileSize. ]
	ifFalse: 
		[ startIndex := (dataFileSize * (processorNumber - 1) / numberOfProcessors) rounded.
		endIndex := (dataFileSize * processorNumber / numberOfProcessors) rounded. ] ].
	^ { startIndex. endIndex. }
]

{ #category : #operating }
DPProcessFileStream class >> map: filename processor: processorNumber of: numberOfProcessors [
	| indexes |

	indexes := self indexesFor: filename processor: processorNumber of: numberOfProcessors.
	^ self new 
		filename: filename;
		startIndex: indexes first;
		endIndex: indexes second;
		map
]

{ #category : #accessing }
DPProcessFileStream >> endIndex [
	"Answer the byte index that will be used to determine the last line of the receiver's stream.
	The stream will adjust this to the next end-of-line.
	If not specified, use end-of-file."

	^ endIndex ifNil: [ filename size ]
]

{ #category : #accessing }
DPProcessFileStream >> endIndex: anObject [
	endIndex := anObject
]

{ #category : #accessing }
DPProcessFileStream >> filename [
	^ filename
]

{ #category : #accessing }
DPProcessFileStream >> filename: anObject [

	filename := anObject asFileReference
]

{ #category : #private }
DPProcessFileStream >> readStream [ 
	"Answer a batchLineReaderByPosition configured for the receiver's portion of the file"

	^ DPLineLimitedReadStream new 
		filename: filename;
		startIndex: self startIndex;
		endIndex: self endIndex;
		resetStreams.
]

{ #category : #enumerating }
DPProcessFileStream >> readStreamDo: aBlock [ 
	"Evaluate aBlock with the receiver's stream, ensuring that it is closed after the block terminates"

	^ self readStream streamDo: aBlock
]

{ #category : #accessing }
DPProcessFileStream >> startIndex [
	"Answer the byte index that will be used to determine the first line of the receiver's stream.
	If not 0 (beginning of file), the stream will adjust this to the next end-of-line."

	^ startIndex ifNil: [ 0 ]
]

{ #category : #accessing }
DPProcessFileStream >> startIndex: anObject [
	startIndex := anObject
]
