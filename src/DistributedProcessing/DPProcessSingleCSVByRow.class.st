Class {
	#name : #DPProcessSingleCSVByRow,
	#superclass : #DPProcessSingleFileStream,
	#instVars : [
		'firstRecord',
		'lastRecord'
	],
	#category : #'DistributedProcessing-Model'
}

{ #category : #private }
DPProcessSingleCSVByRow >> csvReaderOn: readStream [

	^ NeoCSVReader on: readStream
]

{ #category : #operations }
DPProcessSingleCSVByRow >> map [ 
	"Open the receiver's stream and csv reader and call #mapRecord: for each record in the receiver's set of records"
	| csvReader |

	self readStreamDo: [ :readStream |
		csvReader := self csvReaderOn: readStream.
		self parseHeader: csvReader.
		firstRecord := csvReader next.
		self mapRecord: firstRecord.
		[ csvReader atEnd ] whileFalse:
			[ self mapRecord: csvReader next ] ].
	^ self result.
]

{ #category : #private }
DPProcessSingleCSVByRow >> mapRecord: csvRecord [
	"mapRecord: is called once with each record of the receiver's file, as an Array of strings"

	self subclassResponsibility 
]

{ #category : #parsing }
DPProcessSingleCSVByRow >> parseHeader: csvReader [
	"If the CSV file has a header, it can be processed here"
]

{ #category : #private }
DPProcessSingleCSVByRow >> result [
	"Answer the result of the mapping as a JSON serialisable object."

	^ self subclassResponsibility
]
