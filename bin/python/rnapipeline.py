import sys
import os
import subprocess
import re
import ConfigParser
import shutil
from optparse import OptionParser
from optparse import OptionGroup

class Paths:
    # This is just an object that makes referencing the various directories
    # that are in use cleaner.
    # Everything except the bin directory and its subdirectories will be based
    # off of the root directory.
    
    def __init__(self,bin_dir, root_dir):
        self.bin = os.path.abspath(bin_dir)
        self.root = os.path.abspath(root_dir)
        
        # bin subdirectories
        self.bash = join(self.bin,"bash")
        self.perl = join(self.bin,"perl")
        self.python = join(self.bin,"python") 
        
        # root subdirectories
        self.output = join(self.root,"results")
    
        # output subdirectories
        self.backup = join(self.output,"references")
        self.blast = join(self.output,"blast")
        self.originals = join(self.output,"originals")
        self.logs = join(self.output,"raw_logs")
        self.tmp = join(self.output,"tmp")                
        
        # blast subdirectories
        self.blastoutput = join(self.blast,"blasts")
        self.blasttmp = join(self.blast, "tmp")
class Module:
    def __init__(self, name, req_vars, location):
        self.name = name
        self.var_list = req_vars
        self.location = location        
class ConfigFiles:
    # This is just an object that makes referencing the various files
    # that are in use cleaner.
    def __init__(self,default,user,backup):
        # Configuration files
        self.default_config = default
        self.user_config = user
        self.backup_config = backup

    # Utility functions
    def get_non_backup_config_files(self):
        return [self.default_config,self.user_config]
class Files:
    def __init__(self, paths, preferences):
        # Files from config:
        self.ref_strains = preferences["referencestrains"]
        self.blast_seq = preferences["blastsequences"]
        
        # Files to be backed up:
        self.ref_strains_backup = join(paths.backup,os.path.basename(self.ref_strains))
        self.blast_seq_backup = join(paths.backup,os.path.basename(self.blast_seq))
        
        # Files to be created
        self.input_seq_file = join(paths.output,"input_sequences")
        self.input_seq_list = join(paths.output, "input_sequences_list")
        self.good_seq_file = join(paths.blast,"good_sequences")
        self.blast_input_file = join(paths.blast,"blast_input")
        self.direction_blast = join(paths.blast,"direction_blast")
        self.final_log = join(paths.output,"pipeline.log")
def join(src,dest):  # Just use from os import path.join instead.
    return os.path.join(src,dest)
def fatal_error(msg):
    print >> sys.stderr, os.path.basename(__file__)+": ERROR! "+msg+". Exiting."
    sys.exit(1)   
def setup_paths_and_configs(options):    
    # bin and root directories
    # these look messy but it also makes sure that a full path is present
    m_paths = Paths(options.bin_dir,options.root_dir)
    m_configs = ConfigFiles(options.default_config_file,options.user_config_file,None)
    m_configs.backup_config = join(os.path.abspath(m_paths.backup),"used_preferences.conf")
    #m_files = Files(m_paths,m_configs)
    return m_paths, m_configs
def setup_configuration_files(config_location_list, m_paths):
    parser = ConfigParser.ConfigParser()
    parser.read(config_location_list)
    if parser.has_section("Preferences"):
        p = parser.items("Preferences")
    else:
        fatal_error("Could not find a preferences section in any configuration file")
    preferences = {}
    for (pref,value) in p:
        if value.find("$bin_dir") != -1:
            value = os.path.abspath(value.replace("$bin_dir",os.path.abspath(m_paths.bin))) 
        if value.find("$root_dir") != -1:
            value = os.path.abspath(value.replace("$root_dir",os.path.abspath(m_paths.root)))
        preferences[pref] = value        
    
    # Notifications should not be mandatory
    notifications = None
    if parser.has_section("Notifications"):
        n = parser.items("Notifications")
        notifications = {}
        for (note,value) in n:
            if (str(value)).find("True") != -1:
                value = True
            elif (str(value)).find("False") != -1:
                value = False

            notifications[note] = value
            
            
    return preferences, notifications
def setup_files(paths, preferences):
    return Files(paths, preferences)
def backup_configuration_file(preferences, notifications, backup_config_location):
    parser = ConfigParser.ConfigParser()
    parser.add_section("Preferences")
    parser.add_section("Notifications")
    
    for key,value in preferences.iteritems():
        parser.set("Preferences", key, value)
    for key,value in notifications.iteritems():
        parser.set("Notifications", key, value)
        
    fp = open(backup_config_location,"w")
    parser.write(fp)
    fp.close()                
