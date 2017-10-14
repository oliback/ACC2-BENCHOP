from flask import Flask, request
import subprocess

app = Flask(__name__)

parameterList = ["octave", "Table.m"]


#Run all problems with default parameters
@app.route('/runall', methods=['GET'])
def run_all():
	return str(subprocess.call(["octave", "Table.m", "all"]))



#Run specified problem with specified parameters
#Example call: 
#curl -i "http://1.2.3.4:1234/p1a?K=1&F=5"

@app.route('/<problem>', methods=['GET'])
def input(problem):
	
	parameterList.append(problem)	
	
	#iterate through the dict from request to get parameters
	for k,v in request.args.iteritems():
		parameter = k + "=" + v
		parameterList.append(parameter)
	
	#print(parameterList)
	
	#call octave with parameters
	data = str(subprocess.call(parameterList))
	
	return data

if __name__ == '__main__':
	app.run(host='0.0.0.0',debug=True)
