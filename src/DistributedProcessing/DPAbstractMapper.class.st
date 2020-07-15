"
DPAbstractMapper provides the basic framework used by DistributedProcessing to perform mapping operations.

Subclasses are typically initialised with the information required to process the data, and implement #map to process their data.

See DPSumLargeCSVExample as an example.

!!Public API and Key Messages

- map 			Process the receiver's data and answer the result as a JSON encodable object
- mapToSton 	Process the receiver's data and answer the result as a STON encodable object

"
Class {
	#name : #DPAbstractMapper,
	#superclass : #Object,
	#instVars : [
		'processorNumber',
		'processorCount'
	],
	#category : #'DistributedProcessing-MapReduce'
}

{ #category : #operations }
DPAbstractMapper >> map [ 
	"Map the receiver's data and answer the results.
	This must answer an object that can be JSON encoded (the default encoding mechanism used by PharoLink.
	If you want to pass other objects, use #mapToSton."

	^ self subclassResponsibility
]

{ #category : #operations }
DPAbstractMapper >> mapToFile: aFileReference [
	"Map the receiver's data writing the results to aFileReference, STON encoded"

	aFileReference asFileReference writeStreamDo: [ :stream |
		STON 
			put: self mapToSton
			onStreamPretty: stream ].
	^ nil
]

{ #category : #operations }
DPAbstractMapper >> mapToSton [
	"Map the receiver's data and answer the results.
	By default, just use the JSON encoded data.
	Override to provide results as other objects."

	^ self map
]

{ #category : #accessing }
DPAbstractMapper >> processorCount [
	^ processorCount
]

{ #category : #accessing }
DPAbstractMapper >> processorCount: anObject [
	processorCount := anObject
]

{ #category : #accessing }
DPAbstractMapper >> processorNumber [
	^ processorNumber
]

{ #category : #accessing }
DPAbstractMapper >> processorNumber: anObject [
	processorNumber := anObject
]
