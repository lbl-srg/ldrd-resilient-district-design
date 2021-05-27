within LDRD.Examples;
model DebugRefMed
  extends Modelica.Icons.Example;
  package Medium = Buildings.Media.Water "Medium model";

  Buildings.Fluid.Sources.Boundary_pT bou1(redeclare final package Medium = Medium, nPorts=2)
    "Boundary pressure condition representing the expansion vessel"
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=180,
        origin={72,0})));
  Loads.BaseClasses.BuildingSpawnRefMediumOffice buildingSpawnRefMediumOffice(
    nPorts_bHeaWat=1,
    nPorts_bChiWat=1,
    nPorts_aHeaWat=1,
    nPorts_aChiWat=1) annotation (Placement(transformation(extent={{-30,-20},{30,40}})));
  Buildings.Fluid.Sources.Boundary_pT bou2(
    redeclare final package Medium = Medium,
    T=323.15,
    nPorts=1)
    "Boundary pressure condition representing the expansion vessel"
    annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=180,
        origin={-70,20})));
  Buildings.Fluid.Sources.Boundary_pT bou3(
    redeclare final package Medium = Medium,
    T=280.15,
    nPorts=1)
    "Boundary pressure condition representing the expansion vessel"
    annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=180,
        origin={-70,-20})));
equation
  connect(buildingSpawnRefMediumOffice.ports_bHeaWat[1], bou1.ports[1])
    annotation (Line(points={{30,4},{54,4},{54,-2},{62,-2}}, color={0,127,255}));
  connect(buildingSpawnRefMediumOffice.ports_bChiWat[1], bou1.ports[2])
    annotation (Line(points={{30,-8},{52,-8},{52,2},{62,2}}, color={0,127,255}));
  connect(bou2.ports[1], buildingSpawnRefMediumOffice.ports_aHeaWat[1])
    annotation (Line(points={{-60,20},{-36,20},{-36,4},{-30,4}}, color={0,127,255}));
  connect(bou3.ports[1], buildingSpawnRefMediumOffice.ports_aChiWat[1])
    annotation (Line(points={{-60,-20},{-36,-20},{-36,-8},{-30,-8}}, color={0,127,255}));
  annotation (
  Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},{100,100}})), Icon(coordinateSystem(extent={{-100,
            -100},{80,100}})));
end DebugRefMed;