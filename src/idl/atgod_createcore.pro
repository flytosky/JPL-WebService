;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;+
; This routine is the core of the whole suite, it creates a new
; quantity according to its input paramters.  It can also be given a
; 'source' variable containing another quantity on which to model the
; new one.  This routine originally grew in a rather chaotic and
; contradictory way, so now I am rewriting it to be more sensible laid
; out.
; <p>
; <b>NOTE</B> When source is given, the default values for all
; keywords are derived from the values in source, not the hard-coded
; defaults.
;
; @keyword source            {type=AtGod_Quantity}
;                            An existing quantity that contains the
;                            values of all the possible keywords that
;                            are not explicitly given at call-time.
; @keyword empty             {type=Boolean} {Default=0}
;                            When set, only 1 data value is allowed in
;                            the dataset (ie 1 prof, surf, and aux).
; @keyword double            {type=Boolean} {Default=0}
;                            Do all floating point values as Doubles
;                            in returned quantity.
; @keyword valueType         {type=Int}
;                            When given, set the data value arrays (in
;                            the default case val and qual as well as
;                            any additional data fields given through
;                            gridFormat, etc).  These follow the IDL
;                            type codes for variables (for more
;                            information, see IDL documentation for
;                            the Size function).  The allowed values
;                            are 1-5 and 12-15. This value is
;                            overwritten if the keyword double is set
;                            and the default is 4 (for float).
; @keyword filename          {type=String} {Default=""}
;                            Nominally the name of the file the
;                            dataset comes from.  It fills the
;                            filename field in the quantity.
; @keyword units             {type=String} {Default=""}
;                            The units the data are in.  An example is ppbv.
; @keyword longContent       {type=String} {Default=""}
;                            The name of the type of data product in long
;                            form.  An example is "Ozone"
; @keyword shortContent      {type=String} {Default=""}
;                            The name of the type of data product in
;                            short form, often containing IDL graphics
;                            formatting.  An example is "O!I3!N" or
;                            equivalently, "O3"
; @keyword longDataType      {type=String} {Default=""}
;                            The type of data being plot in long
;                            form.  An example is "Level 2 GP Data"
; @keyword shortDataType     {type=String} {Default=""}
;                            The type of data being plot in long
;                            form.  An example is "L2GP"
; @keyword noProfs           {type=Long} {Default=1}
;                            The number of profiles in the returned dataset.
; @keyword noSurfs           {type=Long} {Default=1}
;                            The number of surfaces in the returned
;                            dataset.  May also be determined by the
;                            number of elements in surfs if not supplied.
; @keyword noAux             {type=Int}
;                            The number of auxilary indicies in the
;                            returned dataset.
; @keyword vertical          {type=String} {Default="P"}
;                            How the vertical coordinates (aka
;                            surfaces) are formatted.  Valid values
;                            are "P" for pressure, "S" for
;                            elevation(?), "N" for none.
; @keyword logSpacing        {type=Boolean} {Default=0}
;                            Whether or not the surfaces are output in
;                            log spaced intervals.
; @keyword spacing           {type=Float}
;                            The spacing between surfs.  Appears to
;                            always be calculated in program making
;                            this keyword unneeded.
; @keyword coherence         {type=Boolean} {Default=1}
;                            When coherent, every value in a certain
;                            surf index were measured at that given
;                            surface.  When incoherent, this cannot
;                            be guarenteed.  It is much more of an
;                            approximation.
; @keyword gridFormat        {type=Int} {Default=0}
;                            When gridFormat != 0, all profiles have
;                            similar lat, lon, etc values for all
;                            surfaces, aux indicies.  When gridFormat=2,
;                            fields are sdded to the return structure
;                            for the max, min, and standard deviation
;                            of each point, which is useful for
;                            gridding and/or binning a dataset.
;                            gridFormat=3 is tuned for GOZCARDS data
;                            including information about average, and
;                            extrema values for latitude (profs and
;                            surfs), lst, and sza (both prof only).
; @keyword auxInfo           {type=Struct} {Default=0}
;                            A structure defining each auxilary index
;                            (ie an equal amount of structures to
;                            noAux if supplied).  If noAux is 1.  This
;                            may be set as 0 and omit the definitions.
; @keyword longAuxContent    {type=String} {Default=""}
;                            A full explanation of what the auxilary
;                            inidicies are.
; @keyword shortAuxContent   {type=String} {Default=""}
;                            An abbreviated explanation of what the
;                            auxilary indicies are.
; @keyword groupInfo         {type=Struct} {Default=0}
;                            A structure defining each group index
;                            If there is only one group, this may be
;                            set as 0 and omit the definitions.
; @keyword longGroupContent  {type=String} {Default=""}
;                            A full explanation of what the group
;                            inidicies are.
; @keyword shortGroupContent {type=String} {Default=""}
;                            An abbreviated explanation of what the
;                            group indicies are.
; @keyword noLats            {type=Int}
;                            The number of latitudes sampled in the
;                            dataset.  Used with lat1 and dLat to
;                            infer the lats.
; @keyword lat1              {type=Float}
;                            The value of the first latitude in the
;                            dataset.  Used with dLat and noLats to
;                            infer the lats.
; @keyword dLat              {type=Float}
;                            The spacing between latitude samples in
;                            the dataset.  Used with lat1 and noLats to
;                            infer the lats.
; @keyword lats              {type=Float[]}
;                            The latitudes in the dataset.  Takes
;                            precedence over lat1, noLats, and dLat.
; @keyword noLons            {type=Int}
;                            The number of longitudes sampled in the
;                            dataset.  Used with lon1 and dLon to
;                            infer the lons.
; @keyword lon1              {type=Float}
;                            The value of the first longitude in the
;                            dataset.  Used with dLon and noLons to
;                            infer the lons.
; @keyword dLon              {type=Float}
;                            The spacing between longitude samples in
;                            the dataset.  Used with lon1 and noLons to
;                            infer the lons.
; @keyword lons              {type=Float[]}
;                            The longitudes in the dataset.  Takes
;                            precedence over lon1, noLons, and dLon.
; @keyword noSubsids         {type=Int}
;                            The number of subsidiary measurements sampled in
;                            the dataset.  Used with subsid1 and dSubsid to
;                            infer the subsidss.
; @keyword subsid1           {type=Float}
;                            The value of the first subsidiary measurement in the
;                            dataset.  Used with dSubsid and noSubsids to
;                            infer the subsids.
; @keyword dsubsid           {type=Float}
;                            The spacing between subsidiary measurements in
;                            the dataset.  Used with subsid1 and noSubsids to
;                            infer the subsids.
; @keyword subsids           {type=Float[]}
;                            The subsidiary measurements in the dataset.  Takes
;                            precedence over subsid1, noSubsids, and dSubsid.
; @keyword subsidType        {type=Int} {Default=0}
; @keyword noYear            {type=Int} 
; @keyword noDays            {type=Int}
;                            The number of days in the measured in the
;                            dataset.
; @keyword days              {type=Long[]}
;                            The days measured in the dataset.
; @keyword dayLen            {type=Long}
;                            The length of the measurement in each day.
; @keyword scale             {type=Float} {Default=1.0}
;                            The scaling for the data being used to go
;                            from the absolute values stroed here to
;                            the units specified in units.
; @keyword badData           {type=Float} {Default=-999.99}
;                            The value in the quantity signifying data
;                            to be ignored.
; @keyword surfs             {type=Float[]}
;                            The surfaces, ie vertical coordinates in
;                            the dataset.
; @keyword noZero            {type=Boolean}
;                            Set this keyword to prevent the
;                            initialization of most arrays in the
;                            quantity (exceptions are the grid arrays
;                            lats/lons/days or surfs where defined).
;                            Normally, each element of the resulting
;                            arrays are set to zero, this makes the
;                            respults unpredictable but is faster.
; @keyword initBad           {type=Booelan}
;                            Set this keyword to give all values in
;                            the quantity's arrays the value of
;                            badData (exceptions are the grid arrays 
;                            lats/lons/days or surfs where defined).
;
; @returns The data in AtGod structure format.
;-
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function AtGod_CreateCore, source=source, empty=empty, double=double, $
                           valueType=valueType, filename=filename, units=units, $
                           longContent=longContent, shortContent=shortContent, $
                           longDataType=longDataType, shortDataType=shortDataType, $
                           noProfs=noProfs, noSurfs=noSurfs, noAux=noAux, $
                           vertical=vertical, logSpacing=logSpacing, spacing=spacing, $
                           coherence=coherence, gridFormat=gridFormat, $
                           auxInfo=auxInfo, longAuxContent=longAuxContent, $
                           shortAuxContent=shortAuxContent, $
                           groupInfo=groupInfo, longGroupContent=longGroupContent, $
                           shortGroupContent=shortGroupContent, $
                           noLats=noLats, lat1=lat1, dLat=dLat, lats=lats, $
                           noLons=noLons, lon1=lon1, dLon=dLon, lons=lons, $
                           noSubsids=noSubsids, subsid1=subsid1, dSubsid=dSubsid, $
                           subsids=subsids, subsidType=subsidType, $
                           noYear=noYear, noDays=noDays, days=days, dayLen=dayLen, $
                           scale=scale, badData=badData, surfs=surfs, $
                           noZero=noZero, initBad=initBad

