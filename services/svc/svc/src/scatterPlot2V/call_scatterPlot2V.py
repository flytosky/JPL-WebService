# call_scatterPlot2V.py
import string
import subprocess
import os
from os.path import basename

class call_scatterPlot2V:
    def __init__(self, 
model1, var1, pres1,
model2, var2, pres2,
start_time, end_time, lonS, lonE, latS, latE, output_dir):

        self.model1 = model1
        self.var1 = var1
        self.pres1 = pres1
        self.model2 = model2
        self.var2 = var2
        self.pres2 = pres2
        self.start_time = start_time
        self.end_time = end_time
        self.lon1 = lonS
        self.lon2 = lonE
        self.lat1 = latS
        self.lat2 = latE

        self.output_dir = output_dir
        self.isDiffPlot = 0

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
                 self.model1 + ' ' + self.var1 + ' ' + self.pres1 + ' ' + \
                 self.model2 + ' ' + self.var2 + ' ' + self.pres2 + ' ' + \
                 self.start_time + ' ' + self.end_time + ' ' + \
                 self.lon1 + ',' + self.lon2 + ' ' + self.lat1 + ',' + self.lat2 + ' ' + \
                 self.output_dir + ' ' + '%d'%self.isDiffPlot

        print 'inputs: ', inputs
        #command = '/home/bytang/projects/cmac/trunk/services/svc/svc/src/scatterPlot2V/wrapper ' +  inputs
        command = './wrapper ' +  inputs
        cmd = command.split(' ')
        cmdstring = string.join(cmd, ' ')
        print 'cmdstring: ', cmdstring

        if 1:
        #try:
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
          image_filename = os.path.basename(image_filename)
          print 'image_filename: ', image_filename
          return (stdout_value, image_filename)
        # 
        #except OSError, e:
        #  err_mesg = 'The subprocess "%s" returns with an error: %s.' % (cmdstring, e)
        #  return (err_mesg, '')


if __name__ == '__main__':
    c1 = call_scatterPlot2V(\
'ukmo_hadgem2-a', 'ts', '200', 'ukmo_hadgem2-a', 'clt', '200', '199001', '199512', '0', '100', '-29', '29', \
'/home/svc/cmac/trunk/services/svc/svc/static/scatterPlot2V')

    mesg = c1.display()
    print 'mesg: ', mesg