def prepare_directory_structure(m_paths):
    shutil.rmtree(m_paths.output, ignore_errors=True)
    shutil.rmtree(m_paths.tmp, ignore_errors=True)
    
    os.mkdir(m_paths.output)
    os.mkdir(m_paths.backup)
    os.mkdir(m_paths.originals)
    os.mkdir(m_paths.blast)
    os.mkdir(m_paths.blastoutput)
    os.mkdir(m_paths.logs)
    os.mkdir(m_paths.tmp)
    os.mkdir(m_paths.blasttmp)
    #os.mkdir(m_paths.tmp)
    #os.mkdir(m_paths.tmplogs)
    #os.mkdir(m_paths.tmpblasts_linear)
def backup_file(src, dest):
    shutil.copy2(src, dest)
def get_qsub_notifications(notifications_list, initial, final):
    notifyString = ""
    if initial == True:
        if notifications_list["emailonbegin"] == True:
            notifyString += "b"
    if notifications_list["emailonabort"] == True:
        notifyString += "a"
    if final == True:
        if notifications_list["emailonend"] == True:
            notifyString += "e"
    if not notifyString:
        notifyString = "n"
    return notifyString
def module_list(pth,fil,prefs):
    # Returns a list of the modules and their required preferences
    # in the order that they need to be run.
    # Need to figure out how to handle linear vs parallel (check the preference
    # when appending the item to the list???).
    list = []
    list.append(Module("fasta_prep", 
                        [("SEQUENCE_DIR",prefs["inputsequences"]),
                        ("PERL_DIR",pth.perl),
                        ("ORIGINALS_DIR",pth.originals),
                        ("INPUT_SEQUENCE_LIST",fil.input_seq_list),
                        ("SUFFIX",prefs["suffix"])],
                        join(pth.bash,"fasta_files_prep.bash")
                        )
                )
    list.append(Module("get_good_seq",
                       [("SEQUENCE_DIR", prefs["inputsequences"]),
                        ("PERL_DIR", pth.perl),
                        ("BLAST_DIR", pth.blast),
                        ("INPUT_SEQUENCES_FILE", fil.input_seq_file),
                        ("GOOD_SEQUENCES_FILE", fil.good_seq_file),
                        ("SUFFIX", prefs["suffix"]),
                        ("DIRECTION", prefs["direction"]),
                        ("NPERCENT", prefs["npercent"]),
                        ("PRIMER3", prefs["primer3"]),
                        ("PRIMER5", prefs["primer5"]),
                        ("MINSEQLENGTH", prefs["minsequencelength"])],
                       join(pth.bash,"get_good_sequences.bash")                      
                       )
                )
    list.append(Module("blast_dir",
                       [("TEMP_DIR", pth.tmp),
                        ("PERL_DIR", pth.perl),
                        ("LOG_DIR",pth.logs),
                        ("BLAST_TEMP_DIR",pth.blasttmp),
                        ("GOOD_SEQUENCES_FILE", fil.good_seq_file),
                        ("DIRECTION_BLAST_FILE", fil.direction_blast),
                        ("BLAST_INPUT_FILE", fil.blast_input_file),
                        ("BLAST_SEQUENCES", prefs["blastsequences"]),
                        ("CUTOFF_LENGTH", prefs["cutofflength"])],
                       join(pth.bash,"blast_direction.bash")
                       )
                )
    list.append(Module("blastall",
                       [("BLAST_TEMP_DIR",pth.blasttmp),
                        ("BLAST_INPUT_FILE", fil.blast_input_file)],
                       join(pth.bash,"blastall.bash")
                       )
                )


    list.append(Module("finalize",
                       [("LOG_DIR",pth.logs),
                        ("FINAL_LOG",fil.final_log)],
                       join(pth.bash,"final_cleanup.bash")
                       )
                )
    
    
    return list
def generate_qsub_command(module,index,paths,prefs,notes,
                          id=None,array=False,initial=False,final=False):
    
    cmd = ["qsub"]
    cmd.append("-N")
    cmd.append(module.name)
    cmd.append("-j")
    cmd.append("oe")
    cmd.append("-o")
    cmd.append(join(paths.logs,str((index+1)).zfill(3)+"."+module.name+".log"))
    cmd.append("-m")
    cmd.append(get_qsub_notifications(notes,initial,final))
    cmd.append("-d")
    cmd.append(paths.output)
    cmd.append("-q")
    cmd.append("tiny")
    
    if id is not None:
        if final:
            cmd.append("-W depend=afterany:"+id)  # Final script is cleanup and we always want it to run.
        elif not array:
            cmd.append("-W depend=afterok:"+id)
        else:
            cmd.append("-W depend=afterokarray:"+id)
                
    if module.var_list:
        cmd.append("-v")
        #var_list = "-v "
        var_list = ""
        for (key,value) in module.var_list:
            var_list += key+"="+value+","
        var_list = var_list.rstrip(", ")
        cmd.append(var_list)
    
    cmd.append(module.location)    
    return cmd