; First set up some variables we will use alot
double = Keyword_Set(double)
gotSource = IsThisAnAtGodQuantity(source, /NOREPORT)
type = double EQ 1 ? 5 : 4      ; Initializes to IDL type codes
IF double EQ 1 THEN BEGIN
  type = 5                      ; The IDL double type code
ENDIF ELSE BEGIN
  IF (Keyword_Set(valueType) && $
      ((valueType[0] GE 1  && valueType[0] LE 5) || $
       (valueType[0] GE 12 && valueType[0] LE 15))) THEN BEGIN
    type = valueType
  ENDIF ELSE IF gotSource EQ 1 THEN BEGIN
    type = Size(source.val[0], /TYPE)
  ENDIF ELSE BEGIN
    type = 4                    ; A float
  ENDELSE
ENDELSE
;; We want to make sure surfaces and some grid data are floating point.  So
;; if type is floating point, use that type, otherwise use a float for
;; any non-long integer, double otherwise
IF type EQ 4 || type EQ 5 THEN BEGIN
  type1 = type
ENDIF ELSE IF type GE 13 || type EQ 3 THEN BEGIN
  type1 = 5
ENDIF ELSE type1 = 4

; Before we do anything else, sort out the low level information

IF gotSource EQ 1 THEN BEGIN
  IF N_Elements(filename) EQ 0 THEN filename = source.filename
  IF N_Elements(longContent) EQ 0 THEN longContent = source.longContent
  IF N_Elements(shortContent) EQ 0 THEN shortContent = source.shortContent
  IF N_Elements(units) EQ 0 THEN BEGIN
    ;; This is a work around because non MLS data doesn't have this
    ;; field.
    tags = Tag_Names(source)
    temp = where(tags EQ 'UNITS', cnt)
    units = cnt GT 0 ? source.units : ''
  ENDIF
  IF N_Elements(longDataType) EQ 0 THEN longDataType = source.longDataType
  IF N_Elements(shortDataType) EQ 0 THEN shortDataType = source.shortDataType
  IF N_Elements(badData) EQ 0 THEN badData = source.badData
  IF N_Elements(gridFormat) EQ 0 THEN gridFormat = source.gridFormat
  IF N_Elements(scale) EQ 0 THEN scale = source.scale
  IF N_Elements(auxInfo) EQ 0 THEN auxInfo = source.auxInfo
  IF N_Elements(groupInfo) EQ 0 THEN groupInfo = source.groupInfo
