import os, hashlib, shutil
from datetime import datetime, timedelta
import md5

from flask import jsonify, request, url_for, make_response
from werkzeug import secure_filename

from svc import app
from svc.src.twoDimMap import call_twoDimMap
from svc.src.twoDimSlice3D import call_twoDimSlice3D
from svc.src.timeSeries2D import call_timeSeries2D
from svc.src.twoDimZonalMean import call_twoDimZonalMean
from svc.src.threeDimZonalMean import call_threeDimZonalMean
from svc.src.threeDimVerticalProfile import call_threeDimVerticalProfile
from svc.src.scatterPlot2V import call_scatterPlot2V

from flask import current_app
from functools import update_wrapper


def crossdomain(origin=None, methods=None, headers=None,
                max_age=21600, attach_to_all=True,
                automatic_options=True):
    if methods is not None:
        methods = ', '.join(sorted(x.upper() for x in methods))
    if headers is not None and not isinstance(headers, basestring):
        headers = ', '.join(x.upper() for x in headers)
    if not isinstance(origin, basestring):
        origin = ', '.join(origin)
    if isinstance(max_age, timedelta):
        max_age = max_age.total_seconds()

    def get_methods():
        if methods is not None:
            return methods

        options_resp = current_app.make_default_options_response()
        return options_resp.headers['allow']

    def decorator(f):
        def wrapped_function(*args, **kwargs):
            if automatic_options and request.method == 'OPTIONS':
                resp = current_app.make_default_options_response()
            else:
                resp = make_response(f(*args, **kwargs))
            if not attach_to_all and request.method != 'OPTIONS':
                return resp

            h = resp.headers

            h['Access-Control-Allow-Origin'] = origin
            h['Access-Control-Allow-Methods'] = get_methods()
            h['Access-Control-Max-Age'] = str(max_age)
            if headers is not None:
                h['Access-Control-Allow-Headers'] = headers
            return resp

        f.provide_automatic_options = False
        return update_wrapper(wrapped_function, f)
    return decorator


def get_host_port(cfg_file):
    myvars = {}
    myfile =  open(cfg_file)
    for line in myfile:
        name, var = line.partition("=")[::2]
        name = name.strip()
        var = var.strip('\n').strip()
        if name is not '' and var is not '':
            myvars[name] = var

    ### print myvars

    return myvars["HOSTNAME"], myvars["PORT"]


@app.route('/svc/twoDimMap', methods=["GET"])
@crossdomain(origin='*')
def displayTwoDimMap():
    """Run displayTwoDimMap"""

    # status and message
    success = True
    message = "ok"
    url = ''
    dataUrl = ''

    # get model, var, start time, end time, lon1, lon2, lat1, lat2, months

    model = request.args.get('model', '')
    var = request.args.get('var', '')
    startT = request.args.get('start_time', '')
    endT = request.args.get('end_time', '')
    lon1 = request.args.get('lon1', '')
    lon2 = request.args.get('lon2', '')
    lat1 = request.args.get('lat1', '')
    lat2 = request.args.get('lat2', '')
    months = request.args.get('months', '')

    print 'model: ', model
    print 'var: ', var
    print 'startT: ', startT
    print 'endT: ', endT
    print 'lon1: ', lon1
    print 'lon2: ', lon2
    print 'lat1: ', lat1
    print 'lat2: ', lat2
    print 'months: ', months

    # get where the input file and output file are
    current_dir = os.getcwd()
    print 'current_dir: ', current_dir

    try:
      seed_str = model+var+startT+endT+lon1+lon2+lat1+lat2+months
      tag = md5.new(seed_str).hexdigest()
      output_dir = current_dir + '/svc/static/twoDimMap/' + tag
      print 'output_dir: ', output_dir
      if not os.path.exists(output_dir):
        os.makedirs(output_dir)

      # chdir to where the app is
      os.chdir(current_dir+'/svc/src/twoDimMap')
      # instantiate the app. class
      c1 = call_twoDimMap.call_twoDimMap(model, var, startT, endT, lon1, lon2, lat1, lat2, months, output_dir)
      # call the app. function
      (message, imgFileName, dataFileName) = c1.displayTwoDimMap()
      # chdir back
      os.chdir(current_dir)

      hostname, port = get_host_port("host.cfg")
      print 'hostname: ', hostname
      print 'port: ', port

      ### url = 'http://cmacws.jpl.nasa.gov:8090/static/twoDimMap/' + tag + '/' + imgFileName
      url = 'http://' + hostname + ':' + port + '/static/twoDimMap/' + tag + '/' + imgFileName
      print 'url: ', url
      dataUrl = 'http://' + hostname + ':' + port + '/static/twoDimMap/' + tag + '/' + dataFileName
      print 'dataUrl: ', dataUrl

      print 'message: ', message
      if len(message) == 0 or message.find('Error') >= 0 or message.find('error:') >= 0 :
        success = False
        url = ''
        dataUrl = ''

    except ValueError, e:
        # chdir to current_dir in case the dir is changed to where the app is in the try block
        os.chdir(current_dir)
        print 'change dir back to: ', current_dir

        success = False
        message = str(e)
    except Exception, e:
        # chdir to current_dir in case the dir is changed to where the app is in the try block
        os.chdir(current_dir)
        print 'change dir back to: ', current_dir

        success = False
        ### message = str("Error caught in displayTwoDimMap()")
        message = str(e)

    return jsonify({
        'success': success,
        'message': message,
        'url': url,
        'dataUrl': dataUrl
    })


