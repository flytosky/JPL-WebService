#!/bin/bash
gunicorn -w2 -b 0.0.0.0:8889 -k tornado --daemon -p nn.pid nn:app
