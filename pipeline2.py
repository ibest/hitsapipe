#!/usr/bin/env python
import sys
import ConfigParser
from optparse import OptionParser
from optparse import OptionGroup
import os
import shutil
import subprocess
import re
import time
class Pipeline:
    '''
    This class will construct a pipeline object
    based on configuration files.  Use the
    run() function to execute the script.
    
    '''
    #__fatal_error = False
    def __init__(self, cli_options):
        self.__fatal_error = False
        self.params = {}
        self.params = self.__configure(cli_options)
        self.__validate()
        self.directories = self.__get_directories()
        self.preferences = self.__get_preferences()
        self.static_vars = self.__get_static_vars()
        self.qsub_options = self.__get_qsub_options()
        self.type = self.preferences['Execution']

        if self.params['debug']:        
            print "Directories:"
            for (k,v) in self.directories.iteritems():
                print "\t"+str(k)+": "+str(v)
            print "Preferences:"
            for (k,v) in self.preferences.iteritems():
                print "\t"+str(k)+": "+str(v)
            print "Static Variables:"
            for (k,v) in self.static_vars.iteritems():
                print "\t"+str(k)+": "+str(v)
            print "qsub Options:"
            for (k,v) in self.qsub_options.iteritems():
                print "\t"+str(k)+": "+str(v)
                
        self.__setup_directory_structure()
    def run(self):
        if not self.__check_for_fatal():
            print "Pipeline successfully configured."
            print "Preparing to execute."      
        
        self.__backup_configuration()
        
        id = self.run_pipeline_prep(id=None, options=None)
        id = self.run_fasta_prep(id, options=None)
        id = self.run_get_good_seqs(id, options=None)
        id = self.run_blast_dir(id, options=None)
        id = self.run_blast_arr_prep(id, options=None)
        id = self.run_blast_arr(id, options=None)
        id = self.run_blast_arr_check(id, options=None)
        id = self.run_blastall_hits(id, options=None)
        id = self.run_clustal_prep(id, options=None)
        id = self.run_clustal(id, options=None)
        id = self.run_clustal_check(id, options=None)
        id = self.run_alignment(id, options=None)
        id = self.run_dist_matrix(id, options=None)
        id = self.run_neighbor(id, options=None)
        id = self.run_finalize(id, options=None)
        
                
        return 0
    def run_pipeline_prep(self, id=None, options=None):
        # No local variables to pass
        variables = {}
        
        cmd_options = {
            'name':             "pipeline_prep",
            'log':              os.path.join(self.directories['logs'], 
                                             "pipeline_prep.log"),
            'variables':        variables,
            'script_location':  os.path.join(self.directories['scripts'], 
                                             "pipeline_prep.sh")
        }
        cmd = self.__get_command(cmd_options)
        return self.execute_job(cmd, cmd_options)
    def run_fasta_prep(self, id=None, options=None):
        variables = {
            'Input_Sequences_List':         os.path.join(
                                                self.directories['blast_input'],
                                                "input_sequences_list")
        }
        
        cmd_options = {
            'name':                         "fasta_prep",
            'log':                          os.path.join(
                                                self.directories['logs'], 
                                                "fasta_prep.log"),
            'variables':                    variables,
            'previous_id':                  id,
            'script_location':              os.path.join(
                                                self.directories['scripts'], 
                                                "fasta_files_prep.sh")
        }
        cmd = self.__get_command(cmd_options)
        return self.execute_job(cmd, cmd_options)
    def run_get_good_seqs(self, id=None, options=None):
        variables = {
#            'Good_Sequences_File':              os.path.join(
#                                                self.directories['blast_input'],
#                                                "good_sequences"),
            'Input_Sequences_File':             os.path.join(
                                                self.directories['blast_input'],
                                                "input_sequences")
        }
        
        cmd_options = {
            'name':                         "get_good_seqs",
            'log':                          os.path.join(
                                                self.directories['logs'], 
                                                "get_good_sequences.log"),
            'variables':                    variables,
            'previous_id':                  id,
            'script_location':              os.path.join(
                                                self.directories['scripts'], 
                                                "get_good_sequences.sh")
        }
        cmd = self.__get_command(cmd_options)
        return self.execute_job(cmd, cmd_options)
    def run_blast_dir(self, id=None, options=None):
        variables = {
            'Direction_Blast_File':         os.path.join(
                                                self.directories['blast'],
                                                "direction_blast")
        }
        
        cmd_options = {
            'name':                         "blast_direction",
            'log':                          os.path.join(
                                                self.directories['logs'], 
                                                "blast_direction.log"),
            'variables':                    variables,
            'previous_id':                  id,
            'parallel':                     True,
            'script_location':              os.path.join(
                                                self.directories['scripts'], 
                                                "blast_direction.sh")
        }
        cmd = self.__get_command(cmd_options)
        return self.execute_job(cmd, cmd_options)
    def run_blast_arr_prep(self, id=None, options=None):
        if self.type != "Parallel":
            return id # Or return None
        # No local variables to pass
        variables = {}
        cmd_options = {
            'name':                 "blast_arr_prep",
            'log':                  os.path.join(self.directories['logs'], 
                                                "blastall_array_prep.log"),
            'variables':            variables,
            'parallel':             True,
            'previous_id':          id,
            'script_location':      os.path.join(self.directories['scripts'], 
                                                "blastall_array_prep.sh")
        }
        cmd = self.__get_command(cmd_options)
        return self.execute_job(cmd, cmd_options)
    def run_blast_arr(self, id=None, options=None):
        # No local variables to pass
        variables = {}
        cmd_options = {
            'name':                 "blast_arr",
            'log':                  os.path.join(self.directories['logs'], 
                                                "blastall_array.log"),
            'variables':            variables,
            'array':                True,
            'parallel':             True,
            'previous_id':          id,
            'script_location':      os.path.join(self.directories['scripts'], 
                                                "blastall_array.sh")
        }
        cmd = self.__get_command(cmd_options)
        return self.execute_job(cmd, cmd_options)
    def run_blast_arr_check(self, id=None, options=None):
        # No local variables to pass
        variables = {}
        cmd_options = {
            'name':                 "blast_arr_check",
            'log':                  os.path.join(self.directories['logs'], 
                                                "blastall_array_check.log"),
            'variables':            variables,
            'previous_id':          id,
            'script_location':      os.path.join(self.directories['scripts'], 
                                                "blastall_array_check.sh")
        }
        cmd = self.__get_command(cmd_options)
        return self.execute_job(cmd, cmd_options)
    def run_blastall_hits(self, id=None, options=None):
        variables = {
            'Blast_Out_5_File':     os.path.join(self.directories['blast'],
                                                 "blastout5"),
            'Hit_Seqs_File':        os.path.join(self.directories['clustal'],
                                                 "hitseqs")                     
        }
        cmd_options = {
            'name':                 "blast_hits",
            'log':                  os.path.join(self.directories['logs'], 
                                                "blastall_hits.log"),
            'variables':            variables,
            'previous_id':          id,
            'script_location':      os.path.join(self.directories['scripts'], 
                                                "blastall_hits.sh")
        }
        cmd = self.__get_command(cmd_options)
        return self.execute_job(cmd, cmd_options)
    def run_clustal_prep(self, id=None, options=None):
        variables = {
            'Clustal_File':         os.path.join(self.directories['clustal'],
                                                 "clustal")                    
        }
        cmd_options = {
            'name':                 "clustal_prep",
            'log':                  os.path.join(self.directories['logs'], 
                                                "clustal_prep.log"),
            'variables':            variables,
            'previous_id':          id,
            'script_location':      os.path.join(self.directories['scripts'], 
                                                "clustal_prep.sh")
        }
        cmd = self.__get_command(cmd_options)
        return self.execute_job(cmd, cmd_options)
    def run_clustal(self, id=None, options=None):
        # No local variables to pass
        variables = {}
        cmd_options = {
            'name':                 "clustal_run",
            'log':                  os.path.join(self.directories['logs'], 
                                                "clustal_run.log"),
            'variables':            variables,
            'parallel':             True,
            'previous_id':          id,
            'script_location':      os.path.join(self.directories['scripts'], 
                                                "clustal_run.sh")
        }
        cmd = self.__get_command(cmd_options)
        return self.execute_job(cmd, cmd_options)
    def run_clustal_check(self, id=None, options=None):
        # No local variables to pass
        variables = {}
        cmd_options = {
            'name':                 "clustal_check",
            'log':                  os.path.join(self.directories['logs'], 
                                                "clustal_check.log"),
            'variables':            variables,
            'previous_id':          id,
            'script_location':      os.path.join(self.directories['scripts'], 
                                                "clustal_check.sh")
        }
        cmd = self.__get_command(cmd_options)
        return self.execute_job(cmd, cmd_options)
    def run_alignment(self, id=None, options=None):
        variables = {}
        cmd_options = {
            'name':                 "alignment",
            'log':                  os.path.join(self.directories['logs'], 
                                                "alignment.log"),
            'variables':            variables,
            'previous_id':          id,
            'script_location':      os.path.join(self.directories['scripts'], 
                                                "alignment.sh")
        }
        cmd = self.__get_command(cmd_options)
        return self.execute_job(cmd, cmd_options)
    def run_dist_matrix(self, id=None, options=None):
        variables = {
            'DNADist_Script':       os.path.join(self.directories['scripts'],
                                                 "dnadist_script"),
            'Distances_File':       os.path.join(self.directories['clustal'],
                                                 "distances")
        }
        cmd_options = {
            'name':                 "dist_matrix",
            'log':                  os.path.join(self.directories['logs'], 
                                                "distance_matrix.log"),
            'variables':            variables,
            'previous_id':          id,
            'script_location':      os.path.join(self.directories['scripts'], 
                                                "distance_matrix.sh")
        }
        cmd = self.__get_command(cmd_options)
        return self.execute_job(cmd, cmd_options)
    def run_neighbor(self, id=None, options=None):
        # No local variables to pass
        variables = {}
        cmd_options = {
            'name':                 "neighbor",
            'log':                  os.path.join(self.directories['logs'], 
                                                "neighbor_run.log"),
            'variables':            variables,
            'previous_id':          id,
            'script_location':      os.path.join(self.directories['scripts'], 
                                                "neighbor_run.sh")
        }
        cmd = self.__get_command(cmd_options)
        return self.execute_job(cmd, cmd_options)
    def run_finalize(self, id=None, options=None):
        variables = {
            'Final_Log':            os.path.join(self.directories['output'],
                                                 "pipeline.log")
        }
        cmd_options = {
            'name':                 "finalize",
            'log':                  os.path.join(self.directories['logs'], 
                                                "finalize.log"),
            'variables':            variables,
            'previous_id':          id,
            'script_location':      os.path.join(self.directories['scripts'], 
                                                "final_cleanup.sh")
        }
        cmd = self.__get_command(cmd_options)
        return self.execute_job(cmd, cmd_options)
    def execute_job_array_prep(self, job_name, hold_filepath, error_filepath):
        arr_count = -1
        if self.type == "Parallel":
            while os.path.exists(hold_filepath) is not True:
                time.sleep(10)
                if os.path.exists(error_filepath):
                    os.remove(error_filepath)
                    self.__set_fatal_error(True, 
                                           err_msg="a job prior to the array "
                                           "failed and the pipeline "
                                           "cannot recover")
                    
            file = open(hold_filepath, "r")
            arr_count = file.readline()
            arr_count = str(arr_count).strip()
        
            os.remove(hold_filepath)
            
            if self.params['debug']:
                print "Number of array items: "+str(int(arr_count))
    
        return int(arr_count)  
    def execute_job_array_check(self, job_name, array_count, base_id):
        if self.type == "Parallel":
            devnull = open('/dev/null', 'w')
            completed_list = []
            for i in xrange(array_count):
                completed_list.append(i)
            
            print "Waiting for \""+job_name+"\" to finish before continuing..."
            while completed_list:
                for (index,value) in enumerate(completed_list):
                    cmd = "qstat -f " + str(base_id) + "[" + str(value) + "] | grep \"job_state = C\""
                    #print "finish_exec cmd: " + str(cmd) 
                    process = subprocess.Popen(cmd, shell=True, stdout=devnull, stderr=devnull)
                    out, err = process.communicate()
                    if process.returncode == 0:
                        #print "array["+str(value)+"] completed. removing..."
                        completed_list.remove(value)
                        #print completed_list
                    else:
                        time.sleep(10)
                        break
            devnull.close()
        return True

    def execute_job(self, cmd, options=None):
        # Calls subprocess.Popen to execute the command.
        # If in standalone mode, it directly outputs stdout
        # to the screen.  If running in parallel mode, it suppresses
        # stdout and instead prints its own messages.  The script
        # output will be sent to a log file by qsub when it executes
        # the script.
        
        id = None
        
        if options.has_key('array'):
            if self.type == "Parallel":
                if self.params['verbose'] or self.params['debug']:
                    msg = "Job \""+str(options['name'])+"\" is an array job "\
                            "and will not be executed until the previous job "\
                            "is complete."
                    print msg
                arr_count = self.execute_job_array_prep(options['name'], 
                                        self.static_vars['Array_Output_File'], 
                                        self.static_vars['Error_File'])
                if self.params['verbose'] or self.params['debug']:
                    print "Number of array items in job: "+str(arr_count)
        else:
                # Set the number of times to loop.
                pass
        
        if self.params['debug']:
            print "=====================Executing====================="
            print cmd
            print "==================================================="
        process = subprocess.Popen(cmd, shell=True,
                                      stdout=subprocess.PIPE, 
                                      stderr=subprocess.STDOUT)
        out, err = process.communicate()
            
        if self.type != "Parallel":
            if out is not None:
                print str(out)
        else:
            id = re.split('[\.]{1}',out)[0]
            if self.params['verbose'] or self.params['debug']:
                print options['name'] + " submitted. ID: "+str(id)
            if options.has_key('array') and arr_count >= 0:
                msg = "Waiting for the array job \""+str(options['name'])\
                        +"\" to finish before continuing ("+str(arr_count)\
                        +" jobs in array)."
                print msg
                self.execute_job_array_check(options['name'], arr_count, id)
                id = None # We don't want the next job to have a dependency
                                
        return id
    def __get_directories(self):
        # Return a dictionary of the directories, based on the parameters
        # that were configured.
        
        d = {
             'work':                    self.params['work_dir'],
             'scripts':                 self.params['scripts_dir']
        }
        d['output']         =           os.path.join(d['work'],'output')
        d['logs']           =           os.path.join(d['output'],'logs')
        d['references']     =           os.path.join(d['output'],'references')
        d['blast']          =           os.path.join(d['output'],'blast')
        d['clustal']        =           os.path.join(d['output'],'clustal')
        d['tree']           =           os.path.join(d['output'],'tree')
        
        d['originals']      =           os.path.join(d['references'],
                                                     'originals')
        
        d['blast_input']    =           os.path.join(d['blast'],'input')
        d['blast_temp']     =           os.path.join(d['blast'],'tmp')
        d['blast_db']       =           os.path.join(d['blast'],'formatdb')
        d['blast_output']   =           os.path.join(d['blast'],'blasts') 
        
        return d
    def __get_preferences(self):
        # Return a dictionary of the preferences variables, based on the
        # parameters that were configured.
        # If qsub isn't found on the system and the execution was
        # set to be parallel, then execution is set
        # to be forced into standalone.
        p = {
             'Execution':               self.params['Execution'],
             'Database':                self.params['Database'],
             'Input_Sequences':          self.params['InputSequences'],
             'Reference_Strains':        self.params['ReferenceStrains'],
             'Blast_Sequences':          self.params['BlastSequences'],
             'Suffix':                  self.params['Suffix'],
             'Direction':               self.params['Direction'],
             'Cutoff_Length':            self.params['CutoffLength'],
             'Max_Blasts':               self.params['MaxBlasts'],
             'Min_Sequence_Length':       self.params['MinSequenceLength'],
             'NHits':                   self.params['NHits'],
             'NPercent':                self.params['NPercent'],
             'Root':                    self.params['Root'],
             'Primer3':                 self.params['Primer3'],
             'Primer5':                 self.params['Primer5'],
             'Debug':                   self.params['debug']                          
        }
        # Make sure qsub exists on the system
        if p['Execution'] == 'Parallel':
            does_qsub_exist = subprocess.Popen(["which","qsub"],
                                               stdout=subprocess.PIPE,
                                               stdin=subprocess.PIPE,
                                               stderr=subprocess.PIPE,
                                               shell=False)
            does_qsub_exist.communicate() # Don't care about output.
            if does_qsub_exist.returncode != 0:
                p['Execution'] = "Forced Standalone"
                
        return p
    def __get_static_vars(self):
        # Returns a dictionary of variables that are used between the scripts
        # to make sure that anything that uses the same variable is
        # always pointing to the same value.
        s = {
            'Perl_Dir':                 self.directories['scripts'],
            'References_Dir':           self.directories['references'],
            'Originals_Dir':            self.directories['originals'],
            'Log_Dir':                  self.directories['logs'],
            'Blast_Dir':                self.directories['blast'],
            'Blast_Temp_Dir':           self.directories['blast_temp'],
            'Blastall_Output_Dir':      self.directories['blast_output'],
            'MPIBlast_Shared':          self.directories['blast_db'],
            'Hit_Output_Dir':           self.directories['clustal'],
            'Clustal_Output_Dir':       self.directories['clustal'],
            'Neighbor_Dir':             self.directories['clustal'],
            'Tree_Dir':                 self.directories['tree']
        }
        s['Good_Sequences_File'] = os.path.join(self.directories['blast_input'],
                                                "good_sequences")
        s['Numseqs_Temp_File'] = os.path.join(s['Blast_Temp_Dir'],
                                              "numseqs.tmp")
        s['Blast_Input_File'] = os.path.join(self.directories['blast_input'],
                                             "blast_input")
        s['Hit_File'] = os.path.join(s['Clustal_Output_Dir'], "hitfiles")
        s['Clustal_All_File'] = os.path.join(s['Clustal_Output_Dir'],
                                             "clustal_all")
        s['Clustal_Alignment_File'] = os.path.join(s['Clustal_Output_Dir'],
                                                   "clustal_all.aln")
        s['Phylip_In_File'] = os.path.join(s['Clustal_Output_Dir'],
                                            "infile")
        s['Array_Output_File'] = os.path.join(self.directories['output'],
                                              "arrayjob.tmp")
        s['Error_File'] = os.path.join(self.directories['output'], "error.tmp")
        return s
    def __get_qsub_options(self):
        # Return a dictionary of the options to be passed to qsub, based
        # on the parameters that were configured.
        
        q = {
             'Email':                   self.params['Email'],
             'NotifyOnAbort':           self.params['NotifyOnAbort'],
             'NotifyOnBegin':           self.params['NotifyOnBegin'],
             'NotifyOnEnd':             self.params['NotifyOnEnd'],
             'Queue':                   self.params['Queue'],
             'Nodes':                   self.params['Nodes']
        }
        return q
    def __configure(self, cli_options):
        # Given the location of the configuration file(s) and the
        # options passed in from the command line, set up a
        # a dictionary, 'p', with the parameters that will be used.
        # This dictionary will be used to set up all of our
        # variables that are used throughout the pipeline.
         
        options = {
            'scripts_dir':      cli_options.scripts_dir,
            'work_dir':         cli_options.work_dir,
            'debug':            cli_options.debug,
            'verbose':          cli_options.verbose
        }
        
        default_qsub_options = {
            "Email":                "None",
            "NotifyOnAbort":        "True",
            "NotifyOnBegin":        "True",
            "NotifyOnEnd":          "True",
            "Queue":                "tiny",
            "Nodes":                "50"
        }
        default_pipeline_options = {
            "Execution":            "Standalone",
            "Database":             "/mnt/home/cblair/rdp/species/species",
            "InputSequences":       "$work_dir/input/sequences",
            "ReferenceStrains":     "$work_dir/input/RefStrains",
            "BlastSequences":       "$work_dir/input/af243169.for",
            "Suffix":               ".fasta",
            "Direction":            "Forward",
            "CutoffLength":         "50",
            "MaxBlasts":            "50",
            "MinSequenceLength":    "300",
            "NHits":                "25",
            "NPercent":             ".01",
            "Root":                 "Methanococcus_jannaschii",
            "Primer3":              "GACTCGGTCC",
            "Primer5":              "CCTAGTGGAGG"
        }
        
        # Default options
        options = dict(options.items() + 
                       default_qsub_options.items() + 
                       default_pipeline_options.items())
        parser = ConfigParser.ConfigParser()
        parser.optionxform = str # Forces case sensitivity
        parser.read(cli_options.config_file)
        
        # Parse the sections and add to parameters
        for sections in parser.sections():
            items = parser.items(sections)
            for (key, value) in items:
                options[key] = value  
                      
        # Perform keyword substitution
        for (key, value) in options.iteritems():        
            if str(value).find("$scripts_dir") != -1:
                value = os.path.abspath(
                        value.replace("$scripts_dir", options['scripts_dir'])) 
            if str(value).find("$work_dir") != -1:
                value = os.path.abspath(
                        value.replace("$work_dir", options['work_dir']))
            if (str(value)).find("None") != -1:
                value = None
            if (str(value)).find("True") != -1:
                value = True
            elif (str(value)).find("False") != -1:
                value = False
            options[key] = value
                
        return options
    def __validate(self):
        # Simple validation, just checks to see if the parameters that
        # were given from the configure method contain at least the
        # required parameters (given as a set by the __required_params()
        # method. This shouldn't ever fail because the defaults are
        # hard-coded in.
        # Also checks that the scripts directory exists
        is_valid = set(self.params).issuperset(self.__required_params())
        self.__set_fatal_error(is_fatal=not is_valid,
                               err_msg="A missing configuration was detected.")
        is_valid = os.path.exists(self.params['scripts_dir'])
        self.__set_fatal_error(is_fatal=not is_valid,
                               err_msg="The scripts directory doesn't exist.")
    def __required_params(self):
        p = set([
            'Execution',
            'Database',
            'InputSequences',
            'ReferenceStrains',
            'BlastSequences',
            'Suffix',
            'Direction',
            'CutoffLength',
            'MaxBlasts',
            'MinSequenceLength',
            'NHits',
            'NPercent',
            'Root',
            'Primer3',
            'Primer5',
        ])
        return p
    def __setup_directory_structure(self):
        # This method removes the 'output' directory if it exists
        # and then recreates the directory and any subdirectories
        # that it needs.  Because the directories dictionary isn't
        # an ordered dictionary (not avail in Python 2.6.6), we can't
        # loop through the dictionary easily to create the subdirectories.
        
        shutil.rmtree(self.directories['output'])
        
        os.mkdir(self.directories['output'])
        
        # Subdirectories of 'output'
        os.mkdir(self.directories['logs'])
        os.mkdir(self.directories['references'])
        os.mkdir(self.directories['blast'])
        os.mkdir(self.directories['clustal'])
        os.mkdir(self.directories['tree'])
        
        # Subdirectories of 'blast'
        os.mkdir(self.directories['blast_input'])
        os.mkdir(self.directories['blast_temp'])
        os.mkdir(self.directories['blast_output'])
        if self.type == "Parallel":
            os.mkdir(self.directories['blast_db'])
    def __backup_configuration(self):
        backup_list = {
                       'qsub Options':              self.qsub_options,
                       'Pipeline Preferences':      self.preferences
       }
        parser = ConfigParser.ConfigParser()
        parser.optionxform = str
        
        for (section,var) in backup_list.iteritems():
            parser.add_section(section)
            for (option, value) in var.iteritems():
                parser.set(section, option, value)
        
        filename = os.path.join(self.directories['references'],
                                'used_preferences.conf')
        fp = open(filename,"w")
        parser.write(fp)
        fp.close() 
    def __check_for_fatal(self):
        return self.__fatal_error
    def __set_fatal_error(self, is_fatal, err_msg=""):
        if not self.__check_for_fatal():
            self.__fatal_error = is_fatal
        if self.__check_for_fatal():
            print >> sys.stderr, "ERROR: "+err_msg+" Exiting."
            sys.exit(1)
    def __get_command(self, cmd_options):
         if self.type != "Parallel":
             # Execute in standalone
             var_list = ""
             for (key,value) in self.preferences.iteritems():
                 var_list += str(key).upper()+"=\""+str(value)+"\" "
             for (key,value) in self.static_vars.iteritems():
                 var_list += str(key).upper()+"=\""+str(value)+"\" "
             for (key,value) in cmd_options['variables'].iteritems():
                 var_list += str(key).upper()+"=\""+str(value)+"\" "
             var_list += "PBS_O_WORKDIR=\""
             var_list += str(self.directories['output'])+"\" "
             
             if cmd_options.has_key('array_id'):
                 var_list += "PBS_ARRAYID=\""
                 var_list += str(cmd_options['array_id'])+"\" "    
             
             var_list = var_list.rstrip()
             cmd = var_list + " " + str(cmd_options['script_location'])
         else:
             # Execute in parallel
             cmd = "qsub "
             cmd += "-N "+str(cmd_options['name'])+" "
             cmd += "-j oe "
             cmd += "-o "+str(cmd_options['log'])+" "
             cmd += "-d "+str(self.directories['output'])+" "
             cmd += "-q "+str(self.qsub_options['Queue'])+" "
             
             if cmd_options.has_key('parallel'):
                 cmd += "-l nodes="+str(self.qsub_options['Nodes'])+" "
             if cmd_options.has_key('array'):
                 cmd_options['array'] -= 1
                 cmd += "-t 0-"+str(cmd_options['array'])+" "
             if cmd_options.has_key('previous_id'):
                 if cmd_options['previous_id'] is not None:
                     cmd += "-W depend=afterok:"
                     cmd += cmd_options['previous_id']+" "
             var_list = ""
             for (key,value) in self.preferences.iteritems():
                 var_list += str(key).upper()+"="+str(value)+","
             for (key,value) in self.static_vars.iteritems():
                 var_list += str(key).upper()+"="+str(value)+","
             for (key,value) in cmd_options['variables'].iteritems():
                 var_list += str(key).upper()+"="+str(value)+","
             
             if cmd_options.has_key('parallel'):
                 var_list += "NNODES="+str(self.qsub_options['Nodes'])+","
             
             var_list = var_list.rstrip(", ")
             if var_list is not None:
                 cmd += "-v "+var_list+" "
             cmd += cmd_options['script_location']
         return cmd
             
