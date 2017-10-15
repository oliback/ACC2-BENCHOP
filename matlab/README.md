# ACC2-BENCHOP matlab section
##### Installing Octave
To install octave version 4 on Ubuntu: 
```
sudo apt-get install octave
```
Table.m can then be ran with the command:
```
octave Table.m
```
It's also possible to use the Octave gui.

On windows, a latex table is produced, on other systems, a simple file with the values is saved.

## command line arguments
Possible parameters to to Table.m:
- p1a
- p1b
- p1c
- p2a
- p2b
- p2c
- all

Example of how the command line arguments can be passed:
```
octave Table.m p1a p1b p2c	(runs three problems)
octave Table.m all	        (runs all problems)
```
It is also possible to specify parameters for each problem, by stating them after the problem.

Default parameter values will be used for each parameter not specified.

Possible parameters:
 - S1 (int)
 - S2 (int)
 - S3 (int)
 - K (int)
 - T (int)
 - r (float)
 - sig (float)
 - Bm (float) (will be multiplied with K to create the B parameter)

Example:
```
Octave Table.m p1a S1=80 S2=90 p2a r=0.01 sig=0.05
```
