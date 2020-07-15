Class {
	#name : #DPProcessFile,
	#superclass : #DPTask,
	#instVars : [
		'fileSpec'
	],
	#category : #'DistributedProcessing-Model'
}

{ #category : #accessing }
DPProcessFile >> fileSpec [
	^ fileSpec
]

{ #category : #accessing }
DPProcessFile >> fileSpec: anObject [
	fileSpec := anObject
]
