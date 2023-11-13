# lakeComo_forecast
 
This project includes all the code developed during the production of my Master thesis [Zanutto, 2022](http://hdl.handle.net/10589/190646).

The goal of the thesis was to investigate the possibility to use operational hydrological forecasts and train a control policy for the release of a water reservoir, the Lake Como in Italy, that was directly informed by the forecasts.

The forecasts are: (i) the probabilistic open source EFAS [reforecast](https://cds.climate.copernicus.eu/cdsapp#!/dataset/efas-reforecast?tab=overview) and (ii) [seasonal reforecast](https://cds.climate.copernicus.eu/cdsapp#!/dataset/efas-seasonal-reforecast?tab=overview), (iii) a short-term deterministic inflow forecast to the lake produced by a local company (these data are protected). 

The historical level and outflow measurements used are not publicy available as well.

- *setup_base* where insert the path to the folder where all data will be included. All the paths in this Readme will be relative to this *data_folder*.  

## 0. Data upload: *data_parser* folder
All the data had different origin, format and variables. It was necessary to format all in the same way. 
In the ***data_parser*** folder, you can find all the classes, functions and scripts that handle the data. 
In particular I decided to use all time series parsed into a *Timetable* MATLAB Object. 
The forecasts where similar, but not equal, hence I created a class (hydrological) *forecast* to handle them. Because of the different definition between the data, the main variable is the *inflow in the **next** 24 hours* ($inf_{24}$), hence between time $t$ and $t+24$. 
>[! Note]
> This decision of using the future discharge ($inf_{24}$) was a decision made at the beginning of the development, with not a lot of knowledge of the system and forced by some data I received early in the development, it is not advisable. Following version should use the *discharge in the **past** x hours* ($dis_x$) as EFASes (and any **GOOD** hydrological model) do.   
### Main functions/script/classes
- *parse_probabilistic_forecast*: creates *forecast* objects for the EFAS forecast starting from the *.NetCDF* raw file.
- *parse_determinstic_forecast*: creates *forecast* objects for the Det forecast starting from *.xlsx* files. 
- *parse_benchmark*: creates a *Timetable* MATLAB Object for the historical measurements and creates some benchmark *forecast* starting from the inflow.  
- *myDOY*: given a datetime array returns an array with the corresponding day of the year, neglecting leap years. 
- *moving_average*: performs a moving average on a *Timetable* object.
- *forecast*: class for a hydrological forecast object.
- *ciclostationary*: computes the annual *cyclostationary* mean of a Timetable object.

### Additional f/s/c
- *timeSeries_generator* creates *.txt* files for external use. It is just a script to render the production faster, not necessary. 
- *cicloseriesGenerator*: fits a cyclostationary array in a timearray.

### Step by Step Instructions
#### Pre:
Your Raw Data should have this structure in the folder *LakeComoRawData*: 
- *efrf* sub seasonal efas forecast
	- *LocationName* (Fuentes, Olginate, LakeComo, Mandello)
		- one file for each instance (twice per week, 99-18). The original data from EFAS are $dis_{06}$, here the data are already processed as $dis_{24}$.
- *efsr* seasonal efas forecast
	- *LocationName* 
		- one file for each instance (monthly, 99-19). Data as $dis_{24}$.
- *PROGEA* 
	- private info. (Data are in excel)
- *utils* 
	- *\*.txt* files with data about the Lake Como, e.g. historical measurements. 

#### Run:
`setup_base;
parse_probabilistic_forecast;
parse_determinstic_forecast;
parse_benchmark;`

#### Output: 
each object in its own class, save each object in a file in *LakeComoProcessedData*. 

## 1. Forecast Analysis *stats*, *efas_analysis* folder 
- The folder *stats* contains the functions to calculate various scores on the forecasts. 
- The folder *efas_analyis* contains the script to use the functions in a automated way and saving all the results in MATLAB *Table* objects. I don't suggest looking at them, as they are not optimized.

### Step by Step Instructions
#### Pre: 
- Install the *Statistical Toolbox*, for the function fitdist.
- Step 0 or load all the files in *LakeComoProcessedData* in the `workspace`.

#### Run:
`setup_base;
nameOfTheScript;` 

#### Output:
Tables with the results, save them in the folder *LakeComoSolutions/Scores*. 

## 2. Perfect Operating Policy *ddp* folder
The folder contains the script to compute the Perfect Operating Policy (POP, [Giuliani et. al, 2015](https://onlinelibrary.wiley.com/doi/abs/10.1002/2015WR017044)), i.e. the policy assuming perfect knowledge of the future. 
### Main scripts 
- Run 1st *lakeComo_ddp_99_18_new_setup* to set up the workspace.
- Run 2nd *lakeComo_ddp_gen_no_vr* to compute the solutions.
>[! Note]
> This script doesn't have the constraint on the speed release, it is checked a posteriori with the function *speed_constraint_check*. 
> Including the constraint directly in the simulation would have meant increasing the dimensionality of the state space, hence, of the computational time. 
- optional *ddpsol_reoder* to reoder in a struct the solutions.

#### Pre:
Load the historical data in the `worskpace`.

#### Run:
`setup_base;
lakeComo_ddp_99_18_new_setup;
lakeComo_ddp_gen_no_vr;
ddpsol_reoder;`

#### Output:
A struct with all the solutions of the ddp. See *ddpsol_reoder* for the info on the struct.
Save the variable in *Solutions/DDP*

### Additional scripts
- *lakeComo_ddp_denaro_setup* substitutes *lakeComo_ddp_99_18_new_setup* in setting up the workspace, it is intended to try and replicate the result of [Denaro et. al, 2017](https://linkinghub.elsevier.com/retrieve/pii/S0309170816304651).

## 3. Input Variable Selection *ivs* folder
In this folder you find the scripts to run the IVS on the processed data. You can find the main algorithms and everything [here](https://github.com/zannads/MATLAB_IterativeInputSelection_with_Rtree-c.git).
It is simply a fork on the original work of [Galelli, Castelletti, 2013](doi:10.1002/wrcr.20339) available [here](https://github.com/Critical-Infrastructure-Systems-Lab/Iterative_Input_Selection.git)

#### Pre: 
- Install the IVS Toolbox.
- Put in the folder *candidate_variables_99_18* all the *.txt* files on which you want to run the IVS. This files have to be formatted correctly, i.e. txt files with a value for each row; total of 7305 values, one per day.
Select the number of the solution in the ddp that you want, create two txt files with release and level *release_sol#_99_18.txt* and save it in *Solutions/DDP*.

#### Run:
`code = "something";
script_ivs_run`

#### Output:
The workspace resulting from each run will be saved as *Solutions/IVS/sol#/_ivs_something_sol#_n#.mat*. 
It's a script and it access the base `workspace`, so it is possible to comment the line where the parameters are defined and define them directly in the command window. 

## 4. Evolutionary Multi-Objective Direct Policy Search *dps_support*
The code to run the optimization is available [here](https://github.com/EILab-Polimi/LakeComo.git). The two specific models developed during the thesis (new problem formulation and joint learning) are available in [my fork of the project](https://github.com/zannads/LakeComo.git).
However, in this folder you can find some functions to upload the result in a struct *matlabize_solution*, extract the parameters of the control law given the point in the pareto front *extract_params*. 

#### Pre:
Solutions are saved in *Solutions/EMODPS* or *Solutions/EMODPS_autoselect* if using the extended policy.
The structure is always:
- */data*    the files uploaded when creating the object.
- */output*  the output files for each seed produce by Borg and the settings file used to produce them.
- */runtime* the runtime files for each seed produce by Borg.

#### Run:
use *matlabize_solution* normally.

#### Output:
A struct as explained by *matlabize_solution*.

## A1 Plots *draws* folder 
All the scripts to generate the plots are here. 

## A2 Lake Como model 
The classes and functions of the model of Lake Como that is implemented in c++ when running the optimization, but in MATLAB to run simple simulations. 
- *model_lakecomo*:			  original class, the control policy is parametrized only by a combination of RBF.
- *model_lakecomoAutoselect*: new class, other than the classic combination of RBF the algorithm selects more parameters from the input as well. 

#### Pre:
Solutions are saved in *Solutions/EMODPS* or *Solutions/EMODPS_autoselect* if using the extended policy.
The structure is always:
- */data* the files uploaded when creating the object.
- */output* the output files for each seed and the settings file used to produce them.
- */runtime* the runtime files for each seed produce by Borg.

#### Run:
is the same with *model_lakeComo* or *model_lakecomoAutoselect*, just change the name of the constructor.
`solN = ##;
sol = matlabize_solution( path );
mdc = model_lakecomo( sol.settings_file );
[J, h, r] = mdc.evaluate( extract_params( sol, solN ) );`

#### Ouput: 
An object of the class *model_lakecomo*, the results of the simulation (objectives J, level h, release r)
