within LDRD.CentralPlants;
model CoolingTowers "Cooling tower"
  extends Buildings.Experimental.DHC.CentralPlants.BaseClasses.PartialPlant(
    final typ=Buildings.Experimental.DHC.Types.DistrictSystemType.CombinedGeneration5,
    final have_fan=true,
    final have_pum=true,
    final have_eleHea=false,
    final nFue=0,
    final have_eleCoo=false,
    final have_weaBus=true,
    allowFlowReversal=false);
  parameter Boolean isCooTow = true
    "Set to true for cooling tower, false for dry cooler"
    annotation(Dialog(group = "Configuration"));
  parameter Modelica.SIunits.MassFlowRate m_flow_nominal
    "Nominal mass flow rate"
    annotation(Dialog(group = "Nominal condition"));
  parameter Modelica.SIunits.PressureDifference dp_nominal=30000
    "Nominal pressure drop"
    annotation(Dialog(group = "Nominal condition"));
  parameter Modelica.SIunits.TemperatureDifference TLvgMin = 9 + 273.15
    "Minimum leaving temperature";
  parameter Modelica.SIunits.TemperatureDifference TEntMax = 12 + 273.15
    "Entering temperature for maximum fan speed";
  parameter Modelica.SIunits.TemperatureDifference dTApp_nominal = 4
    "Approach"
    annotation (Dialog(group="Nominal condition"));
  parameter Modelica.SIunits.TemperatureDifference dTRan_nominal=
     4
    "Design range temperature (water in - water out)"
    annotation (Dialog(group="Nominal condition"));
  Buildings.Fluid.HeatExchangers.CoolingTowers.YorkCalc yorkCalc(
    redeclare final package Medium = Medium,
    final m_flow_nominal=m_flow_nominal,
    final dp_nominal=dp_nominal,
    energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyState,
    TAirInWB_nominal=285.15,
    final TApp_nominal=dTApp_nominal,
    final TRan_nominal=dTRan_nominal,
    fraPFan_nominal=130,
    yMin=0.1)
    "Cooling tower"
    annotation (Placement(transformation(extent={{-10,30},{10,50}})));
  Buildings.Experimental.DHC.EnergyTransferStations.BaseClasses.Pump_m_flow pum(
    redeclare final package Medium = Medium,
    final m_flow_nominal=m_flow_nominal,
    final dp_nominal=dp_nominal)
    "Pump"
    annotation (
     Placement(transformation(
        extent={{10,10},{-10,-10}},
        rotation=180,
        origin={160,40})));
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
    final dTApp_nominal=dTApp_nominal,
    final fraFreCon=yorkCalc.fraFreCon,
    final TLvgMin=TLvgMin,
    final TEntMax=TEntMax) "Controller"
    annotation (Placement(transformation(extent={{-70,80},{-50,100}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TWatLvg(final unit="K",
      displayUnit="degC") "Water leaving temperature" annotation (Placement(
        transformation(extent={{-340,80},{-300,120}}),    iconTransformation(
          extent={{-380,100},{-300,180}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TWatEnt(final unit="K",
      displayUnit="degC") "Water entering temperature" annotation (Placement(
        transformation(extent={{-340,120},{-300,160}}),  iconTransformation(
          extent={{-380,160},{-300,240}})));
  Buildings.Controls.OBC.CDL.Logical.Sources.Constant typCoo(
    final k=isCooTow)
    "Boolean depending on cooler type: true = cooling tower, false = dry cooler"
    annotation (Placement(transformation(extent={{-140,210},{-120,230}})));
  Buildings.Controls.OBC.CDL.Logical.Switch tem(
    y(final unit="K"))
    "Air temperature (DB or WB depending on type)"
    annotation (Placement(transformation(extent={{-80,210},{-60,230}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput m_flowBorFieMin(final unit=
        "kg/s") if have_pum
    "Minimum mass flow rate through borefield if integrated" annotation (
      Placement(transformation(extent={{300,60},{340,100}}), iconTransformation(
          extent={{300,-200},{380,-120}})));
  Buildings.Controls.OBC.CDL.Continuous.Max maxMasFlow
    "Compute maximum mass flow between main loop and cooler loop"
    annotation (Placement(transformation(extent={{220,70},{240,90}})));
equation
  connect(port_aSerAmb, yorkCalc.port_a)
    annotation (Line(points={{-300,40},{-10,40}}, color={0,127,255}));
  connect(yorkCalc.port_b, pum.port_a)
    annotation (Line(points={{10,40},{150,40}}, color={0,127,255}));
  connect(pum.port_b, port_bSerAmb)
    annotation (Line(points={{170,40},{300,40}}, color={0,127,255}));
  connect(con.yPumMasFlo, pum.m_flow_in)
    annotation (Line(points={{-48,95},{160,95},{160,52}}, color={0,0,127}));
  connect(con.yFan, yorkCalc.y) annotation (Line(points={{-48,85},{-40,85},{-40,
          48},{-12,48}}, color={0,0,127}));
  connect(m_flow, con.m_flow) annotation (Line(points={{-320,180},{-100,180},{-100,
          96},{-72,96}}, color={0,0,127}));
  connect(TWatLvg, con.TWatLvg) annotation (Line(points={{-320,100},{-120,100},{
          -120,87},{-72,87}}, color={0,0,127}));
  connect(TWatEnt, con.TWatEnt) annotation (Line(points={{-320,140},{-112,140},{
          -112,90},{-72,90}}, color={0,0,127}));
  connect(pum.P, PPum) annotation (Line(points={{171,49},{260,49},{260,160},{320,
          160}}, color={0,0,127}));
  connect(yorkCalc.PFan, PFan) annotation (Line(points={{11,48},{20,48},{20,200},
          {320,200}}, color={0,0,127}));
  connect(typCoo.y, tem.u2)
    annotation (Line(points={{-118,220},{-82,220}}, color={255,0,255}));
  connect(weaBus.TWetBul, tem.u1) annotation (Line(
      points={{1,266},{-100,266},{-100,228},{-82,228}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));
  connect(weaBus.TDryBul, tem.u3) annotation (Line(
      points={{1,266},{-100,266},{-100,212},{-82,212}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));
  connect(tem.y, yorkCalc.TAir) annotation (Line(points={{-58,220},{-20,220},{-20,
          44},{-12,44}}, color={0,0,127}));
  connect(tem.y, con.TAir) annotation (Line(points={{-58,220},{-20,220},{-20,
          120},{-80,120},{-80,93},{-72,93}},     color={0,0,127}));
  connect(maxMasFlow.y, m_flowBorFieMin)
    annotation (Line(points={{242,80},{320,80}}, color={0,0,127}));
  connect(pum.m_flow_actual, maxMasFlow.u2) annotation (Line(points={{171,45},{
          200,45},{200,74},{218,74}}, color={0,0,127}));
  connect(m_flow, maxMasFlow.u1) annotation (Line(points={{-320,180},{200,180},
          {200,86},{218,86}}, color={0,0,127}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-300,-300},
            {300,300}})), Diagram(graphics={Text(
          extent={{-96,-62},{62,-114}},
          lineColor={28,108,200},
          horizontalAlignment=TextAlignment.Left,
          textString="fraPFan set to 150 instead of default 1833! 
per ASHRAE How to Design & Control Waterside Economizers

Match Carrier dry coolers 09VE 1163 UI 450E9 12A1V0 with 10 K approach

Dry coolers have a practical minimum approach of 8 to 14°C (15 to 25°F). 
When a lower process-fluid outlet temperature is required, 
an air-humidification chamber can be provided to reduce the
inlet air temperature toward the wet-bulb temperature. 
A 5.6°C (10°F) approach is feasible.
")}),
    experiment(
      StopTime=31622400,
      __Dymola_NumberOfIntervals=8760,
      Tolerance=1e-06,
      __Dymola_Algorithm="Cvode"));
end CoolingTowers;
