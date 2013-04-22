from flask import render_template

from services import app

@app.route('/')
def index():
    #app.logger.debug("Got here")
    return render_template('index.html', title="services",
                           content="CMAC web services")
