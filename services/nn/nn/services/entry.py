import os, hashlib, shutil
import math
from datetime import datetime

from flask import jsonify, request, url_for, make_response
from werkzeug import secure_filename

from nn import app
from nn.src import circle

@app.route('/nn/ls', methods=["GET"])
def ls():
    """Run ls"""

    # status and message
    success = True
    message = ""

    # get query
    query = request.args.get('query', '*')

    # get ls result
    docs = []
    ### try: docs = dirList=os.listdir('.')
    try: docs = dirList=os.listdir(query)
    except Exception, e:
        success = False
        message = str(e)

    return jsonify({
        'success': success,
        'message': message,
        'docs': docs,
        'query': query,
    })

@app.route('/nn/area', methods=["GET"])
def area():
    """calculate area of circle"""

    # status and message
    success = True
    message = "no error"

    # get radius
    r = request.args.get('r', '*')

    try:
      r = float(r)
      ### a = math.pi * r * r
      c1 = circle.circle(r)
      a = c1.area()
    except ValueError, e:
        success = False
        message = str(e)
        a = 'undefied'

    return jsonify({
        'success': success,
        'message': message,
        'r': r,
        'area': a,
    })


@app.route('/nn/perimeter', methods=["GET"])
def perimeter():
    """calculate perimeter of circle"""

    # status and message
    success = True
    message = "no error"

    # get radius
    r = request.args.get('r', '*')

    try:
      r = float(r)
      ### p = 2 * math.pi * r
      c1 = circle.circle(r)
      p = c1.perimeter()
    except ValueError, e:
        success = False
        message = str(e)
        p = 'undefied'

    return jsonify({
        'success': success,
        'message': message,
        'r': r,
        'perimeter': p,
    })


@app.route('/data/upload', methods=["POST"])
def upload():
    """Upload file."""

    # save file securely
    f = request.files.get('file', None)
    if f is None:
        # return error json with 500 code
        return jsonify({
            'success': False,
            'message': "Parameter 'file' not specified.",
            'md5': "",
        }), 500

    # save to temp file
    fname = secure_filename(f.filename)
    ts = datetime.now()
    tsstr = ts.isoformat('T').replace('-','').replace(':','')
    tsdir = os.path.join('/tmp', 'ldos_upload', '%s-%s' % (tsstr, fname))
    validateDirectory(tsdir)
    temp = os.path.join(tsdir, fname)
    f.save(temp)
 
    # copy temp file to md5 location in fuse repo
    md5hash, md5file = md5Location(temp)
    shutil.rmtree(tsdir)

    return jsonify({
        'success': True,
        'message': "",
        'md5': md5hash,
    })