;  IF N_Elements(logSpacing) EQ 0 THEN logSpacing = source.logSpacing
  IF N_Elements(longAuxContent) EQ 0 THEN longAuxContent = source.longAuxContent
  IF N_Elements(shortAuxContent) EQ 0 THEN $
    shortAuxContent = source.shortAuxContent
  IF N_Elements(longGroupContent) EQ 0 THEN $
    longGroupContent = source.longGroupContent
  IF N_Elements(shortGroupContent) EQ 0 THEN $
    shortGroupContent = source.shortGroupContent
  IF N_Elements(noYear) EQ 0 THEN noYear = source.noYear
  IF N_Elements(vertical) EQ 0 THEN vertical = source.vertical
ENDIF ELSE BEGIN
  IF N_Elements(filename) EQ 0 THEN filename = ""
  IF N_Elements(longContent) EQ 0 THEN longContent = ""
  IF N_Elements(shortContent) EQ 0 THEN shortContent = ""
  IF N_Elements(units) EQ 0 THEN units = ""
  IF N_Elements(longDataType) EQ 0 THEN longDataType = ""
  IF N_Elements(shortDataType) EQ 0 THEN shortDataType = ""
  IF N_Elements(badData) EQ 0 THEN badData = -999.99
  IF N_Elements(gridFormat) EQ 0 THEN gridFormat = 0
  IF N_Elements(scale) EQ 0 THEN scale = 1.0
  IF N_Elements(longAuxContent) EQ 0 THEN longAuxContent = ''
  IF N_Elements(shortAuxContent) EQ 0 THEN shortAuxContent = ''
  IF N_Elements(longGroupContent) EQ 0 THEN longGroupContent = ''
  IF N_Elements(shortGroupContent) EQ 0 THEN shortGroupContent = ''
  IF N_Elements(noYear) EQ 0 THEN noYear = 0
  IF N_Elements(vertical) EQ 0 THEN vertical = 'P'
