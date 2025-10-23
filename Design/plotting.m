%plot(value(var_wind.wind_elec));
%plot(value(var_sofc.sofc_operational_state));
%plot(wind);
%plot(solar);
%showprob(optimproblem_object);
%data = [var_util.import var_legacy_diesel.electricity var_pv.pv_elec var_ees.ees_dchrg var_lees.ees_dchrg var_rees.rees_dchrg var_ldg.ldg_elec var_legacy_diesel_binary.electricity var_lbot.lbot_elec var_run_of_river.electricity var_pem.elec var_ror_integer.elec var_wave.electricity var_sofc.sofc_electricity]
%hold
%area(data)
%legend('import', 'diesel', 'pv', 'ees', 'lees', 'rees', 'ldg', 'legacy diesel', 'lbot', 'ror', 'pem', 'ror_int', 'wave', 'sofc');

% battery_charge_cycles = sum(var_ees.ees_dchrg)./var_ees.ees_adopt;
% hydrogen_cycles = sum(var_h2es.h2es_dchrg)./var_h2es.h2es_adopt;

# Ignore MATLAB autosave and CPLEX log files#
*.asv
*.log
*.mat

%%%Ignoring data files that are too large to upload to the free website  
/Data

*.mdmp