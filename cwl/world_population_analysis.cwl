#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow

inputs:
  outputfilename:
    type: string

outputs:
  analysis:
    type: File
    outputSource:
      worldpopulation/outputfile


steps:
  worldpopulation:
    run: worldpopulation.tool
    in:
      outputfilename: outputfilename
    out: [outputfile]
