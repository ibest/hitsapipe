#!/usr/bin/env python
import sys
import ConfigParser
from optparse import OptionParser
from optparse import OptionGroup
import os

class Pipeline:
    '''
    This class will construct a pipeline object
    based on configuration files.  Use the
    run() function to execute the script.
    
    '''
    __fatal_error = False
    #params = {} # By declaring this global, we can call params.update() from anywhere to add to the parameter list
    def __init__(self, config_files, cli_options, debug=False):
        self.params = self.__configure(config_files, cli_options)
        self.__validate(self.params)
        if not self.__check_for_fatal():
            # All of the parameters are valid, so set them.
            # Explicitly state the static variables to make
            # passing them easier.
            self.static = {
                'database':                 self.params['database'],
                'input sequences':          self.params['input sequences'],
                'reference_strains':        self.params['reference strains'],
                'blast sequences':          self.params['blast sequences'],
                'suffix':                   self.params['suffix'],
                'direction':                self.params['direction'],
                'cutoff length':            self.params['cutoff length'],
                'max blasts':               self.params['max blasts'],
                'min sequence length':      self.params['min sequence length'],
                'nhits':                    self.params['nhits'],
                'npercent':                 self.params['npercent'],
                'root':                     self.params['root'],
                'primer3':                  self.params['primer3'],
                'primer5':                  self.params['primer5']                 
            }
            self.directories = {
                'work':                     self.params['work_dir'],
                'scripts':                  self.params['scripts_dir'],
                'output':                   self.params['output_dir'],
                'logs':                     self.params['logs_dir'],
                'backup':                   self.params['backup_dir'],
                'blast':                    self.params['blast_dir'],
                'clustal':                  self.params['clustal_dir'],
                'tree':                     self.params['tree_dir'],
                'blast_input':              self.params['blast_input_dir'],
                'blast_temp':               self.params['blast_temp_dir'],
                'blast_db':                 self.params['blast_db_dir'],
                'blast_output':             self.params['blast_output_dir']
            }            
            
    def __configure(self, config_files, cli_options):
        parser = ConfigParser.ConfigParser()
        parser.read(config_files.values())
        
        if parser.has_section("Pipeline Preferences") == False:
            self.__set_fatal_error(True)
        
        params = {
            'scripts_dir':      cli_options['scripts_dir'],
            'work_dir':         cli_options['work_dir']
        }
        params['output_dir'] =  os.path.join(cli_options['work_dir'],'output')
        params['logs_dir'] =  os.path.join(params['output_dir'],'logs')
        params['backup_dir'] =  os.path.join(params['output_dir'],'references')
        params['blast_dir'] =  os.path.join(params['output_dir'],'blast')
        params['clustal_dir'] =  os.path.join(params['output_dir'],'clustal')
        params['tree_dir'] =  os.path.join(params['output_dir'],'tree')
        
        params['blast_input_dir'] =  os.path.join(params['blast_dir'],'input')
        params['blast_temp_dir'] =  os.path.join(params['blast_dir'],'tmp')
        params['blast_db_dir'] =  os.path.join(params['blast_dir'],'formatdb')
        params['blast_output_dir'] =  os.path.join(params['blast_dir'],'blasts')                
        
        
        for sections in parser.sections():
            items = parser.items(sections)
            for (key, value) in items:
                #print "(key,value) = ("+key+","+value+")"
                if value.find("$scripts_dir") != -1:
                    value = os.path.abspath(value.replace("$scripts_dir", params["scripts_dir"])) 
                if value.find("$work_dir") != -1:
                    value = os.path.abspath(value.replace("$work_dir", params["work_dir"]))
                if (str(value)).find("None") != -1:
                    value = None
                if (str(value)).find("True") != -1:
                    value = True
                elif (str(value)).find("False") != -1:
                    value = False
                params[key] = value        
                
        return params 
    def __validate(self, params):
        is_valid = set(params).issuperset(self.__required_params())
        self.__set_fatal_error(not is_valid) # We want a false value if it's valid
        return is_valid
    def __required_params(self):
        p = set([
            'database',
            'input sequences',
            'reference strains',
            'blast sequences',
            'suffix',
            'direction',
            'cutoff length',
            'max blasts',
            'min sequence length',
            'nhits',
            'npercent',
            'root',
            'primer 3',
            'primer 5',
        ])
        return p
    def __check_for_fatal(self):
        return self.__fatal_error
    def __set_fatal_error(self, to_set):
        if not self.__check_for_fatal():
            self.__fatal_error = to_set
        if self.__check_for_fatal():
            print >> sys.stderr, "Fatal error occurred while configuring pipeline. Exiting."
            
    def run(self):
        if not self.__check_for_fatal():
            print "Pipeline successfully configured."
            print "Preparing to execute."
            
        return 0
    def run_pipeline_prep(self):
        pass
    def run_fasta_prep(self):
        pass

def main():
    # Set up an OptionParser object to make the command line arguments easy.
    # NOTE:  optparse has been deprecated since Python 2.7, but as of May 2013,
    #        the cluster is using Python 2.4.3. argparse should be used once
    #        a newer version of Python is in use.
    parser = OptionParser(usage="%prog [options] \n"
                          "Put a better description of what is required here.")
    parser.add_option("-p", "--pref", action="store", dest="user_config_file", help="the file where the your preferences are located (not the defaults) [default: %default]")
    parser.add_option("-w", "--work", action="store", dest="work_dir", help="the working directory where all output will be stored [default: %default]")
    adv_group = OptionGroup(parser, "Advanced Options", "Use these options at your own risk. Changing these options could cause the program to fail.")
    adv_group.add_option("-c", "--conf", action="store", dest="default_config_file", help="the file where the default preferences are located [default: %default]")
    adv_group.add_option("-s", "--scripts", action="store", dest="scripts_dir", help="the directory where the script directories are located [default: %default]")
    parser.add_option_group(adv_group)
    debug_group = OptionGroup(parser, "Debug Options", "Use this to get additional output about the variables used in each of the modules.")
    debug_group.add_option("-d", "--debug", action="store_true", dest="debug", help="will output variable values in log files [default: %default]")
    parser.add_option_group(debug_group)
    
    # Set up the defaults
    parser.set_default("scripts_dir", os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)),"scripts")))
    parser.set_default("work_dir", os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)),".")))
    parser.set_default("default_config_file", os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)),"./preferences/defaults/new_default_preferences.conf")))
    parser.set_default("user_config_file", os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)),"./preferences/user/new_user_preferences.conf")))
    parser.set_default("debug", False)
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
    
    config_files = {
        "default_config_file":      options.default_config_file,
        "user_config_file":         options.user_config_file
    }
    cli_options = {
        "scripts_dir":              options.scripts_dir,
        "work_dir":                 options.work_dir
    }
    debug = options.debug 
    
    pipeline = Pipeline(config_files, cli_options, debug)
    sys.exit(pipeline.run())
    
if __name__ == '__main__':
    main()
    