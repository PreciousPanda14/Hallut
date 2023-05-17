function [Laddning,Sum, Sum_koldioxid_egen, Sum_koldioxid_sparad] = PeakHourShift(Elpris,Elforbrukning, Batterikapacitet, netto_el, Max_out, Nmbr_hours, Nmbr_hours_win, Sol_el, Sol_storlek)
% definerar variabler
Sum=0; %Total summa, inkomster minus kostnader
Sum_koldioxid_egen=0; %Den själv förbrukade koldioxiden
Sum_koldioxid_sparad=0; %Den sparade koldioxiden kopplat till solcellerna
Sald_el=0; %Total summa såld el (från solceller+ batteri)
Konsumerad_el_net=0; %total konsumerad el från nätet (egen konsumption+ uppladdning batteri)
Konsumerad_el_sol=0; %total konsumerad el från solen (direkt konsumption+ uppladdning batteri)
Bat_sol=0; %koll på hur mycket av elen i batteriet som är från solcellerna
Bat_smuts=0; %koll på hur mycket av elen i batteriet som är från elnätet
Bat_sol_tot=0; %Hur mycket solel som sålts från batteriet
Bat_smuts_tot=0; %Hur mycket elnäts-el som sålts från batteriet
Bat_kon_smuts=0; %Hur mycket elnätsel som konsumeras från batteri
Bat_kon_sol=0; %Hur mycket solel som konsumeras från batteri


%konstanter och återkommande/essentiella vektorer
Bat_offset= 1./0.96; %hur mycket extra el som behövs för att ladda batteriet 
Elpris_day=zeros(1,24); %vektor med elpris varje timme på ett dygn. Uppdateras varje dygn.
Laddning= zeros(8760,1); %Total laddning varje timme i batteriet
Koldioxid_ekv_Eu=265.5; %Koldioxidekvivalent EU
Koldioxid_ekv_sol=41; %Koldioxidekvivalent solcell
Elskatt_net= 0.392; %punktskatt el från elnätet
El_moms=1.25; %moms på elen
Skatte_red=0.6; %skattereduktionen per kWh
net_nytta=0.02; % nätnytta per exporterad kWh till elnätet
proc=0; % procent av batteriet som vid varje tillfälle är från solel

%går igenom alla timmar på året 

