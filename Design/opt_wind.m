%% Wind Constraints
if ~isempty(wind_v) || (~isempty(wind_legacy) && sum(wind_legacy(2,:)) > 0)
    %% PV Energy balance when curtailment is allowed
    if curtail_wind
         Constraints = [Constraints
             (var_wind.wind_elec + var_rees.rees_chrg + rel_eff.*var_rel.rel_prod <= (wind_legacy(2,:)./e_adjust).*wind + repmat(var_wind.wind_adopt./e_adjust,T,1).*wind) :'Wind Energy Balance'];
    %     Constraints = [Constraints, (wind_wholesale + wind_elec + wind_nem + rees_chrg <= repmat(solar,1,K).*repmat(wind_adopt,T,1)):'Wind Energy Balance'];
    else
          Constraints = [Constraints
              (var_wind.wind_elec + var_rees.rees_chrg + rel_eff.*var_rel.rel_prod == (wind_legacy(2,:)./e_adjust).*wind + repmat(var_wind.wind_adopt./e_adjust,T,1).*wind) :'Wind Energy Balance'];
%             (var_wind.wind_elec + var_wind.wind_nem + sum(var_rees.rees_chrg,2) + sum(rel_eff.*var_rel.rel_prod,2)  == (sum(wind_legacy(2,:))/e_adjust)*wind + (sum(var_wind.wind_adopt))/e_adjust*wind) :'Wind Energy Balance'];
%         Constraints = [Constraints, (wind_wholesale + wind_elec + wind_nem + rees_chrg == repmat(wind,1,K).*repmat(wind_adopt,T,1)):'Wind Energy Balance'];
    end
    %% Min PV to adopt: Forces 3 kW Adopted
    if toolittle_wind ~= 0
        Constraints = [Constraints,(toolittle_wind <= sum(var_wind.wind_adopt)):'toolittle_wind'];
%         for k=1:K
%             Constraints = [Constraints, (implies(wind_adopt(k) <= toolittle_wind, wind_adopt(k) == 0)):'toolittle_wind'];
%         end
    end
    
    %% Max PV to adopt (capacity constrained)
    if ~isempty(maxwind) && ~isempty(wind_v) 
        Constraints = [Constraints
            (var_wind.wind_adopt' <= maxwind'):'Mav Wind Capacity'];  
%         Constraints = [Constraints, (sum(var_wind.wind_adopt) <= maxwind'):'Mav Wind Capacity'];
    end
    
    %% Don't curtail for residential
%     residential = find(strcmp(rate,'R1') |strcmp(rate,'R2') | strcmp(rate,'R3')| strcmp(rate,'R4'));   
%     Constraints = [Constraints,...
%         ( wind*wind_adopt(residential) ==  wind_wholesale(:,residential) + wind_elec(:,residential) + wind_nem(:,residential) + rees_chrg(:,residential)):'No residential curtail' ];
end