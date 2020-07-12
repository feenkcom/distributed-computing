"
DPSampleLargeCSVExample produces a CSV file that can be processed (mapped) by DPSumLargeCSVExample and reduced by DPReduceLargeCSVExample.

The CSV file has the following columns: 

- Row number (integer)
- Encoding, one of hex decimal octal binary.
- A random number between 1 and 128, encoded with the encoding above.
- The random number above, decimal encoded.
- A long string.

The final record contains the sum of all the previous random values (to facilitate validation).

To produce a file and answer the file name: 

[[[
file := DPSampleLargeCSVExample new 
	fileSize: (2.5 * (1024 ** 2));
	create
]]]

to process the resulting file:

[[[
mgr := DPMapReduceSimpleManager new
	processorClass: DPSumLargeCSVExample;
	reducerClass: DPReduceLargeCSVExample;
	processorCount: 8;
	file: file;
	run.
]]]

to wait for completion and retrieve the result:

[[[
mgr
	waitForCompletion;
	result.
]]]

"
Class {
	#name : #DPSampleLargeCSVExample,
	#superclass : #Object,
	#instVars : [
		'filename',
		'fileSize'
	],
	#category : #'DistributedProcessing-Examples'
}

{ #category : #'base conversion' }
DPSampleLargeCSVExample class >> converters [

	^ { 
		[ :v | v printStringBase: 16 ].
		[ :v | v printStringBase: 10 ].
		[ :v | v printStringBase: 8 ].
		[ :v | v printStringBase: 2 ]. }.
]

{ #category : #'base conversion' }
DPSampleLargeCSVExample class >> formats [

	^ #(hex decimal octal binary)
]

{ #category : #'base conversion' }
DPSampleLargeCSVExample class >> prefixFor: baseName [

	^ self prefixes at: (self formats indexOf: baseName)
]

{ #category : #'base conversion' }
DPSampleLargeCSVExample class >> prefixes [

	^ #('16r' '' '8r' '2r')
]

{ #category : #accessing }
DPSampleLargeCSVExample >> contents [
	"For testing, answer a csv reader on the file"

	self create.
	^ (self filename readStreamDo: [ :s |
			(NeoCSVReader on: s) upToEnd ]).
]

{ #category : #'api - instantiation' }
DPSampleLargeCSVExample >> create [ 

	self filename exists ifTrue: [ ^ self ].
	self filename writeStreamDo: [ :stream |
		self createOn: stream ].
	^ filename
]

{ #category : #private }
DPSampleLargeCSVExample >> createOn: stream [
	| number format lineNumber total formats converters |

	formats := self class formats.
	converters := self class converters.
	total := 0.
	lineNumber := 1.
	[ stream position < self fileSize ] whileTrue:
		[ number := (1 to: 128) atRandom.
		format := (1 to: 4) atRandom.
		stream 
			print: lineNumber;
			<< ', ';
			<< (formats at: format);
			<< ', ';
			<< ((converters at: format) value: number);
			<< ', ';
			print: number;
			<< ', "This is some text to pad out each line and increase parsing time"';
			lf.
		total := total + number.
		lineNumber := lineNumber + 1 ].

		stream 
			print: lineNumber;
			<< ', ';
			<< 'decimal';
			<< ', ';
			print: total;
			<< ', ';
			print: total;
			<< ', "This is some text to pad out each line and increase parsing time"';
			lf.
]

{ #category : #accessing }
DPSampleLargeCSVExample >> fileSize [
	^ fileSize ifNil: [ 5 * (1024 ** 3) ]
]

{ #category : #accessing }
DPSampleLargeCSVExample >> fileSize: anObject [
	fileSize := anObject
]

{ #category : #accessing }
DPSampleLargeCSVExample >> filename [

	^ filename ifNil: [ filename := FileReference newTempFilePrefix: 'Large' suffix: '.csv' ]
]

{ #category : #accessing }
DPSampleLargeCSVExample >> filename: aFileReference [

	filename := aFileReference asFileReference.

]
