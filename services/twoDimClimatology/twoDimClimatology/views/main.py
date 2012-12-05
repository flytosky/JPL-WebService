from flask import render_template

from twoDimClimatology import app

@app.route('/')
def index():
    #app.logger.debug("Got here")
    return render_template('index.html', title="twoDimClimatology",
                           content="Two Dimensional Climatology")
