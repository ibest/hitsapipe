from optparse import OptionParser
from optparse import OptionGroup
from os import path
import sys
#from subprocess import call
import subprocess
import ConfigParser
import re
import commands
#import subprocess

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
        success = subprocess.call(["source",m_path])
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
def which(program):
    import os
    def is_exe(fpath):
        return os.path.isfile(fpath) and os.access(fpath, os.X_OK)

    fpath, fname = os.path.split(program)
    if fpath:
        if is_exe(program):
            return program
    else:
        for path in os.environ["PATH"].split(os.pathsep):
            path = path.strip('"')
            exe_file = os.path.join(path, program)
            if is_exe(exe_file):
                return exe_file

    return None

def configure(default_file, user_file, scriptdir, maindir):
    parser = ConfigParser.ConfigParser()
    parser.read([default_file,user_file])
    
    preferences = parser.items("Preferences")
    programs = parser.items("Programs")
    
    # Iterate through preferences and $scriptdir and $maindir with full paths.
    for (pref,value) in preferences:
        value = re.sub("$scriptdir/",path.abspath(scriptdir),value)
        value = re.sub("$maindir/",path.abspath(maindir),value)
        
    # Iterate through programs and verify each exists.
    # Need to test the case that a location is expanded by re.sub and fails the which
    # command, that it still removes the item from the list properly.
    new_programs = []     
    for (prog,loc) in programs:
        loc = re.sub("$scriptdir/",path.abspath(scriptdir),loc)
        loc = re.sub("$maindir/",path.abspath(maindir),loc)
        #print "(" + prog + "," + loc + ") = " + str(commands.getstatusoutput("which " + loc))
        if commands.getstatusoutput("which " + loc)[0] == 0: # [0] is the return value
        #if subprocess.call(["which",loc], stdout=subprocess.PIPE, stdin=subprocess.PIPE, stderr=subprocess.PIPE, shell=False) == 0: # Accomplishes the same thing as commands.getstatusoutput.
            new_programs.append((prog,loc))
            
    # Return the preferences and programs.
    return preferences, new_programs
    
    
    
def get_keys(tuple_list):
    key_list = []
    for (key,value) in tuple_list:
        key_list.append(key)
    return key_list
        
def required_preferences():
    # This is simply a list of the required preferences.
    # If these preferences are not defined, then the program should terminate.
    # This will be called by get_preferences to make sure all preferences are accounted for. 
    return ["execution","clustalexecution","npercent","direction","suffix","nhits","nnodes","root","primer3","primer5","database","referencestrains","blastsequences","maxblastcount","cutofflength","minsequencelength"]    
def required_programs():
    # This is simply a list of the required preferences.
    # If these preferences are not defined, then the program should terminate.
    # This will be called by get_preferences to make sure all preferences are accounted for.
    return ["blastall","formatdb","dnadist","neighbor","seqret"]
    
    
    

def main():
    
    # Set up the parser that will see what options are set.
    parser = OptionParser(usage="%prog [options]", version="%prog 0.1", epilog="Last modified 11 April 2013")
   
    parser.add_option("-m", "--main", action="store", dest="maindir", default="../../", help="set the working directory where all output is")
    parser.add_option("-p", "--pref", action="store", dest="pref_file", default="../../usr/preferences/preferences.conf", help="file where the preferences are located") # Should this not have a default?

    adv_group = OptionGroup(parser, "Advanced Options",
                            "Use these options at your own risk.  "
                            "Changing these options can cause the program to fail.  "
                            "It is best to use the default in this case.")
    adv_group.add_option("-s", "--script", action="store", dest="scriptdir", default="../", help="set the directory where the scripts are located")
    adv_group.add_option("-c", "--conf", action="store", dest="conf_file", default="../../etc/defaults.conf", help="specify the default configuration (preferences) file")
    parser.add_option_group(adv_group)

    
    (options, args) = parser.parse_args()
    
    if len(args) > 0:
        parser.error("incorrect number of arguments")
    
    # Set up local variables.  Decide if I wanted to use this or not.
    scriptdir = expand_dir(options.scriptdir)
    maindir = expand_dir(options.maindir)
    pref_file = expand_file(options.pref_file)
    conf_file = expand_file(options.conf_file)
    
    print "Main directory: \t" + maindir
    print "Script directory: \t" + scriptdir
    print "Preferences File: \t" + pref_file
    print "Configuration File: \t" + conf_file
    #print "Concatenation  : \t" + path.abspath(scriptdir+"..///etc/////defaults.conf")
    
    # End of parser
    
    # Make sure all the files at least exist.
    if path.exists(scriptdir) == False:
        fatal_error_msg("Script directory could not be found.")
    if path.exists(maindir) == False:
        fatal_error_msg("Working/output directory could not be found.")
    if path.exists(pref_file) == False:                                 # In the final version, this check should be removed.
        fatal_error_msg("Preferences file could not be found.") 
    if path.exists(conf_file) == False:
        fatal_error_msg("Default configuration file could not be found.")
        
    preferences, programs = configure(conf_file,pref_file,scriptdir,maindir)
    
    # Make sure that all the requisite preferences have been defined.
    if set(get_keys(preferences)).issuperset(required_preferences()) == False:
        missing = "" 
        for item in (set(required_preferences()) - set(get_keys(preferences))):
            missing += item + ", "
        fatal_error_msg("Missing required preference(s): " + missing.rstrip(", ") + ".")
    # Make sure that all the requisite programs are set and exist.
    if set(get_keys(programs)).issuperset(required_programs()) == False:
        missing = "" 
        for item in (set(required_programs()) - set(get_keys(programs))):
            missing += item + ", "
        fatal_error_msg("Missing required programs(s): " + missing.rstrip(", ") + ".")
    
    
    
    
    ## 
    
    
    
    # Finally, if everything went well, exit with status 0.
    sys.exit(0)


    
if __name__ == '__main__':
    main()