@app.route('/svc/timeSeries2D', methods=["GET"])
@crossdomain(origin='*')
def display_timeSeries2D():
    """Run display_timeSeries2D"""

    # status and message
    success = True
    message = "ok"
    url = ''
    dataUrl = ''

    # get model, var, start time, end time, lon1, lon2, lat1, lat2

    model = request.args.get('model', '')
    var = request.args.get('var', '')
    startT = request.args.get('start_time', '')
    endT = request.args.get('end_time', '')
    lon1 = request.args.get('lon1', '')
    lon2 = request.args.get('lon2', '')
    lat1 = request.args.get('lat1', '')
    lat2 = request.args.get('lat2', '')

    print 'model: ', model
    print 'var: ', var
    print 'startT: ', startT
    print 'endT: ', endT
    print 'lon1: ', lon1
    print 'lon2: ', lon2
    print 'lat1: ', lat1
    print 'lat2: ', lat2

    # get where the input file and output file are
    current_dir = os.getcwd()
    print 'current_dir: ', current_dir

    try:
      seed_str = model+var+startT+endT+lon1+lon2+lat1+lat2
      tag = md5.new(seed_str).hexdigest()
      output_dir = current_dir + '/svc/static/timeSeries2D/' + tag
      print 'output_dir: ', output_dir
      if not os.path.exists(output_dir):
        os.makedirs(output_dir)

      # chdir to where the app is
      os.chdir(current_dir+'/svc/src/timeSeries2D')
      # instantiate the app. class
      c1 = call_timeSeries2D.call_timeSeries2D(model, var, startT, endT, lon1, lon2, lat1, lat2, output_dir)
      # call the app. function
      (message, imgFileName, dataFileName) = c1.display_timeSeries2D()
      # chdir back
      os.chdir(current_dir)

      hostname, port = get_host_port("host.cfg")
      print 'hostname: ', hostname
      print 'port: ', port

      ### url = 'http://cmacws.jpl.nasa.gov:8090/static/timeSeries2D/' + tag + '/' + imgFileName
      url = 'http://' + hostname + ':' + port + '/static/timeSeries2D/' + tag + '/' + imgFileName
      print 'url: ', url
      dataUrl = 'http://' + hostname + ':' + port + '/static/timeSeries2D/' + tag + '/' + dataFileName
      print 'dataUrl: ', dataUrl

      print 'message: ', message
      if len(message) == 0 or message.find('Error') >= 0 or message.find('error:') >= 0 :
        success = False
        url = ''
        dataUrl = ''

    except ValueError, e:
        # chdir to current_dir in case the dir is changed to where the app is in the try block
        os.chdir(current_dir)
        print 'change dir back to: ', current_dir

        success = False
        message = str(e)
    except Exception, e:
        # chdir to current_dir in case the dir is changed to where the app is in the try block
        os.chdir(current_dir)
        print 'change dir back to: ', current_dir

        success = False
        ### message = str("Error caught in display_timeSeries2D()")
        message = str(e)

    return jsonify({
        'success': success,
        'message': message,
        'url': url,
        'dataUrl': dataUrl
    })


