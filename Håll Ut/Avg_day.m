function [outputArg1,outputArg2] = Avg_day(inputArg1,inputArg2)
Sum=0;
Avg_day=0;
for i=1:8760
    
    
     if mod(i,24)==1
         Avg_day=0;
      for k=0:23
          Avg_day=Avg_day+Elpris(i+k);
         Elpris_day(k+1)=Elpris(i+k);
      end
      [~, idx]= sort(Elpris_day);
      Avg_day=Avg_day./24;
     end
    
%     if mod(i,24)-5==0
%         Sum=Sum+(Batterikapacitet-Laddning(i)).*Elpris(i);
%         Laddning(i)=Batterikapacitet;
%     end
    
    if Elpris(i)>=Avg_day
        
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
           
            Sum= Sum+(netto_el(i)).*Elpris(i);
  
        else
            if Laddning(i)-netto_el(i)<=Batterikapacitet
                Laddning(i)=Laddning(i)-netto_el(i);
            else
                Sum=Sum- ((-netto_el(i)-(Batterikapacitet-Laddning(i))).*Elpris(i));
                Laddning(i)=Batterikapacitet;
            end
        end
 
    Laddning(i+1)=Laddning(i);
    end
end
end

