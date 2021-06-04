"
DPReduceLargeCSVExample processes the mapped values and calculates the total.

See DPLargeCSVExample for the record format and how to run the example.  The mapped values are checked to ensure that there aren't any gaps or overlaps in the rows from the original CSV file processed.


"
Class {
	#name : #DPReduceLargeCSVExample,
	#superclass : #DPAbstractReducer,
	#category : #'DistributedProcessing-Examples'
}

{ #category : #enumerating }
DPReduceLargeCSVExample class >> reduce: anArray [ 

	^ self new
		mappedValues: anArray;
		result
]

{ #category : #private }
DPReduceLargeCSVExample >> reduce [
	| sorted |

	sorted := mappedValues sorted: [ :a :b | a third first asNumber < b third first asNumber ].
	self assert: sorted first third first asNumber equals: 1.
	1 to: sorted size - 1 do: [ :i |
		self assert: (sorted at: i) fourth first asNumber
				equals: (sorted at: i+1) third first asNumber - 1 ].
	^ sorted inject: 0 into: [ :sum :each | sum + each second ]
]