@app.route('/svc/twoDimSlice3D', methods=["GET"])
@crossdomain(origin='*')
def displayTwoDimSlice3D():
    """Run displayTwoDimSlice3D"""

    # status and message
    success = True
    message = "ok"
    url = ''
    dataUrl = ''

    # get model, var, start time, end time, pressure_level, lon1, lon2, lat1, lat2, months

    model = request.args.get('model', '')
    var = request.args.get('var', '')
    startT = request.args.get('start_time', '')
    endT = request.args.get('end_time', '')
    pr = request.args.get('pr', '')
    lon1 = request.args.get('lon1', '')
    lon2 = request.args.get('lon2', '')
    lat1 = request.args.get('lat1', '')
    lat2 = request.args.get('lat2', '')
    months = request.args.get('months', '')

    print 'model: ', model
    print 'var: ', var
    print 'startT: ', startT
    print 'endT: ', endT
    print 'pr: ', pr
    print 'lon1: ', lon1
    print 'lon2: ', lon2
    print 'lat1: ', lat1
    print 'lat2: ', lat2
    print 'months: ', months

    # get where the input file and output file are
    current_dir = os.getcwd()
    print 'current_dir: ', current_dir

    try:
      seed_str = model+var+startT+endT+pr+lon1+lon2+lat1+lat2+months
      tag = md5.new(seed_str).hexdigest()
      output_dir = current_dir + '/svc/static/twoDimSlice3D/' + tag
      print 'output_dir: ', output_dir
      if not os.path.exists(output_dir):
        os.makedirs(output_dir)

      # chdir to where the app is
      os.chdir(current_dir+'/svc/src/twoDimSlice3D')
      # instantiate the app. class
      c1 = call_twoDimSlice3D.call_twoDimSlice3D(model, var, startT, endT, pr, lon1, lon2, lat1, lat2, months, output_dir)
      # call the app. function
      (message, imgFileName, dataFileName) = c1.displayTwoDimSlice3D()
      # chdir back
      os.chdir(current_dir)

      hostname, port = get_host_port("host.cfg")
      print 'hostname: ', hostname
      print 'port: ', port

      url = 'http://' + hostname + ':' + port + '/static/twoDimSlice3D/' + tag + '/' + imgFileName
      print 'url: ', url
      dataUrl = 'http://' + hostname + ':' + port + '/static/twoDimSlice3D/' + tag + '/' + dataFileName
      print 'dataUrl: ', dataUrl

      print 'message: ', message
      if len(message) == 0 or message.find('Error') >= 0 or message.find('error:') >= 0 :
        success = False
        url = ''
        dataUrl = ''

    except ValueError, e:
        # chdir to current_dir in case the dir is changed to where the app is in the try block
        os.chdir(current_dir)
        print 'change dir back to: ', current_dir

        success = False
        message = str(e)
    except Exception, e:
        # chdir to current_dir in case the dir is changed to where the app is in the try block
        os.chdir(current_dir)
        print 'change dir back to: ', current_dir

        success = False
        ### message = str("Error caught in displayTwoDimSlice3D()")
        message = str(e)

    return jsonify({
        'success': success,
        'message': message,
        'url': url,
        'dataUrl': dataUrl
    })


