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

        # temporary fix
        # This application level knowledge may not belong here
        if self.model == 'NASA_AMSRE' and self.var == 'ts':
          self.var = 'tos'


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

          if stderr_value.find('error:') >= 0:
             return (stderr_value, '')

          fst = 'figFile: '
          l1 = len(fst)
          ### print 'l1: ', l1
          image_filename = ''

          lines = stdout_value.split('\n')
          for line in lines:
            ### print '*****: ', line
            if line.find('figFile: ') >= 0:
              print '***** line: ', line
              image_filename = line[l1:]

          print 'image_filename: ', image_filename
          return (stdout_value, image_filename)
        except OSError, e:
          err_mesg = 'The subprocess "%s" returns with an error: %s.' % (cmdstring, e)
          return (err_mesg, '')


if __name__ == '__main__':
    c1 = call_twoDimMap('ukmo_hadgem2-a', 'ts', '199001', '199512', '0', '100', '-29', '29', '4,5,6,10,12', '/home/svc/cmac/trunk/services/twoDimMap/twoDimMap/static/')

    mesg = c1.displayTwoDimMap()
    print 'mesg: ', mesg
