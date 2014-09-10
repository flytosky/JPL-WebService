import os
import glob

def calcTimeBounds(fn):
  # find the start of the time bounds
  temp1 = fn.find('_19') 
  temp19 = fn.find('_18') 
  if temp1==-1 and temp19==-1:
    return [0, 0]

  # pick 18?? if no 19??
  if temp1==-1:
    temp1 = temp19
  temp1 += 1

  # find the start of the second time bound
  temp1a = fn[temp1:]
  temp2 = temp1a.find('-') 
  if temp2==-1:
    return [0, 0]

  # some file has other parts after the time bounds.
  # for now, ignore those files
  temp2a = temp1a[temp2:]
  temp3 = temp2a.find('_') 
  if temp3>-1:
    return [0, 0]

  temp1b = temp1
  temp2b = temp1 + temp2

#  if temp3>-1:
#    print fn
#    temp3b = temp2b + temp3
#  else:
#    temp3b = -3

  temp3b = -3

  y1 = fn[temp1b:temp2b]
  y2 = fn[(temp2b+1):temp3b]
  #print fn, y1, y2
  year1 = int(y1)
  year2 = int(y2)

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
    files = glob.glob( dir00 + '/' + dataSource + '/' + varName + '_*.nc' )
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

        for source in sources:
                for var in vars:
                        bounds = getTimeBounds(serviceType, source, var)
                        print '%20s  %10s:  %7d : %7d'%(source, var, bounds[0], bounds[1])
        print("end test")

        ### source = 'cccma/canam4'
        ### var = 'rlus'
        ### source = 'argo/argo'
        ### var = 'os'
        ### source = 'NASA/MODIS'
        source = 'nasa/modis'
        var = 'clt'

        retDateList = getTimeBounds(serviceType, source, var)
        print(retDateList, serviceType, source, var)