@app.route('/svc/twoDimZonalMean', methods=["GET"])
@crossdomain(origin='*')
def displayTwoDimZonalMean():
    """Run displayTwoDimZonalMean"""

    # status and message
    success = True
    message = "ok"
    url = ''
    dataUrl = ''

    # get model, var, start time, end time, lat1, lat2, months

    model = request.args.get('model', '')
    var = request.args.get('var', '')
    startT = request.args.get('start_time', '')
    endT = request.args.get('end_time', '')
    lat1 = request.args.get('lat1', '')
    lat2 = request.args.get('lat2', '')
    months = request.args.get('months', '')

    print 'model: ', model
    print 'var: ', var
    print 'startT: ', startT
    print 'endT: ', endT
    print 'lat1: ', lat1
    print 'lat2: ', lat2
    print 'months: ', months

    # get where the input file and output file are
    current_dir = os.getcwd()
    print 'current_dir: ', current_dir

    try:
      seed_str = model+var+startT+endT+lat1+lat2+months
      tag = md5.new(seed_str).hexdigest()
      output_dir = current_dir + '/svc/static/twoDimZonalMean/' + tag
      print 'output_dir: ', output_dir
      if not os.path.exists(output_dir):
        os.makedirs(output_dir)

      # chdir to where the app is
      os.chdir(current_dir+'/svc/src/twoDimZonalMean')
      # instantiate the app. class
      c1 = call_twoDimZonalMean.call_twoDimZonalMean(model, var, startT, endT, lat1, lat2, months, output_dir)
      # call the app. function
      ### print 'before the call to c1.displayTwoDimZonalMean() ...'
      (message, imgFileName, dataFileName) = c1.displayTwoDimZonalMean()
      ### print 'after the call to c1.displayTwoDimZonalMean()'
      # chdir back
      os.chdir(current_dir)

      hostname, port = get_host_port("host.cfg")
      print 'hostname: ', hostname
      print 'port: ', port

      url = 'http://' + hostname + ':' + port + '/static/twoDimZonalMean/' + tag + '/' + imgFileName
      print 'url: ', url
      dataUrl = 'http://' + hostname + ':' + port + '/static/twoDimZonalMean/' + tag + '/' + dataFileName
      print 'dataUrl: ', dataUrl

      print 'message: ', message
      if len(message) == 0 or message.find('Error') >= 0 or message.find('error:') >= 0 :
        success = False
        url = ''
        dataUrl = ''

    except ValueError, e:
        # chdir to current_dir in case the dir is changed to where the app is in the try block
        os.chdir(current_dir)
        print 'change dir back to: ', current_dir

        success = False
        message = str(e)
    except Exception, e:
        # chdir to current_dir in case the dir is changed to where the app is in the try block
        os.chdir(current_dir)
        print 'change dir back to: ', current_dir

        success = False
        ### message = str("Error caught in displayTwoDimZonalMean()")
        message = str(e)


    return jsonify({
        'success': success,
        'message': message,
        'url': url,
        'dataUrl': dataUrl
    })


