within LDRD.Examples;
model ParallelSpawnChillers
  "Parallel connection with central CHW plant and Spawn office building"
  extends BaseClasses.PartialParallelSpawn(
    final facMulTim={1, 10},
    final facMulSpa=10,
    redeclare
      Loads.BuildingTimeSeriesWithETS bui[nBui-1](final filNam=filNam),
    datDes(
      idxBuiSpa=3),
    dis(show_entFlo=true),
    conSto(show_entFlo=true),
    conPla(show_entFlo=true),
    PChi(nin=nBui+1),
    EPum(nin=4));

  parameter String filNam[nBui-1]={
    "modelica://LDRD/Resources/Loads/RefBldgHospitalNew2004_v1.4_7.2_5A_USA_IL_CHICAGO-OHARE.mos",
    "modelica://LDRD/Resources/Loads/RefBldgMidriseApartmentNew2004_v1.4_7.2_5A_USA_IL_CHICAGO-OHARE.mos"}
    "Library paths of the files with thermal loads as time series";

  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant dpDisSet(
    final k=datDes.dpPumDisSet)
    "DP set point"
    annotation (Placement(transformation(extent={{-20,-70},{0,-50}})));
  Buildings.Controls.OBC.CDL.Continuous.PID conPumDis(
    k=0.01,
    Ti=600,
    r=datDes.dpPumDisSet) "Distribution pump controller"
    annotation (Placement(transformation(extent={{30,-70},{50,-50}})));
  Buildings.Fluid.FixedResistances.PressureDrop bypEnd(
    redeclare final package Medium = Medium,
    final m_flow_nominal=datDes.mEnd_flow_nominal,
    from_dp=true,
    final dp_nominal=datDes.dpPumDisSet)
    "End of the line bypass (optional)"
    annotation (Placement(transformation(extent={{50,130},{70,150}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant masFloBorFie(final k=
        pumSto.m_flow_nominal) "Borefield nominal flow rate"
    annotation (Placement(transformation(extent={{-320,-170},{-300,-150}})));
  Buildings.Controls.OBC.CDL.Continuous.Min minFlo
    "Minimum between main flow and borefield nominal flow"
    annotation (Placement(transformation(extent={{-280,-140},{-260,-160}})));
  CentralPlants.Chillers plaCoo(
    redeclare final package Medium = Medium,
    final m_flow_nominal=datDes.mPla_flow_nominal)
    "Cooling plant"  annotation (
      Placement(transformation(
        extent={{-20,-20},{20,20}},
        rotation=90,
        origin={-160,0})));
  Modelica.Blocks.Continuous.Integrator ESto(initType=Modelica.Blocks.Types.Init.InitialState)
    "Stored energy"
    annotation (Placement(transformation(extent={{200,-70},{220,-50}})));
  Modelica.Blocks.Continuous.Integrator EPumPla(initType=Modelica.Blocks.Types.Init.InitialState)
    "Plant pump energy"
    annotation (Placement(transformation(extent={{200,50},{220,70}})));
  Modelica.Blocks.Continuous.Integrator EFanPla(initType=Modelica.Blocks.Types.Init.InitialState)
    "Plant fan electric energy"
    annotation (Placement(transformation(extent={{200,90},{220,110}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant zer(final k=0) "Zero"
    annotation (Placement(transformation(extent={{160,90},{180,110}})));
equation
  connect(plaCoo.PCoo, PChi.u[4]);
  connect(dis.dp, conPumDis.u_m) annotation (Line(points={{22,143},{40,143},{40,
          -40},{20,-40},{20,-80},{40,-80},{40,-72}}, color={0,0,127}));
  connect(conPumDis.y, pumDis.y)
    annotation (Line(points={{52,-60},{68,-60}}, color={0,0,127}));
  connect(dpDisSet.y, conPumDis.u_s)
    annotation (Line(points={{2,-60},{28,-60}}, color={0,0,127}));
  connect(dis.port_bDisSup, bypEnd.port_a)
    annotation (Line(points={{20,140},{50,140}}, color={0,0,127}));
  connect(bypEnd.port_b, dis.port_aDisRet) annotation (Line(points={{70,140},{80,
          140},{80,134},{20,134}}, color={0,127,255}));
  connect(mDisWat_flow.m_flow, minFlo.u2) annotation (Line(points={{0,-109},{0,
          -104},{-292,-104},{-292,-144},{-282,-144}},
                                              color={0,0,127}));
  connect(masFloBorFie.y, minFlo.u1) annotation (Line(points={{-298,-160},{-294,
          -160},{-294,-156},{-282,-156}},
                                  color={0,0,127}));
  connect(minFlo.y, pumSto.m_flow_in) annotation (Line(points={{-258,-150},{
          -200,-150},{-200,-132}},
                            color={0,0,127}));
  connect(TDisWatBorLvg.T,plaCoo. TWatEnt) annotation (Line(points={{-91,-40},{
          -170.667,-40},{-170.667,-22.6667}},
                                     color={0,0,127}));
  connect(conPla.port_bCon,plaCoo. port_aSerAmb) annotation (Line(points={{-90,-10},
          {-110,-10},{-110,-30},{-162.667,-30},{-162.667,-20}}, color={0,127,255}));
  connect(plaCoo.port_bSerAmb, conPla.port_aCon) annotation (Line(points={{
          -162.667,20},{-162.667,26},{-162.667,30},{-110,30},{-110,-4},{-90,-4}},
                                                                 color={0,127,255}));
  connect(plaCoo.weaBus, buiSpa.weaBus) annotation (Line(
      points={{-177.733,0.0666667},{-200,0.0666667},{-200,200},{50,200},{50,170}},
      color={255,204,51},
      thickness=0.5));

  connect(mDisWat_flow.m_flow,plaCoo. m_flow) annotation (Line(points={{0,-109},
          {0,-104},{-174,-104},{-174,-22.6667},{-174.667,-22.6667}},
                      color={0,0,127}));
  connect(conSto.dH_flow, ESto.u) annotation (Line(points={{-87,-78},{180,-78},
          {180,-60},{198,-60}}, color={215,215,215}));
  connect(plaCoo.PPum, EPumPla.u) annotation (Line(points={{-170.667,22.6667},{
          -170.667,60},{198,60}}, color={215,215,215}));
  connect(EPumPla.y, EPum.u[4]) annotation (Line(points={{221,60},{240,60},{240,
          120},{258,120}}, color={0,0,127}));
  connect(conPla.dH_flow, EPla.u)
    annotation (Line(points={{-87,2},{-87,10},{198,10}}, color={0,0,127}));
  connect(zer.y, EFanPla.u)
    annotation (Line(points={{182,100},{198,100}}, color={0,0,127}));
  connect(uEnaChi[1].y[1], plaCoo.uEna) annotation (Line(points={{-318,180},{
          -220,180},{-220,-40},{-178.667,-40},{-178.667,-22.6667}}, color={255,
          0,255}));
  annotation (
  Diagram(
  coordinateSystem(preserveAspectRatio=false, extent={{-360,-260},{360,260}})),
  experiment(
      StopTime=158112000,
      Tolerance=1e-06,
      __Dymola_NumberOfIntervals=43800,
      __Dymola_Algorithm="Cvode",
      __Dymola_experimentSetupOutput(equidistant=true, events=false)));
end ParallelSpawnChillers;
