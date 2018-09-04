====================================
 REANA example - "world population"
====================================

.. image:: https://img.shields.io/travis/reanahub/reana-demo-worldpopulation.svg
   :target: https://travis-ci.org/reanahub/reana-demo-worldpopulation

.. image:: https://badges.gitter.im/Join%20Chat.svg
   :target: https://gitter.im/reanahub/reana?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge

.. image:: https://img.shields.io/github/license/reanahub/reana-demo-worldpopulation.svg
   :target: https://github.com/reanahub/reana-demo-worldpopulation/blob/master/LICENSE

About
=====

This `REANA <http://www.reana.io/>`_ reproducible analysis example demonstrates
how to use parametrised Jupyter notebook to analyse the world population
evolution.

Analysis structure
==================

Making a research data analysis reproducible basically means to provide
"runnable recipes" addressing (1) where is the input data, (2) what software was
used to analyse the data, (3) which computing environments were used to run the
software and (4) which computational workflow steps were taken to run the
analysis. This will permit to instantiate the analysis on the computational
cloud and run the analysis to obtain (5) output results.

1. Input data
-------------

We shall use the following input dataset:

- `World_historical_and_predicted_populations_in_percentage.csv <inputs/World_historical_and_predicted_populations_in_percentage.csv>`_

It contains historical and predicted world population numbers in CSV format and
was compiled from `Wikipedia <https://en.wikipedia.org/wiki/World_population>`_.

2. Analysis code
----------------

We have developed a simple Jupyter notebook for illustration:

- `worldpopulation.ipynb <code/worldpopulation.ipynb>`_

It studies the input dataset and prints a figure about how the world population
evolved in the given region as a function of time.

The analysis code can be seen by browsing the above notebook.

3. Compute environment
----------------------

In order to be able to rerun the analysis even several years in the future, we
need to "encapsulate the current compute environment", for example to freeze the
Jupyter notebook version and the notebook kernel that our analysis was using. We
shall achieve this by preparing a `Docker <https://www.docker.com/>`_ container
image for our analysis steps.

Let us assume that we are using CentOS7 operating system and Jupyter Notebook
1.0 with IPython 5.0 kernel to run the above analysis on our laptop. We can use
an already-prepared Docker image called `reana-env-jupyter
<https://github.com/reanahub/reana-env-jupyter>`_. Please have a look at that
repository if you would like to create yours. Here it is enough to use this
environment "as is" and simply mount our notebook code for execution.

4. Analysis workflow
--------------------

This analysis is very simple because it consists basically of running only the
notebook which will produce the final plot.

In order to ease the rerunning of the analysis with different parameters, we are
using `papermill <https://github.com/nteract/papermill>`_ to parametrise the
notebook inputs.

The input parameters are located in a tagged cell and define:

- ``input_file`` - the location of the input CVS data file (see above)
- ``region`` - the region of teh world to analyse (e.g. Africa)
- ``year_min`` - starting year
- ``year_max`` - ending year
- ``output_file`` - the location where the final plot should be produced.

The workflow can be represented as follows:

.. code-block:: console

              START
               |
               |
               V
   +---------------------------+
   | run parametrised notebook |  <-- input_file
   |                           |  <-- region, year_min, year_max
   |    $ papermill ...        |
   +---------------------------+
               |
               | plot.png
               V
              STOP

For example:

.. code-block:: console

    $ papermill ./code/worldpopulation.ipynb /dev/null \
         -p input_file ./inputs/World_historical_and_predicted_populations_in_percentage.csv \
         -p output_file ./outputs/plot.png \
         -p region Europe \
         -p year_min 1600 \
         -p year_max 2010
    $ ls -l outputs/plot.png

Note that you can also use `CWL <http://www.commonwl.org/v1.0/>`_ or `Yadage
<https://github.com/diana-hep/yadage>`_ workflow specifications:

- `workflow definition using CWL <workflow/cwl/worldpopulation.cwl>`_
- `workflow definition using Yadage <workflow/yadage/workflow.yaml>`_


5. Output results
-----------------

The example produces a plot representing the population of the given world
region relative to the total world population as a function of time:

.. figure:: https://raw.githubusercontent.com/reanahub/reana-demo-worldpopulation/master/docs/plot.png
   :alt: plot.png
   :align: center

Local testing
=============

*Optional*

If you would like to test the analysis locally (i.e. outside of the REANA
platform), you can proceed as follows.

Using pure Docker:

.. code-block:: console

    $ rm -rf outputs && mkdir outputs
    $ docker run -i -t  --rm \
                  -v `pwd`/code:/code \
                  -v `pwd`/inputs:/inputs \
                  -v `pwd`/outputs:/outputs \
                  reanahub/reana-env-jupyter \
              papermill /code/worldpopulation.ipynb /dev/null
    $ firefox outputs/plot.png

In case you are using CWL workflow specification:

.. code-block:: console

    $ mkdir cwl-local-run
    $ cd cwl-local-run
    $ cp -a ../code ../inputs ../workflow/cwl/worldpopulation_job.yml .
    $ cwltool --quiet --outdir="../outputs" ../workflow/cwl/worldpopulation.cwl worldpopulation_job.yml
    $ firefox ../outputs/plot.png

