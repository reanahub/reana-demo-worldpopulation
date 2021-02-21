#!/usr/bin/env cwl-runner

# Note that if you are working on the analysis development locally, i.e. outside
# of the REANA platform, you can proceed as follows:
#
#   $ cd reana-demo-worldpopulation
#   $ mkdir cwl-local-run
#   $ cd cwl-local-run
#   $ cp -a ../code ../data ../workflow/cwl/worldpopulation_job.yml .
#   $ cwltool --quiet --outdir="../results" ../workflow/cwl/worldpopulation.cwl worldpopulation_job.yml
#   $ firefox ../results/plot.png

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
    hints:
      reana:
        compute_backend: slurmcern
    run: worldpopulation.tool
    in:
      notebook: notebook
      input_file: input_file
      output_file: output_file
      region: region
      year_min: year_min
      year_max: year_max
    out: [plot]

$namespaces:
  reana: http://reana.io