ENDELSE

IF N_Elements(subsidType) EQ 0 THEN subsidType = 0

;; This needs to be done here because badData could not be defined
;; until now.
IF Keyword_Set(initBad) THEN arrayInit = badData[0]

; First sort out the horizontal information (independent of any
; gridding) and the aux index information

IF N_Elements(noProfs) EQ 0 THEN BEGIN
  noProfs = gotSource EQ 1 ? source.noProfs : 1
ENDIF

cnt = N_Elements(auxInfo)     ; A temporary count of the given auxInfo
IF N_Elements(noAux) EQ 0 THEN BEGIN
  IF cnt NE 0 THEN BEGIN
    noAux = cnt
  ENDIF ELSE BEGIN
    noAux = gotSource EQ 1 ? source.noAux : 1
  ENDELSE
ENDIF 
IF cnt LT noAux THEN BEGIN
  oneAux = {id:0L, groupId:0L, groupIndex:0L}
  auxInfo = Replicate(oneAux, noAux)
  IF noAux GT 1 THEN auxInfo.id = LIndGen(noAux)
ENDIF ELSE IF cnt NE noAux THEN auxInfo = auxInfo[0:noAux-1]

cnt = N_Elements(groupInfo)     ; A temp count of the given groupInfo
IF N_Elements(noGroups) EQ 0 THEN BEGIN
  IF cnt NE 0 THEN BEGIN
    noGroups = cnt
  ENDIF ELSE BEGIN
    noGroups = gotSource EQ 1 ? source.noGroups : 1
  ENDELSE
ENDIF
IF cnt EQ 0 THEN BEGIN
  oneGroup = {id:0L}
  groupInfo = Replicate(oneGroup, noGroups)
  IF noGroups GT 1 THEN groupInfo.id = LIndGen(noGroups)
ENDIF ELSE IF cnt NE noGroups THEN groupInfo = groupInfo[0:noGroups-1]

