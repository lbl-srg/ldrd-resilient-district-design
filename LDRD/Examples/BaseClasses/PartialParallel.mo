within LDRD.Examples.BaseClasses;
partial model PartialParallel "Partial model for parallel network"
  extends Modelica.Icons.Example;
  package Medium = Buildings.Media.Water "Medium model";

  parameter String weaName=
    "modelica://LDRD/Resources/WeatherData/USA_IL_Chicago-OHare.Intl.AP.725300_modified.mos"
    "Name of the weather file";
  parameter Real facMulTim[nBui] = fill(1, nBui)
    "Building loads multiplier factor - Time series"
    annotation(Evaluate=true);
  parameter Boolean allowFlowReversalSer = true
    "Set to true to allow flow reversal in the service lines"
    annotation(Dialog(tab="Assumptions"), Evaluate=true);
  parameter Boolean allowFlowReversalBui = false
    "Set to true to allow flow reversal for in-building systems"
    annotation(Dialog(tab="Assumptions"), Evaluate=true);
  parameter Integer nBui = datDes.nBui
    "Number of buildings connected to DHC system"
    annotation (Evaluate=true);

  inner parameter Data.DesignData datDes(final mCon_flow_nominal=bui.mSerWat_flow_nominal)
    "Design data"
    annotation (Placement(transformation(extent={{-340,220},{-320,240}})));
  // COMPONENTS
  replaceable ThermalStorages.BoreField_500_180 borFie
    constrainedby ThermalStorages.BoreField_500_180(
      redeclare each final package Medium =Medium)
    "Bore field"
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-230,-80})));
  Buildings.Fluid.Movers.SpeedControlled_y  pumDis(
    redeclare final package Medium = Medium,
    energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyState,
    per(
      pressure(V_flow={0,1,2}*datDes.mPumDis_flow_nominal/1000,
      dp = {1.2,1,0}*datDes.dpPumDis_nominal),
      motorCooledByFluid=false),
    addPowerToMedium=false,
    use_inputFilter=true)
    "Distribution pump"
    annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=90,
        origin={80,-60})));
  Buildings.Fluid.Sources.Boundary_pT bou(
    redeclare final package Medium=Medium,
    nPorts=1)
    "Boundary pressure condition representing the expansion vessel"
    annotation (Placement(transformation(
      extent={{-10,-10},{10,10}},
      rotation=180,
      origin={112,-20})));
  Buildings.Experimental.DHC.EnergyTransferStations.BaseClasses.Pump_m_flow pumSto(
    redeclare final package Medium = Medium,
    final m_flow_nominal=borFie.borFieDat.conDat.mBorFie_flow_nominal,
    final allowFlowReversal=allowFlowReversalSer) "Bore field pump" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=180,
        origin={-200,-120})));
  Buildings.Experimental.DHC.Examples.Combined.Generation5.Networks.BaseClasses.ConnectionSeriesStandard
    conPla(
    redeclare final package Medium = Medium,
    show_entFlo=true,
    final mDis_flow_nominal=datDes.mPumDis_flow_nominal,
    final mCon_flow_nominal=datDes.mPla_flow_nominal,
    lDis=0,
    lCon=0,
    dhDis=0.2,
    dhCon=0.2,
    final allowFlowReversal=allowFlowReversalSer)
    "Connection to the plant (no pressure drop, 0 pipe length)"
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-80,-10})));
  Buildings.Experimental.DHC.Examples.Combined.Generation5.Networks.UnidirectionalParallel
    dis(
    redeclare final package Medium = Medium,
    final nCon=nBui,
    final dp_length_nominal=datDes.dp_length_nominal,
    final mDis_flow_nominal=datDes.mPumDis_flow_nominal,
    final mCon_flow_nominal=datDes.mCon_flow_nominal,
    final mDisCon_flow_nominal=datDes.mDisCon_flow_nominal,
    final mEnd_flow_nominal=datDes.mEnd_flow_nominal,
    final lDis=datDes.lDis,
    final lCon=datDes.lCon,
    final lEnd=datDes.lEnd,
    final allowFlowReversal=allowFlowReversalSer) "Distribution network"
    annotation (Placement(transformation(extent={{-20,130},{20,150}})));
  Buildings.Experimental.DHC.Examples.Combined.Generation5.Networks.BaseClasses.ConnectionSeriesStandard
    conSto(
    redeclare final package Medium = Medium,
    final mDis_flow_nominal=datDes.mPumDis_flow_nominal,
    final mCon_flow_nominal=pumSto.m_flow_nominal,
    lDis=0,
    lCon=0,
    dhDis=0.2,
    dhCon=0.2,
    final allowFlowReversal=allowFlowReversalSer)
    "Connection to the bore field (no pressure drop, 0 pipe length)"
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-80,-90})));
  Buildings.Fluid.Sensors.TemperatureTwoPort TDisWatSup(
    redeclare final package Medium = Medium,
    final m_flow_nominal=datDes.mPumDis_flow_nominal) "District water supply temperature"
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-80,20})));
  Buildings.Fluid.Sensors.TemperatureTwoPort TDisWatRet(
    redeclare final package Medium = Medium,
    final m_flow_nominal=datDes.mPumDis_flow_nominal) "District water return temperature"
    annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=90,
        origin={80,0})));
  Buildings.Fluid.Sensors.TemperatureTwoPort TDisWatBorLvg(
    redeclare final package Medium = Medium,
    final m_flow_nominal=datDes.mPumDis_flow_nominal)
    "District water borefield leaving temperature"
    annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-80,-40})));
  replaceable Loads.BuildingTimeSeriesWithETS bui[nBui]
    constrainedby Loads.BaseClasses.PartialBuildingWithETS(
      bui(final facMul=facMulTim),
      redeclare each final package MediumBui = Medium,
      redeclare each final package MediumSer = Medium,
      each final allowFlowReversalBui=allowFlowReversalBui,
      each final allowFlowReversalSer=allowFlowReversalSer) "Building and ETS"
    annotation (Placement(transformation(extent={{-10,170},{10,190}})));
  Buildings.Controls.OBC.CDL.Continuous.MultiSum PPumETS(
    final nin=nBui)
    "ETS pump power"
    annotation (Placement(transformation(extent={{120,190},{140,210}})));
  Modelica.Blocks.Continuous.Integrator EPumETS(
    initType=Modelica.Blocks.Types.Init.InitialState)
    "ETS pump electric energy"
    annotation (Placement(transformation(extent={{200,190},{220,210}})));
  Buildings.Controls.OBC.CDL.Continuous.MultiSum EPum(nin=3) "Total pump electric energy"
    annotation (Placement(transformation(extent={{260,110},{280,130}})));
  Buildings.Controls.OBC.CDL.Continuous.MultiSum PChi(
    final nin=nBui)
    "Chiller power"
    annotation (Placement(transformation(extent={{120,150},{140,170}})));
  Modelica.Blocks.Continuous.Integrator EChi(initType=Modelica.Blocks.Types.Init.InitialState)
    "Chiller electric energy" annotation (Placement(transformation(extent={{200,150},{220,170}})));
  Buildings.Controls.OBC.CDL.Continuous.MultiSum ETot(nin=2) "Total electric energy"
    annotation (Placement(transformation(extent={{300,150},{320,170}})));
  Modelica.Blocks.Continuous.Integrator EPumDis(initType=Modelica.Blocks.Types.Init.InitialState)
    "Distribution pump electric energy"
    annotation (Placement(transformation(extent={{200,-110},{220,-90}})));
  Modelica.Blocks.Continuous.Integrator EPumSto(initType=Modelica.Blocks.Types.Init.InitialState)
    "Storage pump electric energy"
    annotation (Placement(transformation(extent={{200,-150},{220,-130}})));
  Buildings.Fluid.Sensors.MassFlowRate mDisWat_flow(redeclare final package
      Medium = Medium) "District water mass flow rate" annotation (Placement(
        transformation(
        extent={{10,-10},{-10,10}},
        rotation=0,
        origin={0,-120})));
  Modelica.Blocks.Continuous.Integrator EPla(initType=Modelica.Blocks.Types.Init.InitialState)
    "Pant energy"
    annotation (Placement(transformation(extent={{200,0},{220,20}})));
  Buildings.Experimental.DHC.Examples.Combined.Generation5.Networks.BaseClasses.ConnectionSeriesStandard
    conCoo(
    redeclare final package Medium = Medium,
    show_entFlo=true,
    final mDis_flow_nominal=pumSto.m_flow_nominal,
    final mCon_flow_nominal=pumSto.m_flow_nominal,
    lDis=0,
    lCon=0,
    dhDis=0.2,
    dhCon=0.2,
    final allowFlowReversal=allowFlowReversalSer)
    "Connection to optional cooler (no pressure drop, 0 pipe length)"
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-150,-80})));
  Buildings.Fluid.Sensors.TemperatureTwoPort TCooEnt(redeclare final package
      Medium = Medium, final m_flow_nominal=datDes.mPumDis_flow_nominal)
    "Cooler entering temperature"   annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-200,-80})));
  Buildings.Fluid.Sensors.TemperatureTwoPort TCooLvg(redeclare final package
      Medium = Medium, final m_flow_nominal=datDes.mPumDis_flow_nominal)
    "Cooler leaving temperature" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-120,-80})));
  Buildings.BoundaryConditions.WeatherData.ReaderTMY3 weaDat(
    final filNam=Modelica.Utilities.Files.loadResource(weaName),
    computeWetBulbTemperature=true)
    "Weather data reader"
    annotation (Placement(transformation(extent={{-340,-10},{-320,10}})));
  Buildings.Controls.OBC.CDL.Logical.Sources.TimeTable uEnaChi[nBui](
    each table=[0,1; 17020800,0; 17625600,1],
    each period=31622400.0)
    "Enable chiller compressor"
    annotation (Placement(transformation(extent={{-340,170},{-320,190}})));
