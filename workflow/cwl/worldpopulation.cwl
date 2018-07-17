#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow

inputs:
  notebook: File
  input_file: File
  output_file: string
  region: string
  year_min: int
  year_max: int

outputs:
  plot:
    type: File
    outputSource:
      worldpopulation/plot

steps:
  worldpopulation:
    run: worldpopulation.tool
    in:
      notebook: notebook
      input_file: input_file
      output_file: output_file
      region: region
      year_min: year_min
      year_max: year_max
    out: [plot]
