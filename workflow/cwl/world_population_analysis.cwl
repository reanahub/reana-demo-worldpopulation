#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow

inputs:
  notebook: File

outputs:
  analysis:
    type: File
    outputSource:
      worldpopulation/result

steps:
  worldpopulation:
    run: worldpopulation.tool
    in:
      notebook: notebook
    out: [result]
