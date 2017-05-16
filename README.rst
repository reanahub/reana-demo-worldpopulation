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

- `World_historical_and_predicted_populations_in_percentage.csv <World_historical_and_predicted_populations_in_percentage.csv>`_

It contains historical and predicted world population numbers in CSV format and
was compiled from `Wikipedia <https://en.wikipedia.org/wiki/World_population>`_.

2. Analysis code
================

We have developed a simple Jupyter notebook for illustration:

- `world_population_analysis.ipynb <world_population_analysis.ipynb>`_

It studies the input dataset and prints several figures about how the world
population evolved in various continents as a function of time.

The resulting plots can be obtained as follows:

.. code-block:: console

   $ jupyter nbconvert world_population_analysis.ipynb

3. Compute environment
======================

Let us assume that we were using CentOS7 operating system and Jupyter Notebook
1.0 with IPython 5.0 kernel to run the above analysis on our laptop. In order to
be able to rerun the analysis with the same version of Jupyter notebook software
even several years in the future, we need to "encapsulate the current
environment" where the original analysis code run.

In our example, we shall achieve this by preparing a `Docker
<https://www.docker.com/>`_ container emulating CentOS7 with instructions on how
to install the wanted Jupyter notebook and IPython kernel versions:

- `Dockerfile <Dockerfile>`_

For example:

.. code-block:: console

    $ cat Dockerfile
    FROM centos:7
    RUN yum install -y epel-release
    RUN yum install -y \
        gcc \
        python-devel \
        python-pip
    RUN pip install ipython==5.0.0 jupyter==1.0.0
    ADD world_population_analysis.ipynb /code/
    WORKDIR /code
    CMD ["jupyter", "nbconvert","world_population_analysis.ipynb"]

We can now build the container image:

.. code-block:: console

    $ docker build -t worldpopulation .

and test whether it works:

.. code-block:: console

    $ docker run -v `pwd`:/code -i -t --rm worldpopulation jupyter nbconvert world_population_analysis.ipynb
    $ firefox world_population_analysis.html

Let us publish it on Docker Hub:

.. code-block:: console

    $ docker push johndoe/worldpopulation

4. Analysis workflow
====================

This analysis is very simple because it consists basically of running a single
step that converts the Jupyter notebook to an HTML file:

.. code-block:: console

   $ jupyter nbconvert world_population_analysis.ipynb

We shall use the `Yadage <https://github.com/diana-hep/yadage>`_ workflow engine
to represent this step in a structured YAML manner:

- `world_population_analysis.yaml <world_population_analysis.yaml>`_

For example:

.. code-block:: console

   $ cat world_population_analysis.yaml
   stages:
     - name: worldpopulation
       scheduler:
         scheduler_type: 'singlestep-stage'
         parameters:
           outputdir: '{workdir}'
           outputfile: '{workdir}/world_population_analysis.html'
         step:
           process:
             process_type: 'string-interpolated-cmd'
             cmd: 'jupyter nbconvert --output-dir="{outputdir}" world_population_analysis.ipynb'
           publisher:
             publisher_type: 'frompar-pub'
             outputmap:
               outputfile: outputfile
           environment:
             environment_type: 'docker-encapsulated'
             image: 'johndoe/worldpopulation'

That's all! Our "world population" analysis is now fully described in the
REANA-compatible reusable analysis manner and is prepared to be run on the REANA
cloud.

Run the example on REANA cloud
==============================

We can now install the REANA client and submit the "world population" analysis
example to run on some particular REANA cloud instance:

.. code-block:: console

   $ pip install reana-client
   $ export REANA_SERVER_URL=https://reana.cern.ch
   $ reana-client run world_population_analysis.yaml
   [INFO] Starting world_population_analysis...
   [...]
   [INFO] Done. You can see the results in the `output/` directory.

**FIXME** The ``reana-client`` package is a not-yet-released work-in-progress.
Until it is available, you can use ``reana run
reanahub/reana-demo-worldpopulation`` on the REANA server side, following the
`REANA getting started
<http://reana.readthedocs.io/en/latest/gettingstarted.html>`_ documentation.
