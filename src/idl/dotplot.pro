;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;+
; This procuedure does a dot plot of a quantity.  The procedure assumes that
; map_set has already been run.  The only thing it does is plot the dots!
; <p>
; The parameters are similar to previous routines
; 
; @param data         {type=AtGod_Quantity}
;                     The data to plot.
; @keyword surf       {type=Int}
;                     The index in data.surfs containing the desired
;                     pressure surface to plot.
; @keyword height     {type=Float}
;                     The actual value of the pressure surface to
;                     plot.  Is only used when surf is not given.
; @keyword auxIndex   {type=Int} {Default=0}
;                     The auxilary index the data is located in.
; @keyword first      {type=Long} {Default=0}
;                     The first profile to plot in the dataset.
; @keyword last       {type=Long} 
;                     The last profile to plot in the dataset.
; @keyword num        {type=Long}
;                     The total number of profiles to plot.  This is
;                     only used when last is not specified.
; @keyword other      {type=String} {Default=val}
;                     The name of the field to plot besides 'val'
;                     (which can be considewred the default).  An
;                     example is 'qual'.
; @keyword dataRange  {type=Float[]}
;                     Used for setting color scale
; @keyword colorRange {type=Long[]}
;                     Used for setting color scale
; @keyword levels     {type=Float[]}
;                     If set, discrete levels for plotting
; @keyword colors     {type=Long[]}
;                     Discrete colors for plotting
; @keyword size       {type=Float}
;                     Size for dots, the same as the symSize graphics
;                     keyword.
; @keyword scale      {type=Float}
;                     Scale factor for data.  If this is not given
;                     either data.scale or 1.0 (when other is given)
;                     is used.
; @keyword border     {type=Boolean} {Default=0}
;                     If set, put colored border round points.
; @keyword bordCol    {type=Long} {Default=!P.color}
;                     Color of border the same as the graphics keyword
;                     color.
; @keyword bordSize   {type=Float} {Default=1.5}
;                     The size of the border compared to size of dots.
; @keyword negpos     {type=Boolean} {Default=0}
;                     Use the +/- color scheme.
; @keyword sort       {type=Int} {Default=0}
;                     If nonzero, indicates that the data should be
;                     sorted.  A negative value means to sort in
;                     descending order.
; @keyword psym       {type=Byte} {Default=8}
;                     The symbol to represent each dot.  By default,
;                     the symbol is a filled in circle stored in the
;                     user-defined symbol index 8. Please see the IDL
;                     documentation of psym for more information.
; @keyword noUserSym  Don't replace usersym with our own circle
; @keyword idl        {type=Boolean}
;                     When set, do all work in IDL avoiding the
;                     available C drivers.
;
; @author Nathaniel Livesey
; @version $Revision: 1.13 $ $Date: 2007/09/24 17:34:55 $
;-
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PRO DotPlot, data, surf=surf, height=height, auxIndex=auxIndex, $
             first=first, last=last, num=num, other=other, $
             dataRange=dataRange, colorRange=colorRange, $
             levels=levels, colors=colors, size=size, scale=scale, $
             border=border, bordCol=bordCol, bordSize=bordSize, $
             negpos=negpos, sort=sort, psym=psym, noUserSym=noUserSym, idl=idl

IF NOT IsThisAnatgodquantity(data) THEN Return
IF N_Elements(auxIndex) EQ 0 THEN auxIndex = 0

; Now find out what is to be plotted
hasOther = N_Elements(other) NE 0

length = data.noProfs
IF hasOther EQ 0 THEN BEGIN    ; Just data (with possibly uncertainty)
  output = data.val[*, *, auxIndex]
ENDIF ELSE BEGIN                ; A field other than data was specified.
  output = DecodeOtherField(data, other, scale=scale)
  output = output[*, *, auxIndex]
  ;;  IF N_Elements(yTitle) EQ 0 THEN yTitle = other
ENDELSE

nSurfs = N_Elements(surf)
IF data.coherence NE 1 AND NOT (hasOther EQ 1 AND nSurfs EQ 0) THEN BEGIN
  MyMessage, /WARNING, 'Dataset not coherent, may make little sense'
ENDIF

; First sort out the horizontal axis.  If asked to fit the mask do so.

IF N_Elements(first) EQ 0 THEN first = 0
IF N_Elements(last) EQ 0 THEN BEGIN
  last = N_Elements(num) EQ 0 ? length - 1 : first + num - 1
ENDIF
IF N_Elements(num) EQ 0 THEN num = last - first + 1

; Now subset the data to be in the right range (don't forget to compensate
; when looking at other elements of the structure eg. data.lat(first+...)
output = output[first:last, *]
IF N_Elements(scale) EQ 0 THEN scale = hasOther EQ 0 ? data.scale : 1.0

inds = Where(output ne data.badData, cnt)
IF cnt NE 0 THEN output[inds] = output[inds] / scale
mask = data.mask[first:last]

; Now find out what surface is wanted

IF nSurfs EQ 0 THEN surf = FindSurf(data, height, other=other)
output = output[*, surf]           ; Again, subset the data.

; Now only use the non masked ones

inds = Where((mask EQ 1) AND (output NE data.badData), cnt)
IF cnt EQ 0 THEN BEGIN
  Print, 'No data to plot'
  Return
END
output = output[inds]

IF N_Elements(sort) NE 0 THEN BEGIN
  order = Sort(output)
  IF sort LT 0 THEN order = Rotate(order, 2)
ENDIF ELSE order = LIndGen(cnt)
inds = inds + first

; Now work out the wanted colors

IF N_Elements(dataRange) EQ 0 THEN BEGIN
  mx = Max(output, min=mn)
  dataRange = [mn, mx]
  IF Keyword_Set(negPos) THEN dataRange = [-1,1] * Max(Abs(dataRange))
ENDIF

IF N_Elements(levels) EQ 0 THEN BEGIN
  cols = QuantityToRange(colorRange=colorRange, output[order],$
                         dataRange=dataRange, negpos=negpos)
ENDIF ELSE BEGIN
  IF N_Elements(colors) EQ 0 THEN $
    MyMessage, /ERROR, 'If setting levels, must also set colors'
  cols = colors[FindIndexBelow(levels, output[order], /USETOP, idl=idl)]
ENDELSE

; Now sort out the symbol size these defaults are the most pleasing.

IF N_Elements(size) EQ 0 THEN BEGIN
  size = !D.name EQ 'X' ? 3.0 : 2.0
ENDIF

IF Keyword_Set(psym) THEN BEGIN
  psym = psym[0]
ENDIF ELSE BEGIN
  psym = 8
  IF NOT KEYWORD_SET ( noUserSym ) THEN BEGIN
    ;; Now make the symbol
    noVerts = 36
    angs = 2 * !pi * FIndGen(noVerts) / (1.0 * noVerts)
    X = 0.5 * Cos(angs)
    Y = 0.5 * Sin(angs)
    UserSym, X, Y, /FILL
  ENDIF
ENDELSE


; Put border on
IF Keyword_Set(border) THEN BEGIN
;  IF N_Elements(bordCol) EQ 0 THEN bordCol = !P.color
  IF N_Elements(bordSize) EQ 0 THEN bordSize = 1.5
  PlotS, data.lon[inds[order]], data.lat[inds[order]], $
         psym=psym, symSize=size*bordSize, color=bordCol, noClip=0
ENDIF

PlotS, data.lon[inds[order]], data.lat[inds[order]], $
       psym=psym, symSize=size, color=cols, noClip=0

END

