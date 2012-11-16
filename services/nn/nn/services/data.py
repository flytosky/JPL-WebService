import os, hashlib, shutil
from datetime import datetime

from flask import jsonify, request, url_for, make_response
from werkzeug import secure_filename

from ldos import app
from ldos.lib import solr
from ldos.lib.utils import validateDirectory
from ldos.lib.indexer import md5Location


@app.route('/data/search', methods=["GET"])
def search():
    """Run search on SOLR and return SOLR docs."""

    # status and message
    success = True
    message = ""

    # get query
    query = request.args.get('query', '*')

    # get solr docs
    docs = []
    try: docs = solr.search(query)
    except Exception, e:
        success = False
        message = str(e)

    return jsonify({
        'success': success,
        'message': message,
        'docs': docs,
        'query': query,
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

@app.route('/data/download', methods=["GET"])
def download():
    """Download file by MD5 hash."""

    # status and message
    success = True
    message = ""

    # get MD5 hash
    md5 = request.args.get('hash', None)
    if md5 is None:
        # return error json with 500 code
        return jsonify({
            'success': False,
            'message': "Parameter 'hash' not specified.",
        }), 500

    # get solr docs
    docs = []
    try: docs = solr.search("hash:%s" % md5)
    except Exception, e:
        success = False
        message = str(e)

    # loop over and return
    for doc in docs:
        local_path = doc['path'][0]
        content_type = doc['content_type']
        if not os.path.isfile(local_path): continue
         
        # make custom response
        f = open(local_path)
        content = f.read()
        f.close()
        resp = make_response(content)
        resp.headers["content-type"] = content_type
        resp.headers["content-disposition"] = 'attachment; filename="%s"' % \
            os.path.basename(local_path)

        return resp

    # if couldn't find raise
    return "Failed to find any local files for hash %s." % md5, 500

@app.route('/data/delete', methods=["GET"])
def delete():
    """Delete file by MD5 hash."""

    # status and message
    success = True
    message = ""

    # get MD5 hash
    md5 = request.args.get('hash', None)
    if md5 is None:
        # return error json with 500 code
        return jsonify({
            'success': False,
            'message': "Parameter 'hash' not specified.",
        }), 500

    # get solr docs
    docs = []
    try: docs = solr.search("hash:%s" % md5)
    except Exception, e:
        success = False
        message = str(e)

    # loop over and return
    for doc in docs:
        local_path = doc['path'][0]
        if not os.path.isfile(local_path): continue

        # remove
        os.unlink(local_path)

    return jsonify({
        'success': True,
        'message': "",
    })
