from flask import render_template

from twoDimMap import app

@app.route('/')
def index():
    #app.logger.debug("Got here")
    return render_template('index.html', title="twoDimMap",
                           content="Two Dimensional Map")
