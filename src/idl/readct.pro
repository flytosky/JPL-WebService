;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;+
; This is my own program to read a color table from a file into arrays
; and return the information.
;
; @param ct      {type=Int}
;                The number of the color table to use.
; @keyword file  {type=String}
;                The name of a file containing the desired color table
;                other than the default color table set in InitColorBoss.
; @keyword red   {type=Byte[]} {out}
;                The red components of the colors in the color table.
; @keyword green {type=Byte[]} {out}
;                The green components of the colors in the color table.
; @keyword blue  {type=Byte[]} {out}
;                The blue components of the colors in the color table.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro ReadCt,ct,file=file,red=red,green=green,blue=blue

common ColBoss,config

IF N_Elements(config) EQ 0 THEN InitColorBoss

IF N_Elements(ct) EQ 0 THEN ct = config.defaultct
IF N_Elements(file) EQ 0 THEN file = config.defaultFile

Openr, unit, file, /GET_LUN, /BLOCK

noTables = 0B
ReadU, unit, noTables

IF ct GE noTables THEN MyMessage, /ERROR, 'No such table in the file'

assocArray = Assoc(unit, BytArr(256), 1)

red = assocArray(ct*3)
green = assocArray(ct*3+1)
blue = assocArray(ct*3+2)

Free_lun,unit

END

