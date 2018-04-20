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

- `world_population_analysis.ipynb <code/world_population_analysis.ipynb>`_

It studies the input dataset and prints several figures about how the world
population evolved in various continents as a function of time.

The resulting plots can be obtained as follows:

.. code-block:: console

   $ jupyter nbconvert world_population_analysis.ipynb

This generates a plot representing the result of our analysis:

.. figure:: https://raw.githubusercontent.com/reanahub/reana-demo-worldpopulation/master/docs/plot.png
   :alt: plot.png
   :align: center

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
- `CWL workflow definition <workflow/cwl/world_population_analysis.cwl>`_

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
              jupyter nbconvert --output-dir=/outputs /code/world_population_analysis.ipynb

Let us check the results:

.. code-block:: console

    $ firefox outputs/world_population_analysis.html

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
         -p notebook=code/world_population_analysis.ipynb \
         -d initdir=`pwd`/yadage-inputs
   2018-02-21 18:44:05,000 - yadage.utils - INFO - setting up backend multiproc:auto with opts {}
   2018-02-21 18:44:05,001 - packtivity.asyncbackends - INFO - configured pool size to 4
   2018-02-21 18:44:05,010 - yadage.utils - INFO - local:. {u'initdir': '/home/simko/private/src/reana-demo-worldpopulation/yadage-local-run/yadage-inputs'}
   2018-02-21 18:44:05,035 - yadage.steering_object - INFO - initializing workflow with {u'notebook': 'code/world_population_analysis.ipynb'}
   2018-02-21 18:44:05,035 - adage.pollingexec - INFO - preparing adage coroutine.
   2018-02-21 18:44:05,035 - adage - INFO - starting state loop.
   2018-02-21 18:44:05,056 - yadage.handlers.scheduler_handlers - INFO - initializing scope from dependent tasks
   2018-02-21 18:44:05,063 - yadage.wflowview - INFO - added node <YadageNode init DEFINED lifetime: 0:00:00.000171  runtime: None (id: 0a54ccbef0a08998a549714f0398694034e1aa46) has result: True>
   2018-02-21 18:44:05,151 - yadage.wflowview - INFO - added node <YadageNode worldpopulation DEFINED lifetime: 0:00:00.000113  runtime: None (id: 28955f1e1213d34e272724ccd6d80f9be9cba829) has result: True>
   2018-02-21 18:44:05,205 - packtivity_logger_init.step - INFO - publishing data: <TypedLeafs: {u'notebook': u'/home/simko/private/src/reana-demo-worldpopulation/yadage-local-run/yadage-inputs/code/world_population_analysis.ipynb'}>
   2018-02-21 18:44:05,233 - adage.node - INFO - node ready <YadageNode init SUCCESS lifetime: 0:00:00.170554  runtime: 0:00:00.027437 (id: 0a54ccbef0a08998a549714f0398694034e1aa46) has result: True>
   2018-02-21 18:44:05,249 - packtivity_logger_worldpopulation.step - INFO - starting file loging for topic: step
   2018-02-21 18:44:05,310 - packtivity_logger_worldpopulation.step - INFO - prepare pull
   2018-02-21 18:44:10,519 - adage.node - INFO - node ready <YadageNode worldpopulation SUCCESS lifetime: 0:00:05.367455  runtime: 0:00:05.271024 (id: 28955f1e1213d34e272724ccd6d80f9be9cba829) has result: True>
   2018-02-21 18:44:10,526 - adage.controllerutils - INFO - no nodes can be run anymore and no rules are applicable
   2018-02-21 18:44:10,526 - adage.pollingexec - INFO - exiting main polling coroutine
   2018-02-21 18:44:10,526 - adage - INFO - adage state loop done.
   2018-02-21 18:44:10,526 - adage - INFO - execution valid. (in terms of execution order)
   2018-02-21 18:44:10,533 - adage.controllerutils - INFO - no nodes can be run anymore and no rules are applicable
   2018-02-21 18:44:10,533 - adage - INFO - workflow completed successfully.

