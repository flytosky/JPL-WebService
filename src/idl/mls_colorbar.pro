;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;+
; This is the same as the routine ColorBar which has been depricated
; due to the existence of a function of the sam ename in IDL 8.0.
; This routine draws a color bar in the position given by !P.region
; If box is set (contour implied) then the color levels are shown
; evenly sized, regardless of the corresponding values.
; If the suppress flag is set, the first contour is not labled.
; If the independentFormat flag is given the tickFormat is independent
; for each level.
; <p>
; Part of the ColorBoss suite.
;
; @keyword contour           {type=Boolean} {Default=0}
;                            The color bar is done as a contour plot.
; @keyword box               {type=Boolean} {Default=0}
;                            The color bar is done where each level
;                            has a set-up box.
; @keyword log               {type=Boolean} {Default=0}
;                            The color levels are in log form.
; @keyword colorRange        {type=Int[]}
;                            The range of colors to include in the
;                            color bar.  Used only in image color bars.
; @keyword dataRange         {type=Float[]}
;                            The range of data to include in the color
;                            bar.  Used only in image color bars.
; @keyword levels            {type=Float[]}
;                            The actual levels used in a box or
;                            contour color bar.
; @keyword axColor           {type=Int}
;                            The color of the box/title for the color bar.
; @keyword title             {type=Strings}
;                            The title for the color bar.
; @keyword yAxis             {type=Boolean} {Default=0}
;                            The color bar is plotted vertically
;                            instead of the horizontal default.
; @keyword charsize          {type=Float}
;                            The same as the graphics keyword of the
;                            same name.
; @keyword xMargin           {type=Float[2]}
;                            The same as the graphics keyword of the
;                            same name.
; @keyword yMargin           {type=Float[2]}
;                            The same as the graphics keyword of the
;                            same name.
; @keyword inverse           {type=Boolean} {Default=0}
;                            Reverse the contour levels when it is an image.
; @keyword tickS             {type=Int}
;                            The same as the graphics keyword of the
;                            same name.
; @keyword inverse           {type=Boolean} {Default=0}
;                            Inverts the colors
; @keyword filCols           {type=Int[]}
;                            The colors used in a contour or box color bar.
; @keyword suppress          {type=Boolean} {Default=0}
;                            When set, the first color level is not displayed.
; @keyword ticklen           {type=Float} {Default=0.1}
;                            The same as the ticklen graphics keyword.
; @keyword minor             {type=Int} {Default=0}
;                            The same as the minor graphics keyword.
; @keyword formatString      {type=String)
;                            The format string for each level.  Will
;                            also work for the functions given to plot
;                            for xTickFormat and yTickFormat.
; @keyword downSample        {type=Int}
;                            When set, only tickmarks are displayed
;                            for level indicies cleanly divisible by downSample.
; @keyword offset            {type=Int} {Default=0}
;                            Used in conjunction with downsample,
;                            offsets the cleanly divisible (ie offset
;                            = 1 means indicies / downsample = 1)
; @keyword independentFormat {type=Boolean} {Default=0}
;                            When set, the tickFormat is independent
;                            for each level.
; @keyword middleLabels      {type=Boolean} {Defa ult=0}
;                            The default action is for the label for
;                            that tick to be at the start of the
;                            color.  When set, this makes the label in
;                            the center of the area representing the
;                            level.  Be wary of using this with downSample
; @keyword oppositeLabels    {type=Boolean} {Default=0}
;                            When set, the labels are put in the axis
;                            opposite the deafault.  This means when
;                            the colorbar is horizontal the labels are
;                            on the top and the labels are on the
;                            right side when vertical.
; @keyword tickName          {type=String[]} {Default=empty}
;                            When set use these tick names.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

pro MLS_ColorBar, contour=contour, box=box, log=log, colorRange=colorRange, $
                  dataRange=dataRange, levels=levels, axColor=axColor, $
                  title=title, yAxis=yAxis, charsize=charsize, $
                  xMargin=xMargin, yMargin=yMargin, $
                  inverse=inverse, tickS=tickS, filCols=filCols, $
                  suppress=suppress, ticklen=ticklen, minor=minor, $
                  formatString=formatString, downSample=downSample, $
                  offset=offset, independentFormat=independentFormat, $
                  middleLabels=middleLabels, oppositeLabels=oppositeLabels, $
                  tickName=tickName

