within LDRD.Loads.BaseClasses.MultiZoneVAV;
partial model PartialOpenLoop
  "Partial model of variable air volume flow system with terminal reheat and five thermal zones"

  package MediumA = Buildings.Media.Air "Medium model for air";
  package MediumW = Buildings.Media.Water "Medium model for water";

  outer replaceable Data.VAVData datVAV;

  final parameter Integer numVAV(min=2, start=5) = datVAV.numVAV
    "Number of served VAV boxes"
    annotation(Evaluate=true);
  final parameter Integer numRet(min=1, start=numVAV) = datVAV.numRet
    "Number of return air inlets"
    annotation(Evaluate=true);

  final parameter Modelica.SIunits.Volume VRoo[numVAV](each start=1500) = datVAV.VRoo
    "Room volumes of each zone"
    annotation(Dialog(group="Zone parameters"));
  final parameter Modelica.SIunits.Area AFlo[numVAV](each start=500) = datVAV.AFlo
    "Floor area of each zone"
    annotation(Dialog(group="Zone parameters"));
  final parameter Modelica.SIunits.Area ATot=sum(AFlo) "Total floor area";

  final parameter Modelica.SIunits.MassFlowRate mAirBox_flow_nominal[numVAV](
    start=VRoo * 6 * 1.2 / 3600) = datVAV.mAirBox_flow_nominal
    "Design mass flow rate of each VAV box"
    annotation(Dialog(group="Air flow rates"));
  final parameter Modelica.SIunits.MassFlowRate mAirRet_flow_nominal[numRet](
    each start=sum(mAirBox_flow_nominal)/numRet) = datVAV.mAirRet_flow_nominal
    "Design mass flow rate of each return air inlet"
    annotation(Dialog(group="Air flow rates"));

  final parameter Modelica.SIunits.MassFlowRate m_flow_nominal = datVAV.m_flow_nominal
    "Nominal mass flow rate";

  final parameter Real ratVFloHea[numVAV](each final unit="1", each start=0.3) = datVAV.ratVFloHea
    "VAV box maximum air flow rate ratio in heating mode"
    annotation(Dialog(group="Air flow rates"));
  final parameter Real ratOAFlo_A[numVAV](
    each final unit="m3/(s.m2)",
    each start=0.3e-3) = datVAV.ratOAFlo_A
    "Outdoor airflow rate required per unit area"
    annotation(Dialog(group="Air flow rates"));
  final parameter Real ratOAFlo_P[numVAV](each start=2.5e-3) = datVAV.ratOAFlo_P
    "Outdoor airflow rate required per person"
    annotation(Dialog(group="Air flow rates"));
  final parameter Real ratP_A[numVAV](each start=5e-2) = datVAV.ratP_A
    "Occupant density"
    annotation(Dialog(group="Air flow rates"));
  final parameter Real effZ(final unit="1") = datVAV.effZ
    "Zone air distribution effectiveness (limiting value) (Ez)"
    annotation(Dialog(group="Air flow rates"));
  final parameter Real divP(final unit="1") = datVAV.divP
    "Occupant diversity ratio (D)"
    annotation(Dialog(group="Air flow rates"));

  final parameter Modelica.SIunits.VolumeFlowRate VOABox_flow_nominal[numVAV]=
    (ratOAFlo_P .* ratP_A .+ ratOAFlo_A) .* AFlo / effZ
    "Zone outdoor air flow rate of each VAV box";
  final parameter Modelica.SIunits.VolumeFlowRate VOA_flow_nominal=
    sum((divP * ratOAFlo_P .* ratP_A .+ ratOAFlo_A) .* AFlo)
    "System uncorrected outdoor air flow rate (Vou)";
  final parameter Real effVen(final unit="1") = if divP < 0.6 then
    0.88 * divP + 0.22 else 0.75
    "System ventilation efficiency";
  final parameter Modelica.SIunits.VolumeFlowRate VOut_flow_nominal=
    VOA_flow_nominal / effVen
    "System design outdoor air flow rate";

  final parameter Modelica.SIunits.Temperature THeaOn = datVAV.THeaOn
    "Heating setpoint during on";
  final parameter Modelica.SIunits.Temperature THeaOff = datVAV.THeaOff
    "Heating setpoint during off";
  final parameter Modelica.SIunits.Temperature TCooOn = datVAV.TCooOn
    "Cooling setpoint during on";
  final parameter Modelica.SIunits.Temperature TCooOff = datVAV.TCooOff
    "Cooling setpoint during off";
  parameter Real yFanMin = 0.1 "Minimum fan speed";

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
    annotation (Placement(transformation(extent={{670,60},{690,140}}),
                    iconTransformation(extent={{-110,-40},{-90,40}})));

  Modelica.Fluid.Interfaces.FluidPort_b port_coiCooRet(
    redeclare final package Medium = MediumW)
    "Cooling coil return port"
    annotation (Placement(
      transformation(extent={{170,-410},{190,-390}}),
      iconTransformation(extent={{6,-110},{26,-90}})));
  Modelica.Fluid.Interfaces.FluidPort_a port_coiCooSup(
    redeclare final package Medium = MediumW)
    "Cooling coil supply port"
    annotation (Placement(
        transformation(extent={{210,-410},{230,-390}}), iconTransformation(
          extent={{-24,-110},{-4,-90}})));
  Modelica.Fluid.Interfaces.FluidPort_b port_coiHeaRet(
    redeclare final package Medium =MediumW)
    "Heating coil return port"
    annotation (Placement(transformation(extent={{70,-410},{90,-390}}),
                         iconTransformation(extent={{-70,-110},{-50,-90}})));
  Modelica.Fluid.Interfaces.FluidPort_a port_coiHeaSup(
    redeclare final package Medium =MediumW)
    "Heating coil supply port"
    annotation (Placement(transformation(extent={{110,-410},{130,-390}}),
                         iconTransformation(extent={{-100,-110},{-80,-90}})));
  Modelica.Fluid.Interfaces.FluidPort_b port_coiRehRet[numVAV](
    redeclare each final package Medium = MediumW)
    "Reheat coil return port"
    annotation (Placement(transformation(extent={{510,-410},{530,-390}}), iconTransformation(
          extent={{80,-110},{100,-90}})));
  Modelica.Fluid.Interfaces.FluidPort_a port_coiRehSup[numVAV](
    redeclare each final package Medium = MediumW)
    "Reheat coil supply port"
    annotation (Placement(transformation(extent={{550,-410},{570,-390}}), iconTransformation(
          extent={{50,-110},{70,-90}})));

  Modelica.Blocks.Interfaces.RealOutput PFan(
    final quantity="Power",
    final unit="W") "Power drawn by fan motors"
    annotation (Placement(transformation(extent={{800,180},{840,220}}),
      iconTransformation(extent={{100,40},{120,60}})));
  Modelica.Blocks.Interfaces.RealOutput QHea_flow(final unit="W")
    "Total heating heat flow rate transferred to the loads (>=0)"
    annotation (Placement(transformation(extent={{800,260},{840,300}}),
      iconTransformation(extent={{100,80},{120,100}})));
  Modelica.Blocks.Interfaces.RealOutput QCoo_flow(final unit="W")
    "Total cooling heat flow rate transferred to the loads (<=0)"
    annotation (Placement(transformation(extent={{800,220},{840,260}}),
      iconTransformation(extent={{100,60},{120,80}})));
  Modelica.Blocks.Interfaces.RealOutput yValHeaMax_actual(
    final unit="1")
    "Maximum opening of heating and reheat coil valves"
    annotation (Placement(transformation(extent={{800,140},{840,180}}),
        iconTransformation(extent={{100,-60},{120,-40}})));
  Modelica.Blocks.Interfaces.RealOutput yValCooMax_actual(
    final quantity="1")
    "Maximum opening of cooling coil valve"
    annotation (Placement(transformation(extent={{800,100},{840,140}}),
        iconTransformation(extent={{100,-80},{120,-60}})));


  Buildings.Fluid.Sources.Outside amb(
    redeclare package Medium = MediumA,
    nPorts=2)
    "Ambient conditions"
    annotation (Placement(transformation(extent={{-142,-52},{-120,-30}})));

  Buildings.Fluid.HeatExchangers.DryCoilEffectivenessNTU heaCoi(
    redeclare package Medium1 = MediumW,
    redeclare package Medium2 = MediumA,
    show_T=true,
    configuration=Buildings.Fluid.Types.HeatExchangerConfiguration.CounterFlow,
    final Q_flow_nominal=datVAV.QHeaCoi_flow,
    final m1_flow_nominal=datVAV.mLiqHeaCoi_flow,
    final m2_flow_nominal=datVAV.mAirHeaCoi_flow,
    final dp1_nominal=0,
    final dp2_nominal=datVAV.dpFil + datVAV.dpAirCooCoi + datVAV.dpAirHeaCoi,
    allowFlowReversal1=false,
    final allowFlowReversal2=allowFlowReversal,
    final T_a1_nominal=datVAV.TLiqEntHeaCoi,
    final T_a2_nominal=datVAV.TAirEntHeaCoi)
    "Heating coil"
    annotation (Placement(transformation(extent={{110,-36},{90,-56}})));

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
      energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
      allowFlowReversal1=false,
      final allowFlowReversal2=allowFlowReversal)
    "Cooling coil"
    annotation (Placement(transformation(extent={{210,-36},{190,-56}})));

  Buildings.Fluid.FixedResistances.PressureDrop dpRetDuc(
    final m_flow_nominal=m_flow_nominal,
    redeclare final package Medium = MediumA,
    final allowFlowReversal=allowFlowReversal,
    final dp_nominal=datVAV.dpDucRet) "Duct pressure drop"
    annotation (Placement(transformation(extent={{480,130},{460,150}})));
  Buildings.Fluid.Movers.SpeedControlled_y fanSup(
    redeclare package Medium = MediumA,
    per(pressure(
      V_flow=m_flow_nominal / 1.2 .* {0, 1, 1.4},
      dp=datVAV.dpTot .* {1.5, 1, 0})),
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial)
    "Supply fan"
    annotation (Placement(transformation(extent={{300,-50},{320,-30}})));

  Buildings.Fluid.Sensors.VolumeFlowRate senSupFlo(
    redeclare final package Medium =MediumA,
    final m_flow_nominal=m_flow_nominal)
    "Sensor for supply fan flow rate"
    annotation (Placement(transformation(extent={{400,-50},{420,-30}})));

  Buildings.Fluid.Sensors.VolumeFlowRate senRetFlo(
    redeclare final package Medium = MediumA,
    final m_flow_nominal=m_flow_nominal)
    "Sensor for return fan flow rate"
    annotation (Placement(transformation(extent={{360,130},{340,150}})));

  Modelica.Blocks.Routing.RealPassThrough TOut(y(
      final quantity="ThermodynamicTemperature",
      final unit="K",
      displayUnit="degC",
      min=0))
    annotation (Placement(transformation(extent={{-300,170},{-280,190}})));
  Buildings.Fluid.Sensors.TemperatureTwoPort TSup(
    redeclare final package Medium = MediumA,
    final m_flow_nominal=m_flow_nominal,
    final allowFlowReversal=allowFlowReversal)
    annotation (Placement(transformation(extent={{330,-50},{350,-30}})));
  Buildings.Fluid.Sensors.RelativePressure dpDisSupFan(
    redeclare final package Medium = MediumA) "Supply fan static discharge pressure"
                                           annotation (Placement(
        transformation(
        extent={{-10,10},{10,-10}},
        rotation=90,
        origin={320,0})));
  Buildings.Controls.SetPoints.OccupancySchedule occSch(occupancy=3600*{6,19})
    "Occupancy schedule"
    annotation (Placement(transformation(extent={{-318,-220},{-298,-200}})));
  Buildings.Fluid.Sensors.TemperatureTwoPort TRet(
    redeclare package Medium = MediumA,
    final m_flow_nominal=m_flow_nominal,
    final allowFlowReversal=allowFlowReversal)
    "Return air temperature sensor"
    annotation (Placement(transformation(extent={{110,130},{90,150}})));
  Buildings.Fluid.Sensors.TemperatureTwoPort TMix(
    redeclare package Medium = MediumA,
    final m_flow_nominal=m_flow_nominal,
    final allowFlowReversal=allowFlowReversal)
    "Mixed air temperature sensor"
    annotation (Placement(transformation(extent={{30,-50},{50,-30}})));
  Buildings.Fluid.Sensors.VolumeFlowRate VOut1(
    redeclare final package Medium =  MediumA,
    final m_flow_nominal=m_flow_nominal) "Outside air volume flow rate"
    annotation (Placement(transformation(extent={{-90,-50},{-70,-30}})));

  VAVReheatBox VAVBox[numVAV](
    redeclare each final package MediumA = MediumA,
    redeclare each final package MediumW = MediumW,
    final m_flow_nominal=mAirBox_flow_nominal,
    final mHotWat_flow_nominal=datVAV.mLiqRehCoi_flow,
    final QHea_flow_nominal=datVAV.QRehCoi_flow,
    final VRoo=VRoo,
    each final allowFlowReversal=allowFlowReversal,
    final ratVFloHea=ratVFloHea,
    final THotWatInl_nominal=datVAV.TLiqEntRehCoi,
    final TAirInl_nominal=datVAV.TAirEntRehCoi,
    final dpFixed_nominal=datVAV.dpAirBox .- 20)
    "VAV boxes"
    annotation (Placement(transformation(extent={{580,20},{620,60}})));
  Buildings.Fluid.FixedResistances.Junction splRetRoo[numRet](
    redeclare each package Medium = MediumA,
    each from_dp=false,
    each linearized=true,
    m_flow_nominal={
      {max(1e-6, sum(mAirRet_flow_nominal[(i + 1):numRet])),
      -sum(mAirRet_flow_nominal[i:numRet]),
      mAirRet_flow_nominal[i]} for i in 1:numRet},
    each energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyState,
    each dp_nominal(each displayUnit="Pa") = {0,0,0},
    each portFlowDirection_1=if allowFlowReversal then Modelica.Fluid.Types.PortFlowDirection.Bidirectional else
        Modelica.Fluid.Types.PortFlowDirection.Leaving,
    each portFlowDirection_2=if allowFlowReversal then Modelica.Fluid.Types.PortFlowDirection.Bidirectional else
        Modelica.Fluid.Types.PortFlowDirection.Entering,
    each portFlowDirection_3=if allowFlowReversal then Modelica.Fluid.Types.PortFlowDirection.Bidirectional else
        Modelica.Fluid.Types.PortFlowDirection.Entering) "Mixer for return air (index 1 closest to AHU)"
    annotation (Placement(transformation(extent={{670,10},{690,-10}})));
  Buildings.Fluid.FixedResistances.Junction splSupRoo[numVAV](
    redeclare each package Medium = MediumA,
    each from_dp=true,
    each linearized=true,
    m_flow_nominal={
      {sum(mAirBox_flow_nominal[i:numVAV]),
      -max(1e-6, sum(mAirBox_flow_nominal[(i + 1):numVAV])),
      -mAirBox_flow_nominal[i]} for i in 1:numVAV},
    each energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyState,
    each dp_nominal(each displayUnit="Pa") = {0,0,0},
    each portFlowDirection_1=if allowFlowReversal then Modelica.Fluid.Types.PortFlowDirection.Bidirectional else
        Modelica.Fluid.Types.PortFlowDirection.Entering,
    each portFlowDirection_2=if allowFlowReversal then Modelica.Fluid.Types.PortFlowDirection.Bidirectional else
        Modelica.Fluid.Types.PortFlowDirection.Leaving,
    each portFlowDirection_3=if allowFlowReversal then Modelica.Fluid.Types.PortFlowDirection.Bidirectional else
        Modelica.Fluid.Types.PortFlowDirection.Leaving)
    "Splitter for supply air (index 1 closest to AHU)"
    annotation (Placement(transformation(extent={{590,-30},{610,-50}})));
  Buildings.BoundaryConditions.WeatherData.Bus weaBus
    "Weather Data Bus" annotation (Placement(transformation(extent={{-330,
            170},{-310,190}}), iconTransformation(extent={{-10,70},{10,90}})));

  Results res(
    final A=ATot,
    PFan=fanSup.P + 0,
    PHea=heaCoi.Q2_flow + sum(VAVBox.terHea.Q2_flow),
    PCooSen=cooCoi.QSen2_flow,
    PCooLat=cooCoi.QLat2_flow)
    "Results of the simulation";
  /*fanRet*/

  Buildings.Examples.VAVReheat.BaseClasses.FreezeStat freSta "Freeze stat for heating coil"
    annotation (Placement(transformation(extent={{-60,-100},{-40,-80}})));

  Buildings.Fluid.Actuators.Dampers.Exponential damRet(
    redeclare final package Medium = MediumA,
    m_flow_nominal=m_flow_nominal,
    riseTime=15,
    final dpDamper_nominal=datVAV.dpEcoDam,
    final dpFixed_nominal=datVAV.dpEcoFix) "Return air damper"
    annotation (Placement(transformation(
        origin={0,-10},
        extent={{10,-10},{-10,10}},
        rotation=90)));
  Buildings.Fluid.Actuators.Dampers.Exponential damOut(
    redeclare final package Medium = MediumA,
    m_flow_nominal=m_flow_nominal,
    from_dp=true,
    riseTime=15,
    final dpDamper_nominal=datVAV.dpEcoDam,
    final dpFixed_nominal=datVAV.dpEcoFix) "Outdoor air damper" annotation (Placement(transformation(extent={{-50,-50},{-30,-30}})));

  Buildings.Fluid.Actuators.Valves.TwoWayEqualPercentage valHea(
    redeclare final package Medium = MediumW,
    final m_flow_nominal=datVAV.mLiqHeaCoi_flow,
    final dpValve_nominal=datVAV.dpValHeaCoi,
    final dpFixed_nominal=datVAV.dpLiqHeaCoi)
    "Heating coil valve"
    annotation (Placement(
        transformation(
        extent={{10,-10},{-10,10}},
        rotation=90,
        origin={80,-80})));
  Buildings.Fluid.Actuators.Valves.TwoWayEqualPercentage valCoo(
    redeclare final package Medium = MediumW,
    final m_flow_nominal=datVAV.mLiqCooCoi_flow,
    final dpValve_nominal=datVAV.dpValCooCoi,
    final dpFixed_nominal=datVAV.dpLiqCooCoi)
    "Cooling coil valve" annotation (Placement(
        transformation(
        extent={{10,-10},{-10,10}},
        rotation=90,
        origin={180,-80})));
  Buildings.Fluid.Actuators.Valves.TwoWayEqualPercentage valReh[numVAV](
    redeclare each final package Medium = MediumW,
    final m_flow_nominal=datVAV.mLiqRehCoi_flow,
    final dpValve_nominal=datVAV.dpValRehCoi,
    final dpFixed_nominal=datVAV.dpLiqRehCoi)
    "Reheat coil valve"
    annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=0,
        origin={540,28})));
  Buildings.Controls.OBC.CDL.Continuous.MultiMax maxHea(
    nin=1 + numVAV) "Compute max signal"
    annotation (Placement(transformation(extent={{760,150},{780,170}})));
  Buildings.Controls.OBC.CDL.Continuous.MultiMax maxCoo(nin=1) "Compute max signal"
    annotation (Placement(transformation(extent={{760,110},{780,130}})));
  Buildings.Fluid.FixedResistances.PressureDrop dpSupDuc(
    final m_flow_nominal=m_flow_nominal,
    redeclare final package Medium = MediumA,
    final allowFlowReversal=allowFlowReversal,
    final dp_nominal=datVAV.dpDucSup) "Duct pressure drop"
    annotation (Placement(transformation(extent={{460,-50},{480,-30}})));
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
  connect(valReh.y_actual, maxHea.u[2:numVAV+1]);

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
      points={{-120,-38.8},{-94,-38.8},{-94,-40},{-90,-40}},
      color={0,127,255},
      smooth=Smooth.None,
      thickness=0.5));

  connect(weaBus.TDryBul, TOut.u) annotation (Line(
      points={{-320,180},{-302,180}},
      color={255,204,51},
      thickness=0.5,
      smooth=Smooth.None));
  connect(amb.weaBus, weaBus) annotation (Line(
      points={{-142,-40.78},{-320,-40.78},{-320,180}},
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
        points={{360,140},{460,140}},
        color={0,127,255},
        smooth=Smooth.None,
        thickness=0.5));
  connect(TSup.port_b, senSupFlo.port_a)
    annotation (Line(
      points={{350,-40},{400,-40}},
      color={0,127,255},
      smooth=Smooth.None,
      thickness=0.5));

  connect(dpDisSupFan.port_b, amb.ports[2]) annotation (Line(
      points={{320,10},{320,14},{-100,14},{-100,-43.2},{-120,-43.2}},
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
      points={{50,-40},{90,-40}},
      color={0,127,255},
      thickness=0.5));
  connect(heaCoi.port_b2, cooCoi.port_a2)
    annotation (Line(
      points={{110,-40},{190,-40}},
      color={0,127,255},
      thickness=0.5));

  for i in 1:numVAV loop
  end for;

  for i in 1:(numVAV-1) loop
    connect(splSupRoo[i].port_2, splSupRoo[i+1].port_1);
  end for;
  for i in 1:(numRet-1) loop
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

  connect(splRetRoo.port_3, ports_a) annotation (Line(points={{680,10},{680,100}}, color={0,127,255}));
  connect(VAVBox.port_bAir, ports_b) annotation (Line(points={{600,60},{600,100}}, color={0,127,255}));
  connect(splSupRoo.port_3, VAVBox.port_aAir) annotation (Line(points={{600,-30},{600,20}}, color={0,127,255}));
  connect(dpRetDuc.port_a, splRetRoo[1].port_2)
    annotation (Line(points={{480,140},{700,140},{700,0},{690,0}}, color={0,127,255}));
  connect(heaCoi.port_a1, port_coiHeaSup) annotation (Line(points={{110,-52},{120,-52},{120,-400}}, color={0,127,255}));
  connect(VAVBox.port_aHotWat, port_coiRehSup)
    annotation (Line(points={{580,40},{560,40},{560,-400}}, color={0,127,255}));
  connect(heaCoi.port_b1, valHea.port_a) annotation (Line(points={{90,-52},{80,-52},
          {80,-70}},                                                                           color={0,127,255}));
  connect(valHea.port_b, port_coiHeaRet) annotation (Line(points={{80,-90},{80,-400}},  color={0,127,255}));
  connect(cooCoi.port_b1, valCoo.port_a) annotation (Line(points={{190,-52},{180,
          -52},{180,-70}},                                                                        color={0,127,255}));
  connect(valCoo.port_b, port_coiCooRet) annotation (Line(points={{180,-90},{180,
          -400}},                                                                         color={0,127,255}));
  connect(VAVBox.port_bHotWat, valReh.port_a) annotation (Line(points={{580,28},{550,28}}, color={0,127,255}));
  connect(valReh.port_b, port_coiRehRet) annotation (Line(points={{530,28},{520,28},{520,-400}}, color={0,127,255}));
  connect(maxHea.y, yValHeaMax_actual) annotation (Line(points={{782,160},{820,160}}, color={0,0,127}));
  connect(maxCoo.y, yValCooMax_actual) annotation (Line(points={{782,120},{820,120}}, color={0,0,127}));
  connect(valHea.y_actual, maxHea.u[1])
    annotation (Line(points={{73,-85},{73,-100},{736,-100},{736,160},{758,160}},  color={0,0,127}));
  connect(valCoo.y_actual, maxCoo.u[1])
    annotation (Line(points={{173,-85},{173,-98},{740,-98},{740,120},{758,120}},    color={0,0,127}));
  connect(senSupFlo.port_b, dpSupDuc.port_a) annotation (Line(points={{420,-40},{460,-40}}, color={0,127,255}));
  connect(dpSupDuc.port_b, splSupRoo[1].port_1) annotation (Line(points={{480,-40},{590,-40}}, color={0,127,255}));
  connect(cooCoi.port_a1, port_coiCooSup) annotation (Line(points={{210,-52},{220,
          -52},{220,-400}}, color={0,127,255}));
  annotation (Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-400,-400},{800,300}})),
                                 Documentation(info="<html>
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
