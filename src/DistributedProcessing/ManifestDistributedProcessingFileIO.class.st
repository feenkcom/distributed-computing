"
I store metadata for this package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : #ManifestDistributedProcessingFileIO,
	#superclass : #PackageManifest,
	#category : #'DistributedProcessing-Manifest'
}

{ #category : #'code-critics' }
ManifestDistributedProcessingFileIO class >> ruleRBToDoCollectRuleV1FalsePositive [
	^ #(#(#(#RGMethodDefinition #(#DPMapReduceSimpleManager #run #false)) #'2020-07-12T18:24:00.908861+02:00') )
]

{ #category : #'code-critics' }
ManifestDistributedProcessingFileIO class >> ruleRBToDoWithIncrementRuleV1FalsePositive [
	^ #(#(#(#RGMethodDefinition #(#DPMapReduceSimpleManager #run #false)) #'2020-07-12T18:24:09.398679+02:00') )
]
