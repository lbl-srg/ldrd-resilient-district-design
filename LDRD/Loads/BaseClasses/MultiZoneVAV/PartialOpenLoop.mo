within LDRD.Loads.BaseClasses.MultiZoneVAV;
partial model PartialOpenLoop
  "Partial model of variable air volume flow system with terminal reheat and five thermal zones"

  package MediumA = Buildings.Media.Air "Medium model for air";
  package MediumW = Buildings.Media.Water "Medium model for water";

  parameter Integer numVAV(min=2, start=5)
    "Number of served VAV boxes"
    annotation(Evaluate=true);
  parameter Integer numRet(min=1, start=numVAV)
    "Number of return air inlets"
    annotation(Evaluate=true);

  parameter Modelica.SIunits.Volume VRoo[numVAV](each start=1500)
    "Room volumes of each zone";
  parameter Modelica.SIunits.Area AFlo[numVAV](each start=500)
    "Floor area of each zone";
  parameter Real ACH[numVAV](each final unit="1/h", each start=1)
    "Design air change per hour of each zone";
  parameter Modelica.SIunits.MassFlowRate m_flow_nominalVAV[numVAV]=
    ACH .* VRoo * conv
    "Design mass flow rate of each VAV box";

  final parameter Modelica.SIunits.Area ATot=sum(AFlo) "Total floor area";

  constant Real conv=1.2/3600 "Conversion factor for nominal mass flow rate";

  parameter Modelica.SIunits.MassFlowRate m_flow_nominal=
    0.7*sum(m_flow_nominalVAV)
    "Nominal mass flow rate";

  parameter Real ratVFloHea(final unit="1") = 0.3
    "VAV box maximum air flow rate ratio in heating mode";

  parameter Modelica.SIunits.Angle lat=41.98*3.14159/180 "Latitude";

  parameter Real ratOAFlo_A(final unit="m3/(s.m2)") = 0.3e-3
    "Outdoor airflow rate required per unit area";
  parameter Real ratOAFlo_P = 2.5e-3
    "Outdoor airflow rate required per person";
  parameter Real ratP_A = 5e-2
    "Occupant density";
  parameter Real effZ(final unit="1") = 0.8
    "Zone air distribution effectiveness (limiting value)";
  parameter Real divP(final unit="1") = 0.7
    "Occupant diversity ratio";

  parameter Modelica.SIunits.VolumeFlowRate VOA_flow_nominalVAV[numVAV]=
    (ratOAFlo_P * ratP_A + ratOAFlo_A) * AFlo / effZ
    "Zone outdoor air flow rate of each VAV box";

  parameter Modelica.SIunits.VolumeFlowRate VOA_flow_nominal=
    (divP * ratOAFlo_P * ratP_A + ratOAFlo_A) * sum(AFlo)
    "System uncorrected outdoor air flow rate";
  parameter Real effVen(final unit="1") = if divP < 0.6 then
    0.88 * divP + 0.22 else 0.75
    "System ventilation efficiency";
  parameter Modelica.SIunits.VolumeFlowRate VOut_flow_nominal=
    VOA_flow_nominal / effVen
    "System design outdoor air flow rate";

  parameter Modelica.SIunits.Temperature THeaOn=293.15
    "Heating setpoint during on";
  parameter Modelica.SIunits.Temperature THeaOff=285.15
    "Heating setpoint during off";
  parameter Modelica.SIunits.Temperature TCooOn=297.15
    "Cooling setpoint during on";
  parameter Modelica.SIunits.Temperature TCooOff=303.15
    "Cooling setpoint during off";
  parameter Modelica.SIunits.PressureDifference dpBuiStaSet(min=0) = 12
    "Building static pressure";
  parameter Real yFanMin = 0.1 "Minimum fan speed";

  parameter Modelica.SIunits.Temperature THotWatInl_nominal(
    displayUnit="degC")=55 + 273.15
    "Reheat coil nominal inlet water temperature";

  parameter Boolean allowFlowReversal=true
    "= false to simplify equations, assuming, but not enforcing, no flow reversal"
    annotation (Evaluate=true);

  parameter Boolean use_windPressure=true "Set to true to enable wind pressure";

  parameter Boolean sampleModel=true
    "Set to true to time-sample the model, which can give shorter simulation time if there is already time sampling in the system model"
    annotation (Evaluate=true, Dialog(tab=
    "Experimental (may be changed in future releases)"));

  Modelica.Blocks.Interfaces.RealInput TRooAir[numVAV](
    each unit="K",
    each displayUnit="degC")
    "Room air temperatures"
    annotation (Placement(transformation(extent={{-360,240},{-340,260}}),
        iconTransformation(extent={{10,-10},{-10,10}},
        rotation=180,
        origin={-110,80})));
  Modelica.Fluid.Interfaces.FluidPorts_b ports_b[numVAV](
    redeclare final package Medium = MediumA)
    "Discharge air"
    annotation (Placement(transformation(extent={{590,60},{610,140}}),
      iconTransformation(extent={{90,-40},{110,40}})));
  Modelica.Fluid.Interfaces.FluidPorts_a ports_a[numRet](
    redeclare final package Medium = MediumA)
    "Return air"
    annotation (Placement(transformation(extent={{630,60},{650,
            140}}), iconTransformation(extent={{-110,-40},{-90,40}})));

  Buildings.Fluid.Sources.Outside amb(redeclare package Medium = MediumA,
      nPorts=2) "Ambient conditions"
    annotation (Placement(transformation(extent={{-136,-56},{-114,-34}})));

  Buildings.Fluid.HeatExchangers.DryCoilEffectivenessNTU heaCoi(
    redeclare package Medium1 = MediumW,
    redeclare package Medium2 = MediumA,
    m1_flow_nominal=m_flow_nominal*1000*(10 - (-20))/4200/10,
    m2_flow_nominal=m_flow_nominal,
    show_T=true,
    configuration=Buildings.Fluid.Types.HeatExchangerConfiguration.CounterFlow,
    Q_flow_nominal=m_flow_nominal*1006*(16.7 - 4),
    dp1_nominal=0,
    dp2_nominal=200 + 200 + 100 + 40,
    allowFlowReversal1=false,
    allowFlowReversal2=allowFlowReversal,
    T_a1_nominal=THotWatInl_nominal,
    T_a2_nominal=4 + 273.15)
    "Heating coil"
    annotation (Placement(transformation(extent={{118,-36},{98,-56}})));

  Buildings.Fluid.HeatExchangers.WetCoilCounterFlow cooCoi(
    show_T=true,
    UA_nominal=3*m_flow_nominal*1000*15/
      Buildings.Fluid.HeatExchangers.BaseClasses.lmtd(
      T_a1=26.2,
      T_b1=12.8,
      T_a2=6,
      T_b2=16),
    redeclare package Medium1 = MediumW,
    redeclare package Medium2 = MediumA,
    m1_flow_nominal=m_flow_nominal*1000*15/4200/10,
    m2_flow_nominal=m_flow_nominal,
    dp2_nominal=0,
    dp1_nominal=0,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    allowFlowReversal1=false,
    allowFlowReversal2=allowFlowReversal)
    "Cooling coil"
    annotation (Placement(transformation(extent={{210,-36},{190,-56}})));
  Buildings.Fluid.FixedResistances.PressureDrop dpRetDuc(
    m_flow_nominal=m_flow_nominal,
    redeclare package Medium = MediumA,
    allowFlowReversal=allowFlowReversal,
    dp_nominal=40) "Pressure drop for return duct"
    annotation (Placement(transformation(extent={{400,130},{380,150}})));
  Buildings.Fluid.Movers.SpeedControlled_y fanSup(
    redeclare package Medium = MediumA,
    per(pressure(V_flow={0,m_flow_nominal/1.2*2}, dp=2*{780 + 10 + dpBuiStaSet,
            0})),
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial) "Supply air fan"
    annotation (Placement(transformation(extent={{300,-50},{320,-30}})));

  Buildings.Fluid.Sensors.VolumeFlowRate senSupFlo(redeclare package Medium =
        MediumA, m_flow_nominal=m_flow_nominal)
    "Sensor for supply fan flow rate"
    annotation (Placement(transformation(extent={{400,-50},{420,-30}})));

  Buildings.Fluid.Sensors.VolumeFlowRate senRetFlo(redeclare package Medium =
        MediumA, m_flow_nominal=m_flow_nominal)
    "Sensor for return fan flow rate"
    annotation (Placement(transformation(extent={{360,130},{340,150}})));

  Buildings.Fluid.Sources.Boundary_pT sinHea[numVAV+1](
    redeclare each package Medium = MediumW,
    each p=300000,
    each T=318.15,
    each nPorts=1) "Sink for all heating coils"
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={80,-238})));
  Buildings.Fluid.Sources.Boundary_pT sinCoo(
    redeclare package Medium = MediumW,
    p=300000,
    T=285.15,
    nPorts=1) "Sink for cooling coil" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={180,-120})));
  Modelica.Blocks.Routing.RealPassThrough TOut(y(
      final quantity="ThermodynamicTemperature",
      final unit="K",
      displayUnit="degC",
      min=0))
    annotation (Placement(transformation(extent={{-300,170},{-280,190}})));
  Buildings.Fluid.Sensors.TemperatureTwoPort TSup(
    redeclare package Medium = MediumA,
    m_flow_nominal=m_flow_nominal,
    allowFlowReversal=allowFlowReversal)
    annotation (Placement(transformation(extent={{330,-50},{350,-30}})));
  Buildings.Fluid.Sensors.RelativePressure dpDisSupFan(redeclare package Medium =
        MediumA) "Supply fan static discharge pressure" annotation (Placement(
        transformation(
        extent={{-10,10},{10,-10}},
        rotation=90,
        origin={320,0})));
  Buildings.Controls.SetPoints.OccupancySchedule occSch(occupancy=3600*{6,19})
    "Occupancy schedule"
    annotation (Placement(transformation(extent={{-318,-220},{-298,-200}})));
  Buildings.Fluid.Sources.MassFlowSource_T souCoo(
    redeclare package Medium = MediumW,
    T=279.15,
    nPorts=1,
    use_m_flow_in=true) "Source for cooling coil" annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={228,-120})));
  Buildings.Fluid.Sensors.TemperatureTwoPort TRet(
    redeclare package Medium = MediumA,
    m_flow_nominal=m_flow_nominal,
    allowFlowReversal=allowFlowReversal) "Return air temperature sensor"
    annotation (Placement(transformation(extent={{110,130},{90,150}})));
  Buildings.Fluid.Sensors.TemperatureTwoPort TMix(
    redeclare package Medium = MediumA,
    m_flow_nominal=m_flow_nominal,
    allowFlowReversal=allowFlowReversal) "Mixed air temperature sensor"
    annotation (Placement(transformation(extent={{30,-50},{50,-30}})));
  Buildings.Fluid.Sources.MassFlowSource_T souHea(
    redeclare package Medium = MediumW,
    T=THotWatInl_nominal,
    use_m_flow_in=true,
    nPorts=1)           "Source for AHU heating coil" annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={128,-120})));
  Buildings.Fluid.Sensors.VolumeFlowRate VOut1(redeclare package Medium =
        MediumA, m_flow_nominal=m_flow_nominal) "Outside air volume flow rate"
    annotation (Placement(transformation(extent={{-90,-50},{-70,-30}})));

  Buildings.Examples.VAVReheat.BaseClasses.VAVReheatBox VAVBox[numVAV](
    redeclare each package MediumA = MediumA,
    redeclare each package MediumW = MediumW,
    m_flow_nominal=m_flow_nominalVAV,
    QHea_flow_nominal=m_flow_nominalVAV*ratVFloHea*cpAir*(32 - 12),
    VRoo=VRoo,
    each allowFlowReversal=allowFlowReversal,
    each ratVFloHea=ratVFloHea,
    each THotWatInl_nominal=THotWatInl_nominal,
    each THotWatOut_nominal=THotWatInl_nominal - 10,
    each TAirInl_nominal=285.15) "VAV boxes"
    annotation (Placement(transformation(extent={{580,20},{620,60}})));
  Buildings.Fluid.FixedResistances.Junction splRetRoo[numRet](
    redeclare each package Medium = MediumA,
    each from_dp=false,
    each linearized=true,
    m_flow_nominal={{sum(m_flow_nominalVAV[i:numVAV]),sum(m_flow_nominalVAV[(i + 1):numVAV]),m_flow_nominalVAV[i]} for
        i in 1:(numVAV - 1)},
    each energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyState,
    each dp_nominal(each displayUnit="Pa") = {0,0,0},
    each portFlowDirection_1=if allowFlowReversal then Modelica.Fluid.Types.PortFlowDirection.Bidirectional else
        Modelica.Fluid.Types.PortFlowDirection.Leaving,
    each portFlowDirection_2=if allowFlowReversal then Modelica.Fluid.Types.PortFlowDirection.Bidirectional else
        Modelica.Fluid.Types.PortFlowDirection.Entering,
    each portFlowDirection_3=if allowFlowReversal then Modelica.Fluid.Types.PortFlowDirection.Bidirectional else
        Modelica.Fluid.Types.PortFlowDirection.Entering) "Mixer for return air"
    annotation (Placement(transformation(extent={{650,10},{630,-10}})));
  Buildings.Fluid.FixedResistances.Junction splSupRoo[numVAV](
    redeclare each package Medium = MediumA,
    each from_dp=true,
    each linearized=true,
    m_flow_nominal={{sum(m_flow_nominalVAV[i:numVAV]),sum(m_flow_nominalVAV[(i + 1):numVAV]),m_flow_nominalVAV[i]} for
        i in 1:(numVAV - 1)},
    each energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyState,
    each dp_nominal(each displayUnit="Pa") = {0,0,0},
    each portFlowDirection_1=if allowFlowReversal then Modelica.Fluid.Types.PortFlowDirection.Bidirectional else
        Modelica.Fluid.Types.PortFlowDirection.Entering,
    each portFlowDirection_2=if allowFlowReversal then Modelica.Fluid.Types.PortFlowDirection.Bidirectional else
        Modelica.Fluid.Types.PortFlowDirection.Leaving,
    each portFlowDirection_3=if allowFlowReversal then Modelica.Fluid.Types.PortFlowDirection.Bidirectional else
        Modelica.Fluid.Types.PortFlowDirection.Leaving) "Splitter for supply air"
    annotation (Placement(transformation(extent={{590,-30},{610,-50}})));
  Buildings.BoundaryConditions.WeatherData.Bus weaBus "Weather Data Bus" annotation (Placement(transformation(extent={{-330,
            170},{-310,190}}), iconTransformation(extent={{-10,70},{10,90}})));

  Results res(
    final A=ATot,
    PFan=fanSup.P + 0,
    PHea=heaCoi.Q2_flow + sum(VAVBox.terHea.Q2_flow),
    PCooSen=cooCoi.QSen2_flow,
    PCooLat=cooCoi.QLat2_flow) "Results of the simulation";
  /*fanRet*/

