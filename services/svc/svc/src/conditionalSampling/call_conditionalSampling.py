# call_threeDimZonalMean.py
import string
import subprocess
import os
from os.path import basename

class call_conditionalSampling:
    def __init__(self, data_source, var, start_time, end_time, lon1, lon2, lat1, lat2, pres1, pres2, months, env_var_source, env_var, bin_min, bin_max, bin_n, env_var_plev, output_dir, displayOpt):
        self.data_source = data_source
        self.var = var
        self.start_time = start_time
        self.end_time = end_time
        self.lon1 = lon1
        self.lon2 = lon2
        self.lat1 = lat1
        self.lat2 = lat2
        self.pres1 = pres1
        self.pres2 = pres2
        self.months = months
        self.env_var_source = env_var_source
        self.env_var = env_var
        self.bin_min = bin_min
        self.bin_max = bin_max
        self.bin_n = bin_n
        self.env_var_plev = env_var_plev
        self.output_dir = output_dir
        self.displayOpt = displayOpt


    def displayConditionalSampling(self):

        inputs = self.data_source + ' ' + self.var + ' ' + self.start_time + ' ' + self.end_time + ' ' + \
                 self.lon1 + ',' + self.lon2 + ' ' + self.lat1 + ',' + self.lat2 + ' ' + \
                 self.pres1 + ',' + self.pres2 + ' ' + self.months + ' ' + \
                 self.env_var_source + ' ' + self.env_var + ' ' + \
                 self.bin_min + ',' + self.bin_max + ',' + self.bin_n + ' ' + \
                 self.env_var_plev + ' ' + self.output_dir + ' ' + self.displayOpt
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
             return (stderr_value, '', '')

          fst = 'figFile: '
          l1 = len(fst)
          ### print 'l1: ', l1
          image_filename = ''

          fst2 = 'dataFile: '
          l2 = len(fst2)
          ### print 'l2: ', l2
          data_filename = ''

          lines = stdout_value.split('\n')
          for line in lines:
            ### print '*****: ', line
            if line.find('figFile: ') >= 0:
              print '***** line: ', line
              image_filename = line[l1:]

            if line.find('dataFile: ') >= 0:
              print '***** line: ', line
              data_filename = line[l2:]

          print 'image_filename: ', image_filename
          print 'data_filename: ', data_filename
          return (stdout_value, image_filename, data_filename)
        except OSError, e:
          err_mesg = 'The subprocess "%s" returns with an error: %s.' % (cmdstring, e)
          return (err_mesg, '', '')


if __name__ == '__main__':
    #./octaveWrapper giss_e2-r clw 200101 200212 '0 360' '-90 90' '20000 90000' '1,2,3,4,5,6,7,8,9,10,11,12' 'giss_e2-r' tos '294,295,296,297,298, 299, 300, 301, 302, 303, 304, 305' '' '/tmp/'
    # c1 = call_conditionalSampling('cccma_canesm2', 'ts', '200101', '200212', '0', '360', '-90', '90', '', '', '5,6,7,8', 'cccma_canesm2', 'tos', '294','305','20', '',  './', '0')
    c1 = call_conditionalSampling('giss_e2-r', 'clw', '200101', '200212', '0', '360', '-30', '30', '20000', '90000', '5,6,7,8', 'giss_e2-r', 'tos', '294','305','20', '',  './', '6')

    mesg = c1.displayConditionalSampling()
    print 'mesg: ', mesg
