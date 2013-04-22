from flask import Flask

app = Flask(__name__)
app.config.from_pyfile('../settings.cfg')

import services.views
import services.services
import services.src
