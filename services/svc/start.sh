#!/bin/bash
gunicorn -w2 -b 0.0.0.0:8890 -k tornado --daemon -p svc.pid svc:app
