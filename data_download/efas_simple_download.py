#! usr/bin/python3

#api request for extended range reforecast 

import cdsapi
import sys
#import time 
import os
#print( os.getcwd())

#print('Number of arguments:', len(sys.argv), 'arguments.')
#print('Argument List:', str(sys.argv))

# the order of the arguments is 
#ftype = efas-reforecast or efas seasonal reforecast (known)
ptype = sys.argv[1]	# ensamble or control (acquire)
if ptype=='e':
	ptype = 'ensemble_perturbed_reforecasts'
	name = "_e"
else:
	ptype = 'control_reforecast'
	name = "_c"
#variab = river_discharge_in_the_last_6_hours' (known)
yr = sys.argv[2]
mth = sys.argv[3]
day = sys.argv[4]
#lt = [array] (known)
#format = 'netcdf' (known)
name = "raw_efrf_" + yr + mth + day + name
months = ["january", "february", "march", "april", "may", "june", "july",
    "august", "september", "october", "november", "december"];
#print(name)
#print( months[int(mth)-1] )

c = cdsapi.Client()
#time.sleep(15+int(day))


c.retrieve(
    'efas-reforecast',
    {
        'product_type': ptype,
        'variable': 'river_discharge_in_the_last_6_hours',
        'model_levels': 'surface_level',
        'hyear': yr,
        'hmonth': months[int(mth)-1],
        'hday': day,
        'leadtime_hour': [
            '0', '1002', '1008',
            '1014', '102', '1020',
            '1026', '1032', '1038',
            '1044', '1050', '1056',
            '1062', '1068', '1074',
            '108', '1080', '1086',
            '1092', '1098', '1104',
            '114', '12', '120',
            '126', '132', '138',
            '144', '150', '156',
            '162', '168', '174',
            '18', '180', '186',
            '192', '198', '204',
            '210', '216', '222',
            '228', '234', '24',
            '240', '246', '252',
            '258', '264', '270',
            '276', '282', '288',
            '294', '30', '300',
            '306', '312', '318',
            '324', '330', '336',
            '342', '348', '354',
            '36', '360', '366',
            '372', '378', '384',
            '390', '396', '402',
            '408', '414', '42',
            '420', '426', '432',
            '438', '444', '450',
            '456', '462', '468',
            '474', '48', '480',
            '486', '492', '498',
            '504', '510', '516',
            '522', '528', '534',
            '54', '540', '546',
            '552', '558', '564',
            '570', '576', '582',
            '588', '594', '6',
            '60', '600', '606',
            '612', '618', '624',
            '630', '636', '642',
            '648', '654', '66',
            '660', '666', '672',
            '678', '684', '690',
            '696', '702', '708',
            '714', '72', '720',
            '726', '732', '738',
            '744', '750', '756',
            '762', '768', '774',
            '78', '780', '786',
            '792', '798', '804',
            '810', '816', '822',
            '828', '834', '84',
            '840', '846', '852',
            '858', '864', '870',
            '876', '882', '888',
            '894', '90', '900',
            '906', '912', '918',
            '924', '930', '936',
            '942', '948', '954',
            '96', '960', '966',
            '972', '978', '984',
            '990', '996',
        ],
        'format': 'netcdf',
    },
    name+'.nc')


f = open(os.getcwd()+"/data_download/efrf_downloaded.txt", "a")
f.write(name+"\n")
f.close()