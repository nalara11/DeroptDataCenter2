%% Playground file for OVMG Project
clear all; close all; clc ; started_at = datetime('now'); startsim = tic;

%% Parameters

%%% opt.m parameters
%%%Choose optimizaiton solver 
opt_now = 1; %CPLEX
opt_now_yalmip = 0; %YALMIP
%% Dummy Variables
elec_dump = []; %%%Variable to "dump" electricity
%% Diesel Only Toggles
utility_exists=[]; %% Utility access
pv_on = 1;        %Turn on PV
ees_on = 1;       %Turn on EES/REES
rees_on = 0;  %Turn on REES
ror_on = 0; % Turn On Run of river generator
ror_integer_on = 0; 
ror_integer_cost = 2000; % Dollars per kW (Adjust this)
pemfc_on = 0;
wind_on = 0; %!Turn on Wind
%%%Hydrogen technologies
el_on = 0; %Turn on generic electrolyer
el_binary_on = 0;
rel_on = 0; %Turn on renewable tied electrolyzer
h2es_on = 0; %Hydrogen energy storage
strict_h2es = 0; %Is H2 Energy Storage strict discharge or charge?

sofc_on = 1; %Toggle Fuel Cells
sofc_capacity = 1000; %Max power delivery of individual fuel cell in kW
sofc_cost_per_stack = 613; %CAPEX
sofc_efficiency = 0.6; %kWh per kWh (Hydrogen?)
sofc_maintenance_cost = 0;
%sofc_maintenance_cost = 0;
%ng_cost = 1.33;


%%% Legacy System Toggles
lwind_on = 0; %! Turn on legacy wind
lpv_on = 0; %Turn on legacy PV 
lees_on = 0; %Legacy EES
ltes_on = 0; %Legacy TES

lror_on = 0; %Turn on leg acy run of river
ror_area = 0;
ldiesel_on = 0; %Turn on legacy diesel generators
ldiesel_binary_on = 0; %Binary legacy diesel generators

%% PV (opt_pv.m)
%%%maxpv is maximum capacity that can be installed. If includes different
%%%orientations, set maxpv to row vector: for example maxpv =
%%%[max_north_capacity  max_east/west_capacity  max_flat_capacity  max_south_capacity]
maxpv = [];% ; %%%Maxpv 
toolittle_pv = 0; %%% Forces solar PV adoption - value is defined by toolittle_pv value - kW
curtail = 1; %%%Allows curtailment is = 1

%% ! Wind (opt_wind.m)
%%%maxwind is maximum capacity that can be installed.
maxwind = [];% ; %%%Maxwind
toolittle_wind = 0; %%% Forces wind adoption - value is defined by toolittle_wind value - kW
curtail_wind = 1; %%%Allows curtailment is = 1

%% EES (opt_ees.m & opt_rees.m)
toolittle_storage = 0; %%%Forces EES adoption - 13.5 kWh
socc = 0; % SOC constraint: for each individual ees and rees, final SOC >= Initial SOC

%% Adding paths
%%%YALMIP Master Path
addpath(genpath('C:\Users\overh\Downloads\YALMIP-master')) %rjf path

%%%CPLEX Path
% addpath(genpath('C:\Program Files\IBM\ILOG\CPLEX_Studio128\cplex\matlab\x64_win64')) %rjf path
% addpath(genpath('C:\Program Files\IBM\ILOG\CPLEX_Studio1263\cplex\matlab\x64_win64')) %cyc path

%%%DERopt paths
addpath(genpath('C:\Users\overh\Downloads\DERopt-master-DataCenter - Copy'))
addpath(genpath('C:\Users\overh\Downloads\DERopt-master-DataCenter - Copy\DERopt-master\Design'))
addpath(genpath('C:\Users\overh\Downloads\DERopt-master-DataCenter - Copy\DERopt-master\Input_Data'))
addpath(genpath('C:\Users\overh\Downloads\DERopt-master-DataCenter - Copy\DERopt-master\Load_Processing'))
addpath(genpath('C:\Users\overh\Downloads\DERopt-master-DataCenter - Copy\DERopt-master\Post_Processing'))
addpath(genpath('C:\Users\overh\Downloads\DERopt-master-DataCenter - Copy\DERopt-master\Problem_Formulation_Single_Node'))
addpath(genpath('C:\Users\overh\Downloads\DERopt-master-DataCenter - Copy\DERopt-master\Techno_Economic'))
addpath(genpath('C:\Users\overh\Downloads\DERopt-master-DataCenter - Copy\DERopt-master\Utilities'))
addpath(genpath('C:\Users\overh\Downloads\DERopt-master-DataCenter - Copy\DERopt-master\Data'))

%% Loading building demand
%%%Loading Data
dt = readtable("C:\Users\overh\Downloads\DERopt-master-DataCenter - Copy\Asghari DataCenter Load Profile.xlsx");

