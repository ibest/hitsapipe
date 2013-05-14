from optparse import OptionParser
from optparse import OptionGroup
from os import path
import sys
from subprocess import call
#import re
def fix_directory(m_path):
    # This function appends a '/' to a path
    # if it doesn't have one.  Be sure to not
    # use this on files.
    if m_path[-1] != '/':
        m_path += '/'
    return m_path
def expand_dir(m_path):
    # Returns a fully expanded absolute path.
    # Requires os.path
    return fix_directory(path.abspath(path.expanduser( m_path )))
def expand_file(m_path):
    # Returns a fully expanded absolute path.
    # Requires os.path
    # Does not call fix directory.
    return path.abspath(path.expanduser(m_path))
def source_file(m_path):
    # Runs the source command with the passed in parameter as the
    # file to source.
    if path.exists(m_path):
        success = call(["source",m_path])
        # At this point you could check that the call was successful.
        if success == 0:
            print m_path + " executed successfully."
            return True
        else:
            print >> sys.stderr, m_path + " execution failed."
            return False
    else:
        print >> sys.stderr, m_path + " does not exist."
        return False
def fatal_error_msg(msg):
    print >> sys.stderr, "Error: " + msg + " Exiting."
    sys.exit(1)  
def parse_file(m_path):
    if path.exists(m_path) == False:
        fatal_error_msg("Preference file does not exist: " + m_path)
     
    
def main():
    
    # Set up the parser that will see what options are set.
    parser = OptionParser(usage="%prog [options]", version="%prog 0.1", epilog="Last modified 11 April 2013")
   
    parser.add_option("-m", "--main", action="store", dest="maindir", default="../../", help="set the working directory where all output is")
    parser.add_option("-p", "--pref", action="store", dest="pref_file", default="../bash/default_prefs.bash", help="file where the preferences are located") # Should this not have a default?

    adv_group = OptionGroup(parser, "Advanced Options",
                            "Use these options at your own risk.  "
                            "Using these variables can cause the program to fail.  "
                            "It is best to use the default in this case.")
    adv_group.add_option("-s", "--script", action="store", dest="scriptdir", default="../", help="set the directory where the scripts are located")
    parser.add_option_group(adv_group)

    
    (options, args) = parser.parse_args()
    
    if len(args) > 0:
        parser.error("incorrect number of arguments")
    
    # Set up local variables.  Decide if I wanted to use this or not.
    scriptdir = expand_dir(options.scriptdir)
    maindir = expand_dir(options.maindir)
    pref_file = expand_file(options.pref_file)
    # End of parser
    
    # Make sure all the files at least exist.
    if path.exists(scriptdir) == False:
        fatal_error_msg("Script directory could not be found.")
    if path.exists(maindir) == False:
        fatal_error_msg("Working/output directory could not be found.")
    if path.exists(pref_file) == False:
        fatal_error_msg("No preference file could be found.")
    
        
    
    
    
    # Source the preferences file.  Is a bash script.
    #if source_file(pref_file) == False:
    #    fatal_error_msg("Cannot continue installing environment variables.")
    #else:
    #    print "Using preference file located at: " + pref_file
        
    # Now that the environment variables are set up (installed), parse
    # through them using `pref_variables`
    # Afterwards, make sure there wasn't an error.
    #prefpath = scriptdir + "bin/bash/pref_variables"
    #if source_file(prefpath) == False:
    #    fatal_error_msg("Cannot continue setting up environment variables.")
    #else:
    #    print "Finished parsing environment variables."
    #if not os.environ[""]
   
    
    # Finally, if everything went well, exit with status 0.
    sys.exit(0)


    
if __name__ == '__main__':
    main()