def exec_qsub(cmd, verbose=False):
    if verbose:
        print "executing: "+str(cmd)
    #sys.exit(0)
    process = subprocess.Popen(cmd, stdout=subprocess.PIPE)
    out, err = process.communicate()
    id = re.split('[\.]{1}',out)[0]
    if verbose:
        print "qsub output:"
        print out
        print "id:"
        print id
    return id
def main():    
    # Set up an OptionParser object to make the command line arguments easy.
    # NOTE:  optparse has been deprecated since Python 2.7, but as of May 2013,
    #        the cluster is using Python 2.4.3. argparse should be used once
    #        a newer version of Python is in use.
    parser = OptionParser(usage="%prog [options] \n"
                          "Put a better description of what is required here.")
    parser.add_option("-p", "--pref", action="store", dest="user_config_file", help="the file where the your preferences are located (not the defaults) [default: %default]")
    parser.add_option("-r", "--root", action="store", dest="root_dir", help="the working directory where all output will be stored [default: %default]")
    adv_group = OptionGroup(parser, "Advanced Options", "Use these options at your own risk. Changing these options could cause the program to fail.")
    adv_group.add_option("-c", "--conf", action="store", dest="default_config_file", help="the file where the default preferences are located [default: %default]")
    adv_group.add_option("-b", "--bin", action="store", dest="bin_dir", help="the directory where the script directories are located [default: %default]")
    parser.add_option_group(adv_group)
    
    # Set up the defaults
    parser.set_default("bin_dir", os.path.abspath(join(os.path.dirname(os.path.abspath(__file__)),"..")))
    parser.set_default("root_dir", os.path.abspath(join(os.path.dirname(os.path.abspath(__file__)),"../..")))
    parser.set_default("default_config_file", os.path.abspath(join(os.path.dirname(os.path.abspath(__file__)),"../../etc/default_preferences.conf")))
    parser.set_default("user_config_file", os.path.abspath(join(os.path.dirname(os.path.abspath(__file__)),"../../usr/preferences/user_preferences.conf")))
    (options, remaining_arguments) = parser.parse_args()

    if len(remaining_arguments) > 0:
        # An incorrect number of arguments was given.  In this situation we can
        # either use the parser's built in error method that inevitably exits
        # or use our own.  Currently using the built in because I believe that it
        # would be better to error out now instead of after jobs have been queued.
        error_message = "There were an incorrect number of arguments passed.\n"
        error_message += "The argument(s) that couldn't be parsed were:\n"
        for arg in remaining_arguments:
            error_message += arg+"\n"
        error_message += "Please see the usage above and try again."
        parser.error(error_message)

    paths, configs = setup_paths_and_configs(options)
    preferences, notifications = setup_configuration_files(configs.get_non_backup_config_files(), paths)

    files = setup_files(paths, preferences)   
    prepare_directory_structure(paths)
    backup_configuration_file(preferences, notifications, configs.backup_config)
    backup_file(files.ref_strains,files.ref_strains_backup) # RefStrain
    backup_file(files.blast_seq,files.blast_seq_backup) # BlastSeq
    
    # Start forming the commands to call qsub with.    
    m_modules = module_list(paths,files,preferences)
    id = None
    for (index,mod_item) in enumerate(m_modules):
        first = False
        last = False
        if index == 0:
            first = True
        if index == [len(m_modules)-1]:
            last = True # This needs to eventually be true to call the cleanup.
        cmd = generate_qsub_command(mod_item, index, paths, preferences, notifications, id=id, initial=first, final=last)
        id = exec_qsub(cmd,verbose=True)
        snapshot = Module("snapshot-"+mod_item.name,
                          [("SOURCE",paths.root),
                           ("DEST", os.path.abspath(paths.root+"/../snapshots/snapshot-"+mod_item.name))],
                          join(paths.bash,"snapshot.bash"))
        cmd = generate_qsub_command(snapshot,index,paths,preferences,notifications,id=id,initial=False,final=False)         
        id = exec_qsub(cmd,verbose=True)
        
    sys.exit(0)
    
if __name__ == '__main__':
    main()

