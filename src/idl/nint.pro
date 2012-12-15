;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;+
; Nearest integer function. <p>
; Example, If X = [-0.9,-0.1,0.1,0.9] then nint(X) = [-1,0,0,1]
;
; @param x The value to find the integer to it.
;
; @returns The nearest integer
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function Nint, x

Return,  Round(x)               ;Fix( x + 0.5 - (x LT 0) )
END

