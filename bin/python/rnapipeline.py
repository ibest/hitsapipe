#!/usr/bin/env python
import sys
import os
import subprocess
import re
import ConfigParser
import shutil
import time
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
        self.output = join(self.root,"output")
    
        # output subdirectories
        self.backup = join(self.output,"references")
        self.blast = join(self.output,"blast")
        self.originals = join(self.output,"originals")
        self.logs = join(self.output,"raw_logs")
        self.tmp = join(self.output,"tmp")
        self.clustaloutput = self.hitoutput = join(self.output,"results")
        self.clustaltmp = join(self.clustaloutput,"tmp")
                        
        
        # blast subdirectories
        self.blastoutput = join(self.blast,"blasts")
        self.blasttmp = join(self.blast, "tmp")
class Module:
    def __init__(self, name, req_vars, location, array_job=False):
        self.name = name
        self.var_list = req_vars
        self.location = location
        self.array_job = array_job        
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
        self.numseqs_tmp = join(paths.tmp, "numseqs.tmp")
        self.blastout5 = join(paths.blast,"blastout5")
        self.hitseqs = join(paths.clustaloutput,"hitseqs")
        self.hitfiles = join(paths.clustaloutput,"hitfiles")
        self.clustal = join(paths.clustaloutput,"clustal")
        self.clustal_all = join(paths.clustaloutput,"clustal_all")
        self.clustal_align = join(paths.clustaloutput,"clustal_all.aln")
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
        if value.find("$output_dir") != -1:
            value = os.path.abspath(value.replace("$output_dir",os.path.abspath(m_paths.output)))
        if (str(value)).find("True") != -1:
            value = True
        elif (str(value)).find("False") != -1:
            value = False

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
def prepare_directory_structure(m_paths, m_prefs):
    shutil.rmtree(m_paths.output, ignore_errors=True)
    shutil.rmtree(m_paths.tmp, ignore_errors=True)
    
    if os.path.exists(m_prefs["arrayjoblogfile"]):
        os.remove(m_prefs["arrayjoblogfile"])
    
    os.mkdir(m_paths.output)
    os.mkdir(m_paths.backup)
    os.mkdir(m_paths.originals)
    os.mkdir(m_paths.blast)
    os.mkdir(m_paths.blastoutput)
    os.mkdir(m_paths.logs)
    os.mkdir(m_paths.tmp)
    os.mkdir(m_paths.blasttmp)
    os.mkdir(m_paths.clustaloutput)
    
    #os.mkdir(m_paths.clustaltmp)
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
    #return notifyString
    return "n" # Overriding settings
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
                        ("NUMSEQS_TEMP_FILE", fil.numseqs_tmp),
                        ("BLAST_SEQUENCES", prefs["blastsequences"]),
                        ("CUTOFF_LENGTH", prefs["cutofflength"])],
                       join(pth.bash,"blast_direction.bash")
                       )
                )
    list.append(Module("blast_arr_prep",
                       [("BLAST_TEMP_DIR", pth.blasttmp),
                        ("BLAST_INPUT_FILE", fil.blast_input_file),
                        ("ARRAY_OUTPUT_FILE",prefs["arrayjoblogfile"])],
                       join(pth.bash,"blastall_array_prep.bash")
                       )
                )
    list.append(Module("blastall_array",
                       [("BLAST_TEMP_DIR",pth.blasttmp),
                        ("BLASTALL_OUTPUT_DIR", pth.blastoutput),
                        ("DATABASE", prefs["database"]),
                        ("NHITS", prefs["nhits"])],
                       join(pth.bash,"blastall_array.bash"),
                       array_job=True
                       )
                )
    list.append(Module("blastall_check",
                       [("BLASTALL_OUTPUT_DIR", pth.blastoutput),
                        ("BLAST_INPUT_FILE", fil.blast_input_file),
                        ("NUMSEQS_TEMP_FILE", fil.numseqs_tmp)],
                       join(pth.bash,"blastall_check.bash")
                       )
                )
    list.append(Module("blastall_hits",
                       [("PERL_DIR", pth.perl),
                        ("BLASTALL_OUTPUT_DIR", pth.blastoutput),
                        ("HIT_OUTPUT_DIR",pth.hitoutput),
                        ("DATABASE", prefs["database"]),
                        ("BLAST_OUT_5_FILE", fil.blastout5),
                        ("HIT_SEQS_FILE", fil.hitseqs),
                        ("HIT_FILE",fil.hitfiles)],
                       join(pth.bash,"blastall_hits.bash")
                       )
                )    
    
    ##### Untested Modules here #####
    


    list.append(Module("clustal_prep",
                       [("PERL_DIR", pth.perl),
                        ("CLUSTAL_OUTPUT_DIR", pth.clustaloutput),
                        ("BLAST_TEMP_DIR", pth.blasttmp),
                        ("CLUSTAL_TEMP_DIR", pth.clustaltmp),
                        ("ARRAY_OUTPUT_FILE",prefs["arrayjoblogfile"]),
                        ("REF_STRAINS_FILE", prefs["referencestrains"]),
                        ("CLUSTAL_FILE", fil.clustal),
                        ("CLUSTAL_ALL_FILE", fil.clustal_all),
                        ("BLAST_INPUT_FILE", fil.blast_input_file),
                        ("HIT_FILE", fil.hitfiles)],
                       join(pth.bash,"clustal_prep.bash")
                       )
                )
    list.append(Module("clustal",
                       [("CLUSTAL_ALL_FILE", fil.clustal_all),
                        ("CLUSTAL_ALIGNMENT_FILE", fil.clustal_align)],
                       join(pth.bash,"clustal_run.bash")
                       )
                )
    list.append(Module("clustal_check",
                       [("CLUSTAL_ALIGNMENT_FILE", fil.clustal_align)],
                       join(pth.bash,"clustal_check.bash")
                       )
                )
    '''
    list.append(Module("alignment",
                       [("PERL_DIR", pth.perl),
                        ("CLUSTAL_OUTPUT_DIR", pth.clustaloutput),
                        ("CLUSTAL_ALIGNMENT_FILE", fil.clustal_alignment),
                        ("PHYLIP_IN_FILE", fil.phylip_in)],
                       join(pth.bash,"alignment.bash")
                       )
                )
    list.append(Module("dist_matrix",
                       [("DNADIST_SCRIPT", fil.dnadist),
                        ("CLUSTAL_OUTPUT_DIR", pth.clustaloutput),
                        ("DISTANCES_FILE", fil.distances),
                        ("PHYLIP_IN_FILE", fil.phylip_in)],
                       join(pth.bash,"distance_matrix.bash")
                       )
                )
    list.append(Module("neighbor",
                       [("PERL_DIR", fil.dnadist),
                        ("NEIGHBOR_DIR", pth.neighbor),
                        ("NEIGHBOR_ROOT", prefs["root"]),
                        ("CLUSTAL_OUTPUT_DIR", pth.clustaloutput)],
                       join(pth.bash,"neighbor_run.bash")
                       )
                )
        
    '''


    list.append(Module("finalize",
                       [("LOG_DIR",pth.logs),
                        ("FINAL_LOG",fil.final_log)],
                       join(pth.bash,"final_cleanup.bash")
                       )
                )
    
    
    return list
