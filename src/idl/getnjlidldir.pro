;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;+
; This function is an attempt to work out where to point users to for
; their MSL AtGod IDL procedures.  It needs to work both for me on the
; floor and at home, and for other users on the floor
;
; @keyword localFile {type=String}
;                    The name of a file below the root directory.  If
;                    this file does not exist, use a default root.
;
; @returns The path of the proper location of Nathaniel's IDL
;          directory.
;
;-
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function GetNJLIDLDir, localFile=file

;; Now we need to find out where we are running in.
useDefault = 0

;; Test #1.  See where this program is running.  Should be in
;; .../idl/misc/ 
;; Help, /SOURCE, name='getnjlidldir', output=op
;; The info we want is on the last line after the spaces
root = File_DirName((StrSplit(op[N_Elements(op)-1], ' ', /EXTRACT, count=cnt))[cnt-1], $
                    /MARK_DIRECTORY)
IF StRegEx(root, 'idl/misc/$', /BOOLEAN) THEN BEGIN
  ;; We need to remove misc/
  root = StrMid(root, 0, StrLen(root) - 5)
ENDIF ELSE BEGIN
  ;; Lets try test #2.  See if there is an idl/atgod under the user's
  ;; home directory.
  home = GetEnv('HOME')
  IF (File_Search(home + '/idl/atgod'))[0] NE '' THEN BEGIN
    root = home + '/idl/'
  ENDIF ELSE useDefault = 1
ENDELSE

;; Now make sure if we want a file that it exists in the directory.
;; This is good for users who want IDL but do not want the mess of
;; compiling, etc.
hasFile = Keyword_Set(file)
IF useDefault || (hasFile && (File_Search(root + file + '/'))[0] EQ '') THEN BEGIN
  Spawn, 'domainname', whereAmI
  SWITCH whereAmI[0] OF
    'mlsscf' : 
    'mls_scf' : BEGIN
      root = '/software/idl_share/idl/'
      BREAK
    END
    'met.edinburgh.ac.uk' : 
    'glg' : BEGIN 
      root = GetEnv('USER') EQ 'mjf' ? '/geos/eosmls/fm4/idl/' : $ ; mark
      '/geos/eosmls/local/idl_test/idl/' ; archie
      BREAK
    END
    ELSE : BEGIN
      IF hasFile THEN BEGIN
        MyMessage, /ERROR, 'This is an unknown location: ' + root + file
      ENDIF ELSE BEGIN
        MyMessage, /ERROR, 'Cannot find an idl root'
      ENDELSE
    END
  ENDSWITCH
ENDIF

Return, root

END
