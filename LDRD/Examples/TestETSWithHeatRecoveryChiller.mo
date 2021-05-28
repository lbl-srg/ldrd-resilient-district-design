within LDRD.Examples;
model TestETSWithHeatRecoveryChiller
  "Validation of the ETS model with heat recovery chiller and optional borefield"
  extends Modelica.Icons.Example;
  package Medium=Buildings.Media.Water
    "Medium model";
  replaceable Loads.BuildingSpawnWithETS bui(
    redeclare package MediumSer = Medium,
    redeclare package MediumBui = Medium)
    "ETS" annotation (Placement(transformation(extent={{-28,-30},{32,30}})));
  Buildings.Fluid.Sources.Boundary_pT disWat(
    redeclare package Medium = Medium,
    use_T_in=true,
    nPorts=2) "District water boundary conditions" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-120,-140})));
  Modelica.Blocks.Sources.CombiTimeTable TDisWatSup(
    tableName="tab1",
    table=[
      0,11;
      49,11;
      50,20;
      100,20],
    extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
    timeScale=3600,
    offset={273.15},
    columns={2},
    smoothness=Modelica.Blocks.Types.Smoothness.MonotoneContinuousDerivative1)
    "District water supply temperature"
    annotation (Placement(transformation(extent={{-330,-150},{-310,-130}})));
  Buildings.Fluid.Sensors.TemperatureTwoPort senTDisWatSup(
    redeclare final package Medium = Medium,
    final m_flow_nominal=bui.ets.hex.m1_flow_nominal) "District water supply temperature"
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-80,0})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant THeaWatSupMinSet(
    k=28 + 273.15)
    "Heating water supply temperature set point - Minimum value"
    annotation (Placement(transformation(extent={{-180,70},{-160,90}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant THeaWatSupMaxSet(
    k=bui.THeaWatSup_nominal)
    "Heating water supply temperature set point - Maximum value"
    annotation (Placement(transformation(extent={{-150,50},{-130,70}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant TChiWatSupSet(
    k=bui.TChiWatSup_nominal)
    "Chilled water supply temperature set point" annotation (Placement(transformation(extent={{-120,30},{-100,50}})));
equation
  connect(TDisWatSup.y[1],disWat.T_in)
    annotation (Line(points={{-309,-140},{-144,-140},{-144,-136},{-132,-136}},color={0,0,127}));
  connect(disWat.ports[1],senTDisWatSup.port_a)
    annotation (Line(points={{-110,-138},{-100,-138},{-100,0},{-90,0}},
                                                               color={0,127,255}));
  connect(senTDisWatSup.port_b, bui.port_aSerAmb) annotation (Line(points={{-70,0},{-28,0}}, color={0,127,255}));
  connect(TChiWatSupSet.y, bui.TChiWatSupSet)
    annotation (Line(points={{-98,40},{-60,40},{-60,15},{-34,15}}, color={0,0,127}));
  connect(THeaWatSupMaxSet.y, bui.THeaWatSupMaxSet)
    annotation (Line(points={{-128,60},{-52,60},{-52,21},{-34,21}}, color={0,0,127}));
  connect(THeaWatSupMinSet.y, bui.THeaWatSupMinSet)
    annotation (Line(points={{-158,80},{-40,80},{-40,27},{-34,27}}, color={0,0,127}));
  connect(bui.port_bSerAmb, disWat.ports[2])
    annotation (Line(points={{32,0},{60,0},{60,-160},{-100,-160},{-100,-142},{-110,-142}}, color={0,127,255}));
  annotation (
    Diagram(
      coordinateSystem(
        preserveAspectRatio=false,
        extent={{-340,-220},{340,220}})),
    Documentation(
      revisions="<html>
<ul>
<li>
July 31, 2020, by Antoine Gautier:<br/>
First implementation.
</li>
</ul>
</html>",
      info="<html>
<p>
This is a partial model used as a base class to construct the
validation and example models.
</p>
<ul>
<li>
The building distribution pumps are variable speed and the flow rate
is considered to vary linearly with the load (with no inferior limit).
</li>
<li>
The Boolean enable signals for heating and cooling typically provided
by the building automation system are here computed based on the condition
that the load is greater than 1% of the nominal load.
</li>
<li>
Simplified chiller performance data are used, which represent a linear
variation of the EIR and the capacity with the evaporator outlet temperature
and the condenser inlet temperature (no variation of the EIR at part
load is considered).
</li>
</ul>
</html>"));
end TestETSWithHeatRecoveryChiller;