public
  Buildings.Controls.OBC.CDL.Continuous.Gain gaiHeaCoi(k=m_flow_nominal*1000*40
        /4200/10) "Gain for heating coil mass flow rate"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=90,
        origin={120,-170})));
  Buildings.Controls.OBC.CDL.Continuous.Gain gaiCooCoi(k=m_flow_nominal*1000*15
        /4200/10) "Gain for cooling coil mass flow rate"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=90,
        origin={220,-170})));
  Buildings.Examples.VAVReheat.BaseClasses.FreezeStat freSta "Freeze stat for heating coil"
    annotation (Placement(transformation(extent={{-60,-100},{-40,-80}})));
  Buildings.Fluid.Sources.MassFlowSource_T souHeaVAV[numVAV](
    redeclare each package Medium = MediumW,
    each T=THotWatInl_nominal,
    each use_m_flow_in=true,
    each nPorts=1) "Source for VAV box reheat coil"
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={542,32})));
  Buildings.Controls.OBC.CDL.Continuous.Gain gaiHeaCoiVAV[numVAV](
    k=VAVBox.mHotWat_flow_nominal) "Gain for VAV box reheat coil mass flow rate"
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={504,40})));

  Buildings.Fluid.Actuators.Dampers.Exponential damRet(
    redeclare package Medium = MediumA,
    m_flow_nominal=m_flow_nominal,
    riseTime=15,
    dpDamper_nominal=5,
    dpFixed_nominal=5) "Return air damper"
    annotation (Placement(transformation(
        origin={0,-10},
        extent={{10,-10},{-10,10}},
        rotation=90)));
  Buildings.Fluid.Actuators.Dampers.Exponential damOut(
    redeclare package Medium = MediumA,
    m_flow_nominal=m_flow_nominal,
    from_dp=true,
    riseTime=15,
    dpDamper_nominal=5,
    dpFixed_nominal=5) "Outdoor air damper" annotation (Placement(transformation(extent={{-50,-50},{-30,-30}})));

protected
  constant Modelica.SIunits.SpecificHeatCapacity cpAir=
    Buildings.Utilities.Psychrometrics.Constants.cpAir
    "Air specific heat capacity";
  constant Modelica.SIunits.SpecificHeatCapacity cpWatLiq=
    Buildings.Utilities.Psychrometrics.Constants.cpWatLiq
    "Water specific heat capacity";
  model Results "Model to store the results of the simulation"
    parameter Modelica.SIunits.Area A "Floor area";
    input Modelica.SIunits.Power PFan "Fan energy";
    input Modelica.SIunits.Power PHea "Heating energy";
    input Modelica.SIunits.Power PCooSen "Sensible cooling energy";
    input Modelica.SIunits.Power PCooLat "Latent cooling energy";

    Real EFan(
      unit="J/m2",
      start=0,
      nominal=1E5,
      fixed=true) "Fan energy";
    Real EHea(
      unit="J/m2",
      start=0,
      nominal=1E5,
      fixed=true) "Heating energy";
    Real ECooSen(
      unit="J/m2",
      start=0,
      nominal=1E5,
      fixed=true) "Sensible cooling energy";
    Real ECooLat(
      unit="J/m2",
      start=0,
      nominal=1E5,
      fixed=true) "Latent cooling energy";
    Real ECoo(unit="J/m2") "Total cooling energy";
  equation

    A*der(EFan) = PFan;
    A*der(EHea) = PHea;
    A*der(ECooSen) = PCooSen;
    A*der(ECooLat) = PCooLat;
    ECoo = ECooSen + ECooLat;

  end Results;

equation
  connect(fanSup.port_b, dpDisSupFan.port_a) annotation (Line(
      points={{320,-40},{320,-10}},
      color={0,0,0},
      smooth=Smooth.None,
      pattern=LinePattern.Dot));
  connect(TSup.port_a, fanSup.port_b) annotation (Line(
      points={{330,-40},{320,-40}},
      color={0,127,255},
      smooth=Smooth.None,
      thickness=0.5));
  connect(amb.ports[1], VOut1.port_a) annotation (Line(
      points={{-114,-42.8},{-94,-42.8},{-94,-40},{-90,-40}},
      color={0,127,255},
      smooth=Smooth.None,
      thickness=0.5));

  connect(cooCoi.port_b1, sinCoo.ports[1]) annotation (Line(
      points={{190,-52},{180,-52},{180,-110}},
      color={28,108,200},
      thickness=0.5));
  connect(weaBus.TDryBul, TOut.u) annotation (Line(
      points={{-320,180},{-302,180}},
      color={255,204,51},
      thickness=0.5,
      smooth=Smooth.None));
  connect(amb.weaBus, weaBus) annotation (Line(
      points={{-136,-44.78},{-320,-44.78},{-320,180}},
      color={255,204,51},
      thickness=0.5,
      smooth=Smooth.None));

  connect(cooCoi.port_b2, fanSup.port_a) annotation (Line(
      points={{210,-40},{300,-40}},
      color={0,127,255},
      smooth=Smooth.None,
      thickness=0.5));

  connect(senRetFlo.port_a, dpRetDuc.port_b)
    annotation (Line(
        points={{360,140},{380,140}},
        color={0,127,255},
        smooth=Smooth.None,
        thickness=0.5));
  connect(TSup.port_b, senSupFlo.port_a)
    annotation (Line(
      points={{350,-40},{400,-40}},
      color={0,127,255},
      smooth=Smooth.None,
      thickness=0.5));

  connect(cooCoi.port_a1, souCoo.ports[1]) annotation (Line(
      points={{210,-52},{228,-52},{228,-110}},
      color={28,108,200},
      thickness=0.5));
  connect(gaiHeaCoi.y, souHea.m_flow_in) annotation (Line(points={{120,-158},{120,
          -132}},                color={0,0,127}));
  connect(gaiCooCoi.y, souCoo.m_flow_in) annotation (Line(points={{220,-158},{220,
          -132}},                color={0,0,127}));
  connect(dpDisSupFan.port_b, amb.ports[2]) annotation (Line(
      points={{320,10},{320,14},{-106,14},{-106,-48},{-110,-48},{-110,-47.2},{-114,
          -47.2}},
      color={0,0,0},
      pattern=LinePattern.Dot));
  connect(senRetFlo.port_b, TRet.port_a) annotation (Line(
      points={{340,140},{226,140},{110,140}},
      color={0,127,255},
      smooth=Smooth.None,
      thickness=0.5));
  connect(freSta.u, TMix.T) annotation (Line(points={{-62,-90},{-70,-90},{-70,
          -68},{20,-68},{20,-20},{40,-20},{40,-29}},
                                                color={0,0,127}));
  connect(TMix.port_b, heaCoi.port_a2) annotation (Line(
      points={{50,-40},{98,-40}},
      color={0,127,255},
      thickness=0.5));
  connect(heaCoi.port_b2, cooCoi.port_a2) annotation (Line(
      points={{118,-40},{190,-40}},
      color={0,127,255},
      thickness=0.5));
  connect(souHea.ports[1], heaCoi.port_a1) annotation (Line(
      points={{128,-110},{128,-52},{118,-52}},
      color={28,108,200},
      thickness=0.5));
  connect(heaCoi.port_b1, sinHea[1].ports[1]) annotation (Line(
      points={{98,-52},{90,-52},{90,-238}},
      color={28,108,200},
      thickness=0.5));

  for i in 1:numVAV loop
    connect(VAVBox[i].port_bHotWat, sinHea[i+1].ports[1]) annotation (Line(
      points={{580,28},{560,28},{560,-238},{90,-238}},
      color={0,127,255},
      smooth=Smooth.None,
      thickness=0.5));
  end for;

  connect(souHeaVAV[:].m_flow_in,gaiHeaCoiVAV[:].y)
    annotation (Line(points={{530,40},{516,40}}, color={0,0,127}));
  connect(souHeaVAV[:].ports[1],VAVBox[:].port_aHotWat) annotation (Line(
      points={{552,32},{580,32},{580,40}},
      color={0,127,255},
      smooth=Smooth.None,
      thickness=0.5));
  connect(splSupRoo[1].port_1, senSupFlo.port_b) annotation (Line(
      points={{590,-40},{420,-40}},
      color={0,127,255},
      smooth=Smooth.None,
      thickness=0.5));

  for i in 1:(numVAV-1) loop
    connect(splSupRoo[i].port_2, splSupRoo[i+1].port_1);
    connect(splRetRoo[i].port_1, splRetRoo[i+1].port_2);
  end for;

  connect(VOut1.port_b, damOut.port_a)
    annotation (Line(points={{-70,-40},{-50,-40}}, color={0,127,255}));
  connect(damOut.port_b, TMix.port_a)
    annotation (Line(points={{-30,-40},{30,-40}}, color={0,127,255}));
  connect(damRet.port_a, TRet.port_b)
    annotation (Line(points={{0,0},{0,140},{90,140}}, color={0,127,255}));
  connect(damRet.port_b, TMix.port_a)
    annotation (Line(points={{0,-20},{0,-40},{30,-40}}, color={0,127,255}));

  connect(splRetRoo.port_3, ports_a) annotation (Line(points={{640,10},{640,100}}, color={0,127,255}));
  connect(VAVBox.port_bAir, ports_b) annotation (Line(points={{600,60},{600,100}}, color={0,127,255}));
  connect(splSupRoo.port_3, VAVBox.port_aAir) annotation (Line(points={{600,-30},{600,20}}, color={0,127,255}));
  connect(dpRetDuc.port_a, splRetRoo[1].port_2)
    annotation (Line(points={{400,140},{420,140},{420,0},{630,0}}, color={0,127,255}));
  annotation (Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-400,
            -400},{750,300}})),  Documentation(info="<html>
<p>
This model consist of an HVAC system, a building envelope model and a model
for air flow through building leakage and through open doors.
</p>
<p>
The HVAC system is a variable air volume (VAV) flow system with economizer
and a heating and cooling coil in the air handler unit. There is also a
reheat coil and an air damper in each of the five zone inlet branches.
The figure below shows the schematic diagram of the HVAC system
</p>
<p align=\"center\">
<img alt=\"image\" src=\"modelica://Buildings/Resources/Images/Examples/VAVReheat/vavSchematics.png\" border=\"1\"/>
</p>
<p>
Most of the HVAC control in this model is open loop.
Two models that extend this model, namely
<a href=\"modelica://Buildings.Examples.VAVReheat.ASHRAE2006\">
Buildings.Examples.VAVReheat.ASHRAE2006</a>
and
<a href=\"modelica://Buildings.Examples.VAVReheat.Guideline36\">
Buildings.Examples.VAVReheat.Guideline36</a>
add closed loop control. See these models for a description of
the control sequence.
</p>
<p>
To model the heat transfer through the building envelope,
a model of five interconnected rooms is used.
The five room model is representative of one floor of the
new construction medium office building for Chicago, IL,
as described in the set of DOE Commercial Building Benchmarks
(Deru et al, 2009). There are four perimeter zones and one core zone.
The envelope thermal properties meet ASHRAE Standard 90.1-2004.
The thermal room model computes transient heat conduction through
walls, floors and ceilings and long-wave radiative heat exchange between
surfaces. The convective heat transfer coefficient is computed based
on the temperature difference between the surface and the room air.
There is also a layer-by-layer short-wave radiation,
long-wave radiation, convection and conduction heat transfer model for the
windows. The model is similar to the
Window 5 model and described in TARCOG 2006.
</p>
<p>
Each thermal zone can have air flow from the HVAC system, through leakages of the building envelope (except for the core zone) and through bi-directional air exchange through open doors that connect adjacent zones. The bi-directional air exchange is modeled based on the differences in static pressure between adjacent rooms at a reference height plus the difference in static pressure across the door height as a function of the difference in air density.
Infiltration is a function of the
flow imbalance of the HVAC system.
</p>
<h4>References</h4>
<p>
Deru M., K. Field, D. Studer, K. Benne, B. Griffith, P. Torcellini,
 M. Halverson, D. Winiarski, B. Liu, M. Rosenberg, J. Huang, M. Yazdanian, and D. Crawley.
<i>DOE commercial building research benchmarks for commercial buildings</i>.
Technical report, U.S. Department of Energy, Energy Efficiency and
Renewable Energy, Office of Building Technologies, Washington, DC, 2009.
</p>
<p>
TARCOG 2006: Carli, Inc., TARCOG: Mathematical models for calculation
of thermal performance of glazing systems with our without
shading devices, Technical Report, Oct. 17, 2006.
</p>
</html>", revisions="<html>
<ul>
<li>
April 16, 2021, by Michael Wetter:<br/>
Refactored model to implement the economizer dampers directly in
<code>Buildings.Examples.VAVReheat.BaseClasses.PartialOpenLoop</code> rather than through the
model of a mixing box. Since the version of the Guideline 36 model has no exhaust air damper,
this leads to simpler equations.
<br/> This is for <a href=\"https://github.com/lbl-srg/modelica-buildings/issues/2454\">issue #2454</a>.
</li>
<li>
March 11, 2021, by Michael Wetter:<br/>
Set parameter in weather data reader to avoid computation of wet bulb temperature which is need needed for this model.
</li>
<li>
February 03, 2021, by Baptiste Ravache:<br/>
Refactored the sizing of the heating coil in the <code>VAVBranch</code> (renamed <code>VAVReheatBox</code>) class.<br/>
This is for
<a href=\"https://github.com/lbl-srg/modelica-buildings/issues/2059\">#2024</a>.
</li>
<li>
July 10, 2020, by Antoine Gautier:<br/>
Added design parameters for outdoor air flow.<br/>
This is for
<a href=\"https://github.com/lbl-srg/modelica-buildings/issues/2019\">#2019</a>
</li>
<li>
November 25, 2019, by Milica Grahovac:<br/>
Declared the floor model as replaceable.
</li>
<li>
September 26, 2017, by Michael Wetter:<br/>
Separated physical model from control to facilitate implementation of alternate control
sequences.
</li>
<li>
May 19, 2016, by Michael Wetter:<br/>
Changed chilled water supply temperature to <i>6&deg;C</i>.
This is
for <a href=\"https://github.com/ibpsa/modelica-ibpsa/issues/509\">#509</a>.
</li>
<li>
April 26, 2016, by Michael Wetter:<br/>
Changed controller for freeze protection as the old implementation closed
the outdoor air damper during summer.
This is
for <a href=\"https://github.com/ibpsa/modelica-ibpsa/issues/511\">#511</a>.
</li>
<li>
January 22, 2016, by Michael Wetter:<br/>
Corrected type declaration of pressure difference.
This is
for <a href=\"https://github.com/ibpsa/modelica-ibpsa/issues/404\">#404</a>.
</li>
<li>
September 24, 2015 by Michael Wetter:<br/>
Set default temperature for medium to avoid conflicting
start values for alias variables of the temperature
of the building and the ambient air.
This is for
<a href=\"https://github.com/lbl-srg/modelica-buildings/issues/426\">issue 426</a>.
</li>
</ul>
</html>"),
    Icon(coordinateSystem(extent={{-100,-100},{100,100}}, preserveAspectRatio=false)));
end PartialOpenLoop;
