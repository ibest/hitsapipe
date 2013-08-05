# HiTSAPipe -- High Throughput Sequence Analysis Program
### Version 0.5.0
***

## DESCRIPTION

HiTSAPipe identifies and groups closely related sequences.

Configuration is done by a single configuration file that can be specified by
the user.

## SYSTEM REQUIREMENTS

-	Python 2.6.6 (May possibly run on Python 2.4)
-	TORQUE 2.5.9+ 

### SOFTWARE REQUIREMENTS

HiTSAPipe requires the following additional software packages to run:

-	Standalone
	-	blastall
	-	clustalw
-	Parallel
	-	mpiexec for Open MPI
	-	mpiBLAST
	-	mpiformatdb
	-	clustalw-mpi

## INSTALLATION

Installation is as simple as cloning the git repository and running 
the `pipeline` python script inside.  The script comes with sample 
input sequences and a sample configuration file.

## RUNNING

HiTSAPipe can be run by just executing the `pipeline` Python script 
as long as the following conditions are met:

-	The configuration file is:
	-	set up correctly
	-	sitting in the same directory as the Python script
	-	is named `preferences.conf`  
-	The scripts directory is in the same directory as the Python script
-	The working directory is the same directory that the Python script 
	sits in (a folder named output will be created in the working directory)

Otherwise, please see the arguments section to set up these options.

## ARGUMENTS

HiTSAPipe takes a number of different arguements that either control 
the location of certain critical files or the amount of output shown.

-	`--work=/path/to/working/dir` is the path where the output will be 
	stored. A folder named output will be created inside this 
	directory.  Setting this option will overwrite anything in 
	the configuration file.
-	`--config=/path/to/config/file` is the path where the configuration 
	file is located.  By default, the pipeline looks for a configuration 
	file named `preferences.conf` in the same directory as the pipeline 
	script.  See the config file section for more details on the syntax 
	of the configuration file.
-	`--scripts=/path/to/scripts/dir` is the path to where the scripts 
	that HiTSAPipe needs in order to run.  By default this is in a 
	directory called scripts located in the same directory as the pipeline 
	script.  Setting this option will overwrite anything in the 
	configuration file.
-	`--verbose` displays additional output from the python script 
	itself to the screen.
-	`--quiet` hides all output from the pipeline script itself.  If 
	running in standalone mode however, the individual scripts that 
	HiTSAPipe calls will still display their output.
-	`--debug` enables additional output in the scripts that HiTSAPipe calls.

## CONFIG FILE

HiTSAPipe optionally takes a `--config=file` flag.  If there is no 
configuration file found, the default options (which can be 
found/modified in the `pipeline` script) are used.  If any options are 
missing from the configuration file, the default option is used in its 
place.  If a command line option is specified, it overrides the 
configuration file.  HiTSAPipe uses the Python ConfigParser class 
in order to parse the configuration file and follows the style of 
RFC 822 (specifically section 3.1.1, "LONG HEADER FIELDS").  This RFC 
can be viewed online 
on [the IETF RFC 822 page](http://tools.ietf.org/html/rfc822.html "RFC 822").

To use the default option that is embedded inside the 
HiTSAPipe application, just place a "#" symbol at the 
beginning of the line that you want to be ignored.
This will tell HiTSAPipe to ignore 
everything on that line. 

You can also you what's called "string interpolation."
That is, placing the value of one string (in our case, 
preference) inside the value of another string.  In order 
to do this, we use the form:

	%(PreferenceNameHere)s

This is useful when specifying directories that are  
used more than once.  In order for string interpolation
to work, both strings (preferences) must be in the same 
section, however their order does not matter.  Here is 
an example as to what this looks like:

	[Section1]
	Directory1 = "Some value"
	[Section2]
	Directory2 = /mnt/home/user
	CorrectFullPath = %(Directory2)s/the/rest/of/the/path
	WrongFullPath = %(Directory1)s/this/is/wrong

The result here would be that `CorrectFullPath` would be the path:

	/mnt/home/user/the/rest/of/the/path

The preference `WrongFullPath`, however, will throw an error and 
HiTSAPipe will exit.  This is because `Directory1` is not in the 
same section as `WrongFullPath`.

You may also nest string interpolations.  This means that
that you can use a structure to define different preferences.
Here is an example as to what this may look like:

	[Directories]
	OutDir = %(WorkDir)s/output
	WorkDir = %(Dir1)s
	Dir1 = /mnt/home/user1/work
	Dir2 = %(WorkDir)/../../user2/other/
	
The result here would be that:

	OutDir = /mnt/home/user1/work/output
	WorkDir = /mnt/home/user1/work
	Dir1 = /mnt/home/user1/work
	Dir2 = /mnt/home/user1/work/../../user2/other/
	
Note that when `Dir2` is used in HiTSAPipe, it would expand this to:
	
	Dir2 = /mnt/home/user2/other
	
like we would expect when using a POSIX shell like bash.

FINAL NOTE:  After the closing parenthesis there is a letter "s" that
is critical to string interpolation working.

See the sample configuration file for examples.


## CONTRIBUTE

If you'd like to contribute to HiTSAPipe, start by forking the repo on GitHub:

https://github.com/ibest/hitsapipe

The best way to get your changes merged back into master is as follows:

1. Clone down your fork
1. Create a thoughtfully named topic branch to contain our change
1. Make all the changes you want
1. Make sure everything still works properly
1. If you are adding new functionality, make sure to document it in the README
1. Don't worry about changing the version number, the hitsapipe project 
will take care of that
1. If necessary, rebase your commits into logical chunks, without errors
1. Push the branch up to GitHub
1. Send a pull request to the hitsapipe project

## RELEASING

HiTSAPipe uses [Semantic Versioning](http://www.semver.org).

Versions numbers are in the form of `x.y.z`, where:

  * `x` is the MAJOR version
  * `y` is the MINOR version
  * `z` is the PATCH version  

The most important piece of information to take from here is that 
changes in the MINOR and PATCH versions maintain backwards compatibility 
with anything from that major version.  MAJOR version changes will be 
backwards incompatible.
The goal is to make any dependency conflicts easier to handle and more 
importantly in this project, define a style to version numbers. 

## LICENSE

HiTSAPipe uses the Mozilla Public License 2.0 (MPL 2.0) unless otherwise 
stated.  Old versions of the HiTSA Pipeline were licensed under MPL 1.1.

You may obtain a copy of the MPLv2.0 at http://mozilla.org/MPL/2.0/

You may obtain a copy of the MPLv1.1 at http://www.mozilla.org/MPL/1.1/
