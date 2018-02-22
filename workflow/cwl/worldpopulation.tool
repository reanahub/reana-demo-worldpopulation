#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement
  - class: DockerRequirement
    dockerPull: reanahub/reana-env-jupyter

baseCommand: ["jupyter", "nbconvert"]

inputs:
  outputfile:
    type: string
    default: world_population_analysis.html
  outputdir:
    type: string
    default: tmp
    inputBinding:
      prefix: --output-dir
      position: 1
  notebook:
    type: File
    inputBinding:
      position: 2

outputs:
  result:
    type: File
    outputBinding:
      glob: $(inputs.outputdir)/$(inputs.outputfile)
