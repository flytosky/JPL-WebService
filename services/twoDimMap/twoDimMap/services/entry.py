import os, hashlib, shutil
from datetime import datetime
import md5

from flask import jsonify, request, url_for, make_response
from werkzeug import secure_filename

from twoDimMap import app
from twoDimMap.src import call_twoDimMap

@app.route('/twoDimMap/display', methods=["GET"])
def display():
    """Run displayTwoDimMap"""

    # status and message
    success = True
    message = "ok"
    url = ''

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

    try:
      # get where the input file and output file are
      current_dir = os.getcwd()
      print 'current_dir: ', current_dir
      tag = md5.new(model+startT+endT+lon1+lat1).hexdigest()
      output_dir = current_dir + '/twoDimMap/static/' + tag
      print 'output_dir: ', output_dir
      if not os.path.exists(output_dir):
        os.makedirs(output_dir)

      # chdir to where the app is
      os.chdir(current_dir+'/twoDimMap/src')
      # instantiate the app. class
      c1 = call_twoDimMap.call_twoDimMap(model, var, startT, endT, lon1, lon2, lat1, lat2, months, output_dir)
      # call the app. function
      message = c1.displayTwoDimMap()
      # chdir back
      os.chdir(current_dir)

      url = 'http://cmacws.jpl.nasa.gov:8088/twoDimMap/static/' + tag

      if message.find('Error') >= 0:
        success = False
        url = ''

    except ValueError, e:
        success = False
        message = str(e)

    return jsonify({
        'success': success,
        'message': message,
        'url': url,
    })

