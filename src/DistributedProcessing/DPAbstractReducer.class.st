"
DPAbstractReducer provides the basic framework used by DistributedProcessing to perform the data reduction operations.

mappedValues is a collection of the results produced by the mapping operation(s).

Subclasses implement #reduce to perform the actual processing.

Public API and Key Messages

- mappedValues:   The input collection of data to be reduced.
- reduce 				The method called to perform the data reduction

See DPReduceLargeCSVExample for an example implementation
 
!!Internal Representation and Key Implementation Points.

!!!Instance Variables
	mappedValues:	<Array>
	result:			<Object>


!!!Implementation Points
"
Class {
	#name : #DPAbstractReducer,
	#superclass : #Object,
	#instVars : [
		'mappedValues',
		'result'
	],
	#category : #'DistributedProcessing-Model'
}

{ #category : #enumerating }
DPAbstractReducer class >> reduce: anArray [ 

	^ self new
		mappedValues: anArray;
		result
]

{ #category : #accessing }
DPAbstractReducer >> mappedValues [
	^ mappedValues
]

{ #category : #accessing }
DPAbstractReducer >> mappedValues: anObject [
	mappedValues := anObject
]

{ #category : #private }
DPAbstractReducer >> reduce [ 
	"Process the supplied mapped values to the reduced result"

	^ self subclassResponsibility
]

{ #category : #accessing }
DPAbstractReducer >> result [
	^ result ifNil: [ result := self reduce ]
]