@app.route('/svc/threeDimZonalMean', methods=["GET"])
@crossdomain(origin='*')
def displayThreeDimZonalMean():
    """Run displayThreeDimZonalMean"""

    # status and message
    success = True
    message = "ok"
    url = ''
    dataUrl = ''

    # get model, var, start time, end time, lat1, lat2, pres1, pres2, months

    model = request.args.get('model', '')
    var = request.args.get('var', '')
    startT = request.args.get('start_time', '')
    endT = request.args.get('end_time', '')
    lat1 = request.args.get('lat1', '')
    lat2 = request.args.get('lat2', '')
    pres1 = request.args.get('pres1', '')
    pres2 = request.args.get('pres2', '')
    months = request.args.get('months', '')

    print 'model: ', model
    print 'var: ', var
    print 'startT: ', startT
    print 'endT: ', endT
    print 'lat1: ', lat1
    print 'lat2: ', lat2
    print 'pres1: ', pres1
    print 'pres2: ', pres2
    print 'months: ', months

    # get where the input file and output file are
    current_dir = os.getcwd()
    print 'current_dir: ', current_dir

    try:
      seed_str = model+var+startT+endT+lat1+lat2+pres1+pres2+months
      tag = md5.new(seed_str).hexdigest()
      output_dir = current_dir + '/svc/static/threeDimZonalMean/' + tag
      print 'output_dir: ', output_dir
      if not os.path.exists(output_dir):
        os.makedirs(output_dir)

      # chdir to where the app is
      os.chdir(current_dir+'/svc/src/threeDimZonalMean')
      # instantiate the app. class
      c1 = call_threeDimZonalMean.call_threeDimZonalMean(model, var, startT, endT, lat1, lat2, pres1, pres2, months, output_dir)
      # call the app. function
      ### (message, imgFileName) = c1.displayThreeDimZonalMean()
      (message, imgFileName, dataFileName) = c1.displayThreeDimZonalMean()
      # chdir back
      os.chdir(current_dir)

      hostname, port = get_host_port("host.cfg")
      print 'hostname: ', hostname
      print 'port: ', port

      url = 'http://' + hostname + ':' + port + '/static/threeDimZonalMean/' + tag + '/' + imgFileName
      print 'url: ', url
      dataUrl = 'http://' + hostname + ':' + port + '/static/threeDimZonalMean/' + tag + '/' + dataFileName
      print 'dataUrl: ', dataUrl

      print 'message: ', message
      if len(message) == 0 or message.find('Error') >= 0 or message.find('error:') >= 0 :
        success = False
        url = ''
        dataUrl = ''

    except ValueError, e:
        # chdir to current_dir in case the dir is changed to where the app is in the try block
        os.chdir(current_dir)
        print 'change dir back to: ', current_dir

        success = False
        message = str(e)
    except Exception, e:
        # chdir to current_dir in case the dir is changed to where the app is in the try block
        os.chdir(current_dir)
        print 'change dir back to: ', current_dir

        success = False
        ### message = str("Error caught in displayThreeDimZonalMean()")
        message = str(e)

    return jsonify({
        'success': success,
        'message': message,
        'url': url,
        'dataUrl': dataUrl
    })


@app.route('/svc/threeDimVerticalProfile', methods=["GET"])
@crossdomain(origin='*')
def displayThreeDimVerticalProfile():
    """Run displayThreeDimVerticalProfile"""

    # status and message
    success = True
    message = "ok"
    url = ''
    dataUrl = ''

    # get model, var, start time, end time, lon1, lon2, lat1, lat2, months

    model = request.args.get('model', '')
    var = request.args.get('var', '')
    startT = request.args.get('start_time', '')
    endT = request.args.get('end_time', '')
    lon1 = request.args.get('lon1', '')
    lon2 = request.args.get('lon2', '')
    lat1 = request.args.get('lat1', '')
    lat2 = request.args.get('lat2', '')
    months = request.args.get('months', '')

    print 'model: ', model
    print 'var: ', var
    print 'startT: ', startT
    print 'endT: ', endT
    print 'lon1: ', lon1
    print 'lon2: ', lon2
    print 'lat1: ', lat1
    print 'lat2: ', lat2
    print 'months: ', months

    # get where the input file and output file are
    current_dir = os.getcwd()
    print 'current_dir: ', current_dir

    try:
      seed_str = model+var+startT+endT+lat1+lat2+lon1+lon2+months
      tag = md5.new(seed_str).hexdigest()
      output_dir = current_dir + '/svc/static/threeDimVerticalProfile/' + tag
      print 'output_dir: ', output_dir
      if not os.path.exists(output_dir):
        os.makedirs(output_dir)

      # chdir to where the app is
      os.chdir(current_dir+'/svc/src/threeDimVerticalProfile')
      # instantiate the app. class
      c1 = call_threeDimVerticalProfile.call_threeDimVerticalProfile(model, var, startT, endT, lon1, lon2, lat1, lat2, months, output_dir)
      # call the app. function
      (message, imgFileName, dataFileName) = c1.displayThreeDimVerticalProfile()
      # chdir back
      os.chdir(current_dir)

      hostname, port = get_host_port("host.cfg")
      print 'hostname: ', hostname
      print 'port: ', port

      url = 'http://' + hostname + ':' + port + '/static/threeDimVerticalProfile/' + tag + '/' + imgFileName
      print 'url: ', url
      dataUrl = 'http://' + hostname + ':' + port + '/static/threeDimVerticalProfile/' + tag + '/' + dataFileName
      print 'dataUrl: ', dataUrl

      print 'message: ', message
      if len(message) == 0 or message.find('Error') >= 0 or message.find('error:') >= 0 :
        success = False
        url = ''
        dataUrl = ''

    except ValueError, e:
        # chdir to current_dir in case the dir is changed to where the app is in the try block
        os.chdir(current_dir)
        print 'change dir back to: ', current_dir

        success = False
        message = str(e)
    except Exception, e:
        # chdir to current_dir in case the dir is changed to where the app is in the try block
        os.chdir(current_dir)
        print 'change dir back to: ', current_dir

        success = False
        ### message = str("Error caught in displayThreeDimVerticalProfile()")
        message = str(e)

    return jsonify({
        'success': success,
        'message': message,
        'url': url,
        'dataUrl': dataUrl
    })


