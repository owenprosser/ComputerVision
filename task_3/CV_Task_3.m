clear; clc; close all;

a = csvread('a.csv');
b = csvread('b.csv');
x = csvread('x.csv');
y = csvread('y.csv');

plot(a,b);
hold;
plot(x,y);

for i = 1:size(a,2)
    disp(i)
end