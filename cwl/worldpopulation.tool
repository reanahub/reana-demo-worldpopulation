#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

requirements:
  DockerRequirement:
    dockerPull: reanahub/reana-demo-worldpopulation

inputs:
  outputfilename:
    type: string

arguments:
  - prefix: -c
    valueFrom: |
      cd /code;
      jupyter nbconvert --output-dir="$(runtime.outdir)" world_population_analysis.ipynb

baseCommand: ["/bin/sh"]

outputs:
  outputfile:
    type: File
    outputBinding:
      glob: $(inputs.outputfilename)