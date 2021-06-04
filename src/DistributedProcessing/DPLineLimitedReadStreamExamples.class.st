"
Demonstrate and test DPLineLimitedReadStream.

"
Class {
	#name : #DPLineLimitedReadStreamExamples,
	#superclass : #Object,
	#category : #'DistributedProcessing-Examples'
}

{ #category : #examples }
DPLineLimitedReadStreamExamples >> dataFile [
	<gtExample>
	| fs file |

	fs := FileSystem memory root.
	file := fs / 'file.txt'.
	file writeStreamDo: [ :stream |
		1 to: 72 do: [ :i |
			stream
				<< 'Line ';
				print: i;
				lf ] ].
	^ file
]

{ #category : #examples }
DPLineLimitedReadStreamExamples >> group1of3 [
	<gtExample>
	| lineReader group |

	lineReader := self lineReader: 1 of: 3.
	group := lineReader collect: [ :line | 
		(Character space split: line) second asNumber ].
	self assert: group first equals: 1.
	self assert: group last equals: 25.
	^ group
]

{ #category : #examples }
DPLineLimitedReadStreamExamples >> group2of3 [
	<gtExample>
	| lineReader group |

	lineReader := self lineReader: 2 of: 3.
	group := lineReader collect: [ :line | 
		(Character space split: line) second asNumber ].
	self assert: group first equals: 26.
	self assert: group last equals: 49.
	^ group
]

{ #category : #examples }
DPLineLimitedReadStreamExamples >> group3of3 [
	<gtExample>
	| lineReader group |

	lineReader := self lineReader: 3 of: 3.
	group := lineReader collect: [ :line | 
		(Character space split: line) second asNumber ].
	self assert: group first equals: 50.
	self assert: group last equals: 72.
	^ group
]

{ #category : #examples }
DPLineLimitedReadStreamExamples >> lineReader: readerNumber of: maxReaderNumber [
	<gtExample>
	| dataFile lineReader startIndex endIndex |

	dataFile := self dataFile.
	readerNumber = 1 ifTrue: 
		[ startIndex := 0.
		endIndex := (dataFile size / maxReaderNumber) rounded ]
	ifFalse: [ readerNumber = maxReaderNumber ifTrue: 
		[ startIndex := (dataFile size * (maxReaderNumber - 1) / maxReaderNumber) rounded.
		endIndex := dataFile size. ]
	ifFalse: 
		[ startIndex := (dataFile size * (readerNumber - 1) / maxReaderNumber) rounded.
		endIndex := (dataFile size * readerNumber / maxReaderNumber) rounded. ] ].
	lineReader := DPLineLimitedReadStream new 
		filename: dataFile;
		startIndex: startIndex;
		endIndex: endIndex.
	^ lineReader
]
