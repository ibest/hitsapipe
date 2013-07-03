# HiTSAPipe -- High Throughput Sequence Analysis Program
***

## DESCRIPTION

HiTSAPipe identifies and groups closely related sequences.

Configuration is done by a single configuration file that can be specified by
the user.

The script itself must be sitting on the headnode of a Beowulf cluster utilizing TORQUE.

HiTSAPipe uses the !!LICENSE!!

## SYSTEM REQUIREMENTS

- Python 2.6.6 (May possibly run on Python 2.4)
- Beowulf Cluster
- TORQUE 2.5.9 

### SOFTWARE REQUIREMENTS

HiTSAPipe requires the following additional software packages to run:

- Standalone
	- blastall (Tested with blastall 2.2.24)
	- clustalw (Tested with clustalw 2.0.12)

- Parallel
	- mpiexec for Open MPI (Tested with mpiexec (OpenRTE) 1.3.2)
	- mpiBLAST (Tested with mpiBLAST 1.4.0)
	- mpiformatdb (Tested with mpiBLAST/mpiformatdb 1.4.0)
	- clustalw-mpi (Tested with 1.82)


## INSTALLATION

Currently, installation is just copying the python pipeline file and the scripts directory and pointing the pipeline to the scripts directory (either with a command line option or by modifying the OptionParser in the Python script).

## RUNNING

Simply run HiTSAPipe by running the python script `pipeline`.

### ARGUMENTS

HiTSAPipe takes a number of different arguements that either control the location of certain critical files or the amount of output shown.

- 	`--work /path/to/working/dir` is the path where the output will be stored. A folder named output will be created inside 	this directory.
- 	`--config /path/to/config/file` is the path where the configuration file is located.  HiTSAPipe uses a configuration 		file that follows the style of IETF's RFC 822 (see section 3.1.1, “LONG HEADER FIELDS”).  An online version of this RFC 	is available on [the IETF RFC 822 page](http://tools.ietf.org/html/rfc822.html "IETF RFC 822").  By default, the 			pipeline looks for a configuration file named `preferences.conf` in the same directory as the pipeline script.
- 	`--scripts /path/to/scripts/dir` is the path to where the scripts that HiTSAPipe needs in order to run.  By default this 		is in a directory called scripts located in the same directory as the pipeline script.
- 	`--verbose` displays basic information of the python script itself to the screen.  By default this option is enabled and 	 is here to help distinguish between quiet mode.
- 	`--quiet` hides all output from the pipeline script itself.  If running in standalone mode however, the individual 			scripts that HiTSAPipe calls will still display their output.
- 	`--debug` enables additional output in both the HiTSAPipe script and in the scripts that it runs.  If this flag is set 		in addition to the --quiet flag, the --quiet flag will be ignored.


## CONFIG FILE

HiTSAPipe optionally takes a `--config file` flag.  See the sample preferences file as an example.

## CONTRIBUTE

To be finished.

## RELEASING

To be finished.