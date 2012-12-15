;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;+
; This routine allocates a color range. The issues involved with
; ranges are more complex than those involved with single colors when
; it comes to the pseudo/direct color models.
; <p>
; In pseudo color, the range is allocated to a fixed range within the
; 256 color table. Then filled with the loadcttoRange routine.
; <p>
; In decomposed color, the range is simply returned as empty, it is
; only in the loadcttorange part that anything useful happens.
; <p>
; Part of the ColorBoss suite.
;
; @param noColors   {type=Long}
;                   Number of colors desired.
; @keyword noRanges {type=Int} {Default=1}
;                   The number of ranges wanted to be available
;                   concurrently. 
;
; @returns The allocated color range.
;
; @author Nathaniel Livesey
; @version $Revision: 1.5 $ $Date: 2003/11/13 23:43:07 $
;-
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function AllocateRange, noColors, noRanges=noRanges
common ColBoss,config

IF N_Elements(config) EQ 0 THEN InitColorBoss

IF config.pseudo THEN BEGIN

  ;; In pseudo color we need to allocate the requested number of colors
  IF N_Elements(noRanges) EQ 0 THEN noRanges = 1
  IF N_Elements(noColors) EQ 0 THEN $
    noColors = Long((1.0 * !D.n_colors - config.firstFree) / noRanges)

  IF config.firstFree+noColors GT !D.n_colors THEN BEGIN
    MyMessage, /WARNING, 'Not enough free colors to allocate range'
    noColors = Long((1.0 * !D.n_colors - config.firstFree) / noRanges)
  ENDIF

  result = LIndGen(noColors) + config.firstFree
  config.firstFree = config.firstFree + noColors
ENDIF ELSE BEGIN

  ;; In decomposed color, there is nothing to do, just return 0
  IF N_Elements(noColors) EQ 0 THEN noColors = 256L
  result = noColors
ENDELSE

Return, result
END

