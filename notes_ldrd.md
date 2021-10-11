# Notes LDRD Resilience 2021

## FIXME

dp_nominal = 30 kPa for cooling towers, within range of https://studylib.net/doc/7221098/cooling-tower-pumping-pressure-drop: without nozzles (typically induced-air crossflow don't require nozzles) the pressure drop is only mainly elevation head
Carrier dry coolers : 50 kPa

Maybe use 50 kPa

- [x] Not used and incorrect values:
  parameter Modelica.SIunits.Temperature TLooMin = 273.15 + 6
    "Minimum loop temperature";
  parameter Modelica.SIunits.Temperature TLooMax = 273.15 + 17
    "Maximum loop temperature";


Central chiller to maintain 16°C: what capacity in resilience mode with minimum sizing of borefield?

Change to dry coolers with 5K approach

Load diversity to fix = 1.0

Check HHW supply T and COP

 `Zone Thermal Comfort Pierce Model Standard Effective Temperature [C](Hourly)`.
TODO: add that output to Spawn model and assess impact.


## TODO

Check VAV ON at night

Sensitivity

- parameter Real divAirFlo(min=0, max=1) = 0.7
- UA wet coil

Change over coils

Nota: reheat is no real reheat, rather heat recovery!





## Kecheng 5102298253

Compute energy (1st Law) and exergy (2nd Law) efficiencies on set of load patterns for the different ETS layouts
see https://www.researchgate.net/publication/316144041_Experimental_comparison_between_R409A_and_R437A_performance_in_a_heat_pump_unit

- HR chiller & // ambient
- HR chiller & WSE in series - plant side
- HR chiller & WSE in series - load side?
- Cascading heater and chiller
- Cascading heater and chiller & WSE in series - plant side


- Night sky radiant cooling
- Cooling towers for night cooling in retrofit

- VAV with ultra-cool coil arrangment: in geocooling circulate CHW also in heating coil!



## Resilience design days

ASHRAE §14.11 in CHICAGO OHARE INTL AP

- Hottest Month: 7
- 0.4% DB = 33.3 (range 10.5) / MCWB = 23.7 (range 5.4)




## FIXME master MBL

*In Buildings.Examples.VAVReheat.Controls.RoomVAV the description is incorrect
Plus the hysteresis can trigger fast control and pressure transients for rooms with a high design heating flow rate.

  parameter Modelica.SIunits.TemperatureDifference dTHys(final min=0) = 0.5
    "Hysteresis width for enabling cooling mode";

*


*  parameter Integer dBor = 6
    "Distance between boreholes";

  NO: dBor is "Borehole buried depth"
*


From HVAC Pump Handbook

There is no minimum speed for these HVAC pumps. Misinfor-
mation about specific, critical, and minimum speeds for HVAC pumps
has caused misapplication of them along with the installation of
unnecessary speed controls.


*Buildings.Experimental.DHC.EnergyTransferStations.Combined.Generation5.BaseClasses.PartialParallel:

- Add
  final parameter Modelica.SIunits.MassFlowRate mDisWat_flow_nominal(min=0)=
    hex.m1_flow_nominal
    "District water mass flow rate"
    annotation (Dialog(group="Nominal condition"));
- Add pressure BC
- Add THeaWatSup_nominal and TChiWatSup_nominal
- Remove tank connection to outside connectors to allow integrating load-side systems like WSE

