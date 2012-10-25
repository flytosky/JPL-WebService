#! /usr/local/bin/octave -qf

function [max,min] = maxmin( a, b )
   if(a >= b )
        max = a;
        min = b;
        return;
   else
        max = b;
        min = a;
        return;
   endif
endfunction
