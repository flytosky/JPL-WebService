#! /usr/local/bin/octave -qf
x=[0,.11,.15,.18,.25,.32,.35,.39,.42,.44,.48,.50];
y = [0 , 1 , 3 , 5 , 12 , 10 , 9 , 7 , 5 , 3 , 7 , 10];
figure(1)
p1 = plot(x,y);
print -dpng p1.png

x1=linspace(0,5,.05);
y1 = spline(x,y,x1)
figure(2)
p2 = plot(x1,y1);
axis([0, .5, 0, 15])
print -dpng p2.png

y2 = interp1(x,y,x1)
figure(3)
p3 = plot(x1,y2);
axis([0, .5, 0, 15])
print -dpng p3.png
