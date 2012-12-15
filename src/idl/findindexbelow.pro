;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;+
; This routine finds the highest index in a vector which is less than
; a given value.  Usually, it never returns the last index, so linear
; interpolation (or in this case extrapolation) based on the results
; from this routine will always work.  However, if the usetop keyword
; is set, the top index can be returned. If usebot is set, then -1 can
; be returned.
; <p>
; If the sequential flag is set, each search starts from where the
; last one left off.
; <p>
; This program has been rewritten to essentially be a driver for the
; IDL built-in function value_locate except when sequential is given.
;
; @param vector        {type=[]}
;                      The vector to search.
; @param value         The value to find the highest index in a vector
;                      which is less than it.
; @keyword useTop      {type=Boolean} {Default=0}
;                      The top index can be returned.
; @keyword useBot      {type=Boolean} {Default=0}
;                      The -1 can be returned.
; @keyword sequential  {type=Boolean} {Default=0}
;                      Each search starts from where the last one left
;                      off.
; @keyword idl         {type=Boolean} {Default=0}
;                      Left in for legacy reasons, does nothing now.
;
; @returns The highest index in a vector which is less than a given value.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FUNCTION FindIndexBelow, vector, value, useTop=useTop, useBot=useBot, $
                         sequential=sequential, idl=idl
  COMPILE_OPT IDL2

  useTop     = Keyword_Set(useTop)
  useBot     = Keyword_Set(useBot)
  sequential = Keyword_Set(sequential)
  
  nVector    = N_Elements(vector)

;; This is the hard case, where we have to go in order
  IF sequential THEN BEGIN
    nValues = N_Elements(value)
    result  = LonArr(nValues)
    inds = LIndGen(nVector)
    lastIndex = -1L
    FOR i = 0L, nValues - 1 DO BEGIN
      tmp = Where(vector LE value[i] AND inds GT lastIndex, cnt)
      IF cnt GT 0 THEN BEGIN
        result[i] = tmp[cnt-1]
        lastIndex = tmp[cnt-1]
      ENDIF ELSE BEGIN
        result[i] = -1L
      ENDELSE
    ENDFOR
  ENDIF ELSE BEGIN
    ;; Easy case, can just use an IDL canned procedure
    IF N_Elements(vector) GT 1 THEN BEGIN
      result = Value_Locate(vector, value)
    ENDIF ELSE BEGIN
      result = Replicate(-1L, N_Elements(value))
      inds   = Where(value EQ vector[0], cnt)
      IF cnt GT 0 THEN result[inds] = 0
    ENDELSE
  ENDELSE

  ;; If use Top is not set, constrain all values to be before the last
  ;; index
  IF ~useTop && nVector GT 1 THEN result <= (N_Elements(vector) - 2)
  ;; If useBot is set, remove all -1 values and replace with 0
  IF ~useBot THEN result >= 0

  RETURN, result
END