- Control of HX is not correct: better control primary with same signal as secondary (if that doens't work, control for same deltaP)
*

Buildings.Experimental.DHC.EnergyTransferStations.BaseClasses.PartialETS

- Add m{SerAmb,Hea,Coo}_flow_nominal with assert if 0
- Add T{Hea,Hot,Chi}WatSup_nominal with assert if Medium.default

*Rename for all ETS mDisWat into mSerWat cf. names of ports
*

`QHea_flow_nominal` in Spawn building = single unit VS all units for TimeSeries.
Same for `mLoa_flow_nominal`.

*Also facMulTerUni is Integer and should better be Real
*
*In `Buildings.Experimental.DHC.EnergyTransferStations.Combined.Generation5.HeatPumpHeatExchanger`

- `dTHHW` is conditional: `if have_hotWat and have_varFloEva` must be removed.
- `loaHHW`:  `if have_varFloEva or have_varFloCon` must be added.
- `priOve`:  `if have_varFloCon` must be added*

*In `Buildings.Experimental.DHC.Loads.Examples.BaseClasses.BuildingSpawnZ6`

- disFloHea disFloCoo improperly connected to outside fluid connectors
- Same for SpawnZ1 and all RC
*

## ASHRAE GSHP

Consider that a single verti-
cal bore can typically support one to two cooling tons (3.5 to 7 kW), which requires
approximately 400 ft 2 (40 m 2 ) of land area. In buildings where the cooling load is much
greater than the heating requirement, the required land area can be reduced significantly
with hybrid GCHPs. Also, designers are attempting to drill to greater depths to reduce the
required land area. Caution is advised with deeper drilling because pump requirements
will likely be greater, bore separation should be increased to reduce the possibility of
cross-drilling during installation, and the potential for pipe failure for depths beyond
500 ft (150 m) is not yet well established (see Appendix C)


## Various

From https://www.tranebelgium.com/files/book-doc/12/fr/12.1hp13yp1.pdf

> Some system designers hesitate to use lower chilled-water temperatures,
concerned that the chiller will become less efficient. As discussed in “Effect of
chilled-water temperature” on page 3:
• Lower chilled-water temperature makes the chiller work harder. However,
while the lower water temperature increases chiller energy consumption,
it significantly reduces the chilled-water flow rate and pump energy. This
combination often lowers system energy consumption

:warning: See §Selecting flow rates above for an assessment of low-flow + low CHWST + high delta-T VS high-flow + high CHWST + low delta-T

> Some designers use the following
approximation instead. For each 1.5 to
2.5°F [0.8°C to 1.4°C] the water
temperature entering the coil is reduced,
the coil returns the water 1°F [0.6°C]
warmer and gives approximately the
same sensible and total capacities. This
is a rough approximation and a coil’s
actual performance depends on its
design.

From Taylor
> The heat exchanger should be a plate & frame type and
selected for an approach of about 3°F (1.7°C) (i.e., the tem-
perature of the chilled water leaving the heat exchanger is
equal to 3°F (1.7°C) above the temperature of the condenser
water entering the heat exchanger).
Heat exchanger cost increases expo-
nentially with approach temperature
so very close approaches should be
tested for cost effectiveness. The heat
exchanger pressure drop on the con-
denser water side should be similar to
that of the condensers so the flow rate
will be similar when serving either
the condensers or heat exchanger.
On the chilled water side, pressure
drop is typically limited to about 5 or
6 psi (34 or 41 kPa) to limit the chilled
water pump energy impact. The heat
exchanger performance must be cer-
tified per AHRI Standard 400 3 as re-
quired by Standard 90.1.


From HVAC Pump Handbook

There is no minimum speed for these HVAC pumps. Misinfor-
mation about specific, critical, and minimum speeds for HVAC pumps
has caused misapplication of them along with the installation of
unnecessary speed controls. As will be reviewed in Chap. 6, variable-
speed centrifugal pumps can be operated down to any speed required
by the water system. Since they are variable-torque machines, very
little energy is required to turn them at low speeds. Information on
this subject is included in Chap. 7 on pump drivers and drives as to
the minimum speed required by motors for their cooling.
The HVAC water system designer really has no need to be con-
cerned with the specific, critical, or minimum speeds of these pumps.

Some pump companies do publish pump brake horsepower curves down to zero flow.
Other equations that use pump efficiency have the same problem,
since the efficiency of a centrifugal pump approaches zero at very low
flows. If this information is not available, the pump company should
provide the minimum flow that will hold the temperature rise to the
desired maximum. The obvious advantage of the variable-speed pump
over the constant-speed pump appears here because there is much
less energy imparted to the water at minimum flows and speeds.
For most HVAC applications, there should not be temperature rises
in a pump higher than 10°F. Do not bypass water to a pump suction!
This continues to elevate the suction temperature. Bypass water
should be returned to a boiler feed system or deaerator on boiler feed
systems or to the cooling tower, boiler, or chiller on condenser, hot, or
chilled water systems. Since it is desired to maintain supply tempera-
ture in hot and chilled water mains, flow-control valves should be
located at the far ends of these mains to maintain their water tem-
perature. Usually, the heat loss or heat gain for these mains requires
a flow that is greater than that required to maintain temperature in
the pump itself.