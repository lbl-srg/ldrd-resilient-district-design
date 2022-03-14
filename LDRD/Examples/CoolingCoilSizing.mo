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
    annotation (Placement(transformation(extent={{-10,90},{10,112}})));

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
    redeclare final package Medium =MediumW, nPorts=4)
    "Boundary condition" annotation (Placement(
        transformation(
        extent={{10,-10},{-10,10}},
        rotation=180,
        origin={-70,18})));
  Buildings.Fluid.Sources.MassFlowSource_T bouWat(
    redeclare final package Medium = MediumW,
    m_flow=datVAV.mLiqCooCoi_flow,
    T=datVAV.TLiqEntCooCoi,
    nPorts=1) "Boundary condition" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=180,
        origin={70,20})));

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
        origin={-70,58})));
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
    annotation (Placement(transformation(extent={{10,34},{-10,14}})));
  Buildings.Fluid.Sources.Boundary_pT bouAir1(redeclare final package Medium =
        MediumA, nPorts=4) "Boundary condition" annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=180,
        origin={70,58})));

  Buildings.Fluid.Sensors.RelativeHumidityTwoPort relHumIn(
    redeclare package Medium = MediumA,
    m_flow_nominal=datVAV.mAirCooCoi_flow) "Inlet relative humidity"
    annotation (Placement(transformation(extent={{-50,48},{-30,68}})));
  Buildings.Fluid.HeatExchangers.WetCoilEffectivenessNTU cooCoi1(
    use_Q_flow_nominal=false,
    UA_nominal=44000,
    show_T=true,
    redeclare package Medium1 = MediumW,
    redeclare package Medium2 = MediumA,
    final m1_flow_nominal=0.28*datVAV.mLiqCooCoi_flow,
    final m2_flow_nominal=datVAV.mAirCooCoi_flow,
    final dp1_nominal=0,
    final dp2_nominal=0,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial)
    "Cooling coil"
    annotation (Placement(transformation(extent={{10,-12},{-10,-32}})));
  Buildings.Fluid.Sources.MassFlowSource_T bouAir2(
    redeclare final package Medium = MediumA,
    X={datVAV.wAirEntCooCoi/(1 + datVAV.wAirEntCooCoi),1 - datVAV.wAirEntCooCoi/
        (1 + datVAV.wAirEntCooCoi)},
    m_flow=datVAV.mAirCooCoi_flow,
    T=datVAV.TAirEntCooCoi,
    nPorts=1)
    "Boundary condition"
    annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=180,
        origin={-70,-16})));
  Buildings.Fluid.Sources.MassFlowSource_T bouWat2(
    redeclare final package Medium = MediumW,
    m_flow=cooCoi1.m1_flow_nominal,
    T=datVAV.TLiqEntCooCoi,
    nPorts=1) "Boundary condition" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=180,
        origin={70,-36})));
  Buildings.Fluid.HeatExchangers.WetCoilEffectivenessNTU cooCoi2(
    use_Q_flow_nominal=false,
    UA_nominal=38500,
    show_T=true,
    redeclare package Medium1 = MediumW,
    redeclare package Medium2 = MediumA,
    final m1_flow_nominal=0.35*datVAV.mLiqCooCoi_flow,
    final m2_flow_nominal=datVAV.mAirCooCoi_flow,
    final dp1_nominal=0,
    final dp2_nominal=0,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial)
    "Cooling coil"
    annotation (Placement(transformation(extent={{10,-54},{-10,-74}})));
  Buildings.Fluid.Sources.MassFlowSource_T bouAir3(
    redeclare final package Medium = MediumA,
    X={datVAV.wAirEntCooCoi/(1 + datVAV.wAirEntCooCoi),1 - datVAV.wAirEntCooCoi
        /(1 + datVAV.wAirEntCooCoi)},
    m_flow=datVAV.mAirCooCoi_flow,
    T=datVAV.TAirEntCooCoi,
    nPorts=1)
    "Boundary condition"
    annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=180,
        origin={-70,-58})));
  Buildings.Fluid.Sources.MassFlowSource_T bouWat3(
    redeclare final package Medium = MediumW,
    m_flow=cooCoi2.m1_flow_nominal,
    T=datVAV.TLiqEntCooCoi,
    nPorts=1) "Boundary condition" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=180,
        origin={70,-78})));
  Buildings.Fluid.HeatExchangers.WetCoilEffectivenessNTU cooCoi3(
    use_Q_flow_nominal=false,
    UA_nominal=33000,
    show_T=true,
    redeclare package Medium1 = MediumW,
    redeclare package Medium2 = MediumA,
    final m1_flow_nominal=0.45*datVAV.mLiqCooCoi_flow,
    final m2_flow_nominal=datVAV.mAirCooCoi_flow,
    final dp1_nominal=0,
    final dp2_nominal=0,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial)
    "Cooling coil"
    annotation (Placement(transformation(extent={{10,-94},{-10,-114}})));
  Buildings.Fluid.Sources.MassFlowSource_T bouAir4(
    redeclare final package Medium = MediumA,
    X={datVAV.wAirEntCooCoi/(1 + datVAV.wAirEntCooCoi),1 - datVAV.wAirEntCooCoi
        /(1 + datVAV.wAirEntCooCoi)},
    m_flow=datVAV.mAirCooCoi_flow,
    T=datVAV.TAirEntCooCoi,
    nPorts=1)
    "Boundary condition"
    annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=180,
        origin={-70,-98})));
  Buildings.Fluid.Sources.MassFlowSource_T bouWat4(
    redeclare final package Medium = MediumW,
    m_flow=cooCoi3.m1_flow_nominal,
    T=datVAV.TLiqEntCooCoi,
    nPorts=1) "Boundary condition" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=180,
        origin={70,-110})));
