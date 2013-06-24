# call_scatterPlot2V.py
import string
import subprocess
import os
from os.path import basename

class call_scatterPlot2V:
    def __init__(self, 
model1, var1, 
model2, var2, 
start_time, end_time, lonS, lonE, latS, latE, output_dir):

        self.model = model1
        self.var = var1
        self.start_time = start_time1
        self.end_time = end_time1
        self.lon1 = lon1a
        self.lon2 = lon1b
        self.lat1 = lat1a
        self.lat2 = lat1b

        self.model = model2
        self.var = var2
        self.start_time = start_time2
        self.end_time = end_time2
        self.lon1 = lon2a
        self.lon2 = lon2b
        self.lat1 = lat2a
        self.lat2 = lat2b

        self.output_dir = output_dir

        # temporary fix
        # This application level knowledge may not belong here
        if self.model == 'NASA_AMSRE' and self.var == 'ts':
          self.var = 'tos'


    def display(self):

        ### print 'current dir: ', os.getcwd()
        # inputs: model name, variable name, start-year-mon, end-year-mon, 'start lon, end lon', 'start lat, end lat', 'mon list'
        # example: ./octaveWrapper ukmo_hadgem2-a ts 199001 199512 '0,100' '-29,29' '4,5,6,10,12'
        inputs = \
                 self.model1 + ' ' + self.var1 + ' ' + \
                 self.model2 + ' ' + self.var2 + ' ' + \
                 self.start_time1 + ' ' + self.end_time1 + ' ' + \
                 self.lon1a + ',' + self.lon1b + ' ' + self.lat1a + ',' + self.lat1b + ' ' + \
                 self.output_dir
        print 'inputs: ', inputs
        command = './pythonWrapper ' +  inputs
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
    c1 = call_scatterPlot2V(\
'ukmo_hadgem2-a', 'ts', 'ukmo_hadgem2-a', 'clt', '199001', '199512', '0', '100', '-29', '29', \
'/home/svc/cmac/trunk/services/twoDimMap/twoDimMap/static/')

    mesg = c1.display()
    print 'mesg: ', mesg
