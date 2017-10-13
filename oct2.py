#!flask/bin/python
from flask import Flask, request, jsonify
import subprocess
import json

app = Flask(__name__)

parameterList = ["octave", "Table.m"]



#Run all problems with default parameters
@app.route('/runall', methods=['GET'])
def run_all():
	return str(subprocess.call([octave, tableM, "all"]))



#Run specified problem with specified parameters
@app.route('/<problem>', methods=['GET'])
def input(problem):
	
	parameterList.append(problem)	
	
	#iterate through the dict from request to get parameters
	for k,v in request.args.iteritems():
		parameter = k + "=" + v
		parameterList.append(parameter)
	
	print(parameterList)
	#call octave with parameters
	data = str(subprocess.call(parameterList))
	
	return data

if __name__ == '__main__':
    app.run(host='0.0.0.0',debug=True)
