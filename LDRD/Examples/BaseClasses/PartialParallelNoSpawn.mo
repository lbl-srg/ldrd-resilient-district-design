within LDRD.Examples.BaseClasses;
partial model PartialParallelNoSpawn "Partial model for parallel network"
  extends Modelica.Icons.Example;
  package Medium = Buildings.Media.Water "Medium model";
  constant Real facMul = 10
    "Building loads multiplier factor";
  parameter Boolean allowFlowReversalSer = true
    "Set to true to allow flow reversal in the service lines"
    annotation(Dialog(tab="Assumptions"), Evaluate=true);
  parameter Boolean allowFlowReversalBui = false
    "Set to true to allow flow reversal for in-building systems"
    annotation(Dialog(tab="Assumptions"), Evaluate=true);
  parameter Integer nBui = datDes.nBui
    "Number of buildings connected to DHC system"
    annotation (Evaluate=true);
  parameter Integer idxBuiTim[nBui] = {1,2}
    "Indices of building models based on time series"
    annotation (Evaluate=true);
  inner Data.VAVDataMediumOffice datVAV
    "Spawn building data"
    annotation (Placement(transformation(extent={{-340,180},{-320,200}})));
  inner parameter Data.DesignDataSpawn datDes(
    final mCon_flow_nominal=bui.mSerWat_flow_nominal)
    "Design data" annotation (Placement(transformation(extent={{-340,220},{-320,240}})));
  // COMPONENTS
  Buildings.Experimental.DHC.Examples.Combined.Generation5.ThermalStorages.BoreField
    borFie(redeclare final package Medium = Medium)
    "Bore field"
    annotation (
      Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-130,-80})));
  Buildings.Experimental.DHC.EnergyTransferStations.BaseClasses.Pump_m_flow pumDis(
    redeclare final package Medium = Medium,
    final m_flow_nominal=datDes.mPumDis_flow_nominal)
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
    final m_flow_nominal=datDes.mSto_flow_nominal,
    final allowFlowReversal=allowFlowReversalSer) "Bore field pump" annotation (Placement(transformation(
        extent={{10,10},{-10,-10}},
        rotation=180,
        origin={-180,-80})));
  Buildings.Experimental.DHC.Examples.Combined.Generation5.Networks.BaseClasses.ConnectionSeriesStandard
    conPla(
    redeclare final package Medium = Medium,
    final mDis_flow_nominal=datDes.mPipDis_flow_nominal,
    final mCon_flow_nominal=datDes.mPla_flow_nominal,
    lDis=0,
    lCon=0,
    dhDis=0.2,
    dhCon=0.2,
    final allowFlowReversal=allowFlowReversalSer)
    "Connection to the plant (pressure drop lumped in plant and network model)"
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-80,-10})));
  Buildings.Experimental.DHC.Examples.Combined.Generation5.Networks.UnidirectionalParallel
    dis(
    redeclare final package Medium = Medium,
    final nCon=nBui,
    final dp_length_nominal=datDes.dp_length_nominal,
    final mDis_flow_nominal=datDes.mPipDis_flow_nominal,
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
    final mDis_flow_nominal=datDes.mPipDis_flow_nominal,
    final mCon_flow_nominal=datDes.mSto_flow_nominal,
    lDis=0,
    lCon=0,
    dhDis=0.2,
    dhCon=0.2,
    final allowFlowReversal=allowFlowReversalSer)
    "Connection to the bore field (pressure drop lumped in plant and network model)"
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-80,-90})));
  Buildings.Experimental.DHC.Examples.Combined.Generation5.CentralPlants.SewageHeatRecovery
    pla(
    redeclare package Medium = Medium,
    final mSew_flow_nominal=datDes.mPla_flow_nominal,
    final mDis_flow_nominal=datDes.mPla_flow_nominal,
    final dpSew_nominal=datDes.dpPla_nominal,
    final dpDis_nominal=datDes.dpPla_nominal,
    final epsHex=datDes.epsPla) "Sewage heat recovery plant"
    annotation (Placement(transformation(extent={{-160,-10},{-140,10}})));
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
    final m_flow_nominal=datDes.mPumDis_flow_nominal) "District water borefield leaving temperature" annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-80,-40})));
  replaceable Loads.BaseClasses.PartialBuildingWithETS bui[nBui]
    constrainedby Loads.BaseClasses.PartialBuildingWithETS(
      bui(each final facMul=facMul),
      redeclare each final package MediumBui = Medium,
      redeclare each final package MediumSer = Medium,
      each final allowFlowReversalBui=allowFlowReversalBui,
      each final allowFlowReversalSer=allowFlowReversalSer) "Building and ETS"
    annotation (Placement(transformation(extent={{-10,170},{10,190}})));
  Modelica.Blocks.Sources.Constant TSewWat(
    k=273.15 + 17)
    "Sewage water temperature"
    annotation (Placement(transformation(extent={{-280,30},{-260,50}})));
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
  /* Manual connections
  */
  /* Manual connections
  */
  connect(bou.ports[1], pumDis.port_a)
    annotation (Line(points={{102,-20},{80,-20},{80,-50}}, color={0,127,255}));
  connect(borFie.port_b, conSto.port_aCon) annotation (Line(points={{-120,-80},
          {-100,-80},{-100,-84},{-90,-84}}, color={0,127,255}));
  connect(pumDis.port_b, conSto.port_aDis) annotation (Line(points={{80,-70},{
          80,-120},{-80,-120},{-80,-100}}, color={0,127,255}));
  connect(borFie.port_a, pumSto.port_b)
    annotation (Line(points={{-140,-80},{-170,-80}}, color={0,127,255}));
  connect(conSto.port_bCon, pumSto.port_a) annotation (Line(points={{-90,-90},{
          -100,-90},{-100,-100},{-200,-100},{-200,-80},{-190,-80}}, color={0,
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
  connect(bui[idxBuiTim].port_bSerAmb, dis.ports_aCon[idxBuiTim]) annotation (Line(points={{10,180},{
          20,180},{20,160},{12,160},{12,150}}, color={0,127,255}));
  connect(dis.ports_bCon[idxBuiTim], bui[idxBuiTim].port_aSerAmb) annotation (Line(points={{-12,150},
          {-12,160},{-20,160},{-20,180},{-10,180}}, color={0,127,255}));
  connect(TSewWat.y, pla.TSewWat) annotation (Line(points={{-259,40},{-180,40},{-180,7.33333},{-161.333,7.33333}},
                              color={0,0,127}));
  connect(pla.port_bSerAmb, conPla.port_aCon) annotation (Line(points={{-140,1.33333},
          {-100,1.33333},{-100,-4},{-90,-4}}, color={0,127,255}));
  connect(conPla.port_bCon, pla.port_aSerAmb) annotation (Line(points={{-90,-10},
          {-100,-10},{-100,-20},{-200,-20},{-200,1.33333},{-160,1.33333}},
        color={0,127,255}));
  annotation (Diagram(
    coordinateSystem(preserveAspectRatio=false, extent={{-360,-260},{360,260}})),
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
end PartialParallelNoSpawn;
