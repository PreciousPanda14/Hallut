function [Laddning,Sum] = modell_basic(Elpris,Batterikapacitet,netto_el)


Laddning= zeros(8760,1); % kWh i batteriet NU
Sum=0;

for i=1:8760
    if netto_el(i)>0
        if Laddning(i)>0
            if Laddning(i)>netto_el(i)
                Laddning(i)=Laddning(i)-netto_el(i);
            else
                Sum=Sum+(netto_el(i)-Laddning(i)).*Elpris(i);
                Laddning(i)=0;
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
    Laddning(i+1)=Laddning(i);
end

end

