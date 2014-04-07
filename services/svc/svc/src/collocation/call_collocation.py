# call_collocation.py
import string
import subprocess
import os
from os.path import basename

class call_collocation:
    def __init__(self, 
sourceData = 'mls-h2o',
targetData = 'cloudsat',
dateS = '20080501',
timeS = '000000',
dateE = '20080501',
timeE = '010000',
output_dir = '/home/svc/cmac/trunk/services/twoDimMap/twoDimMap/static/'):

        self.sourceData = sourceData
        self.targetData = targetData 

        self.dateS = dateS
        self.timeS = timeS

        self.dateE = dateE
        self.timeE = timeE

        self.output_dir = output_dir

        # temporary fix
        # This application level knowledge may not belong here
        #if self.model1 == 'NASA_AMSRE' and self.var == 'ts':
        #  self.var = 'tos'

    def display(self):

        ### print 'current dir: ', os.getcwd()
        # inputs: model name, variable name, start-year-mon, end-year-mon, 'start lon, end lon', 'start lat, end lat', 'mon list'
        # example: ./octaveWrapper ukmo_hadgem2-a ts 199001 199512 '0,100' '-29,29' '4,5,6,10,12'
                 #'%g'%self.lon1 + ',' + '%g'%self.lon2 + ' ' + '%g'%self.lat1 + ',' + '%g'%self.lat2 + ' ' + \
        inputs = \
                 self.sourceData + ' ' \
                 self.targetData + ' ' \
                 self.dateS + ' ' \
                 self.timeS + ' ' \
                 self.dateE + ' ' \
                 self.timeE 

        print 'inputs: ', inputs
        #command = '/home/bytang/projects/cmac/trunk/services/svc/svc/src/scatterPlot2V/wrapper ' +  inputs
        command = './wrapper ' +  inputs
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
    c1 = call_collocation()

    mesg = c1.display()
    print 'mesg: ', mesg
