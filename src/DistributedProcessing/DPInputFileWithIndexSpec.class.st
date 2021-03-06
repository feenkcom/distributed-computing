Class {
	#name : #DPInputFileWithIndexSpec,
	#superclass : #DPInputFileSpec,
	#instVars : [
		'prefix',
		'suffix'
	],
	#category : #'DistributedProcessing-Model'
}

{ #category : #accessing }
DPInputFileWithIndexSpec >> filename [ 

	^ (String streamContents: [ :stream |
		stream
			<< prefix;
			<< '.';
			print: taskIndex;
			<< '.';
			<< suffix ]) asFileReference
]

{ #category : #accessing }
DPInputFileWithIndexSpec >> prefix [
	^ prefix
]

{ #category : #accessing }
DPInputFileWithIndexSpec >> prefix: anObject [
	prefix := anObject
]

{ #category : #printing }
DPInputFileWithIndexSpec >> printOn: aStream [

	super printOn: aStream.
	aStream
		<< '(';
		<< (prefix ifNil: [ '<Unknown>' ]);
		<< '.';
		print: taskIndex;
		<< '.';
		<< (suffix ifNil: [ '<Unknown>' ]);
		<< ')'
]

{ #category : #accessing }
DPInputFileWithIndexSpec >> readStream [ 

	^ ZnCharacterReadStream 
		on: self filename binaryReadStream 
		encoding: self encoding
]

{ #category : #accessing }
DPInputFileWithIndexSpec >> suffix [
	^ suffix
]

{ #category : #accessing }
DPInputFileWithIndexSpec >> suffix: anObject [
	suffix := anObject
]
