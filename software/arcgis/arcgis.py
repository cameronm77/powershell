#!/usr/bin/env python3

##########
# Update .sde files in a particular directory
##########

import arcpy
from glob import glob
import os

def main():

    # This line is now grabbed programatically
    #ent_gdb = "C:\\gdbs\\enterprisegdb.sde"

    # may need to be updated depending on file location of keycodes UPDATE
    authorization_file = "C:\\temp\\keycodes"

    # this finds all of the files with file extension .sde in the folder you
    # specify. the file list returns with the entire filepath
    # example: /home/rgeist/all_devices_macs.txt
    file_list = glob(os.path.join('Y:\\<ComputerName>\\PRIVATE\\08-ArcGIS\\ArcGIS_Connect', '*.sde'))

    # goes through the files in your directory and updates them
    for ent_gdb in file_list:
        #arcpy.UpdateEnterpriseGeodatabaseLicense_management(ent_gdb, authorization_file)
		print(ent_gdb)
	#Switch the print back to arcpy to run the update geodatabase tool
if __name__ == '__main__':
    main()
