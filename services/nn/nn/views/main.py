from flask import render_template

from nn import app

@app.route('/')
def index():
    #app.logger.debug("Got here")
    return render_template('index.html', title="NN",
                           content="Nearest Neighbor Search")
