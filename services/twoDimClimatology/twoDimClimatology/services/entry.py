import os, hashlib, shutil
from datetime import datetime

from flask import jsonify, request, url_for, make_response
from werkzeug import secure_filename

from twoDimClimatology import app
from twoDimClimatology.src import call_twoDimClimatology

@app.route('/twoDimClimatology/display', methods=["GET"])
def display():
    """Run displayTwoDimClimatology"""

    # status and message
    success = True
    message = "ok"
    url = ''

    # get model, input_file, output_file
    model = request.args.get('model', 'ukmo')
    data_file = request.args.get('data', '')
    image_file = request.args.get('image', '')

    try:
      # get where the input file and output file are
      current_dir = os.getcwd()
      print 'current_dir: ', current_dir
      data_file = current_dir + '/twoDimClimatology/' + data_file
      image_file1 = current_dir + '/twoDimClimatology/' + image_file

      # chdir to where the app is
      os.chdir(current_dir+'/twoDimClimatology/src')
      # instantiate the app. class
      c1 = call_twoDimClimatology.call_twoDimClimatology(model, data_file, image_file1)
      # call the app. function
      message = c1.displayTwoDimClimatology()
      # chdir back
      os.chdir(current_dir)

      url = 'http://oscar2.jpl.nasa.gov:8088' + image_file

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