In case you are using Yadage workflow specification:

.. code-block:: console

    $ mkdir -p yadage-local-run/yadage-inputs
    $ cd yadage-local-run
    $ cp -a ../code ../inputs yadage-inputs
    $ yadage-run . ../workflow/yadage/workflow.yaml \
         -p notebook=code/worldpopulation.ipynb \
         -p input_file=inputs/World_historical_and_predicted_populations_in_percentage.csv \
         -p region=Africa \
         -p year_min=1500 \
         -p year_max=2012 \
         -d initdir=`pwd`/yadage-inputs
    $ firefox worldpopulation/plot.png

Running the example on REANA cloud
==================================

We are now ready to run this example and on the `REANA <http://www.reana.io/>`_
cloud.

First we need to create a `reana.yaml <reana.yaml>`_ file describing the
structure of our analysis with its inputs, the code, the runtime environment,
the computational workflow steps and the expected outputs:

.. code-block:: yaml

    version: 0.3.0
    inputs:
      files:
        - code/worldpopulation.ipynb
        - inputs/World_historical_and_predicted_populations_in_percentage.csv
      parameters:
        notebook: code/worldpopulation.ipynb
        input_file: inputs/World_historical_and_predicted_populations_in_percentage.csv
        output_file: outputs/plot.png
        region: Africa
        year_min: 1500
        year_max: 2012
    outputs:
      files:
       - outputs/plot.png
    workflow:
      type: serial
      specification:
        steps:
          - environment: 'reanahub/reana-env-jupyter'
            commands:
              - mkdir -p outputs && papermill $notebook /dev/null -p input_file ${input_file} -p output_file ${output_file} -p region $region -p year_min ${year_min} -p year_max ${year_max}

In case you are using CWL or Yadage workflow specifications:

- `reana.yaml using CWL <reana-cwl.yaml>`_
- `reana.yaml using Yadage <reana-yadage.yaml>`_

We proceed by installing the REANA command-line client:

.. code-block:: console

    $ mkvirtualenv reana-client
    $ pip install reana-client

We should now connect the client to the remote REANA cloud where the analysis
will run. We do this by setting the ``REANA_SERVER_URL`` environment variable
and ``REANA_ACCESS_TOKEN`` with a valid access token:

.. code-block:: console

    $ export REANA_SERVER_URL=https://reana.cern.ch/
    $ export REANA_ACCESS_TOKEN=<ACCESS_TOKEN>

Note that if you `run REANA cluster locally
<http://reana-cluster.readthedocs.io/en/latest/gettingstarted.html#deploy-reana-cluster-locally>`_
on your laptop, you would do:

.. code-block:: console

    $ eval $(reana-cluster env --all)

Let us test the client-to-server connection:

.. code-block:: console

    $ reana-client ping
    Connected to https://reana.cern.ch - Server is running.

We proceed to create a new workflow instance:

.. code-block:: console

    $ reana-client create
    workflow.1
    $ export REANA_WORKON=workflow.1

We can now seed the analysis workspace with our input CSV data file and our
Jupyter notebook:

.. code-block:: console

    $ reana-client upload ./inputs ./code
    File inputs/World_historical_and_predicted_populations_in_percentage.csv was successfully uploaded.
    File code/worldpopulation.ipynb was successfully uploaded.

    $ reana-client list
    NAME                                                                  SIZE    LAST-MODIFIED
    code/worldpopulation.ipynb                                            19223   2018-08-29 08:11:57.575697+00:00
    inputs/World_historical_and_predicted_populations_in_percentage.csv   574     2018-08-29 08:11:57.542697+00:00

We can now start the workflow execution:

.. code-block:: console

    $ reana-client start
    workflow.1 has been started.

After several minutes the workflow should be successfully finished. Let us query
its status:

.. code-block:: console

    $ reana-client status
    NAME       RUN_NUMBER   CREATED               STATUS     PROGRESS
    workflow   1            2018-08-29T08:11:35   finished   2/2

We can list the output files:

.. code-block:: console

    $ reana-client list
    NAME                                                                  SIZE    LAST-MODIFIED
    outputs/plot.png                                                      15879   2018-08-29 08:12:54.547782+00:00
    code/worldpopulation.ipynb                                            19223   2018-08-29 08:11:57.575697+00:00
    inputs/World_historical_and_predicted_populations_in_percentage.csv   574     2018-08-29 08:11:57.542697+00:00

We finish by downloading the generated plot:

.. code-block:: console

    $ reana-client download outputs/plot.png
    File outputs/plot.png downloaded to /home/simko/private/project/reana/src/reana-demo-worldpopulation.

Contributors
============

The list of contributors in alphabetical order:

- Alizee Pace <alizee.pace@gmail.com>
- `Anton Khodak <https://orcid.org/0000-0003-3263-4553>`_ <anton.khodak@ukr.net>
- `Diego Rodriguez <https://orcid.org/0000-0003-0649-2002>`_ <diego.rodriguez@cern.ch>
- `Dinos Kousidis <https://orcid.org/0000-0002-4914-4289>`_ <dinos.kousidis@cern.ch>
- `Tibor Simko <https://orcid.org/0000-0001-7202-5803>`_ <tibor.simko@cern.ch>
