import sys
import os
import subprocess
import re

class main_paths:
    def __init__(self, bin_dir, root_dir, results_dir):
        self.bin = os.path.abspath(bin_dir)
        self.root = os.path.abspath(root_dir)
        self.results = os.path.abspath(results_dir)
        
        self.bash = os.path.join(self.bin,"bash")
        self.perl = os.path.join(self.bin,"perl")
        self.python = os.path.join(self.bin,"python") 
        
        self.tmp = os.path.join(self.root, "tmp")  

def join(d,p):
    return os.path.join(d,p)
def main():
    paths = main_paths(sys.argv[1], sys.argv[2], sys.argv[3])
    print "Paths:"
    print "bin: "+paths.bin
    print "root: "+paths.root
    print "results: "+paths.results
    print "bash: "+paths.bash
    print "perl: "+paths.perl
    print "python: "+paths.python

    
    pbs_directives = open(join(paths.tmp,"test.pbs"),"w")
    pbs_directives.writelines(["#!/bin/bash\n","#PBS -N varTest\n","#PBS -o "+join(paths.results,"newoutput.log")+"\n","#PBS -d "+paths.root+"\n"]) # accepts a list of strings.  remember to newline each of them

    with open (join(paths.python,"sleep.pbs"), "r") as myfile:
        data = myfile.readlines()
        
    pbs_directives.writelines(data)
    pbs_directives.close()
    
    renameoutput = open(join(paths.tmp,"renameSuccess.pbs"),"w")
    renameoutput.writelines(["#!/bin/bash\n","#PBS -N renameSuccess\n","#PBS -o "+join(paths.results,"renameSuccess.log")+"\n","#PBS -d "+paths.root+"\n"])
    
    with open (join(paths.python,"renameoutput.pbs"), "r") as myfile:
        data = myfile.readlines()
        
    renameoutput.writelines(data)
    renameoutput.close()
    
    renameoutput = open(join(paths.tmp,"renameFail.pbs"),"w")
    renameoutput.writelines(["#!/bin/bash\n","#PBS -N renameFail\n","#PBS -o "+join(paths.results,"renameFail.log")+"\n","#PBS -d "+paths.root+"\n"])
    
    with open (join(paths.python,"renameoutput.pbs"), "r") as myfile:
        data = myfile.readlines()
        
    renameoutput.writelines(data)
    renameoutput.close()
    
    renameoutput = open(join(paths.tmp,"renameAny.pbs"),"w")
    renameoutput.writelines(["#!/bin/bash\n","#PBS -N renameAny\n","#PBS -o "+join(paths.results,"renameAny.log")+"\n","#PBS -d "+paths.root+"\n"])
    
    with open (join(paths.python,"renameoutput.pbs"), "r") as myfile:
        data = myfile.readlines()
        
    renameoutput.writelines(data)
    renameoutput.close()
    
    #command = "qsub "+join(paths.tmp,"test.pbs")
    command = "qsub -q tiny -t 0-3 "+join(paths.python,"array.pbs")
    #command = "qsub -N outsidePriority "+join(paths.tmp,"test.pbs") # The job name is now outsidePriority even if it was specified in a directive inside the file
    process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE)
    out, err = process.communicate()
    print out
    #id2 = re.split('[[\.]{1}',out)[0] # get the id number of the job or job array that was submitted
    id = re.split('[\.]{1}',out)[0] # get the id number of the job or job array that was submitted
    print out.rstrip()
    print "submitting out"
    command = "qsub -q tiny -W depend=afterokarray:"+str(out.rstrip())+" "+join(paths.tmp,"renameSuccess.pbs")
    #print command
    subprocess.call(command, shell=True)
    print "out submitted"
    print "submitting id"
    command = "qsub -q tiny -W depend=afterokarray:"+id+" "+join(paths.tmp,"renameFail.pbs")
    #print command
    subprocess.call(command, shell=True)
    print "id submitted"
    #command = "qsub -W depend=afteranyarray:"+id+" "+join(paths.tmp,"renameAny.pbs")
    #subprocess.call(command, shell=True)
    
    sys.exit(0)
    
if __name__ == '__main__':
    main()

