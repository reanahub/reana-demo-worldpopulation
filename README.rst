================================================
 Reusable analysis example - "world population"
================================================

.. image:: https://img.shields.io/travis/reanahub/reana-demo-worldpopulation.svg
   :target: https://travis-ci.org/reanahub/reana-demo-worldpopulation

.. image:: https://badges.gitter.im/Join%20Chat.svg
   :target: https://gitter.im/reanahub/reana?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge

.. image:: https://img.shields.io/github/license/reanahub/reana-demo-worldpopulation.svg
   :target: https://github.com/reanahub/reana-demo-worldpopulation/blob/master/COPYING

About
=====

This repository provides an example on how a research data analysis using
Jupyter notebooks could be packaged for the `REANA <http://reanahub.io/>`_
reusable research data analysis plaftorm.

Making a research data analysis reproducible means to provide "runnable recipes"
addressing (1) where the input datasets are, (2) what software was used to
analyse the data, (3) which computing environment was used to run the software,
and (4) which workflow steps were taken to run the analysis.

1. Input dataset
================

We shall use the following input dataset:

- `World_historical_and_predicted_populations_in_percentage.csv <inputs/World_historical_and_predicted_populations_in_percentage.csv>`_

It contains historical and predicted world population numbers in CSV format and
was compiled from `Wikipedia <https://en.wikipedia.org/wiki/World_population>`_.

2. Analysis code
================

We have developed a simple Jupyter notebook for illustration:

- `worldpopulation.ipynb <code/worldpopulation.ipynb>`_

It studies the input dataset and prints several figures about how the world
population evolved in various continents as a function of time.

The resulting plots can be obtained as follows:

.. code-block:: console

   $ papermill ./code/worldpopulation.ipynb /dev/null \
         -p input_file ./inputs/World_historical_and_predicted_populations_in_percentage.csv \
         -p output_file ./outputs/plot.png
   $ ls -l outputs/plot.png

This generates a plot representing the result of our analysis:

.. figure:: https://raw.githubusercontent.com/reanahub/reana-demo-worldpopulation/master/docs/plot.png
   :alt: plot.png
   :align: center

Note that if you would like to plot different region and different year range,
you can pass ``region``, ``year_min`` and ``year_max`` parameters via the ``-p``
command line option:

.. code-block:: console

   $ papermill ./code/worldpopulation.ipynb /dev/null \
         -p input_file ./inputs/World_historical_and_predicted_populations_in_percentage.csv \
         -p output_file ./outputs/plot.png \
         -p region Europe \
         -p year_min 1600 \
         -p year_max 2010
   $ ls -l outputs/plot.png

Let us now try to provide runnable recipes so that our analysis can be run in a
reproducible manner on the REANA cloud.

3. Compute environment
======================

Let us assume that we were using CentOS7 operating system and Jupyter Notebook
1.0 with IPython 5.0 kernel to run the above analysis on our laptop. In order to
be able to rerun the analysis with the same version of Jupyter notebook software
even several years in the future, we need to "encapsulate the current
environment" where the original analysis code run.

In our example, we shall achieve this by using a prepared `Docker
<https://www.docker.com/>`_ image called `reana-env-jupyter
<https://github.com/reanahub/reana-env-jupyter>`_. Please have a look at that
repository if you'd like to create yours. Here it is enough to use this
environment "as is" and simply mount our notebook for execution.

4. Analysis workflow
====================

This analysis is very simple because it consists basically of running a single
step that converts the Jupyter notebook to an HTML file. Nevertheless we
demonstrate how one could use the `Yadage
<https://github.com/diana-hep/yadage>`_ workflow engine and `Common Workflow
Language <http://www.commonwl.org/v1.0/>`_ specification to express this in a
structured YAML format. The corresponding workflow descriptions can be found
here:

- `Yadage workflow definition <workflow/yadage/workflow.yaml>`_
- `CWL workflow definition <workflow/cwl/worldpopulation.cwl>`_

Now our "world population" analysis is now fully described in the
REANA-compatible reusable analysis manner and is prepared to be run on the REANA
cloud.

Local testing with Docker
=========================

Let us test whether everything works well locally in our containerised
environment. We shall use Docker locally. Note how we mount our local
directories ``inputs``, ``code`` and ``outputs`` into the containerised
environment:

.. code-block:: console

    $ rm -rf outputs && mkdir outputs
    $ docker run -i -t  --rm \
                  -v `pwd`/code:/code \
                  -v `pwd`/inputs:/inputs \
                  -v `pwd`/outputs:/outputs \
                  reanahub/reana-env-jupyter \
              papermill /code/worldpopulation.ipynb /dev/null

Let us check the results:

.. code-block:: console

    $ firefox outputs/plot.png