def generate_non_qsub_command(module,paths,files,prefs):
    #cmd = ["PBS_O_WORKDIR="+paths.output]
    
    cmd = "PBS_O_WORKDIR="+paths.output+" "
    if module.var_list:
        for(key,value) in module.var_list:
            #cmd.append(str(key+"="+value))
            cmd += str(key+"="+value+" ")
    
    #cmd.append(module.location)
    cmd += str(module.location)
    #cmd += " "
    #cmd += "> "+str(join(paths.logs,module.name+".log"))
    
    return cmd
    
def generate_qsub_command(module, index, paths, files, prefs, notes, 
                          arr_count=None, id=None, previous_array=False,  
                          initial=False,final=False):
    
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
    if arr_count is not None:
        arr_count -= 1
        cmd.append("-t")
        cmd.append("0-"+str(arr_count))
        arr_count += 1 # This isn't necessary

    # Eventually this should check if there's a job dependency.
    if id is not None:
        if previous_array:
            if final:
                cmd.append("-W depend=afteranyarray:"+id)  # Final script is cleanup and we always want it to run.
            else:
                cmd.append("-W depend=afterokarray:"+id)  # Final script is cleanup and we always want it to run.
        else:
            if final:
                cmd.append("-W depend=afterany:"+id)
            else:
                cmd.append("-W depend=afterok:"+id)            
                
    if module.var_list:
        cmd.append("-v")
        var_list = ""
        for (key,value) in module.var_list:
            var_list += key+"="+value+","
        var_list = var_list.rstrip(", ")
        cmd.append(var_list)
    
    cmd.append(module.location)    
    return cmd
def exec_qsub(cmd, mod_name=None, verbose=False):
    process = subprocess.Popen(cmd, stdout=subprocess.PIPE)
    out, err = process.communicate()
    id = re.split('[\.]{1}',out)[0]
    #id = re.split('[\n]{1}',out)[0]
    if verbose:
        if mod_name is not None:
            print mod_name + " submitted. ID: "+str(id)
        else:
            print "id:"+str(id)
    return id
def wait_to_exec_array(filepath):
    # Since we currently have no way of having a node call qsub itself,
    # in the event that we want to create an array job and don't know the
    # number of elements in the array until part of the job has finished,
    # we need to wait until the process that determines the number of jobs
    # in the array finishes and then create the array job.
    while os.path.exists(filepath) is not True:
        time.sleep(10)
        
    file = open(filepath, "r")
    arr_count = file.readline()
    arr_count = str(arr_count).strip()
    
    
    os.remove(filepath)
    
    return int(arr_count) # If arr_count isn't an integer it will return 0.        

