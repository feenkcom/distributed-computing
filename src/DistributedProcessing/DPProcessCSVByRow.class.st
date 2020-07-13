"
DPProcessCSVByRow provides a framework for processing CSV files by multiple processors.

This assumes that each line of the input file can be processed independently (is embarrasingly parallel).

DPProcessCSVByRow takes a startIndex and endIndex (byte offsets within the CSV file) to specify the portion of the input file to be processed.  The read stream takes care of line-aligning the indexes to ensure every row is processed.

Subclasses are responsible for implementing #mapRecord: and #result.  #mapRecord: processes the supplied record and updates the receiver's internal state.  #result provides the final result.

Currently DPProcessCSVByRow assumes that the results are JSON encodable.


Public API and Key Messages

- startIndex:  The byte offset in the source data file to begin at (0 for the start of file).
- endIndex: 		The byte offset in the source data file to end at (file size for the end of file).
- #mapRecord: 	Process a single record from the source data.
- #result 		Answer the mapped data

DPProcessCSVByRow keeps the first and last records processed for optional validation.

See DPSumLargeCSVExample as an example concrete implementation.
 
!!Internal Representation and Key Implementation Points.

!!!Instance Variables
	endIndex:			<Integer>
	filename:			<FileReference>
	firstRecord:		<Array>
	lastRecord:		<Array>
	startIndex:		<Integer>


!!!Implementation Points
"
Class {
	#name : #DPProcessCSVByRow,
	#superclass : #DPAbstractMapper,
	#instVars : [
		'filename',
		'startIndex',
		'endIndex',
		'firstRecord',
		'lastRecord'
	],
	#category : #'DistributedProcessing-Model'
}

{ #category : #private }
DPProcessCSVByRow class >> indexesFor: filename processor: processorNumber of: numberOfProcessors [
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
DPProcessCSVByRow class >> map: filename processor: processorNumber of: numberOfProcessors [
	| indexes |

	indexes := self indexesFor: filename processor: processorNumber of: numberOfProcessors.
	^ self new 
		filename: filename;
		startIndex: indexes first;
		endIndex: indexes second;
		map
]

{ #category : #private }
DPProcessCSVByRow >> csvReaderOn: readStream [

	^ NeoCSVReader on: readStream
]

{ #category : #accessing }
DPProcessCSVByRow >> endIndex [
	^ endIndex ifNil: [ filename size ]
]

{ #category : #accessing }
DPProcessCSVByRow >> endIndex: anObject [
	endIndex := anObject
]

{ #category : #accessing }
DPProcessCSVByRow >> filename [
	^ filename
]

{ #category : #accessing }
DPProcessCSVByRow >> filename: anObject [

	filename := anObject asFileReference
]

{ #category : #operations }
DPProcessCSVByRow >> map [ 
	"Add all the numbers in the third column of the supplied csv file, using the encoding specified in the second column and answer the filename and sum"
	| csvReader |

	self readStreamDo: [ :readStream |
		csvReader := self csvReaderOn: readStream.
		firstRecord := csvReader next.
		self mapRecord: firstRecord.
		[ csvReader atEnd ] whileFalse:
			[ self mapRecord: csvReader next ] ].
	^ self result.
]

{ #category : #private }
DPProcessCSVByRow >> mapRecord: csvRecord [

	self subclassResponsibility 
]

{ #category : #private }
DPProcessCSVByRow >> readStream [ 
	"Answer a batchLineReaderByPosition configured for the receiver's portion of the file"

	^ DPLineLimitedReadStream new 
		filename: filename;
		startIndex: self startIndex;
		endIndex: self endIndex;
		resetStreams.
]

{ #category : #enumerating }
DPProcessCSVByRow >> readStreamDo: aBlock [ 

	^ self readStream streamDo: aBlock
]

{ #category : #private }
DPProcessCSVByRow >> result [ 

	^ self subclassResponsibility
]

{ #category : #accessing }
DPProcessCSVByRow >> startIndex [
	^ startIndex ifNil: [ 0 ]
]

{ #category : #accessing }
DPProcessCSVByRow >> startIndex: anObject [
	startIndex := anObject
]