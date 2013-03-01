# call_twoDimMap.py
import string
import subprocess
import os
from os.path import basename

class call_twoDimMap:
    def __init__(self, model, var, start_time, end_time, lon1, lon2, lat1, lat2, months, output_dir):
        self.model = model
        self.var = var
        self.start_time = start_time
        self.end_time = end_time
        self.lon1 = lon1
        self.lon2 = lon2
        self.lat1 = lat1
        self.lat2 = lat2
        self.months = months
        self.output_dir = output_dir

    def displayTwoDimMap(self):

        ### print 'current dir: ', os.getcwd()
        # inputs: model name, variable name, start-year-mon, end-year-mon, 'start lon, end lon', 'start lat, end lat', 'mon list'
        # example: ./octaveWrapper ukmo_hadgem2-a ts 199001 199512 '0,100' '-29,29' '4,5,6,10,12'
        inputs = self.model + ' ' + self.var + ' ' + self.start_time + ' ' + self.end_time + ' ' + \
                 self.lon1 + ',' + self.lon2 + ' ' + self.lat1 + ',' + self.lat2 + ' ' + \
                 self.months + ' ' + self.output_dir
        print 'inputs: ', inputs
        command = './octaveWrapper ' +  inputs
        cmd = command.split(' ')
        cmdstring = string.join(cmd, ' ')
        print 'cmdstring: ', cmdstring

        try:
          proc=subprocess.Popen(cmd, cwd='.', stdout=subprocess.PIPE, stderr=subprocess.PIPE, close_fds=True)
          # wait for the process to finish
          stdout_value, stderr_value = proc.communicate()
          print 'stdout_value: ', stdout_value
          print 'stderr_value: ', stderr_value

          return stdout_value
        except OSError, e:
          return 'The subprocess "%s" returns with an error: %s.' % (cmdstring, e)


if __name__ == '__main__':
    c1 = call_twoDimMap('ukmo_hadgem2-a', 'ts', '199001', '199512', '0', '100', '-29', '29', '4,5,6,10,12', '/home/svc/cmac/trunk/services/twoDimMap/twoDimMap/static/')

    mesg = c1.displayTwoDimMap()
    print 'mesg: ', mesg
