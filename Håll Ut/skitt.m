clear all;
close all;
clc;


Koldioxid_ekv_Eu=265.5;
Koldioxid_ekv_sol=41;

Elpris = elpris(); %Elpris varje timme under året, utan skatt
[Timmar, Elforbrukning]= elanvandning(); %Elförbrukning och en timvektor för ett hushåll
Solel_tim_m2= readmatrix('Solel_tim_m2');% soleffekt, kWh/m2, varje timme under året 

%Elpris=Elpris.*(52.8824./171.217);
%Elforbrukning=Elforbrukning.*2;
% El_tihi=zeros(1,24);
% for i=1:8760
%     if mod(i,24)==0
%         El_tihi(24)= El_tihi(24)+ Elforbrukning(i);
%     else
%         El_tihi(mod(i,24))= El_tihi(mod(i,24))+ Elforbrukning(i);
%     end
% end
% El_tihi=El_tihi./365;
% 
% figure(1)
% plot(0:23, El_tihi)



%soleffekt().';% kWh/m^2 varje timme hela året

% fileID = fopen('Solel_tim_m2.txt','w');
% fprintf(fileID,'%d\n',Solel_tim_m2);
% fclose(fileID);


m2_solcell = 30;
verkningsgrad=0.17; %verkningsgrad solcell
Batterikapacitet= 13.8; %kWh
Solel_tim= Solel_tim_m2.*m2_solcell.*verkningsgrad;% Solel en får ut från solcellerna
netto_el=Elforbrukning - Solel_tim; 

Inhamtning_mat=[0,488.5, 814.2, 1139.9];
Utslapp_alt=[0,2.48, 4.14, 5.5;
             0,132, 219.8, 308.1;
             0,463.94, 772.52, 1082.53];

Batteri_kostnad=[0,39650, 56400,74500];
Solpaneler_kostnad=[0,91211, 132651, 156090];
r=0.027;


%Laddning= zeros(8760,1); % kWh i batteriet NU
%Sum=0;
%Avg_day=0;
Max_out=3; % Maximal output för batteriet per timme (kWh)
Nmbr_hours=7; % timmar under sommaren som anses bäst/dyrast
Nmbr_hours_win=10; % timmar under vintern som anses bäst/dyrast
%Koldioxid_sum=0;
%Koldioxid_ekv=0;

BatteriKapaciteter=[0,8.28, 13.8, 19.32]; %Batterikapaciteter som prövas
Solcells_storlekar=[0,30, 50, 70]; %Solcellstrolekar som prövas

%PeakHourShift(Elpris,Elforbrukning, BatteriKapaciteter(1), netto_el, Max_out, Nmbr_hours, Nmbr_hours_win, Sol_el);

OptimalValues=zeros(4,4,6); %optimala värden för varje kombination av 
%solceller och batteristrolekar enligt ovan vektorer med avseende på sum.
% För dessa optimala summor fås även:nmbr_hours(:,:,2),nmbr_hours_win(:,:,3),
% koldixoid_egen(:,:,4), koldioxid_sparad(:,:,5), differens(:,:,2)

%Elpris_day=zeros(1,24);

% Tar reda på optimala värden för alla kombinationer av storlekar på
% batteri och solcellsyta med avseende på sum. Dessa läggs i Optimal_Values
for i=1:4
    Sol_el=Solel_tim_m2.*Solcells_storlekar(i).*verkningsgrad;
    netto_el=Elforbrukning - Sol_el;
    for j=1:4
        hours_values=zeros(1,25);
        for k=0:24
            [~,Sum,~,~]=PeakHourShift(Elpris,Elforbrukning, BatteriKapaciteter(j), netto_el, Max_out, k, Nmbr_hours_win, Sol_el,Solcells_storlekar(i));
            hours_values(k+1)=Sum;
        end
        [~, idx]=sort(hours_values);
        OptimalValues(i,j,2)=idx(1);
        hours_values=zeros(1,25);
        for k=0:24
            [~,Sum,~,~]=PeakHourShift(Elpris,Elforbrukning, BatteriKapaciteter(j), netto_el, Max_out, Nmbr_hours, k, Sol_el,Solcells_storlekar(i));
            hours_values(k+1)=Sum;
        end
        [~, idx]=sort(hours_values);
        OptimalValues(i,j,3)=idx(1);
        [~,Sum_opt, Kol_egen, Kol_sparad]=PeakHourShift(Elpris,Elforbrukning, BatteriKapaciteter(j), netto_el, Max_out, OptimalValues(i,j,2),OptimalValues(i,j,3), Sol_el,Solcells_storlekar(i));
        OptimalValues(i,j,1)=Sum_opt;
        OptimalValues(i,j,2)=OptimalValues(i,j,2)-1;
        OptimalValues(i,j,3)=OptimalValues(i,j,3)-1;
        OptimalValues(i,j,4)=Kol_egen;
        OptimalValues(i,j,5)=Kol_sparad;
        OptimalValues(i,j,6)=Kol_egen-Kol_sparad;
    end
end

OptimalValues(:,:,4)=OptimalValues(:,:,4)./(10.^3);
OptimalValues(:,:,5)=OptimalValues(:,:,5)./(10.^3);
OptimalValues(:,:,6)=OptimalValues(:,:,6)./(10.^3);

Netto_summa_res=zeros(4,4);
Utslapp_tio=zeros(4,4);
Utslapp_tretio=zeros(4,4);

Kostnad_tio=zeros(4,4);
Kostnad_tretio=zeros(4,4);

Utslapp_tio_alla=zeros(3,4,4);


for i=1:4
    for j=1:4
        Netto_summa_res(i,j)=OptimalValues(1,1,1)-OptimalValues(i,j,1);
        if i~=4
             Utslapp_tio(i,j)=Inhamtning_mat(j)+ Utslapp_alt(i,j)+ (10.*OptimalValues(4,j,6));
             Utslapp_tretio(i,j)=Inhamtning_mat(j)+ Utslapp_alt(i,j)+ (30.*OptimalValues(4,j,6));
        end
        Kostnad_tio(i,j)= Batteri_kostnad(j)+Solpaneler_kostnad(i);
        Kostnad_tretio(i,j)= Batteri_kostnad(j)+Solpaneler_kostnad(i);
        for k=1:30
             if k<=10
                 Kostnad_tio(i,j)=Kostnad_tio(i,j)- (Netto_summa_res(i,j)./((1+r).^k));
             end
             Kostnad_tretio(i,j)= Kostnad_tretio(i,j)- (Netto_summa_res(i,j)./((1+r).^k));
             if mod(k,10)==0 && k~=30
                 Kostnad_tretio(i,j)=Kostnad_tretio(i,j)+ Batteri_kostnad(j);
             end
        end
    end
end

for k=1:4
    for i=1:3
        for j=1:4
            Utslapp_tio_alla(i,j,k)=Inhamtning_mat(j)+ Utslapp_alt(i,j)+ (10.*OptimalValues(k,j,6));
           
            
           
          
        end
    end
end
Utslapp_tio_alla_netto=zeros(3,4,4);

for k=1:4
    for i=1:3
        for j=1:4
            Utslapp_tio_alla_netto(i,j,k)=Utslapp_tio_alla(1,1,1)-Utslapp_tio_alla(i,j,k);
           
            
           
          
        end
    end
end


%[Laddning,Sum] = PeakHourShift(Elpris,Elforbrukning, Batterikapacitet, netto_el, Max_out, Nmbr_hours, Nmbr_hours_win);

% figure(1)
% plot(Timmar, Laddning(2:end))
% figure(2)
% plot(Timmar, Elpris)




