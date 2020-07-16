Class {
	#name : #DPInputFileSpec,
	#superclass : #Object,
	#instVars : [
		'encoding',
		'taskIndex',
		'taskCount'
	],
	#category : #'DistributedProcessing-Model'
}

{ #category : #accessing }
DPInputFileSpec >> basename [ 

	^ self filename basename
]

{ #category : #accessing }
DPInputFileSpec >> encoding [

	^ encoding ifNil: [ 'utf8' ]
]

{ #category : #accessing }
DPInputFileSpec >> encoding: anObject [
	encoding := anObject
]

{ #category : #accessing }
DPInputFileSpec >> filename [

	^ self subclassResponsibility
]

{ #category : #accessing }
DPInputFileSpec >> readStream [ 

	^ self subclassResponsibility 
]

{ #category : #enumerating }
DPInputFileSpec >> readStreamDo: aBlock [ 
	| readStream |

	readStream := self readStream.
	^ [ aBlock value: readStream ]
		ensure: [ readStream close ]
]

{ #category : #accessing }
DPInputFileSpec >> taskCount [
	^ taskCount
]

{ #category : #accessing }
DPInputFileSpec >> taskCount: anObject [
	taskCount := anObject
]

{ #category : #accessing }
DPInputFileSpec >> taskIndex [
	^ taskIndex
]

{ #category : #accessing }
DPInputFileSpec >> taskIndex: anObject [
	taskIndex := anObject
]
