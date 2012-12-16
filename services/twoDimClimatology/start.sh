#!/bin/bash
gunicorn -w2 -b 0.0.0.0:8888 -k tornado --daemon -p twoDimClimatology.pid twoDimClimatology:app
