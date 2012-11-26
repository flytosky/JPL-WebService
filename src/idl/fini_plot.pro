pro fini_plot,imprime

; Procedure qui sert a terminer une sortie graphique.
; En particulier, pour les fichiers Postscript, on ferme le fichier
; et on selectionne la destination de ce fichier.
; Cette nouvelle version permet de specifier  la destination a l'appel
; et peut etre utilisee en mode non-interactif.

common VAR_PLOT, nom_fichier_Postscript,choix_app,app_prec,pos_prec

!P.POSITION=pos_prec	; on remet les coord. originales
if choix_app gt 2 then begin
  device,/close

  if choix_app lt 8 then begin
    IF N_PARAMs() ne 0 then BEGIN
      IF (imprime lt 1) or (imprime gt 4) then BEGIN
        print,' Le choix de l''appareil de sortie: ',imprime,'  est invalide'
        print,' Il faut choisir entre 1 et 4'
        print,' On place la sortie dans un fichier Postscript'
        impr=1
      ENDIF else BEGIN
      impr=imprime
      ENDELSE

      goto, impr_choisi
    ENDIF

recommence:

    print,' Imprimante ?'
    print,'	1:  fichier postscript'
    print,'	2:  ATMOSPHERE'
    print,' 	3:  MESOSPSHERE'
    print,' 	4:  EXOSPSHERE'
    read,impr

impr_choisi:
    case impr of
	1: print,' Le fichier Postscript est: wave.ps'
	2: spawn,'lpr -Plw1 wave.ps'
	3: spawn,'lpr -Plw2 -h wave.ps'
	4: spawn,'lp  -dlw3 wave.ps'
     else: begin
             print,' Il faut choisir entre 1-4 '
             goto, recommence
           end
    endcase
  endif

  if (choix_app eq 8) or (choix_app eq 9) then begin
    print,' '
    print,' Le fichier ',nom_fichier_Postscript,' est pret a etre inclus dans un document WORD'
    print,' '
  end

end

;;;;ini_plot

set_plot,app_prec

end