def main():
    # Set up an OptionParser object to make the command line arguments easy.
    # NOTE:  optparse has been deprecated since Python 2.7, but as of May 2013,
    #        the cluster is using Python 2.4.3. argparse should be used once
    #        a newer version of Python is in use.
    parser = OptionParser(usage="%prog [options] \n"
                          "Put a better description of what is required here.")
    parser.add_option("-p", "--pref", action="store", dest="config_file", help="the file where the your preferences are located (not the defaults) [default: %default]")
    parser.add_option("-w", "--work", action="store", dest="work_dir", help="the working directory where all output will be stored [default: %default]")
    parser.add_option("-v", "--verbose", action="store_true", dest="verbose", help="output basic information [default: %default]")
    adv_group = OptionGroup(parser, "Advanced Options", "Use these options at your own risk. Changing these options could cause the program to fail.")
    adv_group.add_option("-s", "--scripts", action="store", dest="scripts_dir", help="the directory where the script directories are located [default: %default]")
    parser.add_option_group(adv_group)
    debug_group = OptionGroup(parser, "Debug Options", "Use this to get additional output about the variables used in each of the modules.")
    debug_group.add_option("-d", "--debug", action="store_true", dest="debug", help="will output variable values in log files [default: %default]")
    parser.add_option_group(debug_group)
    
    # Set up the defaults
    parser.set_default("scripts_dir", os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)),"scripts")))
    parser.set_default("work_dir", os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)),".")))
    parser.set_default("verbose", True) # Set to False by default?
    parser.set_default("config_file", os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)),"./preferences/preferences.conf")))
    #parser.set_default("debug", False)
    parser.set_default("debug", True) # Temporary for easy testing
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
    
    pipeline = Pipeline(options)
    sys.exit(pipeline.run())
    
if __name__ == '__main__':
    main()
    