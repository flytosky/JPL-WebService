twoDimClimatology
====

Two Dimemsional Climatology

Install Dependencies via pip
----------------------------
source activate
pip install flask
pip install gunicorn
pip install tornado
pip install httplib2
pip install lxml

To install/develop
--------------------------
python setup.py develop|install

To run in development mode
--------------------------
python run.py

To run in production mode
--------------------------
gunicorn -w2 -b 0.0.0.0:8888 -k tornado --daemon -p twoDimClimatology.pid twoDimClimatology:app
