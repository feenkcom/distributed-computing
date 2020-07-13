Class {
	#name : #BaselineOfDistributedProcessing,
	#superclass : #BaselineOf,
	#category : #BaselineOfDistributedProcessing
}

{ #category : #baselines }
BaselineOfDistributedProcessing >> baseline: spec [ 

	spec for: #common do: [ 
		<baseline>
		spec blessing: #baseline.
		
		spec
			package: #'DistributedProcessing';
			group: 'Core' with: #(#'DistributedProcessing');
			group: 'all' with: #(#Core);
			group: 'default' with: #(#all).
		]
]
