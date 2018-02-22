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
step that converts the Jupyter notebook to an HTML file. Nevertheless we demonstrate
how one could use the `Yadage
<https://github.com/diana-hep/yadage>`_ workflow engine and `Common Workflow Language
<http://www.commonwl.org/v1.0/>`_ specification to express this in a
structured YAML format. The corresponding
workflow descriptions can be found under  ``workflow/yadage/workflow.yaml`` and
``workflow/cwl/world_population_analysis.cwl`` paths.


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
=========================

Let us test whether the CWL workflow execution works locally as well.

To prepare the execution, we can:

- either place input files ``code/world_population_analysis.ipynb`` into the directory with ``world_population_analysis_job.yml``

.. code-block:: console


    $ cp code/world_population_analysis.ipynb workflow/cwl/


- or place ``world_population_analysis_job.yml`` to the root of the repository and edit it to correctly point to the input files:


.. code-block:: console
   :emphasize-lines: 6

    $ cp workflow/cwl/world_population_analysis_job.yml .
    $ vim world_population_analysis_job.yml

    notebook:
      class: File
      path: code/world_population_analysis.ipynb


We can now run the corresponding commands locally as follows:

.. code-block:: console

   // use this command, if input files were copied
   $ cwltool --quiet --outdir="outputs" workflow/cwl/helloworld.cwl workflow/cwl/world_population_analysis_job.yml

   // or use this command, if helloworld-job.yml was edited
   $ cwltool --quiet --outdir="outputs" workflow/cwl/helloworld.cwl world_population_analysis_job.yml

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

    version: 0.1.0
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

For CWL version see ``reana-cwl.yaml``

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
    $ reana-client ping
    [INFO] REANA Server URL ($REANA_SERVER_URL) is: http://192.168.99.100:32658
    [INFO] Connecting to http://192.168.99.100:32658
    [INFO] Server is running.

We can now initialise workflow and upload our input CSV data file and our
Jupyter notebook:

.. code-block:: console

    $ reana-client workflow create
    [INFO] REANA Server URL ($REANA_SERVER_URL) is: http://192.168.99.100:32658
    [INFO] Validating REANA specification file: /home/simko/private/src/reana-demo-worldpopulation/reana.yaml
    [INFO] Connecting to http://192.168.99.100:32658
    {u'message': u'Workflow workspace created', u'workflow_id': u'e4ec8128-a815-4bdd-b63c-faa26def77ae'}
    $ export REANA_WORKON=e4ec8128-a815-4bdd-b63c-faa26def77ae
    $ reana-client inputs upload World_historical_and_predicted_populations_in_percentage.csv
    [INFO] REANA Server URL ($REANA_SERVER_URL) is: http://192.168.99.100:32658
    [INFO] Workflow "e4ec8128-a815-4bdd-b63c-faa26def77ae" selected
    Uploading ./inputs/World_historical_and_predicted_populations_in_percentage.csv ...
    File ./inputs/World_historical_and_predicted_populations_in_percentage.csv was successfully uploaded.
    $ reana-client code upload world_population_analysis.ipynb
    [INFO] REANA Server URL ($REANA_SERVER_URL) is: http://192.168.99.100:32658
    [INFO] Workflow "e4ec8128-a815-4bdd-b63c-faa26def77ae" selected
    Uploading ./code/world_population_analysis.ipynb ...
    File ./code/world_population_analysis.ipynb was successfully uploaded.
    $ reana-client inputs list
    [INFO] REANA Server URL ($REANA_SERVER_URL) is: http://192.168.99.100:32658
    Name                                                        |Size|Last-Modified
    ------------------------------------------------------------|----|--------------------------------
    World_historical_and_predicted_populations_in_percentage.csv|574 |2018-02-21 18:42:17.466009+00:00
    $ reana-client code list
    [INFO] REANA Server URL ($REANA_SERVER_URL) is: http://192.168.99.100:32658
    Name                           |Size |Last-Modified
    -------------------------------|-----|--------------------------------
    world_population_analysis.ipynb|49847|2018-02-21 18:42:40.289009+00:00

Start workflow execution and enquire about its running status:

.. code-block:: console

    $ reana-client workflow start
    [INFO] REANA Server URL ($REANA_SERVER_URL) is: http://192.168.99.100:32658
    [INFO] Workflow `e4ec8128-a815-4bdd-b63c-faa26def77ae` selected
    Workflow `e4ec8128-a815-4bdd-b63c-faa26def77ae` has been started.
    [INFO] Connecting to http://192.168.99.100:32658
    {u'status': u'running', u'organization': u'default', u'message': u'Workflow successfully launched', u'user': u'00000000-0000-0000-0000-000000000000', u'workflow_id': u'e4ec8128-a815-4bdd-b63c-faa26def77ae'}
    Workflow `e4ec8128-a815-4bdd-b63c-faa26def77ae` has been started.
    $ reana-client workflow status
    [INFO] REANA Server URL ($REANA_SERVER_URL) is: http://192.168.99.100:32658
    [INFO] Workflow "e4ec8128-a815-4bdd-b63c-faa26def77ae" selected
    Name            |UUID                                |User                                |Organization|Status
    ----------------|------------------------------------|------------------------------------|------------|-------
    romantic_babbage|e4ec8128-a815-4bdd-b63c-faa26def77ae|00000000-0000-0000-0000-000000000000|default     |running

After the workflow execution successfully finished, we can retrieve its output:

.. code-block:: console

    $ reana-client outputs list
    [INFO] REANA Server URL ($REANA_SERVER_URL) is: http://192.168.99.100:32658
    [INFO] Workflow "e4ec8128-a815-4bdd-b63c-faa26def77ae" selected
    Name                                          |Size  |Last-Modified
    ----------------------------------------------|------|--------------------------------
    worldpopulation/world_population_analysis.html|309515|2018-02-21 19:59:25.342521+00:00
    _yadage/yadage_snapshot_backend.json          |476   |2018-02-21 19:59:25.342521+00:00
    _yadage/yadage_snapshot_workflow.json         |6676  |2018-02-21 19:59:25.342521+00:00
    _yadage/yadage_template.json                  |855   |2018-02-21 19:59:25.342521+00:00
    $ reana-client outputs download worldpopulation/world_population_analysis.html
    [INFO] REANA Server URL ($REANA_SERVER_URL) is: http://192.168.99.100:32658
    [INFO] worldpopulation/world_population_analysis.html binary file downloaded ... writing to ./outputs/
    File worldpopulation/world_population_analysis.html downloaded to ./outputs/

Let us verify the result:

.. code-block:: console

    $ firefox outputs/worldpopulation/world_population_analysis.html

This example uses Yadage workflow engine. If you would like to use CWL workflow engine,
please just use ``-f reana-cwl.yaml`` with reana-client commands

Thank you for using the `REANA <http://reanahub.io/>`_ reusable analysis
platform.
