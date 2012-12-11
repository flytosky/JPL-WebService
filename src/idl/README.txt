Hi Jonathan:

I found from Googling that people are using Craig Markwardt's
CVSVLIB for SAVE and RESTORE in GDL:

http://ubuntuforums.org/showthread.php?t=1318166

http://gnudatalanguage.sourceforge.net/

IDL SAVE files (supported using the Craig Markwardt's CMSVLIB
<http://cow.physics.wisc.edu/~craigm/idl/down/cmsvlib.tar.gz>)


So I downloaded and installed cmsvlib in the VM running on oscar2.
It is a bunch of .pro files:
/home/sflops/local/cmsvlib/*.pro
(on cmac-vm on oscar2)


I tried a simple case in GDL:
GDL> var1=3
GDL> CMSAVE, var1, filename='myfile.sav'


(myfile.sav is created in local dir)

GDL> CMRESTORE, 'myfile.sav', var1
GDL> print, var1
       3

(So it seems to be working.)


Could you please take a read of those web pages above
and try it with a real IDL example?

BTW, you should automatically have this lib installed
in your PATH because in your .bashrc file I have put
in a line:
# env for CMAC project
source /home/sflops/local/cmac-env.sh
to get cmac-env and in

/home/sflops/local/cmac-env.sh
I have a line for GDL
# for GDL
export GDL_STARTUP=/home/sflops/.gdl_startup


Just so you know how/where GDL env variables are set.

Please let me know how the GDL CMSAVE and CMRESTORE work for you.

Thanks,
-Lei


