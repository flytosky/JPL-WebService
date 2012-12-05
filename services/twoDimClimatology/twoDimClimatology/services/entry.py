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

    # get radius
    model = request.args.get('model', 'ukmo')

    try:
      # chdir to where the app is
      current_dir = os.getcwd()
      os.chdir(current_dir+'/twoDimClimatology/src')
      c1 = call_twoDimClimatology.call_twoDimClimatology(model)
      message = c1.displayTwoDimClimatology()
      # chdir back
      os.chdir(current_dir)
      print 'current dir: ', os.getcwd()

      url = 'jpg file, fix me!!!'
    except ValueError, e:
        success = False
        message = str(e)

    return jsonify({
        'success': success,
        'message': message,
        'url': url,
    })

