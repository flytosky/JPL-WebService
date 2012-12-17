;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro InitMessages, reset=reset, maxLevel=maxLevel, noWarnings=noWarnings, $
                  indentFactor=indentFactor, prefix=prefix, showcalls=showcalls, $
                  forceHalt=forceHalt, logfile=logfile, closeLog=closeLog, $
                  pvm=pvm, closePvm=closePvm, widgetLabel=widgetLabel, $
                  exitIDL=exitIDL, stopOnWarning=stopOnWarning

; Note - show calls bit 0 on error, bit 1 on warning

common MyMessage,messageInfo,tids

myTid=0L

IF Keyword_Set(pvm) THEN Initidlpvmlog,pvm=pvm,myTid=myTid

IF Keyword_Set(closePvm) THEN tids=0L
IF N_Elements(tids) EQ 0 THEN tids=0L

IF N_Elements(messageInfo) EQ 0 or keyword_set(reset) THEN begin ; Start new
  IF N_Elements(maxLevel) EQ 0 THEN maxLevel=-1 ; Show all levels
  IF N_Elements(noWarnings) EQ 0 THEN noWarnings=0
  IF N_Elements(forceHalt) EQ 0 THEN forceHalt=1
  IF N_Elements(showCalls) EQ 0 THEN showCalls=1
  IF N_Elements(indentFactor) EQ 0 THEN indentFactor=2
  IF N_Elements(stopOnWarning) EQ 0 THEN stopOnWarning=0
  IF N_Elements(exitIDL) EQ 0 THEN exitIDL=1
  IF N_Elements(prefix) EQ 0 THEN prefix=''
  IF N_Elements(logFile) EQ 0 THEN logFile=''

  IF N_Elements(messageInfo) NE 0 THEN begin
    IF messageInfo.logFile NE '' THEN Free_lun,messageInfo.logUnit
  ENDIF

  messageInfo = {maxLevel:maxLevel, $
                 noWarnings:noWarnings, $
                 forceHalt:forceHalt, $
                 stopOnWarning:stopOnWarning, $
                 showCalls:showCalls, $
                 exitIDL:exitIDL, $
                 prefix:prefix, $
                 logFile:logFile, $
                 logUnit:0L, $
                 widgetLabel:0L, $
                 blank:'                                                         ', $
                 myTid:myTid, $
                 indentFactor:indentFactor}
  IF logFile NE '' THEN begin 
    Openw,unit,logFile,/get_lun
    messageInfo.logUnit=unit
  ENDIF

ENDIF ELSE BEGIN
  IF N_Elements(maxLevel) NE 0 THEN messageInfo.maxLevel=maxLevel
  IF N_Elements(noWarnings) NE 0 THEN messageInfo.noWarnings=noWarnings
  IF N_Elements(forceHalt) NE 0 THEN messageInfo.forceHalt=forceHalt
  IF N_Elements(indentFactor) NE 0 THEN messageInfo.indentFactor=indentFactor
  IF N_Elements(showCalls) NE 0 THEN messageInfo.showCalls=showCalls
  IF N_Elements(prefix) NE 0 THEN messageInfo.prefix=prefix
  IF N_Elements(exitIDL) NE 0 THEN messageInfo.exitIDL=exitIDL
  IF N_Elements(widgetLabel) NE 0 THEN messageInfo.widgetLabel=widgetLabel
  IF N_Elements(stopOnWarning) NE 0 THEN $
    messageInfo.stopOnWarning=stopOnWarning
  IF keyword_set(closeLog) THEN BEGIN
    Free_lun,messageInfo.logUnit
    messageInfo.logFile=''
  ENDIF
  IF keyword_set(logFile) THEN BEGIN
    IF messageInfo.logFile NE '' THEN Free_lun,messageInfo.logUnit
    Openw,unit,logFile,/get_lun
    messageInfo.logUnit=unit
    messageInfo.logFile=logFile
  ENDIF
ENDELSE

END

