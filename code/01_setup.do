*******************************************************
* 01_setup.do — Session setup and folders
*******************************************************
version 17
set more off

* Create folders if not present
cap mkdir "data"
cap mkdir "data/raw"
cap mkdir "data/clean"
cap mkdir "output"
cap mkdir "output/tables"
cap mkdir "output/figures"
cap mkdir "logs"
