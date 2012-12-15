  FUNCTION make_bins,a,b,no,LOG = log
  IF KEYWORD_SET(log) THEN BEGIN
    f = a * (b/a)^(FINDGEN(no) / FLOAT(no - 1))
  ENDIF ELSE BEGIN
    f = a + (b - a) * FINDGEN(no) / FLOAT(no - 1)
  ENDELSE
  RETURN,f
  END
