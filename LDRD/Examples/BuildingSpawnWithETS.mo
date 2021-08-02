within LDRD.Examples;
model BuildingSpawnWithETS
  extends Modelica.Icons.Example;
  package Medium = Buildings.Media.Water "Medium model";

  Loads.BuildingSpawnWithETS bui(
    bui(facMul=10))
    "Building with ETS"
    annotation (Placement(transformation(extent={{-30,-30},{30,30}})));
  Buildings.Fluid.Sources.Boundary_pT bou3(
    redeclare final package Medium = Medium,
    p=Medium.p_default + 2*max(bui.ets.dp1Hex_nominal, bui.ets.dp1WSE_nominal),
    T=289.15,
    nPorts=1)
    "Boundary pressure condition representing the expansion vessel"
    annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=180,
        origin={-70,0})));

  Buildings.Fluid.Sources.Boundary_pT bou1(redeclare final package Medium = Medium, nPorts=1)
    "Boundary pressure condition representing the expansion vessel"
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=180,
        origin={70,0})));
  Buildings.Controls.OBC.CDL.Logical.Sources.TimeTable uEnaChi(table=[0,1;
        17020800,0; 17625600,1], period=31622400.0)
    "Enable chiller compressor"
    annotation (Placement(transformation(extent={{-80,30},{-60,50}})));
equation
  connect(bou3.ports[1], bui.port_aSerAmb) annotation (Line(points={{-60,-4.44089e-16},{-30,0}}, color={0,127,255}));
  connect(bui.port_bSerAmb, bou1.ports[1]) annotation (Line(points={{30,0},{60,6.66134e-16}}, color={0,127,255}));
  connect(uEnaChi.y[1], bui.uEnaChi) annotation (Line(points={{-58,40},{-40,40},
          {-40,18},{-36,18}}, color={255,0,255}));
  annotation (
  Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},{100,100}}),
        graphics={Text(
          extent={{-66,-52},{60,-74}},
          lineColor={28,108,200},
          textString="Resilience week
{'start': 17020800.0, 'end': 17625600.0}")}),                                           Icon(coordinateSystem(extent={{-100,
            -100},{80,100}})),
  experiment(
      StartTime=16520800,
      StopTime=17625600,
      Tolerance=1e-06,
      __Dymola_Algorithm="Cvode"));
end BuildingSpawnWithETS;
