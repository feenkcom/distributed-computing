Class {
	#name : #DPProcessFileStream,
	#superclass : #DPAbstractMapper,
	#instVars : [
		'filename'
	],
	#category : #'DistributedProcessing-Model'
}

{ #category : #operating }
DPProcessFileStream class >> map: filename processor: processorNumber of: numberOfProcessors [

	^ self new 
		filename: filename;
		processorNumber: processorNumber;
		processorCount: numberOfProcessors;
		map
]

{ #category : #operating }
DPProcessFileStream class >> map: filename processor: processorNumber of: numberOfProcessors to: resultPrefix in: destDirectory [
	| sourceFilename resultFilename |

	sourceFilename := String streamContents: [ :stream |
		stream 
			<< filename asFileReference fullName;
			<< '.';
			print: processorNumber;
			<< '.csv' ].
	resultFilename := String streamContents: [ :stream |
		stream
			<< resultPrefix;
			<< '.';
			print: processorNumber;
			<< '.ston' ].
	^ self new 
		filename: sourceFilename;
		processorNumber: processorNumber;
		processorCount: numberOfProcessors;
		mapToFile: destDirectory asFileReference / resultFilename
]

{ #category : #enumerating }
DPProcessFileStream >> readStreamDo: aBlock [ 
	"Evaluate aBlock with the receiver's stream, ensuring that it is closed after the block terminates"

	^ self filename readStreamDo: aBlock
]
