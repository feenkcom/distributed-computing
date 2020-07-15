"
BatchLineReaderByPosition provides a stream like interface for reading part of a file, one character or line at a time.

It avoids having to parse the file leading up to the desired lines by positioning the stream at the start index (byte offset) and reading until the next line end character (as a binary stream).  Lines are then read from the file (as a character stream) until the end index is passed.


Public API and Key Messages

- message one   
- message two 
- (for bonus points) how to create instances.

   One simple example is simply gorgeous.
 
Internal Representation and Key Implementation Points.

    Instance Variables
	filename:		<Object>
	readstream:		<Object>


    Implementation Points
"
Class {
	#name : #DPLineLimitedReadStream,
	#superclass : #Object,
	#instVars : [
		'filename',
		'startIndex',
		'endIndex',
		'binaryStream',
		'characterStream',
		'encoding'
	],
	#category : #'DistributedProcessing-MapReduce'
}

{ #category : #accessing }
DPLineLimitedReadStream >> atEnd [ 

	^ binaryStream atEnd or: [ binaryStream position >= endIndex ].
]

{ #category : #'initialize-release' }
DPLineLimitedReadStream >> close [ 

	binaryStream ifNotNil: [ binaryStream close ].
	characterStream ifNotNil: [ characterStream close ].
]

{ #category : #enumerating }
DPLineLimitedReadStream >> collect: aBlock [ 
	"Evaluate aBlock with each line in the receiver's stream and answer the results"

	self resetStreams.
	^ Array streamContents: [ :stream |
		[ self atEnd ] whileFalse:
			[ stream nextPut: (aBlock value: self nextLine) ] ]
]

{ #category : #accessing }
DPLineLimitedReadStream >> encoding [
	^ encoding
]

{ #category : #accessing }
DPLineLimitedReadStream >> encoding: anObject [
	encoding := anObject
]

{ #category : #accessing }
DPLineLimitedReadStream >> endIndex [
	^ endIndex
]

{ #category : #accessing }
DPLineLimitedReadStream >> endIndex: anObject [
	endIndex := anObject
]

{ #category : #accessing }
DPLineLimitedReadStream >> filename [
	^ filename
]

{ #category : #accessing }
DPLineLimitedReadStream >> filename: aFileReference [

	filename := aFileReference asFileReference.

]

{ #category : #initialization }
DPLineLimitedReadStream >> initialize [ 

	super initialize.
	encoding := 'utf8'.
]

{ #category : #accessing }
DPLineLimitedReadStream >> next [

	^ characterStream next
]

{ #category : #accessing }
DPLineLimitedReadStream >> nextLine [ 

	^ characterStream nextLine
]

{ #category : #accessing }
DPLineLimitedReadStream >> position [ 
	"Answer the position of the binary read stream.
	startIndex and endIndex are relative to the binary stream."

	^ binaryStream position
]

{ #category : #initialization }
DPLineLimitedReadStream >> resetStreams [
	| ch |

	binaryStream := filename binaryReadStream.
	endIndex < filename size ifTrue: 
		[ binaryStream position: endIndex.
		[ ch := binaryStream next.
		ch = 13 or: [ ch = 10 ] ] whileFalse:
			[ endIndex := endIndex + 1 ] ].
	binaryStream position: startIndex.
	startIndex > 0 ifTrue:
		[ [ ch := binaryStream next.
		ch = 13 or: [ ch = 10 ] ] whileFalse.
		ch = 13 ifTrue: [ binaryStream peekFor: 10 ] ].
	characterStream := ZnCharacterReadStream on: binaryStream encoding: encoding.

]

{ #category : #accessing }
DPLineLimitedReadStream >> startIndex [
	^ startIndex
]

{ #category : #accessing }
DPLineLimitedReadStream >> startIndex: anObject [
	startIndex := anObject
]

{ #category : #enumerating }
DPLineLimitedReadStream >> streamDo: aBlock [ 

	self resetStreams.
	^ [ aBlock value: self ]
		ensure: [ self close ]
]
