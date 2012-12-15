;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;+
; This function returns true if the quantity given is an AtGod
; quantity.
;
; @param quantity   {Required}
;                   The quantity to check for being an AtGod Quantity.
; @keyword noReport {type=Boolean} {Default=0}
;                   When set, do not print an error message when not
;                   an AtGod Quantity.
;
; @returns 1 (aka true) when an AtGodQuantity 0 (aka false) otherwise.
; 
;-
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function IsThisAnAtGodQuantity, quantity, noreport=noreport

IF N_Elements(quantity) NE 1 OR N_Tags(quantity) EQ 0 THEN BEGIN
  IF NOT Keyword_Set(noReport) THEN $
    Print, 'Error: This is not an atgod quantity'
  Return, 0
ENDIF

IF (Where(Tag_Names(quantity) EQ 'ORIGINALTAGS'))[0] EQ -1 THEN BEGIN
  IF NOT Keyword_Set(noReport) THEN $
    Print,'Error: This is not an atgod quantity'
  Return, 0
ENDIF

; That should be good enough

Return, 1
END

