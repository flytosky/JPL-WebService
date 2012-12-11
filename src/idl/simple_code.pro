;;;sample read plot commands



;;; restore,'IWC/Aura_MLS_L2IWC_V2.2_20051231.sav'
cmrestore,'IWC/Aura_MLS_L2IWC_V2.2_20051231.sav'
plot,latitude
plot,longitude
plot,pressure
print,pressure
plot,iwc(2,*)
plot,iwc(2,*),tit='hi',charsize=2,xtit='no. meas',ytit='IWC'
;;; map_set,/cont
;;; map_set,0,180,/cont
plots,longitude,latitude
set_plot,'ps'

end
