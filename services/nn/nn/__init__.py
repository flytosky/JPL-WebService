from flask import Flask

app = Flask(__name__)
app.config.from_pyfile('../settings.cfg')

import nn.views
import nn.services
import nn.src
