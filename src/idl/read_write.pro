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

    if (iday lt 10) then begin
       openw, lun, 'Aura_MLS_L2IWC_V2.2_'+year+month(imon)+'0'+strmid(string(iday),7)+'.txt', /GET_LUN
    endif else begin
       openw, lun, 'Aura_MLS_L2IWC_V2.2_'+year+month(imon)+strmid(string(iday),7)+'.txt', /GET_LUN
    endelse

        printf, lun, iwc
        free_lun, lun

endif
ENDFOR
ENDFOR



end