for i=1:8760
     
    %beräknar ens egna konsumerad solel direkt från solceller
    if netto_el(i)>=0
        Konsumerad_el_sol=Konsumerad_el_sol+ Sol_el(i);
    else
        Konsumerad_el_sol=Konsumerad_el_sol+ (netto_el(i)+Sol_el(i));
    end
    
    % Sorterar elpriserna varje dag från minst till störst 
    % samt har koll på dess timme (idx)
     if mod(i,24)==1
      for k=0:23
         Elpris_day(k+1)=Elpris(i+k);
      end
      [~, idx]= sort(Elpris_day);
     end
     
    
     %går igenom "sommarmånaderna" (April-Oktober)
    
    if ismember(i,2521:6912)
        
        %Tar ut dyraste Nmbr_hours st timmarna på dygnet, lägger 
        %i Best_ind (Best index, då idx=timme)
        if mod(i,24)==1
          Best_ind=zeros(1,Nmbr_hours);
         for k=(24-Nmbr_hours+1):24
             Best_ind(k-24+Nmbr_hours)=idx(k);
         end
        end
        
        % Laddar upp batteriet helt billigaste timmen varje dygn
        if mod(i,24)-(idx(1)+1)==0 
            Sum=Sum+((Batterikapacitet-Laddning(i)).*Bat_offset.*((Elpris(i)+Elskatt_net).*El_moms));
            Konsumerad_el_net=Konsumerad_el_net+ ((Batterikapacitet-Laddning(i)).*Bat_offset);
            Bat_smuts=Bat_smuts+(Batterikapacitet-Laddning(i));
            proc= Bat_sol./Batterikapacitet;
            
            Laddning(i)=Batterikapacitet;
            
        end
        
        
         % För timmarna under dygnet som är bäst/dyrast
         % Sommar=säljer el från både solcell och batteri dessa timmar 
        if ismember(mod(i,24),Best_ind)

            if netto_el(i)>0
                if Laddning(i)>0
                    if Laddning(i)>=netto_el(i)
                        if netto_el(i)<=Max_out
                            if Laddning(i)>=Max_out
                                
                                Sum=Sum- ((Max_out-netto_el(i)).*Elpris(i));
                                Bat_sol_tot=Bat_sol_tot+(proc.*(Max_out-netto_el(i)));
                                Bat_smuts_tot=Bat_smuts_tot+((1-proc).*(Max_out-netto_el(i)));
                                %Konsumerad_el_net=Konsumerad_el_net- ((Max_out-netto_el(i)) .*(1-proc)); 
                                %Konsumerad_el_sol=Konsumerad_el_sol-((Max_out-netto_el(i)) .*(proc));
           
                                Laddning(i)=Laddning(i)-Max_out;
                                Bat_smuts=(Laddning(i).*(1-proc));
                                Bat_sol=(Laddning(i).*(proc));
                                Sald_el=Sald_el+ (Max_out-netto_el(i));
                            else
                                Sum=Sum- ((Laddning(i)-netto_el(i)).*Elpris(i));
                                Bat_sol_tot=Bat_sol_tot+(proc.*(Laddning(i)-netto_el(i)));
                                Bat_smuts_tot=Bat_smuts_tot+((1-proc).*(Laddning(i)-netto_el(i)));
                                %Konsumerad_el_net=Konsumerad_el_net- ((Laddning(i)-netto_el(i)) .*(1-proc)); 
                                %Konsumerad_el_sol=Konsumerad_el_sol-((Laddning(i)-netto_el(i)) .*(proc));
                                Sald_el=Sald_el+ (Laddning(i)-netto_el(i));
           
                                Laddning(i)=0;
                                Bat_smuts=(Laddning(i).*(1-proc));
                                Bat_sol=(Laddning(i).*(proc));
                                
                            end
                        else 
                            Laddning(i)=Laddning(i)-Max_out;
                            Sum=Sum+ (netto_el(i)-Max_out).*((Elpris(i)+Elskatt_net).*El_moms);
                     
                                Bat_smuts=(Laddning(i).*(1-proc));
                                Bat_sol=(Laddning(i).*(proc));
                             Konsumerad_el_net=Konsumerad_el_net+ (netto_el(i)-Max_out);
                        end
                    else
                        if Laddning(i)<=Max_out
                            Sum=Sum+ (netto_el(i)-Laddning(i)).*((Elpris(i)+Elskatt_net).*El_moms);
                              
                            Konsumerad_el_net=Konsumerad_el_net+ (netto_el(i)-Laddning(i)) ;
                            Laddning(i)=0;
                       
                                Bat_smuts=(Laddning(i).*(1-proc));
                                Bat_sol=(Laddning(i).*(proc));
                        else
                            Laddning(i)=Laddning(i)-Max_out;
                            Sum=Sum+ (netto_el(i)-Max_out).*((Elpris(i)+Elskatt_net).*El_moms);
                            Konsumerad_el_net=Konsumerad_el_net+ (netto_el(i)-Max_out) ;
                            
                                Bat_smuts=(Laddning(i).*(1-proc));
                                Bat_sol=(Laddning(i).*(proc));

                        end
                    end
                else 
                    Sum= Sum+(netto_el(i)).*((Elpris(i)+Elskatt_net).*El_moms);
                    Konsumerad_el_net=Konsumerad_el_net+ (netto_el(i)) ;
                end
            else %nettoel<0
                if Laddning(i)<=Max_out
                  Sum=Sum- ((-netto_el(i)+Laddning(i)).*Elpris(i));
                  Sald_el=Sald_el+ (-netto_el(i)+Laddning(i));
           
                  Bat_sol_tot=Bat_sol_tot+(proc.*(Laddning(i)));
                  Bat_smuts_tot=Bat_smuts_tot+((1-proc).*(Laddning(i)));
                  %Konsumerad_el_net=Konsumerad_el_net- ((Laddning(i)) .*(1-proc)); 
                  %Konsumerad_el_sol=Konsumerad_el_sol-((Laddning(i)) .*(proc));
           
                  Laddning(i)=0;
                Bat_smuts=(Laddning(i).*(1-proc));
                Bat_sol=(Laddning(i).*(proc));
                else
                    Sum=Sum- (-netto_el(i)+Max_out).*Elpris(i);
                    Sald_el=Sald_el+ (-netto_el(i)+Max_out);
                  
                    Bat_sol_tot=Bat_sol_tot+(proc.*(Max_out));
                    Bat_smuts_tot=Bat_smuts_tot+((1-proc).*(Max_out));
                    %Konsumerad_el_net=Konsumerad_el_net- ((Max_out) .*(1-proc)); 
                    %Konsumerad_el_sol=Konsumerad_el_sol-((Max_out) .*(proc));

                    Laddning(i)=Laddning(i)-Max_out;
                    Bat_smuts=(Laddning(i).*(1-proc));
                    Bat_sol=(Laddning(i).*(proc));
                end
            end

        else % Här är vi när det inte är en av de bästa/dyraste timmarna
            %Sommar= Laddar batteri snarare än säljer från
            if netto_el(i)>=0
              if Laddning(i)>0
                        if Laddning(i)>=netto_el(i)
                            if netto_el(i)<=Max_out
                                Laddning(i)=Laddning(i)-netto_el(i);
                                Bat_kon_smuts=Bat_kon_smuts+ (netto_el(i).*(1-proc));
                                Bat_kon_sol=Bat_kon_sol+ (netto_el(i).*(proc));
                               
                                Bat_smuts=(Laddning(i).*(1-proc));
                                Bat_sol=(Laddning(i).*(proc));
                            else 
                             
                                Sum=Sum+ (netto_el(i)-Max_out).*((Elpris(i)+Elskatt_net).*El_moms);
                                Konsumerad_el_net=Konsumerad_el_net+ (netto_el(i)-Max_out) ;
                                Bat_kon_smuts=Bat_kon_smuts+ (Max_out.*(1-proc));
                                Bat_kon_sol=Bat_kon_sol+ (Max_out.*(proc));

                                Laddning(i)=Laddning(i)-Max_out;
                                Bat_smuts=(Laddning(i).*(1-proc));
                                Bat_sol=(Laddning(i).*(proc));
                            end
                        else
                            if Laddning(i)<=Max_out
                                Sum=Sum+ (netto_el(i)-Laddning(i)).*((Elpris(i)+Elskatt_net).*El_moms);
                                Konsumerad_el_net=Konsumerad_el_net+ (netto_el(i)-Laddning(i));
                                Bat_kon_smuts=Bat_kon_smuts+ (Laddning(i).*(1-proc));
                                Bat_kon_sol=Bat_kon_sol+ (Laddning(i).*(proc));
                                Laddning(i)=0;
                                Bat_smuts=(Laddning(i).*(1-proc));
                                Bat_sol=(Laddning(i).*(proc));
                            else
                                
                                Sum=Sum+ (netto_el(i)-Max_out).*((Elpris(i)+Elskatt_net).*El_moms);
                                Konsumerad_el_net=Konsumerad_el_net+ (netto_el(i)-Max_out) ;
                               Bat_kon_smuts=Bat_kon_smuts+ (Max_out.*(1-proc));
                                Bat_kon_sol=Bat_kon_sol+ (Max_out.*(proc));

                                Laddning(i)=Laddning(i)-Max_out;
                                Bat_smuts=(Laddning(i).*(1-proc));
                                Bat_sol=(Laddning(i).*(proc));

                            end
                        end
             else 
                 Sum= Sum+(netto_el(i)).*((Elpris(i)+Elskatt_net).*El_moms);
                 Konsumerad_el_net=Konsumerad_el_net+ (netto_el(i)) ;
             end


            else %netto_el<0
                if (-netto_el(i)./Bat_offset)<=Batterikapacitet-Laddning(i)
                    Laddning(i)=Laddning(i)-(netto_el(i)./Bat_offset);
                    Konsumerad_el_sol=Konsumerad_el_sol+(-netto_el(i)) ;

                    Bat_sol= Bat_sol+(netto_el(i)./Bat_offset);
                    proc=Bat_sol./Laddning(i);
                    
                else
                    Sum=Sum- ((-netto_el(i)-((Batterikapacitet-Laddning(i)).*Bat_offset)).*Elpris(i));
                    Sald_el=Sald_el+(-netto_el(i)-((Batterikapacitet-Laddning(i)).*Bat_offset)) ;
                    Konsumerad_el_sol=Konsumerad_el_sol+((Batterikapacitet-Laddning(i)).*Bat_offset) ;
                    
                    Bat_sol=Bat_sol+ (Batterikapacitet-Laddning(i));
                    Laddning(i)=Batterikapacitet;
                    proc= Bat_sol./Laddning(i);
                end
            end

        end
    else %Här är vi under "vinstermånaderna" (Oktober-April.
        
        
        % Tar ut de Nmbr_hours_win st dyraste timmarna under varje dygn
       if mod(i,24)==1
       Best_ind=zeros(1,Nmbr_hours_win);
     for k=(24-Nmbr_hours_win+1):24
         Best_ind(k-24+Nmbr_hours_win)=idx(k);
     end 
       end
        
        %Laddar upp batteriet den billgaste timmen varje dygn
        if mod(i,24)-(idx(1)+1)==0 
        Sum=Sum+((Batterikapacitet-Laddning(i)).*Bat_offset.*((Elpris(i)+Elskatt_net).*El_moms));
        Konsumerad_el_net=Konsumerad_el_net+ ((Batterikapacitet-Laddning(i)).*Bat_offset) ;
      
        Bat_smuts=Bat_smuts+(Batterikapacitet-Laddning(i));
        Laddning(i)=Batterikapacitet;
        proc= Bat_sol./Batterikapacitet;
        end
    
    %Här är vi under de bästa/dyraste timmarna under dygnet
    %Vinter= här sparas batteriet till de dyraste timmarna, och används då
    if ismember(mod(i,24),Best_ind)
        
        if netto_el(i)>=0
            if Laddning(i)>0
                if Laddning(i)>=netto_el(i)
                    if netto_el(i)<=Max_out
                        Laddning(i)=Laddning(i)-netto_el(i);
                        Bat_kon_smuts=Bat_kon_smuts+ (netto_el(i).*(1-proc));
                        Bat_kon_sol=Bat_kon_sol+ (netto_el(i).*(proc));
                        Bat_smuts=(Laddning(i).*(1-proc));
                        Bat_sol=(Laddning(i).*(proc));

                    else 
                        Laddning(i)=Laddning(i)-Max_out;
                        Sum=Sum+ (netto_el(i)-Max_out).*((Elpris(i)+Elskatt_net).*El_moms);
                        Konsumerad_el_net=Konsumerad_el_net+ (netto_el(i)-Max_out) ;
                        Bat_kon_smuts=Bat_kon_smuts+ (Max_out.*(1-proc));
                        Bat_kon_sol=Bat_kon_sol+ (Max_out.*(proc));
                 
                    Bat_smuts=(Laddning(i).*(1-proc));
                    Bat_sol=(Laddning(i).*(proc));
                    end
                else
                    if Laddning(i)<=Max_out
                        Sum=Sum+ (netto_el(i)-Laddning(i)).*((Elpris(i)+Elskatt_net).*El_moms);
                         Konsumerad_el_net=Konsumerad_el_net+ (netto_el(i)-Laddning(i)) ;
                         Bat_kon_smuts=Bat_kon_smuts+ (Laddning(i).*(1-proc));
                        Bat_kon_sol=Bat_kon_sol+ (Laddning(i).*(proc));
                        Laddning(i)=0;

                    Bat_smuts=(Laddning(i).*(1-proc));
                    Bat_sol=(Laddning(i).*(proc));
                    else
                        Laddning(i)=Laddning(i)-Max_out;
                        Sum=Sum+ (netto_el(i)-Max_out).*((Elpris(i)+Elskatt_net).*El_moms);
                        Konsumerad_el_net=Konsumerad_el_net+ (netto_el(i)-Max_out) ;
                        Bat_kon_smuts=Bat_kon_smuts+ (Max_out.*(1-proc));
                        Bat_kon_sol=Bat_kon_sol+ (Max_out.*(proc));
                        
                    Bat_smuts=(Laddning(i).*(1-proc));
                    Bat_sol=(Laddning(i).*(proc));
           
                    end
                end
            else 
                Sum= Sum+(netto_el(i)).*((Elpris(i)+Elskatt_net).*El_moms);
                Konsumerad_el_net=Konsumerad_el_net+(netto_el(i));
            end
        else %netto_el<0
       
              Sum=Sum- (-netto_el(i)).*Elpris(i);
              Sald_el=Sald_el+ (-netto_el(i));
       
        end
   
    else %Här är vi under billigare timmarana på dygnet
        %Vinter= köper el från nät, sparar batteri till dyrare timmar
        if netto_el(i)>=0
          
           Sum=Sum+ (netto_el(i).*((Elpris(i)+Elskatt_net).*El_moms));
           Konsumerad_el_net=Konsumerad_el_net+ netto_el(i) ;
            
        else
            if (-netto_el(i)./Bat_offset)<=Batterikapacitet-Laddning(i)
                Laddning(i)=Laddning(i)-(netto_el(i)./Bat_offset);
                Konsumerad_el_sol=Konsumerad_el_sol+(-netto_el(i));

                Bat_sol=Bat_sol-(netto_el(i)./Bat_offset);
                proc= Bat_sol./Laddning(i);
                
            else
                Sum=Sum- ((-netto_el(i)-((Batterikapacitet-Laddning(i)).*Bat_offset)).*Elpris(i));
                Sald_el=Sald_el+ (-netto_el(i)-((Batterikapacitet-Laddning(i)).*Bat_offset)) ;
                Konsumerad_el_sol=Konsumerad_el_sol+ ((Batterikapacitet-Laddning(i)).*Bat_offset) ;
                Laddning(i)=Batterikapacitet;
           
                
                Bat_sol=Bat_sol+ (Batterikapacitet-Laddning(i));
                proc=Bat_sol./Batterikapacitet;
                
            end
        end
 
    end
    end
    
    
    
    Laddning(i+1)=Laddning(i);
end

%Sum
% beräknar skattereduktionen och tar bort från summan
if Sol_storlek~=0
    if ((Sald_el)-(Konsumerad_el_net))>=0
        if Batterikapacitet~=0
            if Skatte_red.*(Konsumerad_el_net-Bat_smuts_tot)<=18000
                Sum=Sum- (Skatte_red.*(Konsumerad_el_net-Bat_smuts_tot));
            else
                Sum=Sum-18000;
            end
        else
             if Skatte_red.*(Konsumerad_el_net)<=18000
                    Sum=Sum- (Skatte_red.*(Konsumerad_el_net));
                else
                    Sum=Sum-18000;
                end
        end
    else
        if Batterikapacitet~=0
            if (Skatte_red.*(Sald_el-Bat_smuts_tot))<=18000
                Sum=Sum-(Skatte_red.*(Sald_el-Bat_smuts_tot));
            else
                Sum=Sum-18000;
            end
        else
           if (Skatte_red.*(Sald_el))<=18000
                Sum=Sum-(Skatte_red.*(Sald_el));
            else
                Sum=Sum-18000;
            end 
        end
    end
end

%Tar bort nätnytta summan från Sum
Sum=Sum-(Sald_el.*net_nytta);

%Tar bort skatten på sålda elen från elnätet från Sum (har betalat för
%mycket skatt då vi säljer tillbaka el från elnätet)
if Batterikapacitet~=0
    Sum=Sum-(Bat_smuts_tot.*Elskatt_net);
end

if Batterikapacitet~=0
    Sum_koldioxid_egen= ((Konsumerad_el_net-Bat_smuts_tot).*Koldioxid_ekv_Eu)+ ((Konsumerad_el_sol-Bat_sol_tot).*Koldioxid_ekv_sol) ;
else
    Sum_koldioxid_egen= (Konsumerad_el_net.*Koldioxid_ekv_Eu)+ (Konsumerad_el_sol.*Koldioxid_ekv_sol) ;
end
%Sum_koldioxid_sparad=(Sald_el-Bat_smuts_tot).*(Koldioxid_ekv_Eu-Koldioxid_ekv_sol);
Sum_koldioxid_sparad= (sum(Sol_el)).*(Koldioxid_ekv_Eu-Koldioxid_ekv_sol);

end

