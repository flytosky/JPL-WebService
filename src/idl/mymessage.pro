;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

pro MyMessage, text, init=init, noName=noName, level=level, $
               warning=warning, parent=parent, error=error

common MyMessage,messageInfo,tids

IF Keyword_Set(init) THEN BEGIN
  InitMessages
  RETURN
ENDIF

IF NOT Keyword_Set(warning) THEN warning=0
IF NOT Keyword_Set(error) THEN error=0
IF NOT Keyword_Set(noname) THEN noName=0
IF N_Elements(level) EQ 0 THEN level=0

IF N_Elements(messageInfo) EQ 0 THEN InitMessages

IF (error EQ 0) AND (warning EQ 0) AND $
   (level GT messageInfo.maxLevel) AND $
   (messageInfo.maxLevel NE -1) THEN RETURN

showCalls=(((messageInfo.showCalls AND 1) NE 0) AND error) OR $
          (((messageInfo.showCalls AND 2) NE 0) AND warning)

IF noName EQ 0 OR showCalls THEN Help,calls=calls

IF noName EQ 0 THEN BEGIN
  IF N_Elements(parent) EQ 0 THEN parent=0
  caller=StrLowCase(calls[1+parent])
  spacePos=StrPos(caller,' ')
  IF spacePos NE -1 THEN caller=StrMid(caller,0,spacePos)
  IF warning OR error THEN caller='('+caller+') ' ELSE caller=caller+': '
ENDIF ELSE caller=''

indent=StrMid(messageInfo.blank,0, $
              level*messageInfo.indentFactor*(1-error)*(1-warning))

IF error OR warning THEN Print,'' ; Leave blank line before error/warning

CASE 1 OF
  error   : output='Error: '+caller+text[0]
  warning : output='Warning: '+caller+text[0]
  ELSE    : output=indent+caller+text[0]
ENDCASE

Print,messageInfo.prefix,output
IF messageInfo.widgetLabel NE 0 THEN BEGIN
  Widget_Control,messageInfo.widgetLabel, set_value=messageInfo.prefix+output
ENDIF
IF messageInfo.logFile NE '' THEN BEGIN
  PrintF,messageInfo.logUnit,messageInfo.prefix,output
  Flush,messageInfo.logUnit
ENDIF
IF tids[0] NE 0 THEN SendidlpvmlogMessage,messageInfo.prefix+output

nTextLines = N_Elements(text)
IF nTextLines NE 1 THEN BEGIN
  FOR element=1, nTextLines-1 DO BEGIN
    IF messageInfo.widgetLabel NE 0 THEN BEGIN
      IF element EQ 1 THEN BEGIN
        Widget_Control,messageInfo.widgetLabel, $
                       set_value=messageInfo.prefix+index+text[element]
      ENDIF
    ENDIF
    Print,messageInfo.prefix,indent,text[element]
    IF messageInfo.logFile ne '' THEN $
      Printf,messageInfo.logUnit,messageInfo.prefix,text[element]
    IF tids[0] NE 0 THEN BEGIN
      SendidlpvmlogMessage, messageInfo.prefix+text[element],info=info
      IF info LT 0 THEN InitMessages,/pvm
    ENDIF
  ENDFOR
ENDIF

IF showCalls THEN Print,calls[1:*]

IF error OR (warning AND messageInfo.stopOnWarning) THEN BEGIN

  IF messageInfo.forceHalt THEN BEGIN
    Catch,/cancel
    On_error,2
  ENDIF
  Message,output,/Noname,/noprint
ENDIF

IF warning THEN Print,''        ; Leave blank line after warnings

END

