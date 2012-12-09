# call_twoDimClimatology.py
import string
import subprocess
import os
from os.path import basename

class call_twoDimClimatology:
    def __init__(self, model='ukmo', inputf=None, outputf=None):
        self.model = model
        self.inputf = inputf
        self.outputf = outputf

    def displayTwoDimClimatology(self):
        ### print 'current file: ', os.path.realpath(__file__)
        ### print 'current dir: ', os.getcwd()
        ### command = '/home/svc/cmac/trunk/services/twoDimClimatology/twoDimClimatology/src/octaveWrapper ' + self.model
        command = './octaveWrapper ' + self.model + ' ' + self.inputf + ' ' + self.outputf
        cmd = command.split(' ')
        cmdstring = string.join(cmd, ' ')
        print 'cmdstring: ', cmdstring

        try:
          proc=subprocess.Popen(cmd, cwd='.', stdout=subprocess.PIPE, stderr=subprocess.PIPE, close_fds=True)
          # wait for the process to finish
          stdout_value, stderr_value = proc.communicate()
          ### print 'stdout_value: ', stdout_value
          ### print 'stderr_value: ', stderr_value

          return stdout_value
        except OSError, e:
          return 'The subprocess "%s" returns with an error: %s.' % (cmdstring, e)


if __name__ == '__main__':
    input_file = '/home/svc/cmac/trunk/services/twoDimClimatology/twoDimClimatology/static/ts_Amon_HadGEM2-A_amip_r1i1p1_197809-200811.nc'
    c1 = call_twoDimClimatology('ukmo', input_file, 'ukmo_ts.jpeg')

    mesg = c1.displayTwoDimClimatology()
    print 'mesg: ', mesg
