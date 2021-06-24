within LDRD.Examples;
model DebugBuildingWithETS_coilDiscretized
  extends Modelica.Icons.Example;
  package Medium = Buildings.Media.Water "Medium model";

  Buildings.Fluid.Sources.Boundary_pT bou1(redeclare final package Medium = Medium, nPorts=1)
    "Boundary pressure condition representing the expansion vessel"
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=180,
        origin={70,-50})));
  Loads.BuildingSpawnWithETS_coilDiscretized bui annotation (Placement(transformation(extent={{-30,-70},{30,-10}})));
  Buildings.Fluid.Sources.Boundary_pT bou3(
    redeclare final package Medium = Medium,
    T=282.15,
    nPorts=1)
    "Boundary pressure condition representing the expansion vessel"
    annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=180,
        origin={-70,-50})));
  inner Data.VAVDataMediumOffice datVAV annotation (Placement(transformation(extent={{-10,64},{10,84}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant THeaWatSupMaxSet(k=50 + 273.15)
    "Heating water supply temperature set point - Maximum value"
    annotation (Placement(transformation(extent={{-90,10},{-70,30}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant TChiWatSupSet(k=7 + 273.15)
    "Chilled water supply temperature set point" annotation (Placement(transformation(extent={{-90,-30},{-70,-10}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant THeaWatSupMinSet(each k=28 + 273.15)
    "Heating water supply temperature set point - Minimum value"
    annotation (Placement(transformation(extent={{-90,50},{-70,70}})));
equation
  connect(bou3.ports[1], bui.port_aSerAmb)
    annotation (Line(points={{-60,-50},{-40,-50},{-40,-40},{-30,-40}}, color={0,127,255}));
  connect(bui.port_bSerAmb, bou1.ports[1])
    annotation (Line(points={{30,-40},{40,-40},{40,-50},{60,-50}}, color={0,127,255}));
  connect(TChiWatSupSet.y, bui.TChiWatSupSet)
    annotation (Line(points={{-68,-20},{-60,-20},{-60,-25},{-36,-25}}, color={0,0,127}));
  connect(THeaWatSupMaxSet.y, bui.THeaWatSupMaxSet)
    annotation (Line(points={{-68,20},{-50,20},{-50,-19},{-36,-19}}, color={0,0,127}));
  connect(THeaWatSupMinSet.y, bui.THeaWatSupMinSet)
    annotation (Line(points={{-68,60},{-40,60},{-40,-13},{-36,-13}}, color={0,0,127}));
  annotation (
  Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},{100,100}})), Icon(coordinateSystem(extent={{-100,
            -100},{80,100}})),
  experiment(
      StartTime=8000000,
      StopTime=9000000,
      Tolerance=1e-06,
      __Dymola_Algorithm="Cvode"));
end DebugBuildingWithETS_coilDiscretized;
