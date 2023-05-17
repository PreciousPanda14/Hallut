function [Elpris] = elpris()
Jan=readmatrix('jantxt.txt');
Feb=readmatrix('febtxt.txt');
Mar=readmatrix('martxt.txt');
Apr=readmatrix('aprtxt.txt');
Maj=readmatrix('majtxt.txt');
Jun=readmatrix('juntxt.txt');
Jul=readmatrix('jultxt.txt');
Aug=readmatrix('augtxt.txt');
Sep=readmatrix('septxt.txt');
Okt=readmatrix('okttxt.txt');
Nov=readmatrix('novtxt.txt');
Dec=readmatrix('dectxt.txt');

Elpris=[Jan; Feb; Mar; Apr; Maj; Jun; Jul; Aug; Sep; Okt; Nov; Dec]./1000;
end

