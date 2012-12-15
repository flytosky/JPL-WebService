;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;+
; This routine allocates a single color requested by the user, it
; returns the value for this color.
; <p>
; Part of the ColorBoss suite.
;
; @param red          {type=Long[]}
;                     Required except when the keyword rgb is given
;                     value(s).  When red, green, and ble have the
;                     same number of values, it is the red component
;                     of the desired color.  When given 3 values while
;                     green and blue are not given values it is the
;                     rgb vector.  When supplied as a [*, 3] array it
;                     is the rgb values for multiple colors.  In IDL
;                     8.0 and above, if it is a string it is one of
;                     the valid colors IDL recognizes (in the !COLOR
;                     system variable).
; @param green        {type=Long[]}
;                     The green component of the desired color unless
;                     one of the other cases desscribed in the red
;                     parameter in which case its values are ignored.
; @param blue         {type=Long[]}
;                     The blue component of the desired color unless
;                     one of the other cases desscribed in the red
;                     parameter in which case its values are ignored.
; @keyword noTransfer {type=Boolean} {Default=0}
;                     Explicitly disallows using the transfer function
;                     on the allocated color.
; @keyword rgb        {type=Long[]}
;                     The color in a single value.  Overrides the
;                     values of red, green, and blue.
; @keyword hex        {type=Boolean} {Default=0}
;                     Does the color in hex.
;
; @returns The value of the newly allocated color.
;
;-
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function AllocateColor, red, green, blue, $
                        noTransfer=noTransfer, rgb=rgb, hex=hex
common ColBoss,config

IF N_Elements(config) EQ 0 THEN InitColorBoss

sz = Size(red)
IF N_Elements(rgb) NE 0 THEN BEGIN ;; RGB in a single value
  IF keyword_set(hex) THEN BEGIN
    useRed   = rgb MOD 256L
    useGreen = rgb / 256L 
    useBlue  = useGreen / 256L
    useGreen = useGreen MOD 256L
  ENDIF ELSE BEGIN
    useBlue  = rgb MOD 256L
    useGreen = rgb / 256L
    useRed   = useGreen / 256L
    useGreen = useGreen MOD 256L
  ENDELSE
ENDIF ELSE IF sz[sz[0]+1] EQ 7 THEN BEGIN  ;; Is a string
  ;; Must be at least IDL8
  IF !VERSION.release lt 8.0 THEN MyMessage, /ERROR, 'Must be at least IDL 8.0 to allocate by color name'
  cNames = StrUpCase(red)
  nColors = sz[sz[0]+2]
  useRed   = BytArr(nColors)
  useGreen = BytArr(nColors)
  useBlue  = BytArr(nColors)
  possibleColors = Tag_Names(!COLOR)
  FOR i = 0, nColors - 1 DO  BEGIN
    inds = Where(cNames[i] EQ possibleColors, cnt)
    IF cnt EQ 0 THEN MyMessage, /ERROR, 'Unknown color: ' + cNames[i]
    useRed[i]   = !COLOR.(inds)[0]
    useGreen[i] = !COLOR.(inds)[1]
    useBlue[i]  = !COLOR.(inds)[2]
  ENDFOR
ENDIF ELSE IF (N_Elements(red) EQ 3 && N_Elements(green) LE 1 && N_Elements(blue) LE 1) THEN BEGIN
  useRed   = red[0]
  useGreen = red[1]
  useBlue  = red[2]
ENDIF ELSE IF sz[0] EQ 2 && sz[2] EQ 3 THEN BEGIN
  useRed   = red[*, 0]
  useGreen = red[*, 1]
  useBlue  = red[*, 2]
ENDIF ELSE BEGIN
  useRed   = red
  useGreen = green
  useBlue  = blue
ENDELSE
nAllocated = N_Elements(useRed)

; First check that this is not straight black or white, if it is we'll
; ignore the transfer function
ignoreTransfer = Max((useRed EQ 0 AND useGreen EQ 0 AND useBlue EQ 0) OR (useRed EQ 255 AND useGreen EQ 255 AND useBlue EQ 255)) EQ 1

IF config.transferFunction NE '' AND NOT Keyword_Set(noTransfer) AND $ 
  ignoreTransfer EQ 0 THEN BEGIN
  dummy = Call_Function(config.transferFunction,$
                        red=useRed,green=useGreen,blue=useBlue)
ENDIF

IF config.pseudo THEN BEGIN
  IF config.firstFree EQ !D.n_colors THEN $
    MyMessage, /ERROR, 'No colors left'

  ;; Sort out result, update information
  result = config.firstFree + (nAllocated EQ 1 ? 0 : LIndgen(nAllocated))
  config.firstFree = config.firstFree + nAllocated

  ;; Read table in, set this value, write table back
  Tvlct, tableRed, tableGreen, tableBlue, /GET

  tableRed[result] = useRed
  tableGreen[result] = useGreen
  tableBlue[result] = useBlue

  TVLCT, tableRed, tableGreen, tableBlue

ENDIF ELSE BEGIN

  ;; In true or direct color, then this is easy
  result = Long(useRed) + '100'xl * Long(useGreen) + $
           '10000'xl * Long(useBlue)
ENDELSE

Return, result
END