def finish_exec_array(arr_count, base_id):
    # A job following an array job must have an array dependency as well.
    # So instead, we wait for the job to finish and then move on to the next
    # job.
    # First make a list of the values to check.
    # Then, iterate over that list.
    # Loop this action until all processes are completed.
    
    devnull = open('/dev/null', 'w')
    completed_list = [False]*(arr_count)
    done = False
    
    print "Waiting for array job to finish before continuing..."
    time.sleep(2) # This sleep is to prevent a qstat output error from appearing.
    while(done is False):
        for (index,value) in enumerate(completed_list):
            cmd = "qstat -f " + str(base_id) + "[" + str(index) + "] | grep \"job_state = C\""
            #print "finish_exec cmd: " + str(cmd) 
            retval = subprocess.call(cmd, shell=True, stdout=devnull)
            if retval == 0:
                completed_list[index] = True
            else:
                time.sleep(10)
                break
        for (index,value) in enumerate(completed_list):
            done = True
            if completed_list[index] is False:
                done = False
                break
    devnull.close()
    
    print "Array job completed.  Continuing."
    return True

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
    prepare_directory_structure(paths, preferences)
    backup_configuration_file(preferences, notifications, configs.backup_config)
    backup_file(files.ref_strains,files.ref_strains_backup) # RefStrain
    backup_file(files.blast_seq,files.blast_seq_backup) # BlastSeq
    
    # Start forming the commands to call qsub with.    
    qsub_process = subprocess.Popen(["which","qsub"], stdout=subprocess.PIPE, stdin=subprocess.PIPE, stderr=subprocess.PIPE, shell=False)
    qsub_process.communicate()  # Don't assign to anything, don't care about output
      
    
    m_modules = module_list(paths,files,preferences)
    id = None
    
    
    
    if qsub_process.returncode == 0 and preferences["runstandaloneonly"] is False:
        for (index,mod_item) in enumerate(m_modules):
            first = False
            last = False
            arr_count = None
            is_prev_array = False
            if index == 0:
                first = True
            if index == (len(m_modules)-1):
                last = True # This needs to eventually be true for notifications
            if mod_item.array_job is True:
                # Then we need to wait until the array count is available in order
                # to continue.
                arr_count = wait_to_exec_array(preferences["arrayjoblogfile"])
                id = None # Set this to none, because the previous job will be done before this gets called.
                if arr_count <= 0:
                    fatal_error("Something went wrong when trying to create an array job")
                    
                if index > 0:
                    if m_modules[index - 1].array_job is True:
                        is_prev_array = True
                
                cmd = generate_qsub_command(mod_item, index, paths, files, 
                            preferences, notifications, 
                            arr_count=arr_count, id=id, 
                            previous_array=is_prev_array, 
                            initial=first, final=last)
                
                id = exec_qsub(cmd,mod_item.name,verbose=True)
                id = re.split('[[\.]{1}',id)[0]
                
                # Need to wait here for job to finish before starting next one.
                #array_wait_cmd = [join(paths.bash,"test_output.sh"),id , (arr_count - 1)]
                #array_wait_cmd = str(join(paths.bash,"test_output.sh")) + " " + str(id) + " " + str((arr_count - 1))
                finish_exec_array(arr_count, id)
                id = None # We don't want to have a job dependency.

            if mod_item.array_job is not True:  
                if index > 0:
                    if m_modules[index - 1].array_job is True:
                        is_prev_array = True
                
                cmd = generate_qsub_command(mod_item, index, paths, files, 
                                            preferences, notifications, 
                                            arr_count=arr_count, id=id, 
                                            previous_array=is_prev_array, 
                                            initial=first, final=last)
                
                id = exec_qsub(cmd,mod_item.name,verbose=True)
    else:
         for (index,mod_item) in enumerate(m_modules):
             # Will need to test if something is an array job and somehow call it
             # for every job.
             # For now just halt.
             #first = False
             #last = False
             
             #if index == 0:
             #    first = True
             #if index == (len(m_modules)-1):
             #    last = True             
             #print "Index: "+str(index)+"| is first? "+str(first)+"| is last? "+str(last)
             if mod_item.array_job is True:
                 # Here just call the module over and over again with $PBS_ARRAYID
                 # set as the index that it should be.
                 fatal_error("Cannot handle array jobs currently")
             cmd = generate_non_qsub_command(mod_item, paths, files, preferences)
             process = subprocess.Popen(cmd,executable="/bin/bash", shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
             
             out, err = process.communicate()
             
             if out is not None:
                 print str(out)
             if err is not None:
                 print str(err)
                 
             log = open(join(paths.logs,mod_item.name+".log"),"w")
             log.writelines(out)
             log.writelines(err)
             log.close()
             
             if process.returncode is not 0:
                 fatal_error("The module \""+mod_item.name+"\" failed")           
    sys.exit(0)
    
if __name__ == '__main__':
    main()

