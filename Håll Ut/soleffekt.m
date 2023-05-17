function [Solel_tim] = soleffekt()
text=fileread('Soltimmar_lund.txt');

A=fopen('Soltimmar_lund.txt', 'r');
D=fscanf(A, '%d');

D=0.01.*D;
B=[D(1:674);0;0;D(675:696);0;0;D(697:718);0;0;D(719:720);0;0;D(721:722);0;0;D(723:726);0;0;D(727:728);0;0;D(729:end)];
T=zeros(31,12);

St= [16.0,32.5, 102.1, 139.7,164.2,172.2, 176.2, 152.3, 91.1, 49.3, 15.1, 10.0];

j=0;
pos=0;
pos_r=0;
for i=1:2:length(B);
    j=j+1;
    if mod(j,12)==0
       pos=12;
    else
        pos=mod(j,12);
    end
    if mod(j,12)==1
        pos_r=pos_r+1;
    end
   h_i=floor(B(i));
   h_e=floor(B(i+1));
   m=B(i+1)-h_e-B(i)+h_i;
   
   if sign(m)==1
      r=m;
   elseif sign(m)==-1
      r=-0.4+m;
   else
       r=0;
   end
   T(pos_r,pos)=(h_e-h_i+r);
end
Tot_t=zeros(1,12);
Ave=zeros(1,12);
Ene=zeros(1,12);
day_func=cell(31,12);
for k=1:12;
    h=0;
    m=0;
    for j=1:31
        h=h+ floor(T(j,k));
        m=m+T(j,k)-floor(T(j,k));
    end
    Tot_t(k)= (h.*60)+(m.*100);

    if k==2
        y=28;
    elseif k==4 ||k==6 ||k==9 ||k==11
        y=30;
    else 
        y=31;
    end
    Ave(k)=mod(((((h.*60)+(m.*100)))./y), 60)./100+ (floor(((((h.*60)+(m.*100)))./(y.*60))));
end


for k=1:12;
    Ene(k)=((St(k))./(Tot_t(k)));
    for j=1:31
        t=(floor(T(j,k)).*60)+ ((T(j,k)-floor(T(j,k))).*100);
        day_func{j,k}=@(x)(heaviside(x-(720-(t./2)))-heaviside(x-((720+(t./2))))).*((pi.*Ene(k))./2).*sin(((pi./t).*(x-(720-(t./2)))));%(heaviside(x-(720-(t./2)))-heaviside(x-((720+(t./2))))).*
    end
end

% figure(1)
% h=0:1440;
% g=day_func{31,1}
% plot(h,g(h))
% integral(g,0,1440);
% ((floor(T(1,1)).*60)+ ((T(1,1)-floor(T(1,1))).*100)).*Ene(1);
% en_day=zeros(31,12);
for k=1:12;
    for j=1:31
        en_day(j,k)=(((floor(T(j,k)).*60)+ ((T(j,k)-floor(T(j,k))).*100)).*Ene(k));%integral(day_func{j,k},0,1440)
    end
    
end
en_day;
y=0;
Solel_tim=zeros(1,8760);
c=0;
for k=1:12;
    if k==2
        y=28;
    elseif k==4 ||k==6 ||k==9 ||k==11
        y=30;
    else 
        y=31;
    end
    for j=1:y
        for i=0:60:1439;
            c=c+1;
         Solel_tim(c)=integral(day_func{j,k},i,i+60);
        end
    end
    
end
end

