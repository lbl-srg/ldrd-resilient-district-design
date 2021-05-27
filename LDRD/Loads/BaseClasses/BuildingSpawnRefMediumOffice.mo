within LDRD.Loads.BaseClasses;
model BuildingSpawnRefMediumOffice "Spawn building model"
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
  parameter Real facMulTerUni[nZon] = abs(QCooTot_flow_nominal) / 10000
    "Multiplier factor for terminal units";
  parameter String idfName=
    "modelica://LDRD/Resources/EnergyPlus/RefBldgMediumOfficeNew2004_v1.4_7.2_3C_USA_CA_SAN_FRANCISCO.idf"
    "Name of the IDF file";
  parameter String weaName=
    "modelica://LDRD/Resources/WeatherData/USA_CA_San.Francisco.Intl.AP.724940_TMY3.mos"
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
  final parameter Modelica.SIunits.HeatFlowRate QHea_flow_nominal[nZon]=QHeaTot_flow_nominal ./ facMulTerUni
    "Design heating heat flow rate (single terminal unit)"
    annotation (Dialog(group="Nominal condition"));
  final parameter Modelica.SIunits.HeatFlowRate QCoo_flow_nominal[nZon]=QCooTot_flow_nominal ./ facMulTerUni
    "Design cooling heat flow rate (single terminal unit)"
    annotation (Dialog(group="Nominal condition"));
  parameter Modelica.SIunits.Temperature T_aHeaWat_nominal=313.15
    "Heating water inlet temperature at nominal conditions"
    annotation (Dialog(group="Nominal condition"));
  parameter Modelica.SIunits.Temperature T_bHeaWat_nominal(
    min=273.15,
    displayUnit="degC")=T_aHeaWat_nominal-5
    "Heating water outlet temperature at nominal conditions"
    annotation (Dialog(group="Nominal condition"));
  parameter Modelica.SIunits.Temperature T_aChiWat_nominal=291.15
    "Chilled water inlet temperature at nominal conditions "
    annotation (Dialog(group="Nominal condition"));
  parameter Modelica.SIunits.Temperature T_bChiWat_nominal(
    min=273.15,
    displayUnit="degC")=T_aChiWat_nominal+5
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
    annotation (Placement(transformation(extent={{-60,90},{-40,110}})));
  Modelica.Blocks.Sources.Constant qRadGai_flow[nZon](
    each k=0) "Radiative heat gain"
    annotation (Placement(transformation(extent={{-60,120},{-40,140}})));
  Modelica.Blocks.Routing.Multiplex3 multiplex3_1[nZon]
    annotation (Placement(transformation(extent={{-20,90},{0,110}})));
  Modelica.Blocks.Sources.Constant qLatGai_flow[nZon](
    each k=0) "Latent heat gain"
    annotation (Placement(transformation(extent={{-60,60},{-40,80}})));
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
    each nPorts=2) "Thermal zone"
    annotation (Placement(transformation(extent={{20,-30},{60,10}})));
  inner Buildings.ThermalZones.EnergyPlus.Building building(
    idfName=Modelica.Utilities.Files.loadResource(
      idfName),
    weaName=Modelica.Utilities.Files.loadResource(
      weaName))
    "Building outer component"
    annotation (Placement(transformation(extent={{40,140},{62,160}})));
  Buildings.Controls.OBC.CDL.Continuous.MultiSum mulSum(
    final nin=nZon)
    annotation (Placement(transformation(extent={{230,110},{250,130}})));
  Buildings.Controls.OBC.CDL.Continuous.MultiSum mulSum3(
    nin=2)
    annotation (Placement(transformation(extent={{230,70},{250,90}})));
  Buildings.Experimental.DHC.Loads.Examples.BaseClasses.FanCoil4Pipe terUni[nZon](
    redeclare each final package Medium1 = Medium,
    redeclare each final package Medium2 = Medium2,
    final facMul=facMulTerUni,
    final QHea_flow_nominal=QHea_flow_nominal,
    final QCoo_flow_nominal=QCoo_flow_nominal,
    each T_aLoaHea_nominal=T_aLoaHea_nominal,
    each T_aLoaCoo_nominal=T_aLoaCoo_nominal,
    each T_bHeaWat_nominal=T_bHeaWat_nominal,
    each T_bChiWat_nominal=T_bChiWat_nominal,
    each T_aHeaWat_nominal=T_aHeaWat_nominal,
    each T_aChiWat_nominal=T_aChiWat_nominal,
    final mLoaHea_flow_nominal=mLoa_flow_nominal,
    final mLoaCoo_flow_nominal=mLoa_flow_nominal) "Terminal unit"
    annotation (Placement(transformation(extent={{-140,-2},{-116,22}})));
  Buildings.Experimental.DHC.Loads.FlowDistribution disFloHea(
    redeclare package Medium=Medium,
    m_flow_nominal=sum(
      terUni.mHeaWat_flow_nominal .* terUni.facMul),
    have_pum=true,
    dp_nominal=100000,
    nPorts_a1=nZon,
    nPorts_b1=nZon)
    "Heating water distribution system"
    annotation (Placement(transformation(extent={{-220,-190},{-200,-170}})));
  Buildings.Experimental.DHC.Loads.FlowDistribution disFloCoo(
    redeclare package Medium=Medium,
    m_flow_nominal=sum(
      terUni.mChiWat_flow_nominal .* terUni.facMul),
    typDis=Buildings.Experimental.DHC.Loads.Types.DistributionType.ChilledWater,
    have_pum=true,
    dp_nominal=100000,
    nPorts_a1=nZon,
    nPorts_b1=nZon)
    "Chilled water distribution system"
    annotation (Placement(transformation(extent={{-160,-230},{-140,-210}})));
equation
  connect(qRadGai_flow.y,multiplex3_1.u1[1])
    annotation (Line(points={{-39,130},{-30,130},{-30,108},{-22,108},{-22,107}},
                                                                      color={0,0,127},smooth=Smooth.None));
  connect(qConGai_flow.y,multiplex3_1.u2[1])
    annotation (Line(points={{-39,100},{-22,100}},color={0,0,127},smooth=Smooth.None));
  connect(multiplex3_1.u3[1],qLatGai_flow.y)
    annotation (Line(points={{-22,93},{-22,92},{-30,92},{-30,70},{-39,70}},
                                                                      color={0,0,127}));
  connect(terUni.port_bHeaWat,disFloHea.ports_a1)
    annotation (Line(points={{-116,0},{-80,0},{-80,-174},{-200,-174}},color={0,127,255}));
  connect(disFloHea.ports_b1,terUni.port_aHeaWat)
    annotation (Line(points={{-220,-174},{-230,-174},{-230,0},{-140,0}},color={0,127,255}));
  connect(disFloCoo.ports_b1,terUni.port_aChiWat)
    annotation (Line(points={{-160,-214},{-250,-214},{-250,2},{-140,2}},color={0,127,255}));
  connect(terUni.port_bChiWat,disFloCoo.ports_a1)
    annotation (Line(points={{-116,2},{-40,2},{-40,-214},{-140,-214}},color={0,127,255}));
  connect(terUni.mReqChiWat_flow,disFloCoo.mReq_flow)
    annotation (Line(points={{-115,4},{-104,4},{-104,-80},{-180,-80},{-180,-224},
          {-161,-224}},                                                                       color={0,0,127}));
  connect(terUni.mReqHeaWat_flow,disFloHea.mReq_flow)
    annotation (Line(points={{-115,6},{-100,6},{-100,-90.5},{-221,-90.5},{-221,-184}},color={0,0,127}));
  connect(terUni.PFan,mulSum.u)
    annotation (Line(points={{-115,10},{-100,10},{-100,220},{216,220},{216,120},
          {228,120}},                                                                      color={0,0,127}));
  connect(disFloHea.PPum,mulSum3.u[1])
    annotation (Line(points={{-199,-188},{220,-188},{220,81},{228,81}},    color={0,0,127}));
  connect(disFloCoo.PPum,mulSum3.u[2])
    annotation (Line(points={{-139,-228},{222,-228},{222,79},{228,79}},color={0,0,127}));
  connect(maxTSet.y,terUni.TSetCoo)
    annotation (Line(points={{-258,220},{-200,220},{-200,14},{-141,14}},color={0,0,127}));
  connect(minTSet.y,terUni.TSetHea)
    annotation (Line(points={{-258,260},{-180,260},{-180,16},{-141,16}},color={0,0,127}));
  connect(disFloHea.QActTot_flow, mulQHea_flow.u) annotation (Line(points={{-199,-186},{212,-186},{212,280},{268,280}},
                                                 color={0,0,127}));
  connect(mulSum3.y, mulPPum.u)
    annotation (Line(points={{252,80},{268,80}}, color={0,0,127}));
  connect(mulSum.y, mulPFan.u)
    annotation (Line(points={{252,120},{268,120}}, color={0,0,127}));
  connect(disFloCoo.QActTot_flow, mulQCoo_flow.u) annotation (Line(points={{
          -139,-226},{218,-226},{218,240},{268,240}}, color={0,0,127}));
  connect(mulHeaWatInl[1].port_b, disFloHea.port_a)
    annotation (Line(points={{-260,-60},{-240,-60},{-240,-180},{-220,-180}}, color={0,127,255}));
  connect(disFloHea.port_b, mulHeaWatOut[1].port_a)
    annotation (Line(points={{-200,-180},{240,-180},{240,-60},{260,-60}}, color={0,127,255}));
  connect(mulChiWatInl[1].port_b, disFloCoo.port_a)
    annotation (Line(points={{-260,-260},{-240,-260},{-240,-220},{-160,-220}}, color={0,127,255}));
  connect(disFloCoo.port_b, mulChiWatOut[1].port_a)
    annotation (Line(points={{-140,-220},{240,-220},{240,-260},{260,-260},{260,-260}}, color={0,127,255}));
  connect(terUni.port_bLoa, zon.ports[1])
    annotation (Line(points={{-140,20},{-160,20},{-160,40},{0,40},{0,-40},{38,-40},{38,-29.1}}, color={0,127,255}));
  connect(zon.ports[2], terUni.port_aLoa)
    annotation (Line(points={{42,-29.1},{42,-40},{80,-40},{80,20},{-116,20}},     color={0,127,255}));
  connect(multiplex3_1.y, zon.qGai_flow) annotation (Line(points={{1,100},{10,100},{10,0},{18,0}}, color={0,0,127}));
  connect(zon.TAir, terUni.TSen)
    annotation (Line(points={{61,8},{70,8},{70,30},{-152,30},{-152,12},{-141,12}}, color={0,0,127}));
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
end BuildingSpawnRefMediumOffice;
