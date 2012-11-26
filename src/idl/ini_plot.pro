PRO ini_plot,choix

; ATTENTION: les choix presentes sont lies a la procedure fini_plot.pro
; Modification 20/10/94 pour pouvoir appeler la procedure en mode 
; non-interactif. On doit alors donner un parametre qui correspond au choix
; de l'appareil
common VAR_PLOT, nom_fichier_Postscript,choix_app,app_prec,pos_prec

;;print,' Version non-interactive'
app_prec=!d.name
pos_prec=!P.position

if N_PARAMs() ne 0 then BEGIN
  if (choix lt 0) or (choix gt 9) then BEGIN
    print,' Le choix de l''appareil de sortie: ',choix,'  est invalide'
    print,' Il faut choisir entre 0 et 9'
    print,' On suppose un terminal-X'
    choix_app=1
  ENDIF else BEGIN
    choix_app=choix
  ENDELSE

  goto, app_choisi  
ENDIF

  recommence:

  print,' Affichage ?'
  print,'   0: SUN'
  print,'   1: X '
  print,'   2: TEKtronix passer au mode TEK (CTRL+bouton milieu)'
  print,'   3: Postscript (portrait)'
  print,'   4: Postscript (paysage)'
  print,'   5: Postscript (carre)'
  print,'   6: Postscript (carre+teintes de gris )'
  print,'   7: Postscript (carre+couleur )'
  print,'   8: Postscript (a inclure dans un fichier WORD)'
  print,'   9: Postscript couleur (a inclure dans un fichier WORD)'

read,choix_app

app_choisi:

case choix_app of
	0: begin
		set_plot,'sun'
	end
	1: begin
		set_plot,'x'
;        	!p.background=1
;		!p.color=0
;		window,2,xsize=700,ysize=600
;                window
	end
	2: begin
        	set_plot,'tek'
	end
	3: begin
		set_plot,'ps'
		device,xsize=18.75,xoffset=1.25,ysize=22.0,yoffset=2.25,/port,/color,bits=16
;                device,xsize=18.75,xoffset=1.25,ysize=22.0,yoffset=2.25,/port,bits=16
	end
	4: begin
		set_plot,'ps'
		device,xsize=25.0,xoffset=1.25,ysize=18.75,yoffset=26.25,/land,/color,bits=24
;		device,xsize=24.0,xoffset=1.25,ysize=17.66,yoffset=26.25,/land,/color,bits=24
;                device,xsize=24.0,xoffset=6.25,ysize=8.66,yoffset=26.25,/land,/color,bits=24
;                device,xsize=24.0,xoffset=1.25,ysize=17.66,yoffset=26.25,/land,bits=24
	end
	5: begin
		set_plot,'ps'
		device,xsize=18.75,xoffset=2.0,ysize=18.75,yoffset=2.0,/port
	end
	6: begin
		set_plot,'ps'
		device,xsize=18.75,xoffset=1.25,ysize=18.75,yoffset=1.25,/port,bits=8
	end
	7: begin
		set_plot,'ps'
		device,xsize=18.75,xoffset=1.25,ysize=18.75,yoffset=2.5,/port,bits=8,/color
	end
	8: begin
;                !p.font=-1
                !p.font=0
		set_plot,'ps'
		print,' Donner la taille de la figure ( X,Y en cm )'
		read,x,y
		print,' Donner le nom du fichier Postscript pour cette figure'
		nom_fichier_Postscript=''
		read,nom_fichier_Postscript
		device,xsize=x,xoffset=0.0,ysize=y,yoffset=0.0,/port,bits=8,filename=nom_fichier_Postscript,$
;                /encapsulated,/color,/times,/bold
                /encapsulated,/color,/helvetica,/bold  
;                /encapsulated,/color,/helvetica
;              /encapsulated,/color,/times
	end

	9: begin
		set_plot,'ps'
		print,' Donner la taille de la figure ( X,Y en cm )'
		read,x,y
		print,' Donner le nom du fichier Postscript pour cette figure'
		nom_fichier_Postscript=''
		read,nom_fichier_Postscript
		device,xsize=x,xoffset=0.0,ysize=y,yoffset=0.0,/port,bits=8,/color,filename=nom_fichier_Postscript,/encapsulated
	end
	else: begin
		print,' Il faut choisir entre 0 et 9'
		goto, recommence
	end
endcase

end

