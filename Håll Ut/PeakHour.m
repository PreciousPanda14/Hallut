function [outputArg1,outputArg2] = PeakHour(inputArg1,inputArg2)
Sum=0;
Avg_day=0;
Koldioxid_sum=0;
Elpris_day=zeros(1,24);
Laddning= zeros(8760,1)
for i=1:8760
    %if i=2520:6912
    
     if mod(i,24)==1
         Avg_day=0;
      for k=0:23
          Avg_day=Avg_day+Elpris(i+k);
         Elpris_day(k+1)=Elpris(i+k);
      end
      [~, idx]= sort(Elpris_day);
      Avg_day=Avg_day./24;
     end
     Best_ind=zeros(1,Nmbr_hours);
     for k=(24-Nmbr_hours+1):24
         Best_ind(k-24+Nmbr_hours)=idx(k);
     end
    if mod(i,24)-(idx(1)+1)==0 
        Sum=Sum+(Batterikapacitet-Laddning(i)).*Elpris(i);
        Laddning(i)=Batterikapacitet;
    end
    
    if ismember(mod(i,24),Best_ind)
        
        if netto_el(i)>0
            if Laddning(i)>0
                if Laddning(i)>=netto_el(i)
                    if netto_el(i)<=Max_out
                        Laddning(i)=Laddning(i)-netto_el(i);
                        Sum=Sum- ((Max_out-netto_el(i)).*Elpris(i));
                    else 
                        Laddning(i)=Laddning(i)-Max_out;
                        Sum=Sum+ (netto_el(i)-Max_out).*Elpris(i);
                    end
                else
                    if Laddning(i)<=Max_out
                        Sum=Sum+ (netto_el(i)-Laddning(i)).*Elpris(i);
                        Laddning(i)=0;
                    else
                        Laddning(i)=Laddning(i)-Max_out;
                        Sum=Sum+ (netto_el(i)-Max_out).*Elpris(i);
           
                    end
                end
            else 
                Sum= Sum+(netto_el(i)).*Elpris(i);
            end
        else
            if Laddning(i)<=Max_out
              Sum=Sum- (-netto_el(i)+Laddning(i)).*Elpris(i);
              Laddning(i)=0;
            else
                Sum=Sum- (-netto_el(i)+Max_out).*Elpris(i);
                Laddning(i)=Laddning(i)-Max_out;
            end
        end
   
    else
        if netto_el(i)>0
          if Laddning(i)>0
                    if Laddning(i)>=netto_el(i)
                        if netto_el(i)<=Max_out
                            Laddning(i)=Laddning(i)-netto_el(i);
                        else 
                            Laddning(i)=Laddning(i)-Max_out;
                            Sum=Sum+ (netto_el(i)-Max_out).*Elpris(i);
                        end
                    else
                        if Laddning(i)<=Max_out
                            Sum=Sum+ (netto_el(i)-Laddning(i)).*Elpris(i);
                            Laddning(i)=0;
                        else
                            Laddning(i)=Laddning(i)-Max_out;
                            Sum=Sum+ (netto_el(i)-Max_out).*Elpris(i);

                        end
                    end
                else 
                    Sum= Sum+(netto_el(i)).*Elpris(i);
                end
               
            
        else
            if Laddning(i)-netto_el(i)<=Batterikapacitet
                Laddning(i)=Laddning(i)-netto_el(i);
            else
                Sum=Sum- ((-netto_el(i)-(Batterikapacitet-Laddning(i))).*Elpris(i));
                Laddning(i)=Batterikapacitet;
            end
        end
 
    end
    Laddning(i+1)=Laddning(i);
end
end

