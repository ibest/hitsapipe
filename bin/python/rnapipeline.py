from optparse import OptionParser
from optparse import OptionGroup
from os import path
from os import listdir
from os import unlink
from os import mkdir
from os import makedirs
import os
import sys
#from subprocess import call
import subprocess
import ConfigParser
import re
import commands
#import subprocess
import shutil


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
def expand_file(m_file):
    # Returns a fully expanded absolute path.
    # Requires os.path
    # Does not call fix directory.
    return path.abspath(path.expanduser(m_file))
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
def which(program):         # Currently not being used.
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
    if parser.has_section("Preferences"):    
        preferences = parser.items("Preferences")
    else:
        fatal_error_msg("No 'Notifications' section in configuration file.")
    if parser.has_section("Programs"):     
        programs = parser.items("Programs")
    else:
        fatal_error_msg("No 'Notifications' section in configuration file.")    
    if parser.has_section("Notifications"):
        notifications = parser.items("Notifications")
    else:
        fatal_error_msg("No 'Notifications' section in configuration file.")
    
    # Iterate through preferences and $scriptdir and $maindir with full paths.
    new_preferences = {}
    for (pref,value) in preferences:
        #value = re.sub("$scriptdir/",path.abspath(scriptdir),value)
        #value = re.sub("$maindir/",path.abspath(maindir),value)
        if value.find("$scriptdir") != -1:
            value = path.abspath(value.replace("$scriptdir",path.abspath(scriptdir)))
        if value.find("$maindir") != -1:    
            value = path.abspath(value.replace("$maindir",path.abspath(maindir)))
        #new_preferences.append((pref,value))
        new_preferences[pref] = value    
        
        
    # Iterate through programs and verify each exists.
    # Need to test the case that a location is expanded by re.sub and fails the which
    # command, that it still removes the item from the list properly.
    new_programs = {}     
    for (prog,loc) in programs:
        loc = re.sub("$scriptdir/",path.abspath(scriptdir),loc)
        loc = re.sub("$maindir/",path.abspath(maindir),loc)
        #print "(" + prog + "," + loc + ") = " + str(commands.getstatusoutput("which " + loc))
        if commands.getstatusoutput("which " + loc)[0] == 0: # [0] is the return value
        #if subprocess.call(["which",loc], stdout=subprocess.PIPE, stdin=subprocess.PIPE, stderr=subprocess.PIPE, shell=False) == 0: # Accomplishes the same thing as commands.getstatusoutput.
            #new_programs.append((prog,loc))
            new_programs[prog] = loc           
               
    new_notifications = {}
    for (key,value) in notifications:
        new_notifications[key] = value        
    # Return the preferences and programs.
    return new_preferences, new_programs, new_notifications
def write_configuration(programs, preferences, notifications, directory):
    
    parser = ConfigParser.ConfigParser()
    parser.add_section("Programs")
    parser.add_section("Preferences")
    parser.add_section("Notifications")
    
    for key,value in programs.iteritems():
        parser.set("Programs", key, value)
    for key,value in preferences.iteritems():
        parser.set("Preferences", key, value)
    for key,value in notifications.iteritems():
        parser.set("Notifications", key, value)
        
    fp = open(directory + "Preferences.conf","w")
    parser.write(fp)
    fp.close()
    
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
def empty_directory(folder_path):                       # Currently not being used
    # This will delete everything inside a folder, but not delete the folder itself
    # Currently this may error out on symbolic links (untested), but we shouldn't be
    # running into any.
    # Stolen from StackOverflow: http://stackoverflow.com/questions/185936/delete-folder-contents-in-python
    for file_object in listdir(folder_path):
        file_object_path = path.join(folder_path, file_object)
        if path.isfile(file_object_path):
            unlink(file_object_path)
        else:
            shutil.rmtree(file_object_path)

def execute_command(path_to,command):                           # Just a wrapper to make the call cleaner
    return subprocess.call(os.path.join(path_to,command), shell=False)
def execute_command(path_to,command, options):
    return subprocess.call(os.path.join(path_to,command) + " " + options, shell=False)
    

