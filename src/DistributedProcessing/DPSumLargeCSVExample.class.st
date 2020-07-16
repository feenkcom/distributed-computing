"
DPSumLargeCSVExample processes the supplied records and calculates the total of the supplied values.

See DPLargeCSVExample for the record format and how to run the example.  The value is decoded using the format specified in the second column and value in the third column.  It is then validated using the value in the fourth column.  (All of this is just to simulate some actual processing).

"
Class {
	#name : #DPSumLargeCSVExample,
	#superclass : #DPProcessCSVByRow,
	#instVars : [
		'total',
		'lineNumber'
	],
	#category : #'DistributedProcessing-Examples'
}

{ #category : #initialization }
DPSumLargeCSVExample >> initialize [

	super initialize.
	total := 0.
]

{ #category : #operations }
DPSumLargeCSVExample >> mapRecord: csvRecord [
	"Add all the numbers in the third column of the supplied csv file, using the encoding specified in the second column and answer the filename and sum"
	| baseNumber value |

	csvRecord second ifNil: [ ^ self ].

	baseNumber := (DPSampleLargeCSVExample prefixFor: csvRecord second trimBoth), csvRecord third trimBoth.
	value := baseNumber asNumber.
	self assert: value equals: csvRecord fourth trimBoth asNumber.
	total := total + value.
	lineNumber := csvRecord first.
	lastRecord := csvRecord.

]

{ #category : #operations }
DPSumLargeCSVExample >> result [

	^ { fileSpec basename. total. firstRecord. lastRecord. }
]
