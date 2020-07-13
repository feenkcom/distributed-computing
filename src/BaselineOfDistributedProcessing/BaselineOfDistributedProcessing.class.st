Class {
	#name : #BaselineOfDistributedProcessing,
	#superclass : #BaselineOf,
	#category : #BaselineOfDistributedProcessing
}

{ #category : #baselines }
BaselineOfDistributedProcessing >> baseline: spec [ 
	<baseline>

	spec for: #common do: [ 
		spec blessing: #baseline.

		spec
			baseline: 'NeoCSV'
			with: [ spec repository: 'github://svenvc/NeoCSV/repository' ].

		spec
			package: #'DistributedProcessing'
				with: [ spec requires: #('NeoCSV') ];
			group: 'Core' with: #(#'DistributedProcessing');
			group: 'all' with: #(#Core);
			group: 'default' with: #(#all).
		]
]
