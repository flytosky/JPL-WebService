;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;+
; This function returns the spacing of x if it is evenly spaced, zero
; otherwise.
; <p>
; (originally part of atgod_misc)
;
; @param x      {type=[]}
;               The array to calculate the spacing for.
; @keyword log  {type=Boolean} {Default=0}
;               Determines the spacing in terms of log.
; @keyword lon  {type=boolean}
;               Set when input is longitude.  Avoids possible
;               nastiness that can happen from longitude wrapping.
;
; @returns The spacing for x, if x is evenly spaced.
;
; @author Nathaniel Livesey
; @version $Revision: 1.4 $ $Date: 2009/11/05 23:48:31 $
;-
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function CalcSpacing,x,log=log, lon=lon

nX = N_Elements(x)
IF nX EQ 1 THEN Return, 0.0

IF Keyword_Set(log) THEN BEGIN
  zero = Where(x EQ 0.0, cnt)
  IF cnt GT 0 THEN Return, 0.0
  spacing = [x,1] / [1,x]
  negative = Where(spacing LE 0.0, cnt)
  IF cnt GT 0 THEN Return, 0.0
  spacing = ALog(spacing)
ENDIF ELSE spacing = [x,0] - [0,x]

spacing = spacing[1:nX-1]
IF Keyword_Set(lon) THEN spacing = NormalizeLongitude(spacing)
mx = Max(spacing, min=mn)

IF mn NE 0.0 THEN delta = Abs((mx-mn)/mn) ELSE Return, 0.0
IF delta GT 1e-3 THEN Return, 0.0 ELSE Return, (mn+mx)/2.0

END

