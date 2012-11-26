
restore,'test.sav'

np=11
nlng=45
nlat=43

zlat_iwc=fltarr(nlat,np)
zlng_iwc=fltarr(nlng,np)
p_iwc=fltarr(np)

;;;compute zonal mean
for j=0,nlat-1 do begin
    for k=0, np-1 do begin    
          zlat_iwc(j,k)=mean(IWCavg(k,*,j))
    endfor
endfor

;;;compute longitude mean
for i=0,nlng-1 do begin
    for k=0, np-1 do begin    
          zlng_iwc(i,k)=mean(IWCavg(k,i,20:22))
    endfor
endfor

;;;compute profile
for k=0, np-1 do begin    
    p_iwc(k)=mean(IWCavg(k,*,20:22))
endfor

 clev = make_bins(0.,4.,21) 
 nlevs = N_ELEMENTS(clev)

InitColorBoss
black = AllocateColor(0, 0, 0)
white = AllocateColor(255, 255, 255)
boxColor = AllocateColor(200, 200, 200)
mainColorRange = AllocateRange(nlevs)
colorTable = 34
LoadCTToRange, colorTable, mainColorRange

pos1=[0.05,0.1,0.30,0.9]
pos2=[0.35,0.1,0.60,0.9]
pos3=[0.73,0.1,0.98,0.9]

contour,zlat_iwc,glat,pressure,level=clev,pos=pos1,c_color=mainColorRange,/cell_fill,$
yra=[300,50],yst=1,xra=[-90,90],xst=1,xticks=6,xtit='Latitude',ytit='Pressure (hPa)'

contour,zlng_iwc,glng,pressure,level=clev,pos=pos2,c_color=mainColorRange,/cell_fill,$
yra=[300,50],yst=1,xra=[0,360],xst=1,xticks=6,/noerase,xtit='Longitude',ytit='Pressure (hPa)'

!P.Position = [0.61, 0.1, 0.62, 0.9]
mls_ColorBar, levels=clev,filCols= mainColorRange, yAxis=1, box=1,title='IWC (mg/m!U3!N)',middleLabels=1,$
formatString='(f5.1)',oppositeLabels=1,downsample=2

plot,p_iwc,pressure,yra=[300,50],yst=1,pos=pos3,/noerase,xtit='IWC (mg/m!U3!M)',ytit='Pressure (hPa)'




end