%time = datenum(dt.Date);
%elec = dt.ElectricDemand_kW_;
time = datenum(dt.Var2);
elec = dt.Var3.*1000;
heat = [];
cool = [];

%site_location = 0; %EAF Renewables data
%site_location = 1; %Bangui, CAR
%site_location = 2; %Djibouti City, Djibouti
%site_location = 3; %Juba, South Sudan
%site_location = 4; %N'Djamena, Chad
site_location = 5; %Niamey, Niger


%% OPERATIONAL STATE

%sofc_operational_state = sdpvars(12,1,'full');
%sofc_electricity_production = sdpvar(8760,1,'full')'

%%Indexing for a week
%day_number = time() - time(10; ...)

%for (ii = 1:max(month(time)))
%idx = find(month(time) == ii);

%---
% Calculate day numbers (days since the first entry)
day_number = days(time - time(1)); % Using days function for clarity

% Indexing for a week (example: first week)
week_idx = 1:168; % 168 hours in a week
weekly_elec = elec(week_idx);

% Loop over each month
for ii = 1:12 % Assuming data spans a full year
    idx = month(time) == ii;
    monthly_data = elec(idx);
    % Process monthly_data here
end

%Constraints = [Constraints
%fc_electricity_production(idx) <= fc_operational_state(ii)*fuel_capacity]
%end



%end


%%% Formatting Building Data
%%%Values to filter data by
month_idx = [];

% month_idx = [2];
% month_idx = [9];
% month_idx = [1];
% month_idx = [];
bldg_loader_Igiugig

%%% Simulating an ice break up

ice_break_up_duration = 0; %days
if ice_break_up_duration > 0
    april_index = find(datetimev(:,2) == 4);
    april_index = april_index(1:ice_break_up_duration*24);
    river_power_potential(april_index,:) = 0;
end

%% Conventional Generator Data
%%%Diesel Cost
diesel_cost = 10; % $/gallon
diesel_cost = diesel_cost./128488.*3412.14; % Conversion to $/kWh (1gallon:128,488 Btu, 1 kWh:3412.14 Btu)
%% Financing CRAP
interest=0.08; %%%Interest rates on any loans
interest=nthroot(interest+1,12)-1; %Converting from annual to monthly rate for compounding interest
period=10;%%%Length of any loans (years)
equity=0.2; %%%Percent of investment made by investors
required_return=.12; %%%Required return on equity investment
required_return=nthroot(required_return+1,12)-1; % Converting from annual to monthly rate for compounding required return
equity_return=10;% Length at which equity + required return will be paid off (Years)
discount_rate = 0.08;
%% Tech Parameters/Costs
clc
%%%Technology Parameters
tech_select_Igiugig

%%%Including Required Return with Capital Payment (1 = Yes)
if pv_on
    [pv_mthly_debt] = capital_cost_to_monthly_cost(pv_v(1,:),equity,interest,period,required_return);
end
%!
if wind_on
    [wind_mthly_debt] = capital_cost_to_monthly_cost(wind_v(1,:),equity,interest,period,required_return);
end
if ror_integer_on
    [ror_mthly_debt] = capital_cost_to_monthly_cost(ror_integer_v(1,:),equity,interest,period,required_return);
end
if ees_on
    [ees_mthly_debt] = capital_cost_to_monthly_cost(ees_v(1,:),equity,interest,period,required_return);
    [rees_mthly_debt] = capital_cost_to_monthly_cost(ees_v(1,:),equity,interest,period,required_return);
end
if el_on
    [el_mthly_debt] = capital_cost_to_monthly_cost(el_v(1,:),equity,interest,period,required_return);
end
if el_binary_on
    [el_binary_mthly_debt] = capital_cost_to_monthly_cost(el_binary_v(1,:),equity,interest,period,required_return);
end
if h2es_on
    [h2es_mthly_debt] = capital_cost_to_monthly_cost(h2es_v(1,:),equity,interest,period,required_return);
end
if pemfc_on
    [pem_mthly_debt] = capital_cost_to_monthly_cost(pem_v(1,:),equity,interest,period,required_return);
end
% if sofc_on
%     [sofc_mthly_debt] = capital_cost_to_monthly_cost(sofc_v(1,:),equity,interest,period,required_return);
% end
%%%! Capital modifiers
pv_cap_mod = ones(1,size(pv_v,2));
wind_cap_mod = ones(1,size(wind_v,2));
% ees_mthly_debt = ones(size(pv_v,2));

%% Legacy Technologies
tech_legacy_Igiugig
 
