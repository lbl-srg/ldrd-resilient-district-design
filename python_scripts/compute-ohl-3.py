#!/usr/bin/env python

import numpy as np
import os
import pandas as pd
import re
import shutil
import datetime
from config3 import *

sim_dir = 'Supermarket_Baseline'

ohl_dir = 'ohl_results_'+datetime.datetime.now().strftime('%Y-%m-%d_%H-%M-%S')

if os.path.isdir(ohl_dir):
    shutil.rmtree(ohl_dir)

for vintage in vintages:
    for climate in climates:
        scenario = '%s_%s' % (vintage,climate)
        for week in weeks:
            os.makedirs(os.path.join(ohl_dir, scenario, week))

for vintage in vintages:
    for climate in climates:
        scenario = '%s_%s' % (vintage,climate)

        # confirm correct filename format
        sim_file_elmts = ['Supermarket', vintage, climate]
        for param in params:
            sim_file_elmts.append(param)
            sim_file_elmts.append('(?P<%s>[0-3])' % param)
        sim_file_fmt = '^' + '_'.join(sim_file_elmts) + '.csv$'
        for sim_file in os.listdir(os.path.join(sim_dir, scenario)):
            assert re.match(sim_file_fmt, sim_file) is not None

        week_starts, week_ends = get_weeks(climate)

        param_values = get_parameter_values(climate)

        # write headers to summary files
        week_files = {}
        for week in weeks:
            week_file = '_'.join(['OHL',vintage,climate,week]) + '.csv'
            week_files[week] = open(os.path.join(ohl_dir, scenario, week, week_file), 'w')
            for param in params:
                week_files[week].write(param_names[param] + ',')
            week_files[week].write('IdealOccHours,OccHoursLostSET,OccHoursLostCO2,OccHoursLostIllum,OccHoursLost\n')

        for sim_file in os.listdir(os.path.join(sim_dir, scenario)):

            data = pd.read_csv(os.path.join(sim_dir, scenario, sim_file))

            # set year = 2018, convert 1-24 hours to 0-23
            data['date'] = data['Date/Time'].apply(lambda x: x.strip().split('  ')[0]) + '/2018'
            data['time'] = data['Date/Time'].apply(lambda x: x.strip().split('  ')[1])
            data['hour'] = (data['time'].apply(lambda x: x.split(':')[0]).astype(int) - 1).astype(str)
            data['min'] = data['time'].apply(lambda x: x.split(':')[1])
            data['sec'] = data['time'].apply(lambda x: x.split(':')[2])
            data['Date/Time'] = data['date'] + ' ' + data['hour'] + ':' + data['min'] + ':' + data['sec']
            data.rename(columns={'Date/Time': 'DateTime [YYYY-MM-DD hh:mm:ss]'}, inplace=True)
            data.index = pd.to_datetime(data['DateTime [YYYY-MM-DD hh:mm:ss]'], format='%m/%d/%Y %H:%M:%S')
            data.drop(['date','time','hour','min','sec','DateTime [YYYY-MM-DD hh:mm:ss]'], axis='columns', inplace=True)

            # drop warmup weeks and non-working hours
            data['keep'] = False
            for week in weeks:
                week_idx = (data.index >= week_starts[week]) & (data.index < week_ends[week])
                data['keep'] = data['keep'] | week_idx
            work_idx = (data.index.hour >= work_start_hr) & (data.index.hour < work_end_hr)
            data['keep'] = data['keep'] & work_idx
            if not include_weekends:
                weekday_idx = data.index.weekday < 5
                data['keep'] = data['keep'] & weekday_idx
            data = data.loc[data['keep']].copy()
            data.drop('keep', axis='columns', inplace=True)

            # remove whitespace from column names
            for col in data.columns:
                data.rename(columns={col: col.strip()}, inplace=True)

            # rename columns, convert units, get zone names, drop extra power columns
            zones = []
            for col in data.columns:
                zone = col.split(':')[0]

                if col.endswith(':Site Outdoor Air Drybulb Temperature [C](Hourly)'):
                    zone = col.split(':')[0]
                    new_col = zone + ':OutAirTemp [F]'
                    data.rename(columns={col: new_col}, inplace=True)
                    data[new_col] = data[new_col] * 9.0/5.0 + 32.0

                elif col.endswith(':People Occupant Count [](Hourly)'):
                    zone = zone[:-len(' PEOPLE')] 
                    new_col = zone + ':IdealOccHours'
                    data.rename(columns={col: new_col}, inplace=True)
                    zones.append(zone)

                elif col.endswith(':Zone Thermal Comfort Pierce Model Standard Effective Temperature [C](Hourly)'):
                    zone = zone[:-len(' PEOPLE')]
                    new_col = zone + ':StdEffTemp [F]'
                    data.rename(columns={col: new_col}, inplace=True)
                    data[new_col] = data[new_col] * 9.0/5.0 + 32.0

                elif col.endswith(':Zone Air CO2 Concentration [ppm](Hourly)'):
                    new_col = zone + ':CO2Conc [ppm]'
                    data.rename(columns={col: new_col}, inplace=True)

                elif col.endswith(':Daylighting Reference Point 1 Illuminance [lux](Hourly)'):
                    new_col = zone + ':Illum [lux]'
                    data.rename(columns={col: new_col}, inplace=True)

                elif col.endswith(':Zone Electric Equipment Electric Power [W](Hourly)'):
                    data.drop(col, axis='columns', inplace=True)

            # drop extra co2 columns
            for col in data.columns:
                if col.endswith(':CO2Conc [ppm]'):
                    zone = col.split(':')[0]
                    if zone not in zones:
                        data.drop(col, axis='columns', inplace=True)

            # fill in zero for missing illum columns
            for zone in zones:
                col = zone + ':Illum [lux]'
                if col not in data.columns:
                    data[col] = 0.0

            for zone in zones:
                data[zone+':OccHoursLostSET'] = np.nan
                data[zone+':OccHoursLostCO2'] = np.nan
                data[zone+':OccHoursLostIllum'] = np.nan
                data[zone+':OccHoursLost'] = np.nan

            for zone in zones:

                # is SET habitable/tolerable?
                data['set habitable?'] = 1.0
                data['set tolerable?'] = 1.0

                # is CO2 habitable?
                data['co2 habitable?'] = 1.0

                # is illum habitable?
                data['illum habitable?'] = 1.0

                # is SET below/above habitable limit?
                data['set below hab?'] = data[zone+':StdEffTemp [F]'] < min_hab_temp
                data['set above hab?'] = data[zone+':StdEffTemp [F]'] > max_hab_temp

                # is SET below/above tolerable limit?
                data['set below tol?'] = data[zone+':StdEffTemp [F]'] < min_tol_temp
                data['set above tol?'] = data[zone+':StdEffTemp [F]'] > max_tol_temp

                # degree-hours in day with SET below/above tolerable limit
                data['deg-hrs set below tol'] = np.nan
                data['deg-hrs set above tol'] = np.nan

                # is CO2 concentration above limit?
                data['co2 conc above lim?'] = data[zone+':CO2Conc [ppm]'] > max_co2_conc

                # CO2 exposure (cumulative concentration)
                data['co2 exp'] = np.nan

                # is CO2 exposure above limit?
                data['co2 exp above lim?'] = False

                # is illuminance below habitable/tolerable limit?
                data['illum below hab lim?'] = data[zone+':Illum [lux]'] < min_hab_illum
                data['illum below tol lim?'] = data[zone+':Illum [lux]'] < min_tol_illum

                for week in weeks:
                    week_idx = (data.index >= week_starts[week]) & (data.index < week_ends[week])

                    for day in sorted(list(set(data.loc[week_idx].index.date))):
                        day_idx = data.index.date == day

                        # if SET goes below habitable limit, habitability = 0 for rest of day
                        if data.loc[day_idx, 'set below hab?'].any():
                            i = data.loc[day_idx & data['set below hab?']].index[0]
                            data.loc[day_idx & (data.index >= i), 'set habitable?'] = 0.0

                        # if SET goes above habitable limit, habitability = 0 for rest of day
                        if data.loc[day_idx, 'set above hab?'].any():
                            i = data.loc[day_idx & data['set above hab?']].index[0]
                            data.loc[day_idx & (data.index >= i), 'set habitable?'] = 0.0

                        # degree-hours in day with SET below/above tolerable limit
                        data.loc[day_idx, 'deg-hrs set below tol'] = ((min_tol_temp - data.loc[day_idx, zone+':StdEffTemp [F]']) * data.loc[day_idx, 'set below tol?']).cumsum()
                        data.loc[day_idx, 'deg-hrs set above tol'] = ((data.loc[day_idx, zone+':StdEffTemp [F]'] - max_tol_temp) * data.loc[day_idx, 'set above tol?']).cumsum()

                        # if CO2 concentration goes above limit, habitability = 0 for rest of day
                        if data.loc[day_idx, 'co2 conc above lim?'].any():
                            i = data.loc[day_idx & data['co2 conc above lim?']].index[0]
                            data.loc[day_idx & (data.index >= i), 'co2 habitable?'] = 0.0

                        # if CO2 exposure goes above limit, habitability = 0 for rest of day
                        data.loc[day_idx, 'co2 exp'] = data.loc[day_idx, zone+':CO2Conc [ppm]'].cumsum()
                        data.loc[day_idx, 'co2 exp above lim?'] = data.loc[day_idx, 'co2 exp'] > max_co2_exp
                        if data.loc[day_idx, 'co2 exp above lim?'].any():
                            i = data.loc[day_idx & data['co2 exp above lim?']].index[0]
                            data.loc[day_idx & (data.index >= i), 'co2 habitable?'] = 0.0

                        # if illuminance goes below habitable limit, habitability = 0 for rest of day
                        if data.loc[day_idx, 'illum below hab lim?'].any():
                            i = data.loc[day_idx & data['illum below hab lim?']].index[0]
                            data.loc[day_idx & (data.index >= i), 'illum habitable?'] = 0.0

                        # if illuminance goes below tolerable limit more than once, habitability = 0 for rest of day
                        if data.loc[day_idx, 'illum below tol lim?'].sum() > 1:
                            i = data.loc[day_idx & data['illum below tol lim?']].index[1]
                            data.loc[day_idx & (data.index >= i), 'illum habitable?'] = 0.0

                # are below/above degree-hours above the tolerable limit?
                data['below deg-hrs above tol?'] = data['deg-hrs set below tol'] > min_tol_deg_hrs
                data['above deg-hrs above tol?'] = data['deg-hrs set above tol'] > max_tol_deg_hrs

                # if below/above degree-hours are above tolerable limit and SET is below/above tolerable limit, tolerability = 0
                data.loc[data['below deg-hrs above tol?'] & data['set below tol?'], 'set tolerable?'] = 0.0
                data.loc[data['above deg-hrs above tol?'] & data['set above tol?'], 'set tolerable?'] = 0.0

                # occupant hours lost = 0 when habitable and tolerable, otherwise = ideal occupant hours
                data[zone+':OccHoursLostSET'] = data[zone+':IdealOccHours'] * (1.0 - data['set habitable?'] * data['set tolerable?'])
                data[zone+':OccHoursLostCO2'] = data[zone+':IdealOccHours'] * (1.0 - data['co2 habitable?'])
                data[zone+':OccHoursLostIllum'] = data[zone+':IdealOccHours'] * (1.0 - data['illum habitable?'])
                data[zone+':OccHoursLost'] = data[zone+':IdealOccHours'] * (1.0 - data['set habitable?'] * data['set tolerable?'] * data['co2 habitable?'] * data['illum habitable?'])

            # write intermediate results to .csv
            keep_cols = ['Environment:OutAirTemp [F]']
            for zone in zones:
                keep_cols.append(zone+':StdEffTemp [F]')
                keep_cols.append(zone+':CO2Conc [ppm]')
                keep_cols.append(zone+':Illum [lux]')
                keep_cols.append(zone+':IdealOccHours')
                keep_cols.append(zone+':OccHoursLostSET')
                keep_cols.append(zone+':OccHoursLostCO2')
                keep_cols.append(zone+':OccHoursLostIllum')
                keep_cols.append(zone+':OccHoursLost')
            for week in weeks:
                week_idx = (data.index >= week_starts[week]) & (data.index < week_ends[week])
                int_file = 'OHL' + sim_file[len('Supermarket'):]
                data.loc[week_idx, keep_cols].to_csv(os.path.join(ohl_dir, scenario, week, int_file), index=True)

            # sum ideal occ hours and occ hours lost over all hours in week and all zones
            sim_params = re.match(sim_file_fmt, sim_file).groupdict()
            ioh_cols = [z+':IdealOccHours' for z in zones]
            ohl_set_cols = [z+':OccHoursLostSET' for z in zones]
            ohl_co2_cols = [z+':OccHoursLostCO2' for z in zones]
            ohl_illum_cols = [z+':OccHoursLostIllum' for z in zones]
            ohl_cols = [z+':OccHoursLost' for z in zones]
            for week in weeks:
                week_idx = (data.index >= week_starts[week]) & (data.index < week_ends[week])
                ioh = data.loc[week_idx, ioh_cols].sum().sum()
                ohl_set = data.loc[week_idx, ohl_set_cols].sum().sum()
                ohl_co2 = data.loc[week_idx, ohl_co2_cols].sum().sum()
                ohl_illum = data.loc[week_idx, ohl_illum_cols].sum().sum()
                ohl = data.loc[week_idx, ohl_cols].sum().sum()
                for param in params:
                    week_files[week].write(param_values[param][sim_params[param]] + ',')
                week_files[week].write('%f,%f,%f,%f,%f\n' % (ioh,ohl_set,ohl_co2,ohl_illum,ohl))

        for week in weeks:
            week_files[week].close()
