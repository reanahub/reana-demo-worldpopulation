================================================
 Reusable analysis example - "world population"
================================================

About
=====

This repository provides an example on how a research data analysis using
Jupyter notebooks could be packaged for the `REANA <http://reanahub.io/>`_
reusable research data analysis plaftorm.

Making a research data analysis reproducible means to provide "runnable recipes"
addressing (1) where the input datasets are, (2) what software was used to
analyse the data, (3) which computing environment was used to run the software,
and (4) which workflow steps was taken to run the analysis.

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

Let us assume that we were using CentOS7 operating system and IPython 5.0 to run
the above analysis on our laptop. In order to be able to rerun the analysis with
the same version of Jupyter notebook software even several years in the future,
we need to "encapsulate the current environment" where the original analysis
code run.

In our example, we shall achieve this by preparing a `Docker
<https://www.docker.com/>`_ container emulating CentOS7 with instructions on how
to install the wanted Ipython and Jupyter versions:

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
    ENTRYPOINT ["jupyter", "nbconvert"]
    CMD ["world_population_analysis.ipynb"]

We can now build the container image:

.. code-block:: console

    $ docker build -t worldpopulation .

and test whether it works:

.. code-block:: console

    $ docker run -v `pwd`:/code -i -t --rm worldpopulation
    $ firefox world_population_analysis.html

Let us publish it on Docker Hub:

.. code-block:: console

    $ docker push johndoe/worldpopulation

4. Workflow steps
=================

This analysis is very simple because it consisted basically of running a single
step that converted the IPython Notebook to an HTML file:

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

That's all! Our analysis is now fully prepared in the REANA-compatible
reproducible manner.

Rerun the analysis
==================

**FIXME** work-in-progress

We can now install REANA client and submit the analysis to REANA cloud:

.. code-block:: console

   $ pip install reana-client
   $ export REANA_SERVER_URL=https://reana.cern.ch
   $ reana-client run world_population_analysis.yaml
   [INFO] Starting world_population_analysis...
   [...]
   [INFO] Done. You can see the results in the `output/` directory.

Let us visualise the results:

.. code-block:: console

   $ ls -l output/world_population_analysis.html
   -rw-r--r-- 1 root root 310847 May  5 10:52 world_population_analysis.html
   $ firefox output/world_population_analysis.html
