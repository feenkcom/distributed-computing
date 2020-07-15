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
	#superclass : #DPProcessSingleFileStream,
	#instVars : [
		'firstRecord',
		'lastRecord'
	],
	#category : #'DistributedProcessing-MapReduce'
}

{ #category : #private }
DPProcessCSVByRow >> csvReaderOn: readStream [

	^ NeoCSVReader on: readStream
]

{ #category : #operations }
DPProcessCSVByRow >> map [ 
	"Open the receiver's stream and csv reader and call #mapRecord: for each record in the receiver's set of records"
	| csvReader |

	self readStreamDo: [ :readStream |
		csvReader := self csvReaderOn: readStream.
		firstRecord := csvReader next.
		(self parseHeader: firstRecord) ifFalse:
			[ self mapRecord: firstRecord ].
		[ csvReader atEnd ] whileFalse:
			[ self mapRecord: csvReader next ] ].
	^ self result.
]

{ #category : #private }
DPProcessCSVByRow >> mapRecord: csvRecord [
	"mapRecord: is called once with each record of the receiver's file, as an Array of strings"

	self subclassResponsibility 
]

{ #category : #parsing }
DPProcessCSVByRow >> parseHeader: csvReader [
	"Process the header file if necessary.
	Answer a boolean indicating whether this really was a header row."

	^ false
]

{ #category : #private }
DPProcessCSVByRow >> result [
	"Answer the result of the mapping as a JSON serialisable object."

	^ self subclassResponsibility
]
