#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement
  - class: DockerRequirement
    dockerPull: reanahub/reana-env-jupyter:1.0.0

baseCommand: ["papermill"]

inputs:
  notebook:
    type: File
    inputBinding:
      position: 1
  notebook_modified:
    type: string
    default: /dev/null
    inputBinding:
      position: 2
  p_input_file:
    type: string
    default: input_file
    inputBinding:
      position: 3
      prefix: -p
  input_file:
    type: File
    inputBinding:
      position: 4
  p_output_file:
    type: string
    default: output_file
    inputBinding:
      position: 5
      prefix: -p
  output_file:
    type: string
    inputBinding:
      position: 6
  p_region:
    type: string
    default: region
    inputBinding:
      position: 7
      prefix: -p
  region:
    type: string
    inputBinding:
      position: 8
  p_year_min:
    type: string
    default: year_min
    inputBinding:
      position: 9
      prefix: -p
  year_min:
    type: int
    inputBinding:
      position: 10
  p_year_max:
    type: string
    default: year_max
    inputBinding:
      position: 11
      prefix: -p
  year_max:
    type: int
    inputBinding:
      position: 12

outputs:
  plot:
    type: File
    outputBinding:
      glob: $(inputs.output_file)