common ColBoss,config

IF N_Elements(config) EQ 0 THEN InitColorBoss

; Set appropriate default values
log = Keyword_Set(log)
box = Keyword_Set(box)
contour = Keyword_Set(contour)
yAxis = Keyword_Set(yAxis)
nLevels = N_Elements(levels)
middleLabels = Keyword_Set(middleLabels)
oppositeLabels = Keyword_Set(oppositeLabels)

IF N_Elements(colorRange) EQ 0 AND contour EQ 0 AND box EQ 0 THEN $
  colorRange = GetDefaultColorRange()
IF N_Elements(ticks) EQ 0 THEN ticks = 0
IF N_Elements(minor) EQ 0 THEN minor = 0
IF N_Elements(ticklen) EQ 0 THEN ticklen = 0.1
IF N_Elements(dataRange) EQ 0 THEN BEGIN
  IF nLevels EQ 0 THEN MyMessage, /ERROR, 'No data range or levels'
  mn = Min(levels, max=mx)
  dataRange = [mn, mx]
ENDIF
IF box EQ 1 THEN dataRange = [0, nLevels]
IF N_ELEMENTS(tickName) EQ 0 THEN tickName = ''

; Not needed, should be IDL defaults
;IF N_Elements(charsize) EQ 0 THEN charsize = !P.charsize
;IF (NOT Keyword_Set(title)) THEN title = ""
;IF (NOT Keyword_Set(axColor)) THEN axColor = !P.color

; First plot the axes for the data, suppress the axes themselves,
; we'll be drawing them in later.
IF yAxis EQ 1 THEN BEGIN
  IF NOT Keyword_Set(yMargin) THEN yMargin = [1, 1]
  IF NOT Keyword_Set(xMargin) THEN xMargin = [6, 1]
  Plot, [0], /NODATA, yRange=[dataRange], xRange=[0,1], yStyle=5, xStyle=5, $
        color=axColor, yTitle=title, /NOERASE, yMargin=yMargin, yTickLen=tickLen, $
        xMargin=xMargin, yTickS=tickS, yType=log, charsize=charsize, yMinor=minor
  result = Convert_Coord([0,1], dataRange, /TO_DEVICE)
ENDIF ELSE BEGIN
  IF NOT Keyword_Set(yMargin) THEN yMargin = [3, 1]
  IF NOT Keyword_Set(xMargin) THEN xMargin = [2, 2]
  Plot, [0], /NODATA, xRange=[dataRange], yRange=[0,1], xStyle=5, yStyle=5, $
        color=axColor, xTitle=title, /NOERASE, yMargin=yMargin, xticklen=tickLen, $
        xMargin=xMargin, xTickS=tickS, xType=log, charsize=charsize, xMinor=xMinor
  result = Convert_Coord(dataRange, [0,1], /TO_DEVICE)
ENDELSE

; Setup some metrics
xPos = result[0, 0]
yPos = result[1, 0]
xSize = result[0, 1] - xPos
ySize = result[1, 1] - yPos

; Fork here depending if it's an image,box, or contour plot

