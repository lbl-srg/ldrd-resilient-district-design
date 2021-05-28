within LDRD.Loads.BaseClasses;
model BuildingSpawnRefMed1 "Spawn building model"
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
  parameter Integer nZon=1
    "Number of conditioned thermal zones";
  parameter String idfName=
    "modelica://LDRD/Resources/EnergyPlus/RefBldgMediumOfficeNew2004_v1.4_7.2_5A_USA_IL_CHICAGO-OHARE.idf"
    "Name of the IDF file";
  parameter String weaName=
    "modelica://Buildings/Resources/weatherdata/USA_IL_Chicago-OHare.Intl.AP.725300_TMY3.mos"
    "Name of the weather file";

  Buildings.ThermalZones.EnergyPlus.ThermalZone zon(
    redeclare package Medium = Medium2,
    zoneName="Core_bottom",
    nPorts=2) "Thermal zone" annotation (Placement(transformation(extent={{24,42},{64,82}})));

  parameter Real facMulTerUni[nZon]={5}
    "Multiplier factor for terminal units";
  parameter Modelica.SIunits.MassFlowRate mLoa_flow_nominal[nZon]=fill(
    1,
    nZon)
    "Load side mass flow rate at nominal conditions (single terminal unit)"
    annotation (Dialog(group="Nominal condition"));
  parameter Modelica.SIunits.HeatFlowRate QHea_flow_nominal[nZon]=
    {4032} ./ facMulTerUni
    "Design heating heat flow rate (single terminal unit)"
    annotation (Dialog(group="Nominal condition"));
  parameter Modelica.SIunits.HeatFlowRate QCoo_flow_nominal[nZon]=
    {-28300} ./ facMulTerUni
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
  Modelica.Blocks.Sources.Constant qConGai_flow(
    k=0)
    "Convective heat gain"
    annotation (Placement(transformation(extent={{-60,104},{-40,124}})));
  Modelica.Blocks.Sources.Constant qRadGai_flow(
    k=0)
    "Radiative heat gain"
    annotation (Placement(transformation(extent={{-60,144},{-40,164}})));
  Modelica.Blocks.Routing.Multiplex3 multiplex3_1
    annotation (Placement(transformation(extent={{-20,104},{0,124}})));
  Modelica.Blocks.Sources.Constant qLatGai_flow(
    k=0)
    "Latent heat gain"
    annotation (Placement(transformation(extent={{-60,64},{-40,84}})));

  inner Buildings.ThermalZones.EnergyPlus.Building building(
    idfName=Modelica.Utilities.Files.loadResource(
      idfName),
    weaName=Modelica.Utilities.Files.loadResource(
      weaName),
    logLevel=Buildings.ThermalZones.EnergyPlus.Types.LogLevels.Debug)
    "Building outer component"
    annotation (Placement(transformation(extent={{30,138},{52,158}})));
  Buildings.Controls.OBC.CDL.Continuous.MultiSum mulSum(
    final nin=nZon)
    annotation (Placement(transformation(extent={{230,110},{250,130}})));
  Buildings.Controls.OBC.CDL.Continuous.MultiSum mulSum3
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
    final mLoaCoo_flow_nominal=mLoa_flow_nominal)
    "Terminal unit"
    annotation (Placement(transformation(extent={{-140,-2},{-116,22}})));
  Buildings.Fluid.Movers.FlowControlled_m_flow pum(
    redeclare final package Medium = Medium,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    m_flow_nominal=1,
    addPowerToMedium=false,
    nominalValuesDefineDefaultPressureCurve=true,
    dp_nominal=10000)
    annotation (Placement(transformation(extent={{-230,-70},{-210,-50}})));
  Buildings.Fluid.Movers.FlowControlled_m_flow pum1(
    redeclare final package Medium = Medium,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    m_flow_nominal=1,
    addPowerToMedium=false,
    nominalValuesDefineDefaultPressureCurve=true,
    dp_nominal=30000)
    annotation (Placement(transformation(extent={{-230,-270},{-210,-250}})));
  Buildings.Fluid.FixedResistances.PressureDrop res(
    redeclare final package Medium = Medium,
    m_flow_nominal=1, dp_nominal=10000)
    annotation (Placement(transformation(extent={{0,-70},{20,-50}})));
  Buildings.Fluid.FixedResistances.PressureDrop res1(
    redeclare final package Medium = Medium,
    m_flow_nominal=1, dp_nominal=10000)
    annotation (Placement(transformation(extent={{0,-270},{20,-250}})));
