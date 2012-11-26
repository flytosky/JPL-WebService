;;; define 4 by 8 degree latitude x longitude grid
nlat=43 & dlat=4. & glat=-84+indgen(nlat)*dlat
nlng=45 & dlng=8. & glng=dlng/2.+indgen(nlng)*dlng

np=11

IWCavg=fltarr(np,nlng,nlat)
press=fltarr(np)

cnt=fltarr(np,nlng,nlat)
tcnt=fltarr(np,nlng,nlat)
CFR=fltarr(np,nlng,nlat)

goto, plt

;;; day, month, year
n_mon=12
day=intarr(n_mon,2)
day(0,*) =[01,31]  
day(1,*) =[01,28] 
day(2,*) =[01,31] 
day(3,*) =[01,30] 
day(4,*) =[01,31] 
day(5,*) =[01,30] 
day(6,*) =[01,31] 
day(7,*) =[01,31] 
day(8,*) =[01,30] 
day(9,*) =[01,31] 
day(10,*)=[01,30] 
day(11,*)=[01,31] 

month=['01','02','03','04','05','06','07','08','09','10','11','12']

year=['2005']

n_mon=1 ; do jan only

FOR imon=0, n_mon-1 do begin
  FOR iday=day(imon,0),day(imon,1) do begin
    if (iday lt 10) then begin
       fname=findfile('IWC/Aura_MLS_L2IWC_V2.2_'+year+month(imon)+'0'+strmid(string(iday),7)+'.sav')
    endif else begin
       fname=findfile('IWC/Aura_MLS_L2IWC_V2.2_'+year+month(imon)+strmid(string(iday),6)+'.sav')
    endelse
    print,'processing '+fname
    if (strlen(fname) gt 6) then begin
    restore,fname

  ; rephase the longitude
    longitude(WHERE(longitude LT 0.0)) = 360.0 + longitude(WHERE(longitude LT 0.0))

for j=0,nlat-1 do begin
for i=0,nlng-1 do begin
    for k=0,np-1 do begin   
             ii=where(abs(latitude-glat(j)) lt dlat/2. $
             and abs(longitude-glng(i)) lt dlng/2. $
             and IWC(k,*) gt 0)

         if(ii(0) ne -1) then begin
             IWCavg(k,i,j) = IWCavg(k,i,j) + total(IWC(k,ii))
             cnt(k,i,j)    = cnt(k,i,j)    + n_elements(ii)
         endif

         jj=where(abs(latitude-glat(j)) lt dlat/2. $
             and abs(longitude-glng(i)) lt dlng/2.$
             and IWC(k,*) ge 0.0)
         if(jj(0) ne -1) then begin
             tcnt(k,i,j)     = tcnt(k,i,j)     + n_elements(jj)
         endif
    endfor
endfor
endfor
endif
  ENDFOR
ENDFOR

for j=0,nlat-1 do begin
for i=0,nlng-1 do begin
    for k=0,np-1 do begin   
        if ( tcnt(k,i,j) gt 0.) then begin
            IWCavg(k,i,j) = IWCavg(k,i,j) / tcnt(k,i,j)
            CFR(k,i,j)    = cnt(k,i,j) / tcnt(k,i,j)
        endif else begin
            IWCavg(k,i,j) = -999.99
            CFR(k,i,j)    = -999.99
        endelse
    endfor
endfor
endfor

save, file='test.sav', glat, glng, IWCavg, CFR, pressure

plt:

restore,'test.sav'

 k=2
 want=reform(IWCavg(k,*,*)) 
 clev = make_bins(0.0,10.0,21) 
 nlevs = N_ELEMENTS(clev)

 InitColorBoss
 black = AllocateColor(0, 0, 0)
 white = AllocateColor(255, 255, 255)
 boxColor = AllocateColor(200, 200, 200)
 mainColorRange = AllocateRange(nlevs)
 colorTable = 34
 LoadCTToRange, colorTable, mainColorRange

 pos=[0.1,0.10,0.85,0.85]

 map_set,0,180,limit=[-90,0,90,360],pos=pos, tit='My Test Plot'

 contour,want,glng,glat,level=clev,c_color=mainColorRange,/cell_fill,/over

 MAP_CONTINENTS,linestyle=0,pos=pos,color=white, thick=3,/over

!P.Position = [0.87, 0.1, 0.88, 0.85]
mls_ColorBar, levels=clev,filCols= mainColorRange, yAxis=1, $
box=1,title='IWC (mg/m!U3!N)',middleLabels=1,$
formatString='(f5.1)',oppositeLabels=1,charsize=1.2,downsample=2



end