CASE 1 OF
  contour EQ 1 : BEGIN
    noPoints = 200
    IF log EQ 1 THEN BEGIN
      axis = (ALog(dataRange[1]) - ALog(dataRange[0])) * LIndGen(noPoints) / $
             (noPoints - 1) + ALog(dataRange[0])
      axis = Exp(axis)
    ENDIF ELSE BEGIN
      axis = (dataRange[1]-dataRange[0]) * LIndGen(noPoints) / $
             (noPoints-1) + dataRange[0]
    ENDELSE
    field = ReBin(/SAMPLE, Reform(axis, noPoints, 1), noPoints, 4)
    IF yAxis EQ 1 THEN BEGIN
      Contour, /OVERPLOT, Transpose(field), IndGen(4) / 3.0, axis, $
               levels=levels, /FILL, c_color=filCols
    ENDIF ELSE BEGIN
      Contour, /OVERPLOT, field, axis, IndGen(4) / 3.0, $
               levels=levels, /FILL, c_color=filCols
    ENDELSE
  END
  box EQ 1 : BEGIN
    noPoints = nLevels + 1
    inds = FIndGen(noPoints)
    field = ReBin(/SAMPLE, Reform(inds, noPoints, 1), noPoints, 4)
    IF yAxis EQ 1 THEN BEGIN
      Contour, /OVERPLOT, Transpose(field), IndGen(4) / 3.0, inds, $
               levels=inds, /FILL, c_color=filCols
    ENDIF ELSE BEGIN
      Contour, /OVERPLOT, field, inds, indgen(4) / 3.0,$
               levels=inds, /FILL, c_color=filCols
    ENDELSE
    nFormatString = N_Elements(formatString)
    IF N_Elements(formatString) EQ 0 THEN BEGIN
      formatString = 'NONE'
      nFormatString = 1
    ENDIF
    IF StrUpCase(formatString[0]) EQ 'NONE' THEN BEGIN
      formatString = DeduceTickFormatString(levels, suppress=suppress, $
                                            stride=downSample, offset=offset, $
                                            independentFormat=independentFormat)
      nFormatString = N_Elements(formatString)
    ENDIF
    tickLevels = levels
    IF nFormatString NE 1 THEN BEGIN
      ;; We have a different format for each level
      IF nFormatString NE nLevels THEN  $
        MyMessage,/ERROR,'Wrong size for formatString'
      IF N_ELEMENTS(tickName) EQ 1 AND tickName(0) EQ '' THEN BEGIN
        tickName = StrArr(nLevels + 1)
        FOR level = 0, nFormatString - 1 DO BEGIN
          thisLevel = StrMid(StrUpCase(formatString[level]), 1, 1) EQ 'I' ? $
            NLong(tickLevels[level]) : tickLevels[level]
          tickName[level] = StrTrim(String(tickLevels[level], $
            format=formatString[level]),2)
        ENDFOR
        tickName[nLevels] = ' '
      ENDIF
    ENDIF ELSE BEGIN
      IF StrMid(StrUpCase(formatString), 1, 1) EQ 'I' THEN $
        tickLevels = NLong(tickLevels)
      IF N_ELEMENTS(tickName) EQ 1 AND tickName(0) EQ '' THEN BEGIN
        IF StrPos(formatString, '(') EQ 0 THEN BEGIN
          tickName = [StrTrim(String(tickLevels, format=formatString), 2), ' ']
        ENDIF ELSE BEGIN
          tickName = StrArr(nLevels + 1)
          FOR i = 0, nLevels - 1 DO BEGIN
            dummy = Execute('tickName[i] = ' + formatString[0] + '(0, 0, tickLevels[i])')
          ENDFOR
          tickName[nLevels] = ' '
        ENDELSE
      ENDIF
      ;;tickName = [StrTrim(String(tickLevels, format=formatString), 2), ' ']
    ENDELSE
    IF N_Elements(downSample) NE 0 THEN BEGIN
      IF N_Elements(offset) EQ 0 THEN offset = 0
      offset = offset MOD downsample
      IF downsample GT 1 THEN BEGIN
        erase = Where(IndGen(nLevels) MOD downSample NE offset, cnt)
        IF cnt GT 0 THEN tickName[erase] = ' '
      ENDIF
    ENDIF
    IF Keyword_Set(suppress) THEN tickName[0] = ' '
  END
  ELSE : BEGIN
    IF StrCmp(!D.name, 'ps', /FOLD_CASE) EQ 1 THEN BEGIN
      majorFieldSize = Max(colorRange, min=min) - min + 1
      minorFieldSize = 2
    ENDIF ELSE BEGIN
      IF yAxis EQ 1 THEN BEGIN
        minorFieldSize = Long(xSize)
        majorFieldSize = Long(ySize)
      ENDIF ELSE BEGIN
        majorFieldSize = Long(xSize) + 1
        minorFieldSize = Long(ySize) + 1
      ENDELSE
    ENDELSE

    field = colorRange
    IF Keyword_Set(inverse) THEN field = Reverse(field)
    field = [[field], [field]]
    field = ConGrid(field, majorFieldSize, minorFieldSize > 1)
    IF yAxis EQ 1 THEN field = Transpose(field)

    IF config.pseudo THEN BEGIN
      TV, Long(field), xPos, yPos, xSize=xSize, ySize=ySize, /DEVICE
    ENDIF ELSE BEGIN
      r = Long(field) MOD '100'xl
      g = Long(field) / '100'xl MOD '100'xl
      b = Long(field) / '10000'xl
      field = [[[r]],[[g]],[[b]]]

      TV, field, xPos, yPos, xSize=xSize, ySize=ySize, /DEVICE, true=3
    ENDELSE
  ENDELSE
