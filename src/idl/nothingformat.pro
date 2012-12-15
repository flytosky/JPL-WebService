;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;+
; A user-defined function for the graphics keywords [XYZ]TickFormat
; that returns an empty string always.  This should never be called
; explicitly. 
;
; @examples Plot, ...., yTickFormat='NothingFormat'
;
; @param axis   {type=Int}
;               The axis number: 0 for X axis, 1 for Y axis, 2 for Z
;               axis.
; @param index  {type=Int}
;               The tick mark index (starting at 0).
; @param value  {type=Double}
;               The data value of the tick mark.
;
; @returns A string to put at the given tick mark.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function NothingFormat, axis, index, value
Return, ' '
END

