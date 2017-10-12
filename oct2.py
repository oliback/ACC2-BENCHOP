#!flask/bin/python
from flask import Flask, jsonify
import subprocess
#import sys


app = Flask(__name__)

octave = "octave"
tableM = "Table.m"


@app.route('/test', methods=['GET'])
def cow_say():
	testdata = "test"
	subprocess.call("date")
	return testdata

@app.route('/p1a', methods=['GET'])
def p1a():
	return str(subprocess.call([octave, tableM, "p1a"]))
	 

if __name__ == '__main__':
    app.run(host='0.0.0.0',debug=True)
