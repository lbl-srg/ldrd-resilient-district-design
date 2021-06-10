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
  parameter Integer nZonCon = 15
    "Number of conditioned zones";
  parameter Integer nZonFre = 3
    "Number of free floating zones";
  parameter Real facMulTerUni[nZonCon] = abs(QCooTot_flow_nominal) / 10000
    "Multiplier factor for terminal units";
  parameter String idfName=
    "modelica://LDRD/Resources/EnergyPlus/RefBldgMediumOfficeNew2004_v1.4_7.2_5A_USA_IL_CHICAGO-OHARE.idf"
    "Name of the IDF file";
  parameter String weaName=
    "modelica://LDRD/Resources/WeatherData/USA_IL_Chicago-OHare.Intl.AP.725300_TMY3.mos"
    "Name of the weather file";
  parameter Modelica.SIunits.HeatFlowRate QHeaTot_flow_nominal[nZonCon]={
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
  parameter Modelica.SIunits.HeatFlowRate QCooTot_flow_nominal[nZonCon]={
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
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant minTSet[nZonCon](
    k=fill(
      293.15,
      nZonCon),
    y(each final unit="K",
      each displayUnit="degC"))
    "Minimum temperature set point"
    annotation (Placement(transformation(extent={{-280,250},{-260,270}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant maxTSet[nZonCon](
    k=fill(
      297.15,
      nZonCon),
    y(each final unit="K",
      each displayUnit="degC"))
    "Maximum temperature set point"
    annotation (Placement(transformation(extent={{-280,210},{-260,230}})));
  Modelica.Blocks.Sources.Constant qConGai_flow[nZonCon](
    each k=0) "Convective heat gain"
    annotation (Placement(transformation(extent={{30,70},{50,90}})));
  Modelica.Blocks.Sources.Constant qRadGai_flow[nZonCon](
    each k=0) "Radiative heat gain"
    annotation (Placement(transformation(extent={{30,100},{50,120}})));
  Modelica.Blocks.Routing.Multiplex3 multiplex3_1[nZonCon]
    annotation (Placement(transformation(extent={{70,70},{90,90}})));
  Modelica.Blocks.Sources.Constant qLatGai_flow[nZonCon](
    each k=0) "Latent heat gain"
    annotation (Placement(transformation(extent={{30,40},{50,60}})));
  Buildings.ThermalZones.EnergyPlus.ThermalZone zon[nZonCon](
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
    each final nPorts=1)
    "Thermal zone - Conditioned"
    annotation (Placement(transformation(extent={{140,-30},{180,10}})));
  inner Buildings.ThermalZones.EnergyPlus.Building building(
    idfName=Modelica.Utilities.Files.loadResource(
      idfName),
    weaName=Modelica.Utilities.Files.loadResource(
      weaName))
    "Building outer component"
    annotation (Placement(transformation(extent={{40,140},{62,160}})));
  Buildings.ThermalZones.EnergyPlus.ThermalZone zonFre[nZonFre](
    redeclare each final package Medium = Medium2,
    zoneName={
"FirstFloor_Plenum",
"MidFloor_Plenum",
"TopFloor_Plenum"},
    each final nPorts=1)
    "Thermal zone - Free floating"
    annotation (Placement(transformation(extent={{0,-30},{40,10}})));
  Modelica.Blocks.Sources.Constant qConGai_flow1[nZonFre](each k=0) "Convective heat gain"
    annotation (Placement(transformation(extent={{-100,70},{-80,90}})));
  Modelica.Blocks.Sources.Constant qRadGai_flow1[nZonFre](each k=0) "Radiative heat gain"
    annotation (Placement(transformation(extent={{-100,100},{-80,120}})));
  Modelica.Blocks.Routing.Multiplex3 multiplex3_2[nZonFre]
    annotation (Placement(transformation(extent={{-60,70},{-40,90}})));
  Modelica.Blocks.Sources.Constant qLatGai_flow1[nZonFre](each k=0) "Latent heat gain"
    annotation (Placement(transformation(extent={{-100,40},{-80,60}})));
  MultiZoneVAV.ASHRAE2006VAV vav(numVAV=nZonCon, numRet=nZonFre)
    "VAV system"
    annotation (Placement(transformation(extent={{90,-50},{110,-30}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant FIXME(k=0)
    annotation (Placement(transformation(extent={{190,70},{210,90}})));
equation
  connect(qRadGai_flow.y,multiplex3_1.u1[1])
    annotation (Line(points={{51,110},{60,110},{60,88},{68,88},{68,87}},
       color={0,0,127},smooth=Smooth.None));
  connect(qConGai_flow.y,multiplex3_1.u2[1])
    annotation (Line(points={{51,80},{68,80}},    color={0,0,127},smooth=Smooth.None));
  connect(multiplex3_1.u3[1],qLatGai_flow.y)
    annotation (Line(points={{68,73},{68,72},{60,72},{60,50},{51,50}},color={0,0,127}));
  connect(multiplex3_1.y, zon.qGai_flow) annotation (Line(points={{91,80},{120,80},{120,0},{138,0}},
                                                                                                   color={0,0,127}));
  connect(qRadGai_flow1.y, multiplex3_2.u1[1]) annotation (Line(
      points={{-79,110},{-70,110},{-70,90},{-62,90},{-62,87}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(qConGai_flow1.y, multiplex3_2.u2[1])
    annotation (Line(
      points={{-79,80},{-62,80}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(multiplex3_2.u3[1], qLatGai_flow1.y)
    annotation (Line(points={{-62,73},{-62,74},{-70,74},{-70,50},{-79,50}},
                                                                       color={0,0,127}));
  connect(multiplex3_2.y, zonFre.qGai_flow)
    annotation (Line(points={{-39,80},{-12,80},{-12,0},{-2,0}},  color={0,0,127}));
  connect(building.weaBus, vav.weaBus)
    annotation (Line(
      points={{62,150},{100,150},{100,-32}},
      color={255,204,51},
      thickness=0.5));
  connect(vav.ports_b, zon.ports[1]) annotation (Line(points={{110,-40},{160,-40},{160,-29.1}}, color={0,127,255}));
  connect(zon.TAir, vav.TRooAir)
    annotation (Line(points={{181,8},{190,8},{190,20},{80,20},{80,-32},{89,-32}}, color={0,0,127}));
  connect(vav.ports_a, zonFre.ports[1]) annotation (Line(points={{90,-40},{20,-40},{20,-29.1}}, color={0,127,255}));
  connect(vav.QCoo_flow, mulQCoo_flow.u)
    annotation (Line(points={{111,-33},{130,-33},{130,240},{268,240}}, color={0,0,127}));
  connect(vav.QHea_flow, mulQHea_flow.u)
    annotation (Line(points={{111,-31},{126,-31},{126,280},{268,280}}, color={0,0,127}));
  connect(FIXME.y, mulPPum.u) annotation (Line(points={{212,80},{268,80}}, color={0,0,127}));
  connect(vav.PFan, mulPFan.u) annotation (Line(points={{111,-35},{134,-35},{134,120},{268,120}}, color={0,0,127}));
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
