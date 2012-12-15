;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;+
; This function returns the nearest surface to the one requested, or 0 if
; no height requested.
; 
; @param data      {type=AtGod_Quantity} {Required}
;                  The data to find the surf for.
; @param height    {type=Float} {Required}
;                  The surface of interest.
; @keyword prof    {type=Int} {default=0}
;                  The profile in the dataset to look for the surface
;                  (in incoherant data only).
; @keyword auxIndex {type=Int} {default=0}
;                  The aux index to look for the surf.  Currently this
;                  value has no affect, it is left in to not break anything.
; @keyword other   {type=String}
;                  A different field to look at.
;
; @returns The index nearest the one requested.
;
; @author Nathaniel Livesey
; @version $Revision: 1.8 $ $Date: 2010/08/20 23:17:52 $
;-
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function FindSurf, data, height, prof=prof, auxIndex=auxIndex, other=other

IF N_Elements(prof) EQ 0 THEN prof=0
;IF N_Elements(auxIndex) EQ 0 THEN auxIndex=0

IF Keyword_Set(other) THEN BEGIN
  dummy=DecodeOtherField(data, other, otherSurfs=otherSurfs, /noData)
  IF otherSurfs EQ 1 THEN Return,0
ENDIF

surfs = data.coherence EQ 1 ? data.surfs : Reform(data.surfs[prof,*])

N = N_Elements(height)
IF N EQ 0 THEN Return,0

result = IntArr(N)
FOR I=0L, N-1L DO BEGIN
  IF data.logSpacing THEN BEGIN
    delta = surfs*0.0
    goodSurfs = Where(surfs GT 0.0, goodCnt)
    IF goodCnt GT 0 THEN BEGIN
      delta[goodSurfs] = ALog(surfs[goodSurfs]) - ALog(height[I])
      badSurfs = Where(surfs LE 0.0, badCnt)
      IF badCnt GT 0 THEN delta[badSurfs] = Max(delta) * 1e2
    ENDIF
  ENDIF ELSE delta = surfs - height[I]
  dummy = Min(Abs(delta), surf)
  result[I] = surf
ENDFOR

Return, (N EQ 1 ? result[0] : result)

END

