import pandas as pd

vintages = ['Post1980',
            '2004']

climates = ['2A',
            '3C',
            '5A']

weeks = ['cold',
         'cool',
         'mild',
         'warm',
         'hot']

def get_weeks(climate):

    if climate == '2A':
        week_starts = {'cold': '2018-01-15',
                       'cool': '2018-02-26',
                       'mild': '2018-10-22',
                       'warm': '2018-08-20',
                       'hot': '2018-07-30'}

    elif climate == '3C':
        week_starts = {'cold': '2018-01-08',
                       'cool': '2018-12-03',
                       'mild': '2018-06-11',
                       'warm': '2018-05-28',
                       'hot': '2018-08-06'}

    elif climate == '5A':
        week_starts = {'cold': '2018-01-01',
                       'cool': '2018-11-19',
                       'mild': '2018-10-08',
                       'warm': '2018-08-13',
                       'hot': '2018-07-16'}

    week_ends = {}
    for week in list(week_starts.keys()):
        week_starts[week] = pd.to_datetime(week_starts[week])
        week_ends[week] = week_starts[week] + pd.Timedelta(days=7)

    assert set(weeks) == set(week_starts.keys())
    assert set(weeks) == set(week_ends.keys())

    return week_starts, week_ends

param_names = {'m1': 'WWR',
               'm2': 'Window Glazing U-value [W/m2-K]',
               'm3': 'Window Glazing SHGC',
               'm4': 'Window Glazing Visible Transmittance',
               'm5': 'Wall Insulation U-value [W/m2-K]',
               'm6': 'Wall Reflectance',
               'm7': 'Roof Insulation U-value [W/m2-K]',
               'm8': 'Roof Reflectance',
               'm9': 'Occupant Density [ft2/person]',
               'm10': 'Plug Load Density [W/ft2]',
               'm11': 'Orientation [deg]',
               'm12': 'Infiltration [m3/s-m2]'}
params = sorted(list(param_names.keys()), key=lambda k: int(k[1:]))

def get_parameter_values(climate):

    param_values = {}

    param_values['m1'] = {'0': '0.2',
                          '1': '0.3',
                          '2': '0.4',
                          '3': '0.5'}

    if climate == '2A':
        param_values['m2'] = {'0': '5.351',
                              '1': '2.969',
                              '2': '2.245',
                              '3': '2.254'}
    elif climate == '3C':
        param_values['m2'] = {'0': '5.351',
                              '1': '2.969',
                              '2': '2.245',
                              '3': '2.399'}
    elif climate == '5A':
        param_values['m2'] = {'0': '2.969',
                              '1': '2.969',
                              '2': '2.245',
                              '3': '2.067'}

    if climate == '2A':
        param_values['m3'] = {'0': '0.551',
                              '1': '0.449',
                              '2': '0.268',
                              '3': '0.167'}
    elif climate == '3C':
        param_values['m3'] = {'0': '0.712',
                              '1': '0.449',
                              '2': '0.268',
                              '3': '0.58'}
    elif climate == '5A':
        param_values['m3'] = {'0': '0.616',
                              '1': '0.449',
                              '2': '0.268',
                              '3': '0.503'}

    if climate == '2A':
        param_values['m4'] = {'0': '0.445',
                              '1': '0.395',
                              '2': '0.533',
                              '3': '0.213'}
    elif climate == '3C':
        param_values['m4'] = {'0': '0.739',
                              '1': '0.395',
                              '2': '0.533',
                              '3': '0.652'}
    elif climate == '5A':
        param_values['m4'] = {'0': '0.657',
                              '1': '0.395',
                              '2': '0.533',
                              '3': '0.582'}

    if climate == '2A':
        param_values['m5'] = {'0': '1.29',
                              '1': '0.85',
                              '2': '0.7',
                              '3': '0.51'}
    elif climate == '3C':
        param_values['m5'] = {'0': '1.26',
                              '1': '0.7',
                              '2': '0.51',
                              '3': '0.47'}
    elif climate == '5A':
        param_values['m5'] = {'0': '0.88',
                              '1': '0.47',
                              '2': '0.38',
                              '3': '0.33'}

    param_values['m6'] = {'0': '0.22',
                          '1': '0.3',
                          '2': '0.5',
                          '3': '0.7'}

    if climate == '2A':
        param_values['m7'] = {'0': '0.57',
                              '1': '0.37',
                              '2': '0.28',
                              '3': '0.23'}
    elif climate == '3C':
        param_values['m7'] = {'0': '0.57',
                              '1': '0.37',
                              '2': '0.28',
                              '3': '0.23'}
    elif climate == '5A':
        param_values['m7'] = {'0': '0.4',
                              '1': '0.35',
                              '2': '0.28',
                              '3': '0.18'}

    param_values['m8'] = {'0': '0.3',
                          '1': '0.55',
                          '2': '0.7',
                          '3': '0.8'}

    param_values['m9'] = {'0': '130',
                          '1': '200',
                          '2': '300',
                          '3': '400'}

    param_values['m10'] = {'0': '1.25',
                           '1': '1',
                           '2': '0.75',
                           '3': '0.5'}

    param_values['m11'] = {'0': '0',
                           '1': '45',
                           '2': '90'}

    param_values['m12'] = {'0': '0.000569',
                           '1': '0.000797',
                           '2': '0.001024',
                           '3': '0.001133'}

    assert set(params) == set(param_values.keys())

    return param_values

work_start_hr = 8 # 8am
work_end_hr = 18 # 6pm

include_weekends = True

min_hab_temp = 40.0 # degF
max_hab_temp = 103.0 # degF

min_tol_temp = 54.0 # degF
max_tol_temp = 86.0 # degF

min_tol_deg_hrs = 216.0 / 7 # degF-hrs, daily
max_tol_deg_hrs = 432.0 / 7 # degF-hrs, daily

max_co2_conc = 30e3 # ppm
max_co2_exp = 40e3 # ppm-hrs

min_hab_illum = 100.0 # lux
min_tol_illum = 150.0 # lux
