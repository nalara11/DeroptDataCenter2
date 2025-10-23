
if lror_on && exist('river_power_potential')
%       Constraints = [Constraints
%          (var_run_of_river.electricity <= river_power_potential):'Run of River is limited by available resources'];
     Constraints = [Constraints
         (var_run_of_river.electricity <= river_power_potential.*repmat(var_run_of_river.swept_area,T,1)):'Run of River is limited by available resources'
         (var_run_of_river.swept_area <= ror_area):'Run of River Swept Area Limit' ];  
     
end
    


%  Constraints = [Constraints
%          (var_run_of_river.electricity <= river_power_potential):'Run of River is limited by available resources'];