#! /usr/local/bin/octave -qf
x = linspace(0, 2*pi, 100);
y = sin(x);
p1 = plot(x, y);

print -dpng fig1.png
