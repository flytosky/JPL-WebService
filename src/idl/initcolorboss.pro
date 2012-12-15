;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;+
; ColorBoss
; <p>
; This is a new set of idl routines, based on the previous
; color_manager set of routines.  However, this module has been
; brought up to date significantly.
; <p>
; Perhaps the most notable thing is the use of 24 bit color, and the
; fact that I'm dealing with loadct correctly.
; <p>
; Also note, I've finally bitten the bullet and moved to the American
; spelling of colour!
; <p>
; This new version also has the space for a transfer function for
; funny printers (e.g. pastel2)
; 
; @param defaultFile {type=String} {Optional} {default='~/idl/my_tables.tbl'}
;                    The table to get the normal color values from.
; @keyword noReset   {type=Boolean}
;                    When set, if the Color Boss has previously been
;                    set up, return without doing any work.
;
;-
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

pro InitColorBoss, defaultFile, noReset=noReset
common ColBoss,config

;; If noReset given and color boss has previously been set up, return gracefully
IF N_Elements(config) NE 0 && Keyword_Set(noReset) THEN RETURN

; If supplied, defaultFile is the color table file the user wishes to
; use by default.

if n_elements(defaultFile) eq 0 then defaultFile= $
  Getnjlidldir()+"my_tables.tbl"

; First ascertain whether we're in pseudo color or true color mode

if !D.name eq 'X' then begin
  Device,get_visual_name=visual
  pseudo=visual eq 'PseudoColor'
endif else pseudo=1

; Force decomposed color if not in pseudo color mode

if not pseudo then Device,/decomposed

; If there was a transfer function before, then keep hold of it.

if n_elements(config) ne 0 $
  then transferFunction=config.transferFunction $
else transferFunction=''

config={ $
  pseudo:pseudo, $              ; Flag to indicate in pseudo color mode.
  defaultCt:34, $                ; Index number for default color table.
  defaultFile:defaultFile, $    ; Filename for default ct file.
  transferFunction:transferFunction, $
  firstFree:0L}                 ; First free color (only needed in pseudo mode)

FlushCMYKMappings

end