Local testing with Yadage
=========================

Let us test whether the Yadage workflow engine execution works locally.

Since Yadage only accepts one input directory as parameter, we are going to
create a wrapper directory which will contain links to ``inputs`` and ``code``
directories:

.. code-block:: console

    $ mkdir -p yadage-local-run/yadage-inputs
    $ cd yadage-local-run
    $ cp -a ../code ../inputs yadage-inputs

We can now run Yadage locally as follows:

.. code-block:: console

   $ yadage-run . ../workflow/yadage/workflow.yaml \
         -p notebook=code/worldpopulation.ipynb \
         -p input_file=inputs/World_historical_and_predicted_populations_in_percentage.csv \
         -p region=Africa \
         -p year_min=1500 \
         -p year_max=2012 \
         -d initdir=`pwd`/yadage-inputs

Let us check the results:

.. code-block:: console

    $ ls -l worldpopulation/plot.png

Local testing with CWL
======================

Let us test whether the CWL workflow execution works locally as well.

To prepare the execution, we are creating a working directory called ``cwl-local-run`` which will contain both
``inputs`` and ``code`` directory content. Also, we need to copy the workflow input file:

.. code-block:: console

   $ mkdir cwl-local-run
   $ cd cwl-local-run
   $ cp -a ../code ../inputs ../workflow/cwl/worldpopulation_job.yml .

We can now run the corresponding commands locally as follows:

.. code-block:: console

   $ cwltool --quiet --outdir="../outputs" ../workflow/cwl/worldpopulation.cwl worldpopulation_job.yml

Let us check the results:

.. code-block:: console

   $ ls -l ../outputs/plot.png

Create REANA file
=================

Putting all together, we can now describe our world population analysis example,
its runtime environment, the inputs, the code, the workflow and its outputs by
means of the following REANA specification file:

.. code-block:: yaml

    version: 0.2.0
    metadata:
      authors:
       - Alizee Pace <alizee.pace@gmail.com>
       - Diego Rodriguez <diego.rodriguez@cern.ch>
       - Tibor Simko <tibor.simko@cern.ch>
      title: World population - a Jupyter notebook reusable analysis example
      date: 21 February 2018
      repository: https://github.com/reanahub/reana-demo-worldpopulation/
    code:
      files:
       - code/worldpopulation.ipynb
    inputs:
      files:
        - inputs/World_historical_and_predicted_populations_in_percentage.csv
      parameters:
        notebook: code/worldpopulation.ipynb
    outputs:
      files:
       - outputs/plot.png
    environments:
      - type: docker
        image: reanahub/reana-env-jupyter
    workflow:
      type: yadage
      file: workflow/yadage/workflow.yaml

For CWL version see ``reana-cwl.yaml``.

Run the example on REANA cloud
==============================

We can now install the REANA client and submit the ROOT6 RooFit analysis example
to run on some particular REANA cloud instance. We start by installing the
client:

.. code-block:: console

    $ mkvirtualenv reana-client -p /usr/bin/python2.7
    $ pip install reana-client

and connect to the REANA cloud instance where we will run this example:

.. code-block:: console

    $ export REANA_SERVER_URL=http://192.168.99.100:32658

If you run REANA cluster locally as well, then:

.. code-block:: console

   $ eval $(reana-cluster env)

Let us check the connection:

.. code-block:: console

   $ reana-client ping
   Server is running.

We can now initialise workflow and upload our input CSV data file and our
Jupyter notebook:

.. code-block:: console

    $ reana-client workflow create
    workflow.3
    $ export REANA_WORKON=workflow.3
    $ reana-client inputs upload ./inputs
    File /home/simko/private/project/reana/src/reana-demo-worldpopulation/inputs was successfully uploaded.
    $ reana-client code upload ./code
    /home/simko/private/project/reana/src/reana-demo-worldpopulation/code/worldpopulation.ipynb was uploaded successfully.
    $ reana-client inputs list
    NAME                                                           SIZE   LAST-MODIFIED
    World_historical_and_predicted_populations_in_percentage.csv   574    2018-04-20 15:17:44.732120+00:00
    $ reana-client code list

Start workflow execution and enquire about its running status:

.. code-block:: console

    $ reana-client workflow start
    $ reana-client workflow status

After the workflow execution successfully finished, we can retrieve its output:

.. code-block:: console

    $ reana-client outputs list
    $ reana-client outputs download outputs/plot.png

Let us verify the result:

.. code-block:: console

    $ display outputs/plot.png

Note that this example demonstrated the use of the Yadage workflow engine. If
you would like to use the CWL workflow engine, please just use ``-f
reana-cwl.yaml`` option with the ``reana-client`` commands.

Thank you for using the `REANA <http://reanahub.io/>`_ reusable analysis
platform.
