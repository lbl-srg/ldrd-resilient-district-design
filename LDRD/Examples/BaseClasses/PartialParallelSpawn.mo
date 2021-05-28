within LDRD.Examples.BaseClasses;
partial model PartialParallelSpawn "Partial model for parallel network"
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
  parameter Integer idxBuiSpa = datDes.idxBuiSpa
    "Index of Spawn building model"
    annotation (Evaluate=true);
  parameter Integer idxBuiTim[nBui-1] = datDes.idxBuiTim
    "Indices of building models based on time series"
    annotation (Evaluate=true);
  inner parameter Data.DesignDataSpawn datDes(
    final mCon_flow_nominal={if i == idxBuiSpa then buiSpa.mSerWat_flow_nominal else bui[i].mSerWat_flow_nominal
      for i in 1:nBui})
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
  replaceable Loads.BaseClasses.PartialBuildingWithETS bui[nBui - 1]
    constrainedby Loads.BaseClasses.PartialBuildingWithETS(
      bui(each final facMul=facMul),
      redeclare each final package MediumBui = Medium,
      redeclare each final package MediumSer = Medium,
      each final allowFlowReversalBui=allowFlowReversalBui,
      each final allowFlowReversalSer=allowFlowReversalSer) "Building and ETS"
    annotation (Placement(transformation(extent={{-10,170},{10,190}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant THeaWatSupMaxSet[nBui](
    k={if i == idxBuiSpa then buiSpa.THeaWatSup_nominal else bui[i].THeaWatSup_nominal for i in 1:nBui})
    "Heating water supply temperature set point - Maximum value"
    annotation (Placement(transformation(extent={{-250,210},{-230,230}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant TChiWatSupSet[nBui](
    k={if i == idxBuiSpa then buiSpa.TChiWatSup_nominal else bui[i].TChiWatSup_nominal for i in 1:nBui})
    "Chilled water supply temperature set point"
    annotation (Placement(transformation(extent={{-220,190},{-200,210}})));
  Modelica.Blocks.Sources.Constant TSewWat(
    k=273.15 + 17)
    "Sewage water temperature"
    annotation (Placement(transformation(extent={{-280,30},{-260,50}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant THeaWatSupMinSet[nBui](
    each k=28 + 273.15)
    "Heating water supply temperature set point - Minimum value"
    annotation (Placement(transformation(extent={{-280,230},{-260,250}})));
  Buildings.Experimental.DHC.Loads.BaseClasses.ConstraintViolation conVio(
    uMin=datDes.TLooMin,
    uMax=datDes.TLooMax,
    nu=3) "Check if loop temperatures are within given range"
    annotation (Placement(transformation(extent={{300,30},{320,50}})));
  Buildings.Controls.OBC.CDL.Continuous.MultiSum PPumETS(final nin=nBui) "ETS pump power"
    annotation (Placement(transformation(extent={{120,190},{140,210}})));
  Modelica.Blocks.Continuous.Integrator EPumETS(
    initType=Modelica.Blocks.Types.Init.InitialState)
    "ETS pump electric energy"
    annotation (Placement(transformation(extent={{200,190},{220,210}})));
  Modelica.Blocks.Continuous.Integrator EPumPla(
    initType=Modelica.Blocks.Types.Init.InitialState)
    "Plant pump electric energy"
    annotation (Placement(transformation(extent={{200,50},{220,70}})));
  Buildings.Controls.OBC.CDL.Continuous.MultiSum EPum(nin=4) "Total pump electric energy"
    annotation (Placement(transformation(extent={{260,110},{280,130}})));
  Buildings.Controls.OBC.CDL.Continuous.MultiSum PChi(final nin=nBui) "Chiller power"
    annotation (Placement(transformation(extent={{120,150},{140,170}})));
  Modelica.Blocks.Continuous.Integrator EChi(initType=Modelica.Blocks.Types.Init.InitialState)
    "Chiller electric energy" annotation (Placement(transformation(extent={{200,150},{220,170}})));
  Buildings.Controls.OBC.CDL.Continuous.MultiSum ETot(nin=2) "Total electric energy"
    annotation (Placement(transformation(extent={{300,150},{320,170}})));
  Modelica.Blocks.Continuous.Integrator EPumDis(initType=Modelica.Blocks.Types.Init.InitialState)
    "Distribution pump electric energy"
    annotation (Placement(transformation(extent={{200,-90},{220,-70}})));
  Modelica.Blocks.Continuous.Integrator EPumSto(initType=Modelica.Blocks.Types.Init.InitialState)
    "Storage pump electric energy"
    annotation (Placement(transformation(extent={{200,-150},{220,-130}})));
  replaceable Loads.BuildingSpawnWithETS buiSpa constrainedby
    Buildings.Experimental.DHC.Loads.BaseClasses.PartialBuildingWithPartialETS(
      redeclare final package MediumBui = Medium,
      redeclare final package MediumSer = Medium,
      final allowFlowReversalBui=allowFlowReversalBui,
      final allowFlowReversalSer=allowFlowReversalSer)
    "Spawn building model and ETS"
    annotation (Placement(transformation(extent={{40,150},{60,170}})));
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
  connect(bui.PCoo, PChi.u[idxBuiTim]);
  connect(buiSpa.PCoo, PChi.u[idxBuiSpa]);
  connect(bui.PPumETS, PPumETS.u[idxBuiTim]);
  connect(buiSpa.PPumETS, PPumETS.u[idxBuiSpa]);
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
  connect(THeaWatSupMaxSet[idxBuiTim].y, bui[idxBuiTim].THeaWatSupMaxSet) annotation (Line(points={{
          -228,220},{-20,220},{-20,187},{-12,187}}, color={0,0,127}));
  connect(TChiWatSupSet[idxBuiTim].y, bui[idxBuiTim].TChiWatSupSet) annotation (Line(points={{-198,
          200},{-24,200},{-24,185},{-12,185}}, color={0,0,127}));
  connect(TSewWat.y, pla.TSewWat) annotation (Line(points={{-259,40},{-180,40},{-180,7.33333},{-161.333,7.33333}},
                              color={0,0,127}));
  connect(pla.port_bSerAmb, conPla.port_aCon) annotation (Line(points={{-140,1.33333},
          {-100,1.33333},{-100,-4},{-90,-4}}, color={0,127,255}));
  connect(conPla.port_bCon, pla.port_aSerAmb) annotation (Line(points={{-90,-10},
          {-100,-10},{-100,-20},{-200,-20},{-200,1.33333},{-160,1.33333}},
        color={0,127,255}));
  connect(THeaWatSupMinSet[idxBuiTim].y, bui[idxBuiTim].THeaWatSupMinSet) annotation (Line(points={{
          -258,240},{-16,240},{-16,189},{-12,189}}, color={0,0,127}));
  connect(TDisWatSup.T, conVio.u[1]) annotation (Line(points={{-91,20},{-100,20},{-100,38.6667},{298,38.6667}},
                                         color={0,0,127}));
  connect(TDisWatRet.T, conVio.u[2]) annotation (Line(points={{69,0},{60,0},{60,
          40},{298,40}}, color={0,0,127}));
  connect(TDisWatBorLvg.T, conVio.u[3]) annotation (Line(points={{-91,-40},{-102,-40},{-102,41.3333},{298,41.3333}},
                                              color={0,0,127}));
  connect(PPumETS.y,EPumETS. u)
    annotation (Line(points={{142,200},{198,200}}, color={0,0,127}));
  connect(pla.PPum, EPumPla.u) annotation (Line(points={{-138.667,5.33333},{-108,5.33333},{-108,44},{180,44},{180,60},{
          198,60}},                                            color={0,0,127}));
  connect(EPumETS.y,EPum. u[1]) annotation (Line(points={{221,200},{240,200},{
          240,121.5},{258,121.5}},
                               color={0,0,127}));
  connect(EPumPla.y, EPum.u[2]) annotation (Line(points={{221,60},{240,60},{240,
          120.5},{258,120.5}}, color={0,0,127}));
  connect(EPumDis.y,EPum. u[3]) annotation (Line(points={{221,-80},{242,-80},{
          242,119.5},{258,119.5}},
                               color={0,0,127}));
  connect(EPumSto.y,EPum. u[4]) annotation (Line(points={{221,-140},{244,-140},
          {244,118.5},{258,118.5}},color={0,0,127}));
  connect(PChi.y, EChi.u) annotation (Line(points={{142,160},{198,160}}, color={0,0,127}));
  connect(EChi.y, ETot.u[1]) annotation (Line(points={{221,160},{280,160},{280,161},{298,161}}, color={0,0,127}));
  connect(EPum.y,ETot. u[2]) annotation (Line(points={{282,120},{290,120},{290,
          159},{298,159}}, color={0,0,127}));
  connect(pumDis.P, EPumDis.u)
    annotation (Line(points={{71,-71},{71,-80},{198,-80}}, color={0,0,127}));
  connect(pumSto.P, EPumSto.u) annotation (Line(points={{-169,-71},{-160,-71},{
          -160,-140},{198,-140}}, color={0,0,127}));
  connect(dis.ports_bCon[idxBuiSpa], buiSpa.port_aSerAmb)
    annotation (Line(points={{-12,150},{-12,160},{40,160}}, color={0,127,255}));
  connect(buiSpa.port_bSerAmb, dis.ports_aCon[idxBuiSpa])
    annotation (Line(points={{60,160},{80,160},{80,150},{12,150}}, color={0,127,255}));
  connect(TChiWatSupSet[idxBuiSpa].y, buiSpa.TChiWatSupSet)
    annotation (Line(points={{-198,200},{-40,200},{-40,165},{38,165}}, color={0,0,127}));
  connect(THeaWatSupMaxSet[idxBuiSpa].y, buiSpa.THeaWatSupMaxSet)
    annotation (Line(points={{-228,220},{28,220},{28,167},{38,167}}, color={0,0,127}));
  connect(THeaWatSupMinSet[idxBuiSpa].y, buiSpa.THeaWatSupMinSet)
    annotation (Line(points={{-258,240},{34,240},{34,169},{38,169}}, color={0,0,127}));
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
end PartialParallelSpawn;