ENDCASE

; Now draw in the axes again.

IF box EQ 1 THEN BEGIN
  tickV = LIndGen(nLevels + 1)
  tickS = N_Elements(tickV) - 1
ENDIF ELSE BEGIN
  tickV = 0
  tickName = ''
ENDELSE

;; Now trim any whitespace off the ticks unless they are empty
temp = StrTrim(tickName, 2)
inds = Where(temp NE '', cnt)
IF cnt GT 0 THEN tickName[inds] = temp[inds]

IF yAxis EQ 1 THEN BEGIN
  ;; Now draw in the ticks and the like, still omit all labels and titles
  Plot, [0], /NODATA, /NOERASE, yRange=[dataRange], xRange=[0,1], $ 
        yStyle=1, xStyle=5, color=axColor, yMargin=yMargin, yTicklen=ticklen, $
        xMargin=xMargin, yTickS=tickS, yTickFormat='NothingFormat', $
        yType=log, yTickV=tickV, yTick_get=tickVals, charSize=charSize

  ;; Now figure out the labels
  IF middleLabels EQ 1 AND box EQ 1 THEN BEGIN
    ;; First we need to get the delta between each tick
    delta = (tickVals[1] - tickVals[0]) / 2.0
    tickVals = tickVals[0:N_Elements(tickVals)-2] + delta
  ENDIF

  Axis, yAxis=oppositeLabels, color=axColor, yTitle=title, yRange=yRange, $
        yStyle=1, yMargin=yMargin, tickLen=0.0, yMinor=1, yTickS=(tickS-1)>0, $
        yType=log, charsize=charsize, yTickV=tickVals, yTickName=tickName, $
        xMargin=xMargin
  Plots, /DEVICE, [xPos, xPos + xSize], [yPos, yPos], color=axColor
  Plots, /DEVICE, [xPos, xPos + xSize], [yPos + ySize, yPos + ySize], color=axColor
ENDIF ELSE BEGIN

  Plot, [0], /NODATA, /NOERASE, xRange=[dataRange], yRange=[0,1], $
        xStyle=1, yStyle=5, color=axColor, yMargin=yMargin, xTicklen=ticklen, $
        xMargin=xMargin, xTickS=tickS, xTickFormat='NothingFormat', $
        xType=log, xTickV=tickV, xTick_get=tickVals, charSize=charSize

    ;; Now figure out the labels
  IF middleLabels EQ 1 AND box EQ 1 THEN BEGIN
    ;; First we need to get the delta between each tick
    delta = (tickVals[1] - tickVals[0]) / 2.0
    tickVals = tickVals[0:N_Elements(tickVals)-2] + delta
  ENDIF

  Axis, xAxis=oppositeLabels, color=axColor, xTitle=title, xRange=xRange, $
        xStyle=1, tickLen=0.0, xMinor=1, xTickS=(tickS-1)>0, $
        xType=log, charsize=charsize, xTickV=tickVals, xTickName=tickName

  Plots, /DEVICE, [xPos, xPos],[yPos, yPos + ySize], color=axColor
  Plots, /DEVICE, [xPos + xSize, xPos + xSize], [yPos, yPos + ySize], color=axColor
ENDELSE

END