initial equation
  for i in 1:nBui loop
    Modelica.Utilities.Streams.print(
      "Nominal mass flow rate in section " + String(i) + ": " +
      String(datDes.mDisCon_flow_nominal[i]));
  end for;
  Modelica.Utilities.Streams.print(
    "Nominal mass flow rate in end of line: " +
    String(dis.mEnd_flow_nominal));
equation
    connect(borFie.port_a, pumSto.port_b)
      annotation (Line(points={{-240,-80},{-260,-80},{-260,-120},{-210,-120}},
                                                       color={0,127,255}));
    connect(borFie.port_b,TCooEnt. port_a)
      annotation (Line(points={{-220,-80},{-210,-80}}, color={0,127,255}));
  connect(bou.ports[1], pumDis.port_a)
    annotation (Line(points={{102,-20},{80,-20},{80,-50}}, color={0,127,255}));

  connect(conSto.port_bCon, pumSto.port_a) annotation (Line(points={{-90,-90},{
          -100,-90},{-100,-120},{-190,-120}},                       color={0,
          127,255}));
  connect(conPla.port_bDis, TDisWatSup.port_a)
    annotation (Line(points={{-80,0},{-80,10}}, color={0,127,255}));
  connect(TDisWatSup.port_b, dis.port_aDisSup) annotation (Line(points={{-80,30},
          {-80,140},{-20,140}}, color={0,127,255}));
  connect(dis.port_bDisRet, TDisWatRet.port_a) annotation (Line(points={{-20,134},
          {-40,134},{-40,120},{80,120},{80,10}},
                                    color={0,127,255}));
  connect(TDisWatRet.port_b, pumDis.port_a) annotation (Line(points={{80,-10},{
          80,-50}},                color={0,127,255}));
  connect(conSto.port_bDis, TDisWatBorLvg.port_a)
    annotation (Line(points={{-80,-80},{-80,-50}}, color={0,127,255}));
  connect(TDisWatBorLvg.port_b, conPla.port_aDis)
    annotation (Line(points={{-80,-30},{-80,-20}}, color={0,127,255}));
  connect(bui.port_bSerAmb, dis.ports_aCon) annotation (Line(points={{10,180},{
          20,180},{20,160},{12,160},{12,150}}, color={0,127,255}));
  connect(dis.ports_bCon, bui.port_aSerAmb) annotation (Line(points={{-12,150},
          {-12,160},{-20,160},{-20,180},{-10,180}}, color={0,127,255}));
  connect(PPumETS.y,EPumETS. u)
    annotation (Line(points={{142,200},{198,200}}, color={0,0,127}));
  connect(EPumETS.y,EPum. u[1]) annotation (Line(points={{221,200},{240,200},{
          240,121.333},{258,121.333}},
                               color={0,0,127}));
  connect(EPumDis.y,EPum. u[2]) annotation (Line(points={{221,-100},{242,-100},
          {242,120},{258,120}},color={0,0,127}));
  connect(EPumSto.y,EPum. u[3]) annotation (Line(points={{221,-140},{244,-140},
          {244,118.667},{258,118.667}},
                                   color={0,0,127}));
  connect(PChi.y, EChi.u) annotation (Line(points={{142,160},{198,160}}, color={0,0,127}));
  connect(EChi.y, ETot.u[1]) annotation (Line(points={{221,160},{280,160},{280,161},{298,161}}, color={0,0,127}));
  connect(EPum.y,ETot. u[2]) annotation (Line(points={{282,120},{290,120},{290,
          159},{298,159}}, color={0,0,127}));
  connect(pumDis.P, EPumDis.u)
    annotation (Line(points={{71,-71},{71,-100},{198,-100}},
                                                           color={0,0,127}));
  connect(pumSto.P, EPumSto.u) annotation (Line(points={{-211,-129},{-220,-129},
          {-220,-140},{198,-140}},color={0,0,127}));
  connect(pumDis.port_b, mDisWat_flow.port_a) annotation (Line(points={{80,-70},
          {80,-120},{10,-120}}, color={0,127,255}));
  connect(mDisWat_flow.port_b, conSto.port_aDis) annotation (Line(points={{-10,
          -120},{-80,-120},{-80,-100}}, color={0,127,255}));

  connect(TCooEnt.port_b, conCoo.port_aDis)
    annotation (Line(points={{-190,-80},{-160,-80}}, color={0,127,255}));
  connect(conCoo.port_bDis, TCooLvg.port_a)
    annotation (Line(points={{-140,-80},{-130,-80}}, color={0,127,255}));
  connect(TCooLvg.port_b, conSto.port_aCon) annotation (Line(points={{-110,-80},
          {-100,-80},{-100,-84},{-90,-84}}, color={0,127,255}));
  connect(bui.PPum, PPumETS.u) annotation (Line(points={{12,183},{66,183},{66,200},
          {118,200}}, color={0,0,127}));
  connect(bui.PCoo, PChi.u) annotation (Line(points={{12,187},{60,187},{60,160},
          {118,160}}, color={0,0,127}));
  connect(uEnaChi.y[1], bui.uEnaChi) annotation (Line(points={{-318,180},{-40,180},
          {-40,186},{-12,186}}, color={255,0,255}));
  annotation (Diagram(
    coordinateSystem(preserveAspectRatio=false, extent={{-360,-260},{360,260}}),
        graphics={Text(
          extent={{-256,232},{-130,210}},
          lineColor={28,108,200},
          textString="Resilience week
{'start': 17020800.0, 'end': 17625600.0}")}),
    Documentation(revisions="<html>
<ul>
<li>
February 23, 2021, by Antoine Gautier:<br/>
First implementation.
</li>
</ul>
</html>", info="<html>
<p>
Partial model with ETS connected in parallel.
Models extending this model must add controls,
and configure some component sizes.
</p>
</html>"));
end PartialParallel;