Let us check the results:

.. code-block:: console

    $ firefox worldpopulation/world_population_analysis.html

Local testing with CWL
======================

Let us test whether the CWL workflow execution works locally as well.

To prepare the execution, we are creating a working directory called ``cwl-local-run`` which will contain both
``inputs`` and ``code`` directory content. Also, we need to copy the workflow input file:

.. code-block:: console

   $ mkdir cwl-local-run
   $ cd cwl-local-run
   $ cp ../code/* ../inputs/* ../workflow/cwl/world_population_analysis_job.yml .

We can now run the corresponding commands locally as follows:

.. code-block:: console

   $ cwltool --quiet --outdir="../outputs" ../workflow/cwl/world_population_analysis.cwl world_population_analysis_job.yml

    [NbConvertApp] Converting notebook /var/lib/cwl/stgccd9de94-1340-41ee-b65b-39b0d826efa3/world_population_analysis.ipynb to html
    [NbConvertApp] Writing 309515 bytes to tmp/world_population_analysis.html
    {
        "analysis": {
            "checksum": "sha1$19ac7a33cedcfade5d561379830a9f64d2c5a780",
            "basename": "world_population_analysis.html",
            "location": "file:///path/to/reana-demo-worldpopulation/outputs/world_population_analysis.html",
            "path": "/path/to/reana-demo-worldpopulation/outputs/world_population_analysis.html",
            "class": "File",
            "size": 309515
        }
    }


Let us check the results:

.. code-block:: console

   $ firefox outputs/world_population_analysis.html

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
       - code/world_population_analysis.ipynb
    inputs:
      files:
        - inputs/World_historical_and_predicted_populations_in_percentage.csv
      parameters:
        notebook: code/world_population_analysis.ipynb
    outputs:
      files:
       - outputs/world_population_analysis.html
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
    /home/simko/private/project/reana/src/reana-demo-worldpopulation/code/world_population_analysis.ipynb was uploaded successfully.
    $ reana-client inputs list
    NAME                                                           SIZE   LAST-MODIFIED
    World_historical_and_predicted_populations_in_percentage.csv   574    2018-04-20 15:17:44.732120+00:00
    $ reana-client code list
    NAME                              SIZE    LAST-MODIFIED
    world_population_analysis.ipynb   49847   2018-04-20 15:17:29.749120+00:00

Start workflow execution and enquire about its running status:

.. code-block:: console

    $ reana-client workflow start
    workflow.3 has been started.
    $ reana-client workflow status
    NAME       RUN_NUMBER   ID                                     USER                                   ORGANIZATION   STATUS
    workflow   3            c4998157-bdfe-4c4f-86f8-e5d2ad3ea003   00000000-0000-0000-0000-000000000000   default        running

After the workflow execution successfully finished, we can retrieve its output:

.. code-block:: console

    $ reana-client outputs list
    NAME                                             SIZE     LAST-MODIFIED
    worldpopulation/world_population_analysis.html   309515   2018-04-20 15:18:42.103120+00:00
    _yadage/yadage_snapshot_backend.json             476      2018-04-20 15:18:42.103120+00:00
    _yadage/yadage_snapshot_workflow.json            8471     2018-04-20 15:18:42.103120+00:00
    _yadage/yadage_template.json                     872      2018-04-20 15:18:42.103120+00:00
    $ reana-client outputs download worldpopulation/world_population_analysis.html
    File worldpopulation/world_population_analysis.html downloaded to ./outputs/

Let us verify the result:

.. code-block:: console

    $ firefox outputs/worldpopulation/world_population_analysis.html

Note that this example demonstrated the use of the Yadage workflow engine. If
you would like to use the CWL workflow engine, please just use ``-f
reana-cwl.yaml`` option with the ``reana-client`` commands.

Thank you for using the `REANA <http://reanahub.io/>`_ reusable analysis
platform.
