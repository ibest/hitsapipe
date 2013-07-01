HiTSA Pipeline -- An RNA Sequencing Pipeline in Python utilizing Beowulf cluster
====================================

## DESCRIPTION

The HiTSA Pipeline is a python script that submits a list of scripts to qsub in
a simple to use manner.

Configuration is done by a single configuration file that can be specified by
the user.

The script itself must be sitting on the headnode of a Beowulf cluster utilizing TORQUE.

## SYSTEM REQUIREMENTS

- Python 2.6.6 (May possibly run on Python 2.4)
- Beowulf Cluster
- TORQUE 2.5.9 

## INSTALLATION

Currently, installation is just copying the python pipeline file and the scripts directory and pointing the pipeline to the scripts directory (either with a command line option or by modifying the OptionParser in the Python script).

## SYNTAX

## RUNNING

## CONFIG FILE

HiTSAPipe optionally takes a `--config file`.  See the example preferences file for an example.

## CONTRIBUTE


## RELEASING