within LDRD.CentralPlants;
model CoolingTowers "Cooling towers"
  extends Buildings.Experimental.DHC.CentralPlants.BaseClasses.PartialPlant(
    final typ=Buildings.Experimental.DHC.Types.DistrictSystemType.CombinedGeneration5,
    final have_fan=true,
    final have_pum=true,
    final have_eleHea=false,
    final nFue=0,
    final have_eleCoo=false,
    final have_weaBus=true,
    allowFlowReversal=false);
  final parameter Boolean isCooTow=true
    "Set to true for cooling towers, false for dry coolers"
    annotation(Dialog(group = "Configuration"));
  parameter Modelica.SIunits.MassFlowRate m_flow_nominal
    "Nominal mass flow rate"
    annotation(Dialog(group = "Nominal condition"));
  parameter Modelica.SIunits.PressureDifference dp_nominal=90000
    "Tower nominal pressure drop (modified on 2/3/22: 3E4 before)"
    annotation(Dialog(group = "Nominal condition"));
  parameter Modelica.SIunits.PressureDifference dpHeaExc_nominal=40000
    "HX nominal pressure drop (primary = secondary)"
    annotation(Dialog(group = "Nominal condition"));
  parameter Modelica.SIunits.TemperatureDifference TLvgMin = 9 + 273.15
    "Minimum leaving temperature";
  parameter Modelica.SIunits.TemperatureDifference TEntMax = 12 + 273.15
    "Entering temperature for maximum fan speed";
  parameter Modelica.SIunits.TemperatureDifference dTApp_nominal = 4
    "Approach of cooling tower"
    annotation (Dialog(group="Nominal condition"));
  parameter Modelica.SIunits.TemperatureDifference dTAppHeaExc_nominal = 2
    "Approach of intermediary HX"
    annotation (Dialog(group="Nominal condition"));
  parameter Modelica.SIunits.TemperatureDifference dTRan_nominal=
     4
    "Design range temperature (water in - water out)"
    annotation (Dialog(group="Nominal condition"));
  parameter Real fraPFan_nominal(unit="W/(kg/s)")=150
    "Fan power divided by water mass flow rate at design condition"
    annotation(Dialog(group="Fan"));

  Buildings.Fluid.HeatExchangers.CoolingTowers.YorkCalc coo(
    redeclare final package Medium = Medium,
    final m_flow_nominal=m_flow_nominal,
    show_T=true,
    final dp_nominal=dp_nominal + dpHeaExc_nominal,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    TAirInWB_nominal=285.15,
    final TApp_nominal=dTApp_nominal,
    final TRan_nominal=dTRan_nominal,
    final fraPFan_nominal=fraPFan_nominal,
    yMin=0.1) "Cooler"
    annotation (Placement(transformation(extent={{-30,30},{-10,50}})));
  Buildings.Experimental.DHC.EnergyTransferStations.BaseClasses.Pump_m_flow pum(
    redeclare final package Medium = Medium,
    final m_flow_nominal=m_flow_nominal,
    final dp_nominal=dp_nominal + dpHeaExc_nominal) "Pump"
    annotation (
     Placement(transformation(
        extent={{10,10},{-10,-10}},
        rotation=180,
        origin={60,40})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput m_flow(final unit="kg/s")
    "Mass flow rate in main line" annotation (Placement(transformation(
        extent={{-20,-20},{20,20}},
        rotation=0,
        origin={-320,180}), iconTransformation(
        extent={{-40,-40},{40,40}},
        rotation=0,
        origin={-340,260})));
  replaceable Controls.CoolingTowers con(
    final m_flow_nominal=m_flow_nominal,
    final dTApp_nominal=dTApp_nominal + dTAppHeaExc_nominal,
    final fraFreCon=coo.fraFreCon,
    final TLvgMin=TLvgMin,
    final TEntMax=TEntMax) "Controller"
    annotation (Placement(transformation(extent={{-70,80},{-50,100}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TDisWatLvg(final unit="K",
      displayUnit="degC") "District water leaving temperature" annotation (
      Placement(transformation(extent={{-340,80},{-300,120}}),
        iconTransformation(extent={{-380,100},{-300,180}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput m_flowBorFieMin(final unit=
        "kg/s") if have_pum
    "Minimum mass flow rate through borefield if integrated" annotation (
      Placement(transformation(extent={{300,60},{340,100}}), iconTransformation(
          extent={{300,-200},{380,-120}})));
  Buildings.Controls.OBC.CDL.Continuous.Max maxMasFlow
    "Compute maximum mass flow between main loop and cooler loop"
    annotation (Placement(transformation(extent={{220,70},{240,90}})));
  Buildings.Controls.OBC.CDL.Logical.Switch swi
    "Select evaporative or dry cooling"
    annotation (Placement(transformation(extent={{-140,210},{-120,230}})));
  Buildings.Controls.OBC.CDL.Logical.Sources.Constant con1(k=isCooTow)
    "Select evaporative or dry cooling parameter"
    annotation (Placement(transformation(extent={{-200,210},{-180,230}})));
  Buildings.Fluid.HeatExchangers.PlateHeatExchangerEffectivenessNTU hex(
    redeclare final package Medium1 = Medium,
    redeclare final package Medium2 = Medium,
    final m1_flow_nominal=m_flow_nominal,
    final m2_flow_nominal=m_flow_nominal,
    show_T=true,
    final dp1_nominal=dpHeaExc_nominal,
    final dp2_nominal=0,
    final use_Q_flow_nominal=true,
    final T_a1_nominal=TEntMax,
    final T_a2_nominal=TEntMax - dTAppHeaExc_nominal - dTRan_nominal,
    final Q_flow_nominal=dTRan_nominal*m_flow_nominal*4186,
    configuration=Buildings.Fluid.Types.HeatExchangerConfiguration.CounterFlow)
    "Intermediary HX for cooling towers"
    annotation (Placement(transformation(extent={{-10,16},{10,-4}})));
  Buildings.Experimental.DHC.EnergyTransferStations.BaseClasses.Pump_m_flow pumPri(
    redeclare final package Medium = Medium,
    final m_flow_nominal=m_flow_nominal,
    final dp_nominal=dpHeaExc_nominal)
    "Primary pump"
    annotation (Placement(
        transformation(
        extent={{10,10},{-10,-10}},
        rotation=180,
        origin={120,0})));
  Buildings.Controls.OBC.CDL.Continuous.Add sumPPum(k1=1, k2=1) "Sum"
    annotation (Placement(transformation(extent={{262,150},{282,170}})));
  Buildings.Fluid.Sources.Boundary_pT bou(
    redeclare final package Medium = Medium,
    nPorts=1) annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={40,70})));
  Buildings.Fluid.Sensors.TemperatureTwoPort TWatLvgTow(redeclare final package
      Medium = Medium, final m_flow_nominal=m_flow_nominal)
    "Water leaving temperature"
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={10,40})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TDisWatEnt(final unit="K",
      displayUnit="degC") "District water entering temperature" annotation (
      Placement(transformation(extent={{-340,120},{-300,160}}),
        iconTransformation(extent={{-380,164},{-300,244}})));
equation
  connect(con.yPumMasFlo, pum.m_flow_in)
    annotation (Line(points={{-48,95},{60,95},{60,52}},   color={0,0,127}));
  connect(con.yFan, coo.y) annotation (Line(points={{-48,85},{-40,85},{-40,48},
          {-32,48}},color={0,0,127}));
  connect(m_flow, con.m_flow) annotation (Line(points={{-320,180},{-100,180},{-100,
          96},{-72,96}}, color={0,0,127}));
  connect(TDisWatLvg, con.TDisWatLvg) annotation (Line(points={{-320,100},{-120,
          100},{-120,84},{-72,84}}, color={0,0,127}));
  connect(coo.PFan, PFan) annotation (Line(points={{-9,48},{0,48},{0,200},{320,
          200}}, color={0,0,127}));
  connect(maxMasFlow.y, m_flowBorFieMin)
    annotation (Line(points={{242,80},{320,80}}, color={0,0,127}));
  connect(pum.m_flow_actual, maxMasFlow.u2) annotation (Line(points={{71,45},{
          200,45},{200,74},{218,74}}, color={0,0,127}));
  connect(m_flow, maxMasFlow.u1) annotation (Line(points={{-320,180},{200,180},
          {200,86},{218,86}}, color={0,0,127}));
  connect(con1.y, swi.u2)
    annotation (Line(points={{-178,220},{-142,220}}, color={255,0,255}));
  connect(weaBus.TWetBul, swi.u1) annotation (Line(
      points={{1,266},{1,260},{-160,260},{-160,228},{-142,228}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));
  connect(weaBus.TDryBul, swi.u3) annotation (Line(
      points={{1,266},{1,260},{-160,260},{-160,212},{-142,212}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(swi.y, con.TAir) annotation (Line(points={{-118,220},{-80,220},{-80,
          93},{-72,93}}, color={0,0,127}));
  connect(swi.y, coo.TAir) annotation (Line(points={{-118,220},{-80,220},{-80,
          44},{-32,44}}, color={0,0,127}));
  connect(port_aSerAmb, hex.port_a1) annotation (Line(points={{-300,40},{-280,
          40},{-280,0},{-10,0}}, color={0,127,255}));
  connect(hex.port_b1, pumPri.port_a) annotation (Line(points={{10,0},{60,0},{
          60,1.72085e-15},{110,1.72085e-15}}, color={0,127,255}));
  connect(pumPri.port_b, port_bSerAmb) annotation (Line(points={{130,
          -6.66134e-16},{280,-6.66134e-16},{280,40},{300,40}}, color={0,127,255}));
  connect(pum.port_b, hex.port_a2) annotation (Line(points={{70,40},{80,40},{80,
          12},{10,12}}, color={0,127,255}));
  connect(con.yPumMasFlo, pumPri.m_flow_in)
    annotation (Line(points={{-48,95},{120,95},{120,12}}, color={0,0,127}));
  connect(sumPPum.y, PPum)
    annotation (Line(points={{284,160},{320,160}}, color={0,0,127}));
  connect(pum.P, sumPPum.u1) annotation (Line(points={{71,49},{80,49},{80,166},{
          260,166}}, color={0,0,127}));
  connect(pumPri.P, sumPPum.u2) annotation (Line(points={{131,9},{140,9},{140,
          154},{260,154}},
                      color={0,0,127}));
  connect(bou.ports[1], pum.port_a)
    annotation (Line(points={{40,60},{40,40},{50,40}}, color={0,127,255}));
  connect(coo.port_b,TWatLvgTow. port_a)
    annotation (Line(points={{-10,40},{0,40}}, color={0,127,255}));
  connect(TWatLvgTow.port_b, pum.port_a)
    annotation (Line(points={{20,40},{50,40}}, color={0,127,255}));
  connect(TWatLvgTow.T,con.TWatLvgTow)  annotation (Line(points={{10,51},{10,60},
          {-78,60},{-78,90},{-72,90}}, color={0,0,127}));
  connect(coo.port_a, hex.port_b2) annotation (Line(points={{-30,40},{-100,40},{
          -100,12},{-10,12}}, color={0,127,255}));
  connect(TDisWatEnt, con.TDisWatEnt) annotation (Line(points={{-320,140},{-112,
          140},{-112,87},{-72,87}}, color={0,0,127}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-300,-300},
            {300,300}})), Diagram(graphics={Text(
          extent={{-228,-28},{138,-190}},
          lineColor={28,108,200},
          horizontalAlignment=TextAlignment.Left,
          textString="fraPFan set to ~150 instead of default 1833!
per ASHRAE How to Design & Control Waterside Economizers
(130 for Carrier dry coolers 09VE 1163 UI 450E9 12A1V0 with 10 K approach)

Liquid pressure drop for cooling towers = 4 m for static head + 5 m for piping and valves ~ 9 mH2O

And for intermediary HX ~ 4 m on each side")}),
    experiment(
      StopTime=31536000,
      __Dymola_NumberOfIntervals=8760,
      Tolerance=1e-06,
      __Dymola_Algorithm="Cvode"),
    Documentation(info="<html>
<p>
Steady-state modeling of the cooling towers yields simulation error
due to freezing conditions, hence the dynamics that are considered.
</p>
</html>"));
end CoolingTowers;