@app.route('/svc/scatterPlot2V', methods=["GET"])
@crossdomain(origin='*')
def displayScatterPlot2V():
    """Run displayScatterPlot2V"""

    # status and message
    success = True
    message = "ok"
    url = ''
    dataUrl = ''

    # get model1, var1, pres1, model2, var2, pres2, start time, end time, lon1, lon2, lat1, lat2

    model1 = request.args.get('model1', '')
    var1 = request.args.get('var1', '')
    pres1 = request.args.get('pres1', '')
    model2 = request.args.get('model2', '')
    var2 = request.args.get('var2', '')
    pres2 = request.args.get('pres2', '')
    startT = request.args.get('start_time', '')
    endT = request.args.get('end_time', '')
    lon1 = request.args.get('lon1', '')
    lon2 = request.args.get('lon2', '')
    lat1 = request.args.get('lat1', '')
    lat2 = request.args.get('lat2', '')

    print 'model1: ', model1
    print 'var1: ', var1
    print 'pres1: ', pres1
    print 'model2: ', model2
    print 'var2: ', var2
    print 'pres2: ', pres2
    print 'startT: ', startT
    print 'endT: ', endT
    print 'lon1: ', lon1
    print 'lon2: ', lon2
    print 'lat1: ', lat1
    print 'lat2: ', lat2

    # get where the input file and output file are
    current_dir = os.getcwd()
    print 'current_dir: ', current_dir

    try:
      seed_str = model1+var1+model2+var2+startT+endT+lat1+lat2+lon1+lon2
      tag = md5.new(seed_str).hexdigest()
      output_dir = current_dir + '/svc/static/scatterPlot2V/' + tag
      print 'output_dir: ', output_dir
      if not os.path.exists(output_dir):
        os.makedirs(output_dir)

      # chdir to where the app is
      os.chdir(current_dir+'/svc/src/scatterPlot2V')
      # instantiate the app. class
      c1 = call_scatterPlot2V.call_scatterPlot2V(model1, var1, pres1, model2, var2, pres2, startT, endT, lon1, lon2, lat1, lat2, output_dir)
      # call the app. function (0 means the image created is scatter plot)
      ### (message, imgFileName) = c1.displayScatterPlot2V(0)
      (message, imgFileName, dataFileName) = c1.display()
      # chdir back
      os.chdir(current_dir)

      hostname, port = get_host_port("host.cfg")
      print 'hostname: ', hostname
      print 'port: ', port
      print 'imgFileName: ', imgFileName

      url = 'http://' + hostname + ':' + port + '/static/scatterPlot2V/' + tag + '/' + imgFileName
      print 'url: ', url
      dataUrl = 'http://' + hostname + ':' + port + '/static/scatterPlot2V/' + tag + '/' + dataFileName
      print 'dataUrl: ', dataUrl

      print 'message: ', message
      if len(message) == 0 or message.find('Error') >= 0 or message.find('error:') >= 0 :
        success = False
        url = ''
        dataUrl = ''

    except ValueError, e:
        # chdir to current_dir in case the dir is changed to where the app is in the try block
        os.chdir(current_dir)
        print 'change dir back to: ', current_dir

        success = False
        message = str(e)
    except Exception, e:
        # chdir to current_dir in case the dir is changed to where the app is in the try block
        os.chdir(current_dir)
        print 'change dir back to: ', current_dir

        success = False
        ### message = str("Error caught in displayScatterPlot2V()")
        message = str(e)

    return jsonify({
        'success': success,
        'message': message,
        'url': url,
        'dataUrl': dataUrl
    })


