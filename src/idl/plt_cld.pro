
ini_plot
ithick=3 & cthick=3
if (!d.name eq 'PS') then ithick=3
if (!d.name eq 'PS') then cthick=3
!p.charthick = ithick
!p.thick=ithick
!x.thick = ithick
!y.thick = ithick
!x.minor=2      
!y.minor=2      
!y.title=' '
!p.charsize=1.3
axis_thick = ithick
!p.font=0

restore,'../V3tmp/MLS-Aura_L2CLD_V3-CLD01_2012d267.sav' & tit='Sept 23, 2012'

cloud=atGod_createcore(noprofs=n_elements(LONGITUDE),nosurfs=11)
cloud.lat=LATITUDE
cloud.lon=LONGITUDE
cloud.val=transpose(MLS_CLD_IWC)
cloud.surfs=pressure

track=cloud
track.val=1

cloud1=cloud
cloud2=cloud
cloud3=cloud
cloud4=cloud

inds = Where(cloud.val LT .24, cnt)
IF cnt GT 0 THEN cloud.val[inds] = cloud.badData

inds = Where(cloud1.val LT .6, cnt)
IF cnt GT 0 THEN cloud1.val[inds] = cloud1.badData

inds = Where(cloud2.val LT 1., cnt)
IF cnt GT 0 THEN cloud2.val[inds] = cloud2.badData

inds = Where(cloud3.val LT 6., cnt)
IF cnt GT 0 THEN cloud3.val[inds] = cloud3.badData

inds = Where(cloud4.val LT 12., cnt)
IF cnt GT 0 THEN cloud4.val[inds] = cloud4.badData

;clev = make_bins(0.0,10,21) 
clev = make_bins(0.0,2.,21) 
;clev = clev[3:*]
nlevs = N_ELEMENTS(clev)

;tit='MLS Measurement Locations  12 December 2006'

InitColorBoss
black = AllocateColor(0, 0, 0)
white = AllocateColor(255, 255, 255)
boxColor = AllocateColor(190, 190, 190)
mainColorRange = AllocateRange(nlevs-1)
colorTable = 34
LoadCTToRange, colorTable, mainColorRange
mainColorRange = [black,mainColorRange]


map_set, 0, 180, /cont, pos=[0.1,0.15,0.85,0.90], tit=tit,limit=[-90,0,90,360],charsize=1.6
dotplot,track,height=100,size=0.5, colors=black,levels=1.0
dotplot,cloud,height=100,size=0.9, colors=mainColorRange,levels=clev
dotplot,cloud1,height=100,size=1.7, colors=mainColorRange,levels=clev
dotplot,cloud2,height=100,size=2.7, colors=mainColorRange,levels=clev
dotplot,cloud3,height=100,size=3.7, colors=mainColorRange,levels=clev
dotplot,cloud4,height=100,size=3.7, colors=boxcolor,levels=clev


!P.Position = [0.87, 0.16, 0.89, 0.90]
mls_ColorBar, levels=clev,filCols= mainColorRange, yAxis=1, box=1,title='100 hPa IWC (mg/m!U3!N)',middleLabels=1,$
formatString='(f4.1)',oppositeLabels=1,charsize=1.6,downsample=2

;endif

fini_plot

end

