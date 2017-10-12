#!flask/bin/python
from flask import Flask, request, jsonify
import subprocess


app = Flask(__name__)

octave = "octave"
tableM = "Table.m"


#run all problems
@app.route('/runall', methods=['GET'])
def run_all():
	return str(subprocess.call([octave, tableM, "all"]))


#run p1a
@app.route('/p1a', methods=['GET'])
def p1a():
	return str(subprocess.call([octave, tableM, "p1a"])) 


#input args
@app.route('/recompute', methods=['GET'])
def input():

	#not finished
	return str(subprocess.call([octave, tableM, problem, parameter]))


if __name__ == '__main__':
    app.run(host='0.0.0.0',debug=True)