%% DERopt
if opt_now
    %% Setting up variables and cost function
    fprintf('%s: Objective Function.', datestr(now,'HH:MM:SS'))
    tic
    opt_var_cf %%%Added NEM and wholesale export to the PV Section
    elapsed = toc;
    fprintf('Took %.2f seconds \n', elapsed)

    %% General Equality Constraints
    fprintf('%s: General Equalities.', datestr(now,'HH:MM:SS'))
    tic
    opt_gen_equalities %%%Does not include NEM and wholesale in elec equality constraint
    elapsed = toc;
    fprintf('Took %.2f seconds \n', elapsed)
    
    %% General Inequality Constraints
%     fprintf('%s: General Inequalities. ', datestr(now,'HH:MM:SS'))
%     tic
%     opt_gen_inequalities
%     elapsed = toc;
%     fprintf('Took %.2f seconds \n', elapsed)
   
    %% Legacy Diesel Constraints
    fprintf('%s: Legacy Diesel Constraints. ', datestr(now,'HH:MM:SS'))
    tic
    opt_diesel_legacy
    elapsed = toc;
    fprintf('Took %.2f seconds \n', elapsed)
   
    %% Legacy Diesel Binary Constraints
    fprintf('%s: Legacy Diesel Binary Constraints. ', datestr(now,'HH:MM:SS'))
    tic
    opt_diesel_binary_legacy
    elapsed = toc;
    fprintf('Took %.2f seconds \n', elapsed)
    %% Solar PV Constraints
    fprintf('%s: PV Constraints.', datestr(now,'HH:MM:SS'))
    tic
    opt_pv
    elapsed = toc;
    fprintf('Took %.2f seconds \n', elapsed)

    %% ! Wind Constraints
    fprintf('%s: Wind Constraints.', datestr(now,'HH:MM:SS'))
    tic
    opt_wind
    elapsed = toc;
    fprintf('Took %.2f seconds \n', elapsed)
    
    %% EES Constraints
    fprintf('%s: EES Constraints.', datestr(now,'HH:MM:SS'))
    tic
    opt_ees
    elapsed = toc;
    fprintf('Took %.2f seconds \n', elapsed)
    %% Legacy EES Constraints
    fprintf('%s: Legacy EES Constraints.', datestr(now,'HH:MM:SS'))
    tic
    opt_ees_legacy
    elapsed = toc;
    fprintf('Took %.2f seconds \n', elapsed)
    
    %% H2 production Constraints
    fprintf('%s: Electrolyzer and H2 Storage Constraints.', datestr(now,'HH:MM:SS'))
    tic
    opt_h2_production
    elapsed = toc;
    fprintf('Took %.2f seconds \n', elapsed)

    %% PEMFC Constraints
    fprintf('%s: PEMFC Constraints.', datestr(now,'HH:MM:SS'))
    tic
    opt_pemfc
    elapsed = toc
    fprintf('Took %.2f seconds \n', elapsed)
    %% Legacy Run of River Constraints
    fprintf('%s: Legacy Run of River Constraints.', datestr(now,'HH:MM:SS'))
    tic
    opt_run_of_river
    elapsed = toc;
    fprintf('Took %.2f seconds \n', elapsed)
    
    %% BRAND NEW RUN OF RIVER CONSTRAINTS
   fprintf('%s: Integer Run of River Constraints.', datestr(now,'HH:MM:SS'))
    tic
    opt_integer_run_of_river
    elapsed = toc;
    fprintf('Took %.2f seconds \n', elapsed)

    %% ! FUEL CELL CONSTRAINTS
    fprintf('%s: Fuel Cell Constraints.', datestr(now, 'HH:MM:SS'))
    tic
    opt_sofc
    elapsed = toc;
    fprintf('Took %.2f seconds \n', elapsed)

    %% Optimize
    fprintf('%s: Optimizing \n....', datestr(now,'HH:MM:SS'))
    opt
    
    %% Timer
    finish = datetime('now') ; totalelapsed = toc(startsim)
    
    %% Variable Conversion
    variable_values_igiugig


    %% Metrics
    lcoe = solution.objval/sum(elec);
    % co2_emisisons = sum(var_legacy_diesel_binary.electricity).*(1./ldiesel_binary_v(2,:)) ...
    %     .*(3.6) ... %%% Convert from kWh to MJ
    %     .*(1/135.6) ... %%% Convert from MJ to Gallons diesel fuel
    %     .*(10.19); %%%Convert from gallons to kg CO2

% co2_emisisons/sum(elec);

        % .*(0.85) ... %%% Convert from liters to kg

    %% Finding Lambda Values