; Now sort out the gridding information if any.
IF gridFormat NE 0 THEN BEGIN

  ;; First take some of the data from the source file if supplied.
  ;; Only take lats,lons etc. *if no other information supplied!*
  IF gotSource EQ 1 THEN BEGIN
    IF source.gridFormat NE 0 THEN BEGIN
      IF N_Elements(lats) EQ 0 AND N_Elements(noLats) EQ 0 THEN lats = source.lats
      IF N_Elements(lons) EQ 0 AND N_Elements(noLons) EQ 0 THEN lons = source.lons
      IF N_Elements(subsids) EQ 0 AND N_Elements(noSubsids) EQ 0 THEN $
        subsids = source.subsids
      IF N_Elements(days) EQ 0 AND N_Elements(noDays) EQ 0 THEN BEGIN
        days = source.days
        IF N_Elements(dayLen) EQ 0 THEN dayLen = source.dayLen
      ENDIF ELSE BEGIN
        IF N_Elements(dayLen) EQ 0 THEN dayLen = source.dayLen[0]
      ENDELSE
    ENDIF ELSE BEGIN
      IF N_Elements(days) EQ 0 AND N_Elements(noDays) EQ 0 AND $
        N_Elements(dayLen) EQ 0 THEN BEGIN

        ;; If the input is not a grid choose the nearest day to the mean day
        ;; as the output day.
        inds = Where(source.day ne Fix(source.baddata), cnt)
        meanDate = Total(source.day[inds]) / cnt
        days = Double(NLong(meanDate))
      ENDIF
    ENDELSE
  ENDIF

  IF N_Elements(lats) EQ 0 THEN BEGIN
    IF N_Elements(noLats) EQ 0 THEN noLats = 17
    IF N_Elements(lat1) EQ 0 THEN lat1 = -80.0
    IF N_Elements(dLat) GT 0 THEN BEGIN
      dLat = dLat[0]
    ENDIF ELSE BEGIN
      dLat = noLats GT 1 ? 2 * Abs(lat1) / (noLats-1) : 90.0
    ENDELSE
    lats = FIndGen(noLats) * dLat + lat1
  ENDIF ELSE BEGIN
    noLats = N_Elements(lats)
    lat1 = lats[0]
    IF N_Elements(dLat) EQ 0 THEN dLat = noLats EQ 1 ? 90.0 : CalcSpacing(lats)
  ENDELSE

  IF N_Elements(lons) EQ 0 THEN BEGIN
    IF N_Elements(noLons) EQ 0 THEN noLons = 18
    IF N_Elements(lon1) EQ 0 THEN lon1 =  -180
    IF N_Elements(dLon) GT 0 THEN BEGIN
      dLon = dLon[0]
    ENDIF ELSE BEGIN
      dLon = noLons GT 1 ? 2 * Abs(lon1) / (noLons) : 360.0
    ENDELSE
    lons = FIndGen(noLons) * dLon + lon1
  ENDIF ELSE BEGIN
    noLons = N_Elements(lons)
    lon1 = lons[0]
    IF N_Elements(dLon) EQ 0 THEN dLon = noLons EQ 1 ? 360.0 : CalcSpacing(lons, /lon)
  ENDELSE

  IF N_Elements(subsids) EQ 0 THEN BEGIN
    IF N_Elements(noSubsids) EQ 0 THEN noSubsids = 1
    IF N_Elements(subsid1) EQ 0 THEN subsid1 = 0.0
    IF N_Elements(dSubsid) EQ 0 THEN dSubsid = 24.0 + (180.0 - 24.0) * subsidType
    subsids = FIndGen(noSubsids) * dSubsid + subsid1
  ENDIF ELSE BEGIN
    noSubsids = N_Elements(subsids)
    subsid1 = subsids[0]
    dSubsid = CalcSpacing(subsids)
  ENDELSE

  IF N_Elements(days) EQ 0 THEN BEGIN
    IF N_Elements(noDays) EQ 0 THEN noDays = 1
    days = DIndGen(noDays)
  ENDIF ELSE noDays = N_Elements(days)

  cnt = N_Elements(dayLen) 
  CASE N_Elements(dayLen) OF
    0 : dayLen = IntArr(noDays) + 1
    noDays :                    ; Do Nothing
    1 : dayLen = Replicate(dayLen[0], noDays)
    ELSE : MyMessage, /ERROR, 'Bad value for daylen'
  ENDCASE

  ;; Now calculate the number of profiles in the data set and deal with that

  noProfs = noLats * noLons * noSubsids * noDays
  locations = LIndGen(noLats, noLons, noSubsids, noDays)

  ;; Now fill up the lat/lon/lst/sza/day/time information

  lat = Reform(lats[locations MOD noLats], noProfs)
  lon = Reform(lons[locations / noLats MOD noLons], noProfs)

  CASE subsidType OF
    0 : BEGIN
      lst = Reform(subsids[locations / (noLats * noLons) MOD noSubsids], noProfs)
      sza = FltArr(noProfs)
    END
    1 : BEGIN
      sza = Reform(subsids[locations / (noLats * noLons) MOD noSubsids], noProfs)
      lst = FltArr(noProfs)
    END
  ENDCASE  

  day  = Reform(days[locations / (noLats * noLons * noSubsids)], noProfs)
  time = (Reform(days[locations / (noLats*noLons*noSubsids)], noProfs) - day) * 8.64d7

ENDIF ELSE BEGIN
  ;; Fill in the categories above with blanks
  lat  = Make_Array(noProfs, type=4, nozero=nozero, value=arrayInit)
  lon  = Make_Array(noProfs, type=4, nozero=nozero, value=arrayInit)
  lst  = Make_Array(noProfs, type=4, nozero=nozero, value=arrayInit)
  sza  = Make_Array(noProfs, type=4, nozero=nozero, value=arrayInit)
  day  = Make_Array(noProfs, type=3, nozero=nozero, value=arrayInit)
  time = Make_Array(noProfs, type=3, nozero=nozero, value=arrayInit)
ENDELSE
  
IF N_Elements(logSpacing) EQ 0 THEN logSpacing = (vertical EQ 'P' OR vertical EQ 'S')

cnt = N_Elements(surfs)
IF cnt NE 0 THEN BEGIN ; Been supplied some surfs information
  ;; This forces a coherence of 1
  IF noProfs EQ 1 OR (N_Elements(coherence) EQ 0) THEN coherence = 1
  IF coherence EQ 0 THEN BEGIN
    s = Size(surfs)
    noSurfs = s[s[0]]
  ENDIF ELSE noSurfs = cnt
ENDIF ELSE BEGIN                ; No surfaces supplied
  IF N_Elements(noSurfs) NE 0 THEN BEGIN ; User requested given noSurfs
    IF N_Elements(coherence) EQ 0 THEN BEGIN
      coherence = gotSource EQ 1 ? source.coherence : 1
    ENDIF
  ENDIF ELSE BEGIN              ; Neither noSurfs nor surfs supplied
    IF gotSource EQ 1 THEN BEGIN     ; However, given a source quantity
      IF N_Elements(coherence) EQ 0 THEN coherence = source.coherence
      IF coherence EQ source.coherence THEN BEGIN
        IF coherence EQ 1 THEN BEGIN
          surfs = source.surfs 
        ENDIF ELSE BEGIN
          IF source.noProfs EQ noProfs THEN $
            surfs = source.surfs[0:(noProfs-1), *, *]
        ENDELSE
        noSurfs = source.noSurfs
      ENDIF ELSE noSurfs = source.noSurfs
    ENDIF ELSE BEGIN
      noSurfs = 1
      coherence = 1
    ENDELSE
  ENDELSE
ENDELSE

IF N_Elements(surfs) EQ 0 THEN BEGIN
  CASE coherence OF
    1: surfs = Make_Array(noSurfs, type=type1, nozero=nozero, value=arrayInit)
    0: surfs = Make_Array(noProfs, noSurfs, type=type1, nozero=nozero, value=arrayInit)
  ENDCASE
ENDIF

spacing = coherence EQ 1 ? CalcSpacing(surfs, log=logSpacing) : 0.0

IF double EQ 1 THEN surfs = 1.0D0 * surfs

; Now setup all the important parameters, create the structure.

IF Keyword_Set(empty) THEN BEGIN
  noProfsOr1 = 1
  noSurfsOr1 = 1
  noAuxOr1 = 1
ENDIF ELSE BEGIN
  noProfsOr1 = noProfs
  noSurfsOr1 = noSurfs
  noAuxOr1 = noAux
ENDELSE

; Create the core data structure
result = {filename:filename,$
          longContent:longContent, $
          shortContent:shortContent, $
          units:units, $
          longDataType:longDataType, $
          shortDataType:shortDataType, $
          noProfs:noProfs,$
          noSurfs:noSurfs,$
          noAux:noAux,$
          noValues:Long(noProfs) * Long(noSurfs) * Long(noAux),$ ; Total no of data points
          noGroups:noGroups, $
          vertical:vertical,$
          logSpacing:logSpacing,$
          spacing:spacing,$
          coherence:coherence,$
          auxInfo:auxInfo, $
          groupInfo:groupInfo, $
          longAuxContent:longAuxContent, $
          shortAuxContent:shortAuxContent, $
          longGroupContent:longGroupContent, $
          shortGroupContent:shortGroupContent, $
          gridFormat:gridFormat, $
          continuity:IntArr(noProfs),$
          lat:Temporary(lat), $
          lon:Temporary(lon), $
          lst:Temporary(lst), $
          sza:Temporary(sza), $
          day:Temporary(day), $
          time:Temporary(time),$
          noYear:noYear, $
          mask:BytArr(noProfs)+1,$
          scale:scale, $
          badData:badData[0],$
          surfs:surfs, $
          val:Make_Array(noProfsOr1, noSurfsOr1, noAuxOr1, type=type, $
                         nozero=nozero, value=arrayInit), $
          qual:Make_Array(noProfsOr1, noSurfsOr1, noAuxOr1, type=type, $
                          nozero=nozero, value=arrayInit), $
          originalTags:0B}

IF gridFormat NE 0 THEN BEGIN
  
  IF gridFormat GT 1 THEN BEGIN
    result = Create_Struct(Temporary(result), $
                           "sd", Make_Array(noProfs, noSurfs, noAux, type=type1, $
                                            nozero=nozero, value=arrayInit), $
                           "no", Make_Array(noProfs, noSurfs, noAux, type=3, $ ; LONG
                                            nozero=nozero, value=0), $
                           "mx", Make_Array(noProfs, noSurfs, noAux, type=type, $
                                            nozero=nozero, value=arrayInit), $
                           "mn", Make_Array(noProfs, noSurfs, noAux, type=type, $
                                            nozero=nozero, value=arrayInit))
    IF gridFormat EQ 3 THEN BEGIN
      result = Create_Struct(Temporary(result), $
                             "latMin", Make_Array(noProfs, noSurfs, noAux, type=type1, $
                                                  nozero=nozero, value=arrayInit), $
                             "latMax", Make_Array(noProfs, noSurfs, noAux, type=type1, $
                                                  nozero=nozero, value=arrayInit), $
                             "latAvg", Make_Array(noProfs, noSurfs, noAux, type=type1, $
                                                  nozero=nozero, value=arrayInit), $
                             "noBinProfs", Make_Array(noProfs, noAux, type=3, $
                                                      nozero=nozero, value=0), $
                             "szaMin", Make_Array(noProfs, noAux, type=type1, $
                                                  nozero=nozero, value=arrayInit), $
                             "szaMax", Make_Array(noProfs, noAux, type=type1, $
                                                  nozero=nozero, value=arrayInit), $
                             "szaAvg", Make_Array(noProfs, noAux, type=type1, $
                                                  nozero=nozero, value=arrayInit), $
                             "lstMin", Make_Array(noProfs, noAux, type=type1, $
                                                  nozero=nozero, value=arrayInit), $
                             "lstMax", Make_Array(noProfs, noAux, type=type1, $
                                                  nozero=nozero, value=arrayInit), $
                             "lstAvg", Make_Array(noProfs, noAux, type=type1, $
                                                  nozero=nozero, value=arrayInit))
    ENDIF
  ENDIF
  
  result = Create_Struct(Temporary(result), $
                         "noLats", noLats, "lat1", lat1, "dLat", dLat, "lats", lats, $
                         "noLons", noLons, "lon1", lon1, "dLon", dLon, "lons", lons, $
                         "noSubsids", noSubsids, "subsid1", subsid1, $
                         "dSubsid", dSubsid, "subsids", subsids, $
                         "subsidType", subsidType, $
                         "noDays", noDays, "days", days, "dayLen", dayLen, $
                         "locations", Temporary(locations))
ENDIF

result.originalTags = N_Tags(result)
Return, result
END

