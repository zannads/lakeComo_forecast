# lakeComo_forecast
 
This project includes all the code developed during the production of my Master thesis (Zanutto, 2022)[http://hdl.handle.net/10589/190646].

The goal of the thesis was to investigate the possibility to use operational hydrological forecasts and train a control policy for the release of a water reservoir, the Lake Como in Italy, that was directly informed by the forecasts.

The forecasts are: (i) the probabilistic open source EFAS (reforecast)[https://cds.climate.copernicus.eu/cdsapp#!/dataset/efas-reforecast?tab=overview] and (ii) (seasonal reforecast)[https://cds.climate.copernicus.eu/cdsapp#!/dataset/efas-seasonal-reforecast?tab=overview], (iii) a short-term deterministic inflow forecast to the lake produced by a local company (these data are protected). 

The historical level and outflow measurements used are not publicy available as well.

## 0. Data upload: *data_parser* folder
All the data had different origin, format and variables. It was necessary to format all in the same way. 
In the ***data_parser*** folder, you can find all the classes, functions and scripts that handle the data. 
In particular I decided to use all time series parsed into a *Timetable* MATLAB Object. 
The forecasts where similar, but not equal, hence I created a class (hydrological) *forecast* to handle them. Because of the different definition between the data, the main variable is the *inflow in the **next** 24 hours* ($inf_24$), hence between time $t$ and $t+24$. 
>[! Note]
> This decision of using the future discharge ($inf_24$) was a decision made at the beginning of the development, with not a lot of knowledge of the system and forced by some data I received early in the development, it is not advisable. Following version should use the *inflow in the **past** x hours* ($dis_x$) as EFASes (and any **GOOD** hydrological model) do.   
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

## 1. Forecast Analysis 
### Determinstic Analysis 

### Probabilistic Analysis