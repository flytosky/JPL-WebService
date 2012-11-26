
restore,'/nas/lacie/perun/CloudSat_only/CLFR_CloudSat_2008-05.idl-save'

np=42
nlng=144
nlat=91

l1=-20
l2=20

zlat_clfr=fltarr(nlat,np)
zlng_clfr=fltarr(nlng,np)
p_clfr=fltarr(np)

;;;compute zonal mean
for j=0,nlat-1 do begin
    for k=0, np-1 do begin    
          ii=where (CLFR_avg(*,j,k) ge 0.)
          zlat_clfr(j,k)=mean(CLFR_avg(ii,j,k))
    endfor
endfor

;;;compute longitude mean
for i=0,nlng-1 do begin
    for k=0, np-1 do begin    
          ii=where (CLFR_avg(i,*,k) ge 0. and glat ge l1 and glat le l2)
          zlng_clfr(i,k)=mean(CLFR_avg(i,ii,k))
    endfor
endfor

;;;compute profile
for k=0, np-1 do begin    
    ;    p_clfr(k)=mean(CLFR_avg(*,l1:l2,k))
    ii=where (glat ge l1 and glat le l2)
    p_clfr(k)=mean(zlat_clfr(ii,k))
endfor

 clev = make_bins(0.1,40.,51,/log) 
; clev = make_bins(0.,40.,51) 
 clev(0)=0. 
 nlevs = N_ELEMENTS(clev)

InitColorBoss
black = AllocateColor(0, 0, 0)
white = AllocateColor(255, 255, 255)
boxColor = AllocateColor(200, 200, 200)
mainColorRange = AllocateRange(nlevs-1)
colorTable = 34
LoadCTToRange, colorTable, mainColorRange
mainColorRange = [white,mainColorRange]


pos1=[0.05,0.1,0.30,0.9]
pos2=[0.35,0.1,0.60,0.9]
pos3=[0.73,0.1,0.98,0.9]

yra=[0,20]
zlat_clfr = smooth(zlat_clfr,3) & ii=where(zlat_clfr lt 0) & zlat_clfr(ii)=0.
zlng_clfr = smooth(zlng_clfr,3) & ii=where(zlng_clfr lt 0) & zlng_clfr(ii)=0.

contour,zlat_clfr,glat,surf,level=clev,pos=pos1,c_color=mainColorRange,/cell_fill,$
yra=yra,yst=1,xra=[-80,80],xst=1,xticks=8,xtit='Latitude',ytit='Height (km)',yticks=9

contour,zlng_clfr,glng,surf,level=clev,pos=pos2,c_color=mainColorRange,/cell_fill,$
yra=yra,yst=1,xra=[0,360],xst=1,xticks=6,/noerase,xtit='Longitude',ytit='Height (km)'

!P.Position = [0.61, 0.1, 0.62, 0.9]
mls_ColorBar, levels=clev,filCols= mainColorRange, yAxis=1, box=1,title='CLFR (%)',middleLabels=1,$
formatString='(f5.1)',oppositeLabels=1,downsample=5

plot,p_clfr,surf,yra=yra,yst=1,pos=pos3,/noerase,xtit='CLFR (%)',ytit='Height (km)', thick=3




end