equation
  connect(bouWat.ports[1], cooCoi.port_a1)
    annotation (Line(points={{60,20},{36,20},{36,18},{10,18}},
                                                 color={0,127,255}));
  connect(cooCoi.port_b1, bouWat1.ports[1])
    annotation (Line(points={{-10,18},{-36,18},{-36,19.5},{-60,19.5}},
                                                   color={0,127,255}));
  connect(bouAir1.ports[1], cooCoi.port_b2) annotation (Line(points={{60,59.5},
          {20,59.5},{20,30},{10,30}},
                                color={0,127,255}));
  connect(bouAir.ports[1], relHumIn.port_a)
    annotation (Line(points={{-60,58},{-50,58}}, color={0,127,255}));
  connect(relHumIn.port_b, cooCoi.port_a2) annotation (Line(points={{-30,58},{
          -20,58},{-20,30},{-10,30}},
                                  color={0,127,255}));
  connect(bouAir2.ports[1], cooCoi1.port_a2)
    annotation (Line(points={{-60,-16},{-10,-16}}, color={0,127,255}));
  connect(cooCoi1.port_b2, bouAir1.ports[2]) annotation (Line(points={{10,-16},
          {22,-16},{22,58.5},{60,58.5}},
                                    color={0,127,255}));
  connect(bouWat2.ports[1], cooCoi1.port_a1) annotation (Line(points={{60,-36},
          {20,-36},{20,-28},{10,-28}},color={0,127,255}));
  connect(cooCoi1.port_b1, bouWat1.ports[2]) annotation (Line(points={{-10,-28},
          {-40,-28},{-40,18.5},{-60,18.5}},
                                          color={0,127,255}));
  connect(bouAir3.ports[1],cooCoi2. port_a2)
    annotation (Line(points={{-60,-58},{-10,-58}}, color={0,127,255}));
  connect(bouWat3.ports[1],cooCoi2. port_a1) annotation (Line(points={{60,-78},
          {20,-78},{20,-70},{10,-70}},color={0,127,255}));
  connect(bouAir4.ports[1],cooCoi3. port_a2)
    annotation (Line(points={{-60,-98},{-10,-98}}, color={0,127,255}));
  connect(bouWat4.ports[1],cooCoi3. port_a1) annotation (Line(points={{60,-110},
          {10,-110}},                 color={0,127,255}));
  connect(cooCoi2.port_b1, bouWat1.ports[3]) annotation (Line(points={{-10,-70},
          {-22,-70},{-22,-28},{-40,-28},{-40,17.5},{-60,17.5}},
                                                            color={0,127,255}));
  connect(cooCoi3.port_b1, bouWat1.ports[4]) annotation (Line(points={{-10,-110},
          {-22,-110},{-22,-28},{-40,-28},{-40,16.5},{-60,16.5}},
                                                             color={0,127,255}));
  connect(cooCoi2.port_b2, bouAir1.ports[3]) annotation (Line(points={{10,-58},
          {38,-58},{38,57.5},{60,57.5}},
                                     color={0,127,255}));
  connect(cooCoi3.port_b2, bouAir1.ports[4]) annotation (Line(points={{10,-98},
          {24,-98},{24,-58},{38,-58},{38,56.5},{60,56.5}},
                                                       color={0,127,255}));
  annotation (
    Diagram(
        coordinateSystem(preserveAspectRatio=false, extent={{-100,-160},{100,
            140}})),
    experiment(StopTime=10000, __Dymola_Algorithm="Cvode"));
end CoolingCoilSizing;