def main():
    
    # Set up the parser that will see what options are set.
    parser = OptionParser(usage="%prog [options] \n"
                          "This program doesn't require any options to run "
                          "if the default locations are used (based on where this program is being executed from):\n"
                          "\tUser Preference file:\t " + expand_file("../../usr/preferences/preferences.conf") + "\n"
                          "\tSequences directory:\t " + expand_dir("../../usr/sequences/"), version="%prog 0.2")#, epilog="Last modified 22 May 2013")

    parser.add_option("-p", "--pref", action="store", dest="pref_file", default="../../usr/preferences/preferences.conf", help="file where the preferences are located")
    parser.add_option("-s", "--seq", "--input", action="store", dest="seq_dir", default="../../usr/sequences/", help="set the directory where the input sequences are; default is inside usr directory")
    parser.add_option("-v", "--verbose", action="store_true", dest="verbose", default=True, help="if true, displays all standard output (errors will also be displayed)")
    parser.add_option("-q", "--quiet", action="store_false", dest="verbose", help="if true, hides all standard output (errors will still be displayed)")

    dangerous_group = OptionGroup(parser, "Hazardous Options",
                                        "These options can been overridden, "
                                        "typically without consequence, but if errors arise, "
                                        "using the default is recommended.")

    dangerous_group.add_option("-m", "--main", "--root", action="store", dest="root_dir", default="../../", help="set the working directory where all output is")
    dangerous_group.add_option("-r", "--results", action="store", dest="results_dir", help="set the directory where results will be stored; default will be based on the program's root directory")
    
    adv_group = OptionGroup(parser, "Advanced Options",
                            "Use these options at your own risk.  "
                            "Changing these options can cause the program to fail.  "
                            "It is best to use the default in this case.")
    adv_group.add_option("--script", action="store", dest="script_dir", default="../", help="set the directory where the scripts are located\nWARNING: The default folders are based on where this directory is defined; changing this is NOT recommended!!")
    adv_group.add_option("--conf", action="store", dest="conf_file", default="../../etc/defaults.conf", help="specify the default configuration (preferences) file")

    parser.add_option_group(dangerous_group)
    parser.add_option_group(adv_group)

    
    (options, args) = parser.parse_args()
    if len(args) > 0:
        parser.error("incorrect number of arguments")
    
    # Set up variables from options
    
    # Dictionaries to hold the directories and files
    paths = {}
    files = {}
    
    
    paths["bin"] = expand_dir(options.script_dir)
    paths["root"] = expand_dir(options.root_dir)
    paths["seq"] = expand_dir(options.seq_dir)
    
    files["user_config"] = expand_file(options.pref_file)
    files["default_config"] = expand_file(options.conf_file)
    
    verbose = options.verbose
    #bin_dir = expand_dir(options.script_dir)
    #root_dir = expand_dir(options.root_dir)
    #seq_dir = expand_dir(options.seq_dir)
    #pref_file = expand_file(options.pref_file)
    #conf_file = expand_file(options.conf_file)
    #verbose = options.verbose
    
    # Set up the conditional variables  
    if options.results_dir != None:
        paths["results"] = expand_dir(options.results_dir)
    else:
        paths["results"] = expand_dir(options.script_dir + "../results/")

        
    # Set up other directory variables
    paths["etc"] = expand_dir(options.script_dir + "../etc/")     # More than likely won't be used.
    paths["tmp"] = expand_dir(options.script_dir + "../tmp/")  # Could also put in /results/tmp/
    paths["bash"] = expand_dir(options.script_dir + "bash")
    paths["perl"] = expand_dir(options.script_dir + "perl")
    paths["python"] = expand_dir(options.script_dir + "python")
    # Output directories:
    paths["backup"] = expand_dir(paths["results"] + "references/")    
    paths["originals"] = expand_dir(paths["results"] + "originals/")
    paths["output"] = expand_dir(paths["results"] + "output/")
    paths["blast"] = expand_dir(paths["results"] + "blast/")
    paths["blasts_linear"] = expand_dir(paths["blast"] + "blasts_linear/")
    paths["blasts_parallel"] = expand_dir(paths["blast"] + "blasts_parallel/")
    
    # Set up specific files that will be needed
    files["good_sequences"] = expand_file(paths["blast"] + "good_sequences")
    files["input_sequences_list"] = expand_file(paths["tmp"] + "input_files")
    files["collated_list"] = expand_file(paths["backup"] + "collated_list")
    files["blast_input"] = expand_file(paths["blast"] + "blast_input")
    
    
    #execute_command(paths["bash"],"load_modules.bash")
    
    
    
    # Temporary printing of directories
    if verbose == True:
        print "Main directory: \t\t" + paths["root"]
        print "Script directory: \t\t" + paths["bin"]
        print "Preferences File: \t\t" + files["user_config"]
        print "Configuration File: \t\t" + files["default_config"]
        print ""
        print "Config (etc) directory: \t" + paths["etc"]
        print "Results (results) directory: \t" + paths["results"]
        print "Backup (references) directory: \t" + paths["backup"]
        print "Working (tmp) directory: \t" + paths["tmp"]
        print "Sequences (seq) directory: \t" + paths["seq"]
        print ""
        #print "Concatenation  : \t" + path.abspath(bin_dir+"///..///etc/////defaults.conf")    
    # End of parser
    
    # Make sure all the files at least exist.
    if path.exists(paths["bin"]) == False:
        fatal_error_msg("Script directory could not be found.")
    if path.exists(paths["root"]) == False:
        fatal_error_msg("Working/output directory could not be found.")
    if path.exists(files["user_config"]) == False:                                 # In the final version, this check should be removed.
        fatal_error_msg("Preferences file could not be found.") 
    if path.exists(files["default_config"]) == False:                                 # In the final version, this check could also be removed.
        fatal_error_msg("Default configuration file could not be found.")
        
    preferences, programs, notifications = configure(files["default_config"],files["user_config"],paths["bin"],paths["root"])
    
    # Make sure that all the requisite preferences have been defined.
    if set(preferences).issuperset(required_preferences()) == False:
        missing = "" 
        for item in (set(required_preferences()) - set(get_keys(preferences))):
            missing += item + ", "
        fatal_error_msg("Missing required preference(s): " + missing.rstrip(", ") + ".")
    # Make sure that all the requisite programs are set and exist.
    if set(programs).issuperset(required_programs()) == False:
        missing = "" 
        for item in (set(required_programs()) - set(get_keys(programs))):
            missing += item + ", "
        fatal_error_msg("Missing required programs(s): " + missing.rstrip(", ") + ".")

    ## Remove traces of previous run, setup current run
    # Remove previous run
    shutil.rmtree(paths["results"], ignore_errors = True)
    shutil.rmtree(paths["tmp"], True)
    
    # Setup current run
    mkdir(paths["results"])
    mkdir(paths["backup"])
    mkdir(paths["tmp"])
    mkdir(paths["originals"])
    mkdir(paths["blast"])
    
    
    # Print out the settings and also save as a configuration file
    if verbose == True:
        print "Using the following settings:\n"
        for key,value in preferences.iteritems():
            #print '{0:25}{1:10}'.format(key, value) # Prints a crudely-formatted list
            print key + "\t\t\t\t" + value
    
    # Write the configuration options that we're using to file
    # as a reference.
    # Then copy the reference strains and blast sequences to the backup
    # directory as well.
    write_configuration(programs, preferences, notifications, paths["backup"])
    shutil.copy2(preferences["referencestrains"], paths["backup"])
    shutil.copy2(preferences["blastsequences"], paths["backup"])
    
    command = os.path.join(paths["bash"], "prepare_fasta_files.bash")
    arg_list = [command, paths["seq"], paths["perl"], files["collated_list"], paths["originals"], preferences["suffix"]] # collated_list is never used again
    #print "Command: " + command + "\n"
    success = subprocess.call(arg_list)
    print "Prepare Fasta Files Script, Success = " + str(success)
    
    command = os.path.join(paths["bash"], "good_sequences.bash")
    arg_list = [command, paths["seq"], paths["perl"], files["input_sequences_list"],paths["blast"],preferences["suffix"],preferences["direction"], preferences["npercent"], preferences["primer3"], preferences["primer5"], preferences["minsequencelength"], files["good_sequences"]]
    success = subprocess.call(arg_list)
    print "Get Good Sequences, Success = " + str(success)
    
    command = os.path.join(paths["bash"], "prepare_for_blast.bash")
    arg_list = [command, files["good_sequences"]]
    success = subprocess.call(arg_list)
    print "Prepare for Blast, Success = " + str(success)
    
    command = os.path.join(paths["bash"], "blast_direction.bash")
    arg_list = [command, files["good_sequences"], preferences["blastsequences"]]
    success = subprocess.call(arg_list)
    print "Blast Direction, Success = " + str(success)        
    # Finally, if everything went well, exit with status 0.
    sys.exit(0)


    
if __name__ == '__main__':
    main()

