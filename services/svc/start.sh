#!/bin/bash
gunicorn -w6 --timeout 300 --graceful-timeout 300 -b 0.0.0.0:8890 -k tornado --daemon -p svc.pid svc:app
