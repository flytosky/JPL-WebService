;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;+
; Loads a color table into the requested range.
; <p>
; Part of the ColorBoss suite
;
; @param ct     A color table.
; @param range  {type=Long[]}
;               A range to put the colors into
; @keyword file {type=String}
;               A file to obtain the color table from
;
;-
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

pro LoadCtToRange, ct, range, file=file
common ColBoss, config

IF N_Elements(config) EQ 0 THEN InitColorBoss

; This routine works a different way depending on which color 
; method is in use.

ReadCt, ct, file=file, red=red, green=green, blue=blue
tableSize = N_Elements(red)

IF config.transferFunction NE '' THEN $
  dummy = Call_Function(config.transferFunction, red=red, green=green, blue=blue)

IF config.pseudo THEN BEGIN

  bottom = Min(range)
  noColors = N_Elements(range)

  inds = NInt(FIndGen(noColors) / ((noColors - 1) > 1) * (tableSize - 1))
  Tvlct, red[inds], green[inds], blue[inds], bottom

ENDIF ELSE BEGIN

  ;; Load the color table

  noColors = range
  inds = NInt(FIndGen(noColors) / (noColors-1)*(tableSize-1))
  range = Long(red[inds]) + '100'xl * Long(green[inds]) + $
         '10000'xl * Long(blue[inds])

ENDELSE

END

