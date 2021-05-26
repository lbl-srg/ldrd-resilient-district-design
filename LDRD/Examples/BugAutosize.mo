within LDRD.Examples;
model BugAutosize
  extends Modelica.Icons.Example;
  package Medium = Buildings.Media.Water "Medium model";

  Buildings.Fluid.Sources.Boundary_pT bou1(redeclare final package Medium = Medium, nPorts=2)
    "Boundary pressure condition representing the expansion vessel"
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=180,
        origin={50,0})));
  Buildings.Experimental.DHC.Examples.Combined.Generation5.Networks.BaseClasses.PipeStandard pipeStandard(
    redeclare final package Medium = Medium,
    m_flow_nominal=0.5,
    dh=0.034,
    length=100) annotation (Placement(transformation(extent={{-10,-50},{10,-30}})));
  Buildings.Fluid.Sources.MassFlowSource_T boundary1(
    redeclare final package Medium = Medium,
    m_flow=0.5,
    nPorts=1) annotation (Placement(transformation(extent={{-60,-50},{-40,-30}})));
  Buildings.Fluid.Sensors.RelativePressure senRelPre(redeclare final package Medium = Medium)
    annotation (Placement(transformation(extent={{-10,-90},{10,-70}})));
  Buildings.Fluid.Sources.MassFlowSource_T boundary2(
    redeclare final package Medium = Medium,
    m_flow=0.5,
    nPorts=1) annotation (Placement(transformation(extent={{-60,-10},{-40,10}})));
  Buildings.Experimental.DHC.Examples.Combined.Generation5.Networks.BaseClasses.PipeAutosize pipeAutosize(
    redeclare final package Medium = Medium,
    dh(start=0.2),
    m_flow_nominal=0.5,
    length=100) annotation (Placement(transformation(extent={{-10,-10},{10,10}})));
equation
  connect(boundary1.ports[1], pipeStandard.port_a) annotation (Line(points={{-40,-40},{-10,-40}}, color={0,127,255}));
  connect(pipeStandard.port_b, bou1.ports[1]) annotation (Line(points={{10,-40},{40,-40},{40,-2}}, color={0,127,255}));
  connect(pipeStandard.port_a, senRelPre.port_a)
    annotation (Line(points={{-10,-40},{-14,-40},{-14,-80},{-10,-80}}, color={0,127,255}));
  connect(pipeStandard.port_b, senRelPre.port_b)
    annotation (Line(points={{10,-40},{14,-40},{14,-80},{10,-80}}, color={0,127,255}));
  connect(boundary2.ports[1], pipeAutosize.port_a) annotation (Line(points={{-40,0},{-10,0}}, color={0,127,255}));
  connect(pipeAutosize.port_b, bou1.ports[2]) annotation (Line(points={{10,0},{40,2}}, color={0,127,255}));
  annotation (
  Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},{100,100}})), Icon(coordinateSystem(extent={{-100,
            -100},{80,100}})));
end BugAutosize;
