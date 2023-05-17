function [T1,Elforbrukning] = elanvandning()
Q=readcell('Elanvändning_2018_1.xlsx');
Q1=readmatrix('Elanvändning_2018_1.xlsx');
T1=datetime(Q(:,1),'InputFormat','yyyy-MM-dd HH:mm');
Elforbrukning = Q1(:,2);
end

