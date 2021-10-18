within LDRD.CentralPlants;
model Chillers "Chiller plant"
  extends Buildings.Experimental.DHC.CentralPlants.BaseClasses.PartialPlant(
    final typ=Buildings.Experimental.DHC.Types.DistrictSystemType.CombinedGeneration5,
    final have_fan=false,
    final have_pum=true,
    final have_eleHea=false,
    final nFue=0,
    final have_eleCoo=true,
    final have_weaBus=true,
    allowFlowReversal=false);

  parameter Modelica.SIunits.MassFlowRate m_flow_nominal
    "Nominal mass flow rate"
    annotation(Dialog(group = "Nominal condition"));
  parameter Modelica.SIunits.PressureDifference dp_nominal=40E3
    "Nominal pressure drop"
    annotation(Dialog(group = "Nominal condition"));
  parameter Modelica.SIunits.TemperatureDifference TSupSet = 15.5 + 273.15
    "Supply temperature set point";
  parameter Modelica.SIunits.TemperatureDifference TEntEna = TSupSet + 0.5
    "Entering temperature for enabling the chiller plant";
  parameter Modelica.SIunits.TemperatureDifference TEntDis = TSupSet - 0.1
    "Entering temperature for disabling the chiller plant";
  parameter Modelica.SIunits.TemperatureDifference TEnt_nominal = 25 + 273.15
    "Entering temperature at design";
  parameter Real COP_nominal(unit="1") = 3.6
    "COP at design";
  parameter Modelica.SIunits.Temperature TCon_nominal = 33.3 + 273.15 + 3
    "Condenser temperature at design";
  parameter Modelica.SIunits.Temperature TEva_nominal = TSupSet - 3
    "Evaporator temperature at design";

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
        origin={-340,220})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TWatEnt(final unit="K",
      displayUnit="degC") "Water entering temperature" annotation (Placement(
        transformation(extent={{-340,120},{-300,160}}),  iconTransformation(
          extent={{-380,120},{-300,200}})));
  Buildings.Fluid.Chillers.Carnot_TEva chi(
    redeclare final package Medium2 = Medium,
    redeclare final package Medium1 = Buildings.Media.Air,
    final QEva_flow_nominal=(TSupSet - TEnt_nominal)*m_flow_nominal*4186,
    final dTEva_nominal=TSupSet - TEnt_nominal,
    final use_eta_Carnot_nominal=false,
    final TCon_nominal=TCon_nominal,
    final TEva_nominal=TEva_nominal,
    final COP_nominal=COP_nominal,
    final dp1_nominal=0,
    final dp2_nominal=dp_nominal) "Chiller"
    annotation (Placement(transformation(extent={{10,36},{-10,56}})));
  Buildings.Controls.OBC.CDL.Continuous.Hysteresis hys(uLow=TEntDis, uHigh=
        TEntEna) "Enable/disable the plant"
    annotation (Placement(transformation(extent={{-200,130},{-180,150}})));
  Buildings.Fluid.Sources.MassFlowSource_WeatherData bou(
    m_flow=chi.m1_flow_nominal,
    nPorts=1,
    redeclare final package Medium = Buildings.Media.Air)
    annotation (Placement(transformation(extent={{62,42},{42,62}})));
  Buildings.Fluid.Sources.Boundary_pT bou1(
    redeclare final package Medium = Buildings.Media.Air, nPorts=1)
    annotation (Placement(transformation(extent={{-60,42},{-40,62}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant TSupSet_actual(k=
        TSupSet) "Supply temperature set point"
    annotation (Placement(transformation(extent={{-80,90},{-60,110}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant zer(final k=0) "Zero"
    annotation (Placement(transformation(extent={{40,90},{60,110}})));
  Buildings.Controls.OBC.CDL.Logical.Switch swiOff2
    "Switch between enabled and disabled mode"
    annotation (Placement(transformation(extent={{120,130},{140,150}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput uEna
    "External enable signal" annotation (Placement(transformation(extent={{-340,
            280},{-300,320}}), iconTransformation(extent={{-380,240},{-300,320}})));
  Buildings.Controls.OBC.CDL.Logical.And and2
                 "Enable/disable the plant"
    annotation (Placement(transformation(extent={{-140,130},{-120,150}})));
equation
  connect(pum.port_b, port_bSerAmb)
    annotation (Line(points={{170,40},{300,40}}, color={0,127,255}));
  connect(pum.P, PPum) annotation (Line(points={{171,49},{260,49},{260,160},{320,
          160}}, color={0,0,127}));
  connect(port_aSerAmb, chi.port_a2)
    annotation (Line(points={{-300,40},{-10,40}}, color={0,127,255}));
  connect(chi.port_b2, pum.port_a)
    annotation (Line(points={{10,40},{150,40}}, color={0,127,255}));
  connect(TWatEnt, hys.u)
    annotation (Line(points={{-320,140},{-202,140}}, color={0,0,127}));
  connect(bou.ports[1], chi.port_a1)
    annotation (Line(points={{42,52},{10,52}}, color={0,127,255}));
  connect(weaBus, bou.weaBus) annotation (Line(
      points={{1,266},{80,266},{80,52.2},{62,52.2}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(TSupSet_actual.y, chi.TSet) annotation (Line(points={{-58,100},{20,100},
          {20,56},{12,56},{12,55}}, color={0,0,127}));
  connect(swiOff2.y, pum.m_flow_in)
    annotation (Line(points={{142,140},{160,140},{160,52}}, color={0,0,127}));
  connect(zer.y, swiOff2.u3) annotation (Line(points={{62,100},{100,100},{100,132},
          {118,132}}, color={0,0,127}));
  connect(m_flow, swiOff2.u1) annotation (Line(points={{-320,180},{100,180},{100,
          148},{118,148}}, color={0,0,127}));
  connect(and2.y, swiOff2.u2)
    annotation (Line(points={{-118,140},{118,140}}, color={255,0,255}));
  connect(uEna, and2.u1) annotation (Line(points={{-320,300},{-160,300},{-160,140},
          {-142,140}}, color={255,0,255}));
  connect(hys.y, and2.u2) annotation (Line(points={{-178,140},{-168,140},{-168,132},
          {-142,132}}, color={255,0,255}));
  connect(chi.P, PCoo) annotation (Line(points={{-11,46},{-20,46},{-20,240},{320,
          240}}, color={0,0,127}));
  connect(chi.port_b1, bou1.ports[1])
    annotation (Line(points={{-10,52},{-40,52}}, color={0,127,255}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-300,-300},
            {300,300}})),
    experiment(
      StopTime=31622400,
      __Dymola_NumberOfIntervals=8760,
      Tolerance=1e-06,
      __Dymola_Algorithm="Cvode"));
end Chillers;
