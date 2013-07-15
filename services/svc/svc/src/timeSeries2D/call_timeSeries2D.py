# call_timeSeries2D.py
import string
import subprocess
import os
from os.path import basename

class call_timeSeries2D:
    def __init__(self, model, var, start_time, end_time, lon1, lon2, lat1, lat2, output_dir):
        self.model = model
        self.var = var
        self.start_time = start_time
        self.end_time = end_time
        self.lon1 = lon1
        self.lon2 = lon2
        self.lat1 = lat1
        self.lat2 = lat2
        self.output_dir = output_dir

        # temporary fix
        # This application level knowledge may not belong here
        if self.model == 'NASA_AMSRE' and self.var == 'ts':
          self.var = 'tos'

    def display_timeSeries2D(self):

        ### print 'current dir: ', os.getcwd()
        # inputs: model name, variable name, start-year-mon, end-year-mon, 'start lon, end lon', 'start lat, end lat' 'output dir'
        # example:  ./octaveWrapper ukmo_hadgem2-a clt 199001 199512 '0 100' '0 20' ./tmp/
        inputs = self.model + ' ' + self.var + ' ' + self.start_time + ' ' + self.end_time + ' ' + \
                 self.lon1 + ',' + self.lon2 + ' ' + self.lat1 + ',' + self.lat2 + ' ' + \
                 self.output_dir
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
#    c1 = call_timeSeries2D('ukmo_hadgem2-a', 'ts', '199001', '199512', '0', '100', '-29', '29', '/home/svc/cmac/trunk/services/svc/svc/src/timeSeries2D')
#    c1 = call_timeSeries2D('ukmo_hadgem2-a', 'ts', '196001', '199512', '0', '100', '-29', '29', '/home/zhai/working/cmac/trunk/services/svc/svc/src/timeSeries2D')
    #c1 = call_timeSeries2D('cccma_canam4', 'ts', '196001', '199512', '0', '100', '-29', '29', '/home/zhai/working/cmac/trunk/services/svc/svc/src/timeSeries2D')
#    c1 = call_timeSeries2D('ncc_noresm', 'ts', '196001', '199512', '0', '100', '-29', '29', '/home/zhai/working/cmac/trunk/services/svc/svc/src/timeSeries2D')
#    c1 = call_timeSeries2D('nasa_amsre', 'tos', '200001', '200912', '0', '100', '-29', '29', '/home/zhai/working/cmac/trunk/services/svc/svc/src/timeSeries2D')
    c1 = call_timeSeries2D('nasa_quikscat', 'sfcWind', '200001', '200912', '0', '100', '-29', '29', '/home/zhai/working/cmac/trunk/services/svc/svc/src/timeSeries2D')

    mesg = c1.display_timeSeries2D()
    print 'mesg: ', mesg
