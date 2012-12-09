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

    # get model, input_file, output_file
    model = request.args.get('model', 'ukmo')
    data_file = request.args.get('data', '')
    image_file = request.args.get('image', '')

    try:
      # chdir to where the app is
      current_dir = os.getcwd()
      print 'current_dir: ', current_dir
      data_file = current_dir + '/' + data_file
      image_file = current_dir + '/' + image_file
      os.chdir(current_dir+'/twoDimClimatology/src')
      c1 = call_twoDimClimatology.call_twoDimClimatology(model, data_file, image_file)
      message = c1.displayTwoDimClimatology()
      # chdir back
      os.chdir(current_dir)

      url = 'http://oscar2.jpl.nasa.gov:8888/' + image_file
    except ValueError, e:
        success = False
        message = str(e)

    return jsonify({
        'success': success,
        'message': message,
        'url': url,
    })

