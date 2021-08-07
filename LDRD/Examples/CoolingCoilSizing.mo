within LDRD.Examples;
model CoolingCoilSizing
  extends Modelica.Icons.Example;
  package MediumA = Buildings.Media.Air
    "Medium model for air";
  package MediumW = Buildings.Media.Water
    "Medium model for chilled water";

  inner replaceable Data.VAVDataMediumOffice datVAV(
    final QCooCoi_flow=QCooCoi_flow,
    TLiqEntCooCoi=TChiWatSup_nominal,
    TLiqEntHeaCoi=THeaWatSup_nominal)
    "VAV system parameters"
    annotation (Placement(transformation(extent={{-10,52},{10,74}})));

  parameter Modelica.SIunits.Temperature TChiWatSup_nominal=7+273.15
    "Chilled water supply temperature"
    annotation(Dialog(group="ETS model parameters"));
  parameter Modelica.SIunits.Temperature THeaWatSup_nominal=50+273.15
    "Heating water supply temperature"
    annotation(Dialog(group="ETS model parameters"));

  parameter Modelica.SIunits.HeatFlowRate QCooCoi_flow=
    fraTotSen * QSenCooCoi_flow
    "Capacity (total)"
    annotation(Dialog(group="Cooling coil design parameters"));
  parameter Modelica.SIunits.HeatFlowRate QSenCooCoi_flow=
    datVAV.QSenCooCoi_flow
    "Sensible heat flow rate (used for verification)"
    annotation(Dialog(group="Cooling coil design parameters"));

  parameter Real fraTotSen = 1.27;

  Buildings.Fluid.Sources.Boundary_pT bouWat1(
    redeclare final package Medium =MediumW, nPorts=1)
    "Boundary condition" annotation (Placement(
        transformation(
        extent={{10,-10},{-10,10}},
        rotation=180,
        origin={-70,-20})));
  Buildings.Fluid.Sources.MassFlowSource_T bouWat(
    redeclare final package Medium = MediumW,
    m_flow=datVAV.mLiqCooCoi_flow,
    T=datVAV.TLiqEntCooCoi,
    nPorts=1) "Boundary condition" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=180,
        origin={70,-20})));

  Buildings.Fluid.Sources.MassFlowSource_T bouAir(
    redeclare final package Medium = MediumA,
    X={
      datVAV.wAirEntCooCoi/(1 + datVAV.wAirEntCooCoi),
      1 - datVAV.wAirEntCooCoi/(1 + datVAV.wAirEntCooCoi)},
    m_flow=datVAV.mAirCooCoi_flow,
    T=datVAV.TAirEntCooCoi,
    nPorts=1)
    "Boundary condition"
    annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=180,
        origin={-70,20})));
  replaceable Buildings.Fluid.HeatExchangers.WetCoilEffectivenessNTU cooCoi(
    use_Q_flow_nominal=true,
    Q_flow_nominal=datVAV.QCooCoi_flow,
    T_a1_nominal=datVAV.TLiqEntCooCoi,
    T_a2_nominal=datVAV.TAirEntCooCoi,
    w_a2_nominal=datVAV.wAirEntCooCoi)
    constrainedby Buildings.Fluid.HeatExchangers.WetCoilEffectivenessNTU(
      show_T=true,
      redeclare package Medium1 = MediumW,
      redeclare package Medium2 = MediumA,
      final m1_flow_nominal=datVAV.mLiqCooCoi_flow,
      final m2_flow_nominal=datVAV.mAirCooCoi_flow,
      final dp1_nominal=0,
      final dp2_nominal=0,
      energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial)
    "Cooling coil"
    annotation (Placement(transformation(extent={{10,-4},{-10,-24}})));
  Buildings.Fluid.Sources.Boundary_pT bouAir1(redeclare final package Medium =
        MediumA, nPorts=1) "Boundary condition" annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=180,
        origin={70,20})));

  Buildings.Fluid.Sensors.RelativeHumidityTwoPort relHumIn(
    redeclare package Medium = MediumA,
    m_flow_nominal=datVAV.mAirCooCoi_flow) "Inlet relative humidity"
    annotation (Placement(transformation(extent={{-50,10},{-30,30}})));
equation
  connect(bouWat.ports[1], cooCoi.port_a1)
    annotation (Line(points={{60,-20},{10,-20}}, color={0,127,255}));
  connect(cooCoi.port_b1, bouWat1.ports[1])
    annotation (Line(points={{-10,-20},{-60,-20}}, color={0,127,255}));
  connect(bouAir1.ports[1], cooCoi.port_b2) annotation (Line(points={{60,20},{20,
          20},{20,-8},{10,-8}}, color={0,127,255}));
  connect(bouAir.ports[1], relHumIn.port_a)
    annotation (Line(points={{-60,20},{-50,20}}, color={0,127,255}));
  connect(relHumIn.port_b, cooCoi.port_a2) annotation (Line(points={{-30,20},{-20,
          20},{-20,-8},{-10,-8}}, color={0,127,255}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false)),
    experiment(StopTime=10000, __Dymola_Algorithm="Cvode"));
end CoolingCoilSizing;
