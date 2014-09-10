import os
import glob
import re
p1 = re.compile( r'_(\d*)-(\d*).nc')

def calcTimeBounds(fn):
  # find the start of the time bounds
  m1 = p1.search(fn)
  g1 =  m1.groups()
  if len(g1)!=2:
    return [0, 0]

  #print fn, g1
  year1 = int(g1[0])
  year2 = int(g1[1])

  return [year1, year2]

def getTimeBounds(serviceType, dataSource, varName):
  # serviceType = '1': Chengxing Zhai's services
  # serviceType = '2': Benyang Tang's services

  dir00 = '/mnt/hgfs/cmacws/data1/data/cmip5'

  subdirs1 = ['regridded', 'break', '.']
  subdirs2 = ['regridded', 'original', '.']

  if serviceType=='1':
    subdirs = subdirs1
  else:
    subdirs = subdirs2

  year1b = 0
  year2b = 0

  # loop over subdirs
  for subdir in subdirs:

    # list of files
    temp1 =  dir00 + '/' + dataSource + '/' + varName + '_*.nc'
    #print temp1
    files = glob.glob( temp1 )
    files1 = [os.path.split(file1)[1] for file1 in files]

    # if no files in that subdir
    if len(files1)==0:
      continue

    year1a = []
    year2a = []
    # loop over files
    for file1 in files1:

      # determine time bounds
      bounds = calcTimeBounds(file1)
      year1a.append(bounds[0]) 
      year2a.append(bounds[1]) 


    year1b = min(year1a) 
    year2b = max(year2a)

    if year1b>0:
      return [year1b, year2b]

  return [0,0]

if __name__ == '__main__':
        if 0:
          sources = ["nasa/modis", ]
          vars = ['lai', ]

        if 1:
          sources = ["argo/argo", "cccma/canam4", "cccma/canesm2", "csiro/mk3.6", "gfdl/cm3", "gfdl/cm3_hist", "gfdl/esm2g",
                           "giss/e2-h", "giss/e2-r", "ipsl/cm5a-lr", "miroc/miroc5", "nasa/airs", "nasa/amsre", "nasa/aviso",
                           "nasa/ceres", "nasa/gpcp", "nasa/grace", "nasa/mls", "nasa/modis", "nasa/quikscat", "nasa/trmm",
                           "ncar/cam5", "ncar/cam5-1-fv2", "ncc/noresm", "noaa/nodc", "ukmo/hadgem2-a", "ukmo/hadgem2-es"]

          vars = ["pr", "cli", "clt", "lai", "rlds", "rldscs","rlus", "rlut", "rlutcs", "rsds", "rsdscs", "rsdt", "rsus", "rsuscs",
                        "rsut", "rsutcs", "sfcWind", "ts", "uas", "vas", "clw", "hus", "ta", "tos", "zos", "ohc700", "ohc2000", "zo", "zl", "os", "ot"] 

                        #["clivi", "clwvi", "z1", "z0", "cltStddev", "cltNobs", "sfcWindNobs", "sfcWindStderr", "uasNobs", "uasStderr", "vasNobs", "vasStderr",
                        #"prw"]
        print("start test")

        serviceType = '1'
        #serviceType = '2'

        """
        for source in sources:
                for var in vars:
                        bounds = getTimeBounds(serviceType, source, var)
                        print '%20s  %10s:  %7d : %7d'%(source, var, bounds[0], bounds[1])
        print("end test")
        """


        ### source = 'cccma/canam4'
        ### var = 'rlus'
        ### source = 'argo/argo'
        ### var = 'os'
        source = 'NASA/MODIS'
        ### source = 'nasa/modis'
        var = 'clt'
 
        retDateList = getTimeBounds(serviceType, source, var)
        print(retDateList, serviceType, source, var)