@app.route('/svc/diffPlot2V', methods=["GET"])
@crossdomain(origin='*')
def displayDiffPlot2V():
    """Run displayDiffPlot2V"""

    # status and message
    success = True
    message = "ok"
    url = ''
    dataUrl = ''

    # get model1, var1,  model2, var2, start time, end time, lon1, lon2, lat1, lat2

    model1 = request.args.get('model1', '')
    var1 = request.args.get('var1', '')
    model2 = request.args.get('model2', '')
    var2 = request.args.get('var2', '')
    startT = request.args.get('start_time', '')
    endT = request.args.get('end_time', '')
    lon1 = request.args.get('lon1', '')
    lon2 = request.args.get('lon2', '')
    lat1 = request.args.get('lat1', '')
    lat2 = request.args.get('lat2', '')

    print 'model1: ', model1
    print 'var1: ', var1
    print 'model2: ', model2
    print 'var2: ', var2
    print 'startT: ', startT
    print 'endT: ', endT
    print 'lon1: ', lon1
    print 'lon2: ', lon2
    print 'lat1: ', lat1
    print 'lat2: ', lat2

    # get where the input file and output file are
    current_dir = os.getcwd()
    print 'current_dir: ', current_dir

    try:
      seed_str = model1+var1+model2+var2+startT+endT+lat1+lat2+lon1+lon2
      tag = md5.new(seed_str).hexdigest()
      output_dir = current_dir + '/svc/static/diffPlot2V/' + tag
      print 'output_dir: ', output_dir
      if not os.path.exists(output_dir):
        os.makedirs(output_dir)

      # chdir to where the app is
      os.chdir(current_dir+'/svc/src/scatterPlot2V')
      # instantiate the app. class
      c1 = call_scatterPlot2V.call_scatterPlot2V(model1, var1, model2, var2, startT, endT, lon1, lon2, lat1, lat2, output_dir)
      # call the app. function (1 means the image created is difference plot)
      (message, imgFileName, dataFileName) = c1.displayScatterPlot2V(1)
      # chdir back
      os.chdir(current_dir)

      hostname, port = get_host_port("host.cfg")
      print 'hostname: ', hostname
      print 'port: ', port

      url = 'http://' + hostname + ':' + port + '/static/diffPlot2V/' + tag + '/' + imgFileName
      print 'url: ', url
      dataUrl = 'http://' + hostname + ':' + port + '/static/diffPlot2V/' + tag + '/' + dataFileName
      print 'dataUrl: ', dataUrl

      print 'message: ', message
      if len(message) == 0 or message.find('Error') >= 0 or message.find('error:') >= 0 :
        success = False
        url = ''
        dataUrl = ''

    except ValueError, e:
        # chdir to current_dir in case the dir is changed to where the app is in the try block
        os.chdir(current_dir)
        print 'change dir back to: ', current_dir

        success = False
        message = str(e)
    except Exception, e:
        # chdir to current_dir in case the dir is changed to where the app is in the try block
        os.chdir(current_dir)
        print 'change dir back to: ', current_dir

        success = False
        ### message = str("Error caught in displayDiffPlot2V()")
        message = str(e)

    return jsonify({
        'success': success,
        'message': message,
        'url': url,
        'dataUrl': dataUrl
    })


