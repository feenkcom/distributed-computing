Class {
	#name : #DPSingleInputFileSpec,
	#superclass : #DPInputFileSpec,
	#instVars : [
		'filename'
	],
	#category : #'DistributedProcessing-Model'
}

{ #category : #accessing }
DPSingleInputFileSpec >> filename [
	^ filename
]

{ #category : #accessing }
DPSingleInputFileSpec >> filename: aFileReference [

	filename := aFileReference asFileReference 
]

{ #category : #accessing }
DPSingleInputFileSpec >> readStream [ 

	^ ZnCharacterReadStream 
		on: self filename binaryReadStream 
		encoding: self encoding
]