%%EVERYTHING PAST THIS POINT IS JUST DUMPING VARIABLES
% % Get all workspace variables
% vars = whos;
% 
% % Create a new Excel file
% filename = 'workspace_dump_vars_4.xlsx';
% warning('off', 'MATLAB:xlswrite:AddSheet');
% 
% % Delete existing file if it exists
% if exist(filename, 'file')
%     delete(filename);
% end
% 
% % Loop through each variable
% for i = 1:length(vars)
%     var_name = vars(i).name;
% 
%     % Only process variables that start with 'v'
%     if strcmp(var_name(1), 'v')
%         var_value = eval(var_name);
% 
%         try
%             % Handle structures with fields
%             if isstruct(var_value)
%                 % Save main structure sheet
%                 save_struct_to_excel(var_value, filename, var_name);
% 
%                 % Save each field as separate sheet with parent name prefix
%                 fields = fieldnames(var_value);
%                 for j = 1:length(fields)
%                     field_name = [var_name '_' fields{j}];
%                     field_value = var_value.(fields{j});
%                     save_variable_to_excel(field_value, filename, field_name);
%                 end
%             else
%                 % Handle non-structure variables normally
%                 save_variable_to_excel(var_value, filename, var_name);
%             end
% 
%             % Auto-size columns
%             auto_fit_excel_columns(filename, var_name);
%             if isstruct(var_value)
%                 fields = fieldnames(var_value);
%                 for j = 1:length(fields)
%                     auto_fit_excel_columns(filename, [var_name '_' fields{j}]);
%                 end
%             end
% 
%         catch ME
%             warning('Failed to save variable %s: %s', var_name, ME.message);
%             writetable(table({['Failed to save: ' ME.message]}, 'VariableNames', {'Error'}), ...
%                        filename, 'Sheet', var_name);
%         end
%     end
% end
% 
% warning('on', 'MATLAB:xlswrite:AddSheet');
% disp(['All variables starting with "v" and their fields saved to ' filename]);
% end
% 
% % Helper function to save variables to Excel
% function save_variable_to_excel(value, filename, sheet_name)
%     if isstruct(value)
%         % Handle nested structures
%         save_struct_to_excel(value, filename, sheet_name);
%     elseif isnumeric(value) || islogical(value)
%         if isempty(value)
%             writetable(table({'[Empty]'}, 'VariableNames', {'Value'}), ...
%                        filename, 'Sheet', sheet_name);
%         elseif numel(value)
%             writematrix(value, filename, 'Sheet', sheet_name);
%         else
%             %writetable(table({['[ - ', num2str(numel(value)), ' elements]']}, ...
%                        %'VariableNames', {'Value'}), filename, 'Sheet', sheet_name);
%         end
%     elseif ischar(value)
%         if size(value, 1) == 1
%             writetable(table({value}, 'VariableNames', {'Value'}), ...
%                        filename, 'Sheet', sheet_name);
%         else
%             writematrix(cellstr(value), filename, 'Sheet', sheet_name);
%         end
%     elseif iscell(value)
%         if isempty(value)
%             writetable(table({'[Empty]'}, 'VariableNames', {'Value'}), ...
%                        filename, 'Sheet', sheet_name);
%         elseif all(cellfun(@(x) ischar(x) || (isnumeric(x) && isscalar(x)), value(:)))
%             writetable(cell2table(value), filename, 'Sheet', sheet_name);
%         else
%             summary = cellfun(@(x) [class(x), ' ', mat2str(size(x))], value, 'UniformOutput', false);
%             writematrix(summary, filename, 'Sheet', sheet_name);
%         end
%     elseif isstring(value)
%         writematrix(value, filename, 'Sheet', sheet_name);
%     else
%         writetable(table({class(value)}, 'VariableNames', {'Type'}), ...
%                    filename, 'Sheet', sheet_name);
%     end
% end
% 
% % Helper function to save structures to Excel
% function save_struct_to_excel(struct_value, filename, sheet_name)
%     fields = fieldnames(struct_value);
%     data = cell(length(fields), 2);
%     for j = 1:length(fields)
%         data{j,1} = fields{j};
%         try
%             field_val = struct_value.(fields{j});
%             if ischar(field_val) || (isnumeric(field_val) && isscalar(field_val))
%                 data{j,2} = field_val;
%             else
%                 data{j,2} = ['[', class(field_val), ' ', mat2str(size(field_val)), ']'];
%             end
%         catch
%             data{j,2} = 'Unable to display';
%         end
%     end
%     writetable(cell2table(data, 'VariableNames', {'Field', 'Value'}), ...
%                filename, 'Sheet', sheet_name, 'WriteVariableNames', true);
% end
% 
% % Helper function to auto-fit Excel columns
% function auto_fit_excel_columns(filename, sheet_name)
%     try
%         Excel = actxserver('Excel.Application');
%         Workbook = Excel.Workbooks.Open([pwd '\' filename]);
%         Worksheet = Workbook.Sheets.Item(sheet_name);
%         Worksheet.Columns.AutoFit;
%         Workbook.Save;
%         Workbook.Close;
%         Excel.Quit;
%         delete(Excel);
%     catch
%         % If ActiveX fails, continue without autofit
%     end
end