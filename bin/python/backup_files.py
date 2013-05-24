>backup_files.py
from optparse import OptionParser
import os

def main():
    
        # Set up the parser that will see what options are set.
    parser = OptionParser(usage="%prog [options]", version="%prog 0.1", epilog="Last modified 22 May 2013")
   
    parser.add_option("-v", "--verbose", action="store_true", dest="verbose", default=False, help="displays any output to the screen")
    
    (options, args) = parser.parse_args()
    if len(args) != 1:
        parser.error("incorrect number of arguments.")
    verbose = options.verbose
    root = os.path.abspath(os.path.expanduser(args[0]))
    backup = root + "usr/backup"
    
    if os.path.exists(backup) == False:
        os.mkdir(backup)
    
    ## Backup directory has been created, start backing up files.
    
    
    
    
        
    
        
        
        
if __name__ == '__main__':
    main()
    
    
    