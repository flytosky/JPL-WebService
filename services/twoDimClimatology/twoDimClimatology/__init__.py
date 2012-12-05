from flask import Flask

app = Flask(__name__)
app.config.from_pyfile('../settings.cfg')

import twoDimClimatology.views
import twoDimClimatology.services
import twoDimClimatology.src
