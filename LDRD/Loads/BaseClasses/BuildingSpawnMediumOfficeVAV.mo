within LDRD.Loads.BaseClasses;
model BuildingSpawnMediumOfficeVAV "Spawn building model"
  extends Buildings.Experimental.DHC.Loads.BaseClasses.PartialBuilding(
    redeclare package Medium=Buildings.Media.Water,
    final have_heaWat=true,
    final have_chiWat=true,
    final have_eleHea=false,
    final have_eleCoo=false,
    final have_pum=true,
    final have_weaBus=false);
  package Medium2=Buildings.Media.Air
    "Medium model";
  parameter Integer nZon = 15
    "Number of conditioned zones";
  parameter Integer nZonFre = 3
    "Number of free floating zones";
  parameter Real facMulTerUni[nZon] = abs(QCooTot_flow_nominal) / 10000
    "Multiplier factor for terminal units";
  parameter String idfName=
    "modelica://LDRD/Resources/EnergyPlus/RefBldgMediumOfficeNew2004_v1.4_7.2_5A_USA_IL_CHICAGO-OHARE.idf"
    "Name of the IDF file";
  parameter String weaName=
    "modelica://LDRD/Resources/WeatherData/USA_IL_Chicago-OHare.Intl.AP.725300_TMY3.mos"
    "Name of the weather file";
  parameter Modelica.SIunits.MassFlowRate mLoa_flow_nominal[nZon] = fill(
    1,
    nZon)
    "Load side mass flow rate at nominal conditions (single terminal unit)"
    annotation (Dialog(group="Nominal condition"));
  parameter Modelica.SIunits.HeatFlowRate QHeaTot_flow_nominal[nZon]={
  4032,
  5139,
  13361,
  5681,
  3765,
  5638,
  3797,
  6099,
  4039,
  6057,
  4064,
  7985,
  5234,
  7944,
  5251}
    "Design heating heat flow rate (all terminal units)"
    annotation (Dialog(group="Nominal condition"));
  parameter Modelica.SIunits.HeatFlowRate QCooTot_flow_nominal[nZon]={
  -28299,
  -29176,
  -27150,
  -14743,
  -9302,
  -4364,
  -10782,
  -17112,
  -10888,
  -6523,
  -12041,
  -16827,
  -10313,
  -6759,
  -12119}
    "Design cooling heat flow rate (all terminal units)"
    annotation (Dialog(group="Nominal condition"));
  final parameter Modelica.SIunits.HeatFlowRate QHea_flow_nominal[nZon]=
    QHeaTot_flow_nominal ./ facMulTerUni
    "Design heating heat flow rate (single terminal unit)"
    annotation (Dialog(group="Nominal condition"));
  final parameter Modelica.SIunits.HeatFlowRate QCoo_flow_nominal[nZon]=
    QCooTot_flow_nominal ./ facMulTerUni
    "Design cooling heat flow rate (single terminal unit)"
    annotation (Dialog(group="Nominal condition"));
  parameter Modelica.SIunits.Temperature T_aHeaWat_nominal=313.15
    "Heating water inlet temperature at nominal conditions"
    annotation (Dialog(group="Nominal condition"));
  parameter Modelica.SIunits.Temperature T_bHeaWat_nominal(
    min=273.15,
    displayUnit="degC")=
    T_aHeaWat_nominal-5
    "Heating water outlet temperature at nominal conditions"
    annotation (Dialog(group="Nominal condition"));
  parameter Modelica.SIunits.Temperature T_aChiWat_nominal=280.15
    "Chilled water inlet temperature at nominal conditions "
    annotation (Dialog(group="Nominal condition"));
  parameter Modelica.SIunits.Temperature T_bChiWat_nominal(
    min=273.15,
    displayUnit="degC")=T_aChiWat_nominal+7
    "Chilled water outlet temperature at nominal conditions"
    annotation (Dialog(group="Nominal condition"));
  parameter Modelica.SIunits.Temperature T_aLoaHea_nominal=273.15 + 20
    "Load side inlet temperature at nominal conditions in heating mode"
    annotation (Dialog(group="Nominal condition"));
  parameter Modelica.SIunits.Temperature T_aLoaCoo_nominal=273.15 + 24
    "Load side inlet temperature at nominal conditions in cooling mode"
    annotation (Dialog(group="Nominal condition"));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant minTSet[nZon](
    k=fill(
      293.15,
      nZon),
    y(each final unit="K",
      each displayUnit="degC"))
    "Minimum temperature set point"
    annotation (Placement(transformation(extent={{-280,250},{-260,270}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant maxTSet[nZon](
    k=fill(
      297.15,
      nZon),
    y(each final unit="K",
      each displayUnit="degC"))
    "Maximum temperature set point"
    annotation (Placement(transformation(extent={{-280,210},{-260,230}})));
  Modelica.Blocks.Sources.Constant qConGai_flow[nZon](
    each k=0) "Convective heat gain"
    annotation (Placement(transformation(extent={{-70,70},{-50,90}})));
  Modelica.Blocks.Sources.Constant qRadGai_flow[nZon](
    each k=0) "Radiative heat gain"
    annotation (Placement(transformation(extent={{-70,100},{-50,120}})));
  Modelica.Blocks.Routing.Multiplex3 multiplex3_1[nZon]
    annotation (Placement(transformation(extent={{-30,70},{-10,90}})));
  Modelica.Blocks.Sources.Constant qLatGai_flow[nZon](
    each k=0) "Latent heat gain"
    annotation (Placement(transformation(extent={{-70,40},{-50,60}})));
  Buildings.ThermalZones.EnergyPlus.ThermalZone zon[nZon](
    redeclare each final package Medium = Medium2,
    zoneName={"Core_bottom",
"Core_mid",
"Core_top",
"Perimeter_bot_ZN_1",
"Perimeter_bot_ZN_2",
"Perimeter_bot_ZN_3",
"Perimeter_bot_ZN_4",
"Perimeter_mid_ZN_1",
"Perimeter_mid_ZN_2",
"Perimeter_mid_ZN_3",
"Perimeter_mid_ZN_4",
"Perimeter_top_ZN_1",
"Perimeter_top_ZN_2",
"Perimeter_top_ZN_3",
"Perimeter_top_ZN_4"},
    nPorts=nZonFre)
                   "Thermal zone - Conditioned"
    annotation (Placement(transformation(extent={{20,-30},{60,10}})));
  inner Buildings.ThermalZones.EnergyPlus.Building building(
    idfName=Modelica.Utilities.Files.loadResource(
      idfName),
    weaName=Modelica.Utilities.Files.loadResource(
      weaName))
    "Building outer component"
    annotation (Placement(transformation(extent={{40,140},{62,160}})));
  Buildings.Controls.OBC.CDL.Continuous.MultiSum mulSum
    annotation (Placement(transformation(extent={{230,110},{250,130}})));
  Buildings.Controls.OBC.CDL.Continuous.MultiSum mulSum3
    annotation (Placement(transformation(extent={{230,70},{250,90}})));
  Buildings.ThermalZones.EnergyPlus.ThermalZone zonFre[nZonFre](
    redeclare each final package Medium = Medium2,
    zoneName={
"FirstFloor_Plenum",
"MidFloor_Plenum",
"TopFloor_Plenum"},
    nPorts=nZon)    "Thermal zone - Free floating" annotation (Placement(transformation(extent={{140,-30},{180,10}})));
  Modelica.Blocks.Sources.Constant qConGai_flow1[nZonFre](each k=0) "Convective heat gain"
    annotation (Placement(transformation(extent={{20,70},{40,90}})));
  Modelica.Blocks.Sources.Constant qRadGai_flow1[nZonFre](each k=0) "Radiative heat gain"
    annotation (Placement(transformation(extent={{20,100},{40,120}})));
  Modelica.Blocks.Routing.Multiplex3 multiplex3_2[nZonFre]
    annotation (Placement(transformation(extent={{60,70},{80,90}})));
  Modelica.Blocks.Sources.Constant qLatGai_flow1[nZonFre](each k=0) "Latent heat gain"
    annotation (Placement(transformation(extent={{20,40},{40,60}})));
  MultiZoneVAV.ASHRAE2006VAV vav(numVAV=nZon, numRet=nZonFre) "VAV system"
    annotation (Placement(transformation(extent={{90,-50},{110,-30}})));
equation
  connect(qRadGai_flow.y,multiplex3_1.u1[1])
    annotation (Line(points={{-49,110},{-40,110},{-40,88},{-32,88},{-32,87}},
                                                                      color={0,0,127},smooth=Smooth.None));
  connect(qConGai_flow.y,multiplex3_1.u2[1])
    annotation (Line(points={{-49,80},{-32,80}},  color={0,0,127},smooth=Smooth.None));
  connect(multiplex3_1.u3[1],qLatGai_flow.y)
    annotation (Line(points={{-32,73},{-32,72},{-40,72},{-40,50},{-49,50}},
                                                                      color={0,0,127}));
  connect(mulSum3.y, mulPPum.u)
    annotation (Line(points={{252,80},{268,80}}, color={0,0,127}));
  connect(mulSum.y, mulPFan.u)
    annotation (Line(points={{252,120},{268,120}}, color={0,0,127}));
  connect(multiplex3_1.y, zon.qGai_flow) annotation (Line(points={{-9,80},{8,80},{8,0},{18,0}},    color={0,0,127}));
  connect(qRadGai_flow1.y, multiplex3_2.u1[1]) annotation (Line(
      points={{41,110},{50,110},{50,88},{58,88},{58,87}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(qConGai_flow1.y, multiplex3_2.u2[1])
    annotation (Line(
      points={{41,80},{58,80}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(multiplex3_2.u3[1], qLatGai_flow1.y)
    annotation (Line(points={{58,73},{58,72},{50,72},{50,50},{41,50}}, color={0,0,127}));
  connect(multiplex3_2.y, zonFre.qGai_flow)
    annotation (Line(points={{81,80},{120,80},{120,0},{138,0}},  color={0,0,127}));
  connect(vav.ports_b, zonFre.ports) annotation (Line(points={{110,-40},{160,-40},{160,-29.1}}, color={0,127,255}));
  connect(vav.ports_a, zon.ports) annotation (Line(points={{90,-40},{40,-40},{40,-29.1}}, color={0,127,255}));
  connect(zon.TAir, vav.TRooAir) annotation (Line(points={{61,8},{80,8},{80,-32},{89,-32}}, color={0,0,127}));
  connect(building.weaBus, vav.weaBus)
    annotation (Line(
      points={{62,150},{100,150},{100,-32}},
      color={255,204,51},
      thickness=0.5));
  connect(mulChiWatInl.port_b, mulChiWatOut.port_a)
    annotation (Line(points={{-260,-260},{260,-260}}, color={0,127,255}));
  connect(mulHeaWatInl.port_b, mulHeaWatOut.port_a) annotation (Line(points={{-260,-60},{260,-60}}, color={0,127,255}));
  annotation (
    Documentation(
      info="
<html>
<p>
This is a simplified six-zone building model based on an EnergyPlus
building envelope model.
It was generated from translating a GeoJSON model specified within the URBANopt UI.
The heating and cooling loads are computed with a four-pipe
fan coil unit model derived from
<a href=\"modelica://Buildings.Experimental.DHC.Loads.BaseClasses.PartialTerminalUnit\">
Buildings.Experimental.DHC.Loads.BaseClasses.PartialTerminalUnit</a>
and connected to the room model by means of fluid ports. The <code>Attic</code> zone
is unconditionned, with a free floating temperature.
</p>
</html>",
      revisions="<html>
<ul>
<li>
February 21, 2020, by Antoine Gautier:<br/>
First implementation.
</li>
</ul>
</html>"),
    Icon(
      graphics={
        Bitmap(
          extent={{-108,-100},{92,100}},
          fileName="modelica://Buildings/Resources/Images/ThermalZones/EnergyPlus/EnergyPlusLogo.png")}));
end BuildingSpawnMediumOfficeVAV;