equation
  connect(qRadGai_flow.y,multiplex3_1.u1[1])
    annotation (Line(points={{-39,154},{-26,154},{-26,121},{-22,121}},color={0,0,127},smooth=Smooth.None));
  connect(qConGai_flow.y,multiplex3_1.u2[1])
    annotation (Line(points={{-39,114},{-22,114}},color={0,0,127},smooth=Smooth.None));
  connect(multiplex3_1.u3[1],qLatGai_flow.y)
    annotation (Line(points={{-22,107},{-26,107},{-26,74},{-39,74}},  color={0,0,127}));
  connect(multiplex3_1.y, zon.qGai_flow) annotation (Line(points={{1,114},{12,114},{12,72},{22,72}}, color={0,0,127}));
  connect(zon.ports[1], terUni[1].port_aLoa)
    annotation (Line(points={{42,42.9},{-8,42.9},{-8,20},{-116,20}}, color={0,127,255}));
  connect(terUni[1].port_bLoa, zon.ports[2])
    annotation (Line(points={{-140,20},{-20,20},{-20,42.9},{46,42.9}}, color={0,127,255}));
  connect(terUni.PFan,mulSum.u)
    annotation (Line(points={{-115,10},{-100,10},{-100,220},{216,220},{216,120},
          {228,120}},                                                                      color={0,0,127}));
  connect(zon.TAir, terUni[1].TSen)
    annotation (Line(points={{65,80},{80,80},{80,198},{-152,198},{-152,12},{-141,12}}, color={0,0,127}));
  connect(maxTSet.y,terUni.TSetCoo)
    annotation (Line(points={{-258,220},{-200,220},{-200,14},{-141,14}},color={0,0,127}));
  connect(minTSet.y,terUni.TSetHea)
    annotation (Line(points={{-258,260},{-180,260},{-180,16},{-141,16}},color={0,0,127}));
  connect(mulSum3.y, mulPPum.u)
    annotation (Line(points={{252,80},{268,80}}, color={0,0,127}));
  connect(mulSum.y, mulPFan.u)
    annotation (Line(points={{252,120},{268,120}}, color={0,0,127}));
  connect(mulHeaWatInl[1].port_b, pum.port_a) annotation (Line(points={{-260,-60},{-230,-60}}, color={0,127,255}));
  connect(pum.port_b, terUni[1].port_aHeaWat)
    annotation (Line(points={{-210,-60},{-160,-60},{-160,2},{-140,2},{-140,0}}, color={0,127,255}));
  connect(terUni[1].mReqHeaWat_flow, pum.m_flow_in)
    annotation (Line(points={{-115,6},{-100,6},{-100,-20},{-220,-20},{-220,-48}},
                                                            color={0,0,127}));
  connect(mulChiWatInl[1].port_b, pum1.port_a) annotation (Line(points={{-260,-260},{-230,-260}}, color={0,127,255}));
  connect(pum1.port_b, terUni[1].port_aChiWat)
    annotation (Line(points={{-210,-260},{-180,-260},{-180,2},{-140,2}}, color={0,127,255}));
  connect(terUni[1].mReqChiWat_flow, pum1.m_flow_in)
    annotation (Line(points={{-115,4},{-80,4},{-80,-240},{-220,-240},{-220,-248}}, color={0,127,255}));
  connect(terUni[1].QActCoo_flow, mulQCoo_flow.u)
    annotation (Line(points={{-115,16},{180,16},{180,240},{268,240}}, color={0,127,255}));
  connect(terUni[1].QActHea_flow, mulQHea_flow.u)
    annotation (Line(points={{-115,18},{180,18},{180,280},{268,280}}, color={0,127,255}));
  connect(terUni[1].port_bHeaWat, res.port_a)
    annotation (Line(points={{-116,0},{-116,-60},{0,-60}}, color={0,127,255}));
  connect(res.port_b, mulHeaWatOut[1].port_a) annotation (Line(points={{20,-60},{260,-60}}, color={0,127,255}));
  connect(res1.port_b, mulChiWatOut[1].port_a) annotation (Line(points={{20,-260},{260,-260}}, color={0,127,255}));
  connect(terUni[1].port_bChiWat, res1.port_a)
    annotation (Line(points={{-116,2},{-60,2},{-60,-260},{0,-260}}, color={0,127,255}));
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
end BuildingSpawnRefMed1;
