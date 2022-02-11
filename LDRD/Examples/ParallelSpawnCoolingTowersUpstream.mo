within LDRD.Examples;
model ParallelSpawnCoolingTowersUpstream
  "Parallel connection with central cooling towers and Spawn office building"
  extends BaseClasses.PartialParallelSpawnUpstream(
    final facMulTim={1, 10},
    final facMulSpa=10,
    redeclare
      Loads.BuildingTimeSeriesWithETS bui[nBui-1](final filNam=filNam),
    datDes(
      idxBuiSpa=3,
      dp_length_nominal=250,
      dpPumDisSet=dpPumDisSet),
    dis(show_entFlo=true),
    conSto(show_entFlo=true),
    conPla(show_entFlo=true),
    EPum(nin=4));
  /*
  Differential pressure set point takes valve + HX nominal pressure drop,
  assuming 50% authority for the control valve.
  */
  parameter Modelica.SIunits.PressureDifference dpPumDisSet=
    2 * (max(buiSpa.ets.dp1Hex_nominal, buiSpa.ets.dp1WSE_nominal) +
    datDes.dp_length_nominal * datDes.lCon[nBui])
    "Differential pressure set point at remote location";

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
  replaceable CentralPlants.CoolingTowers plaCoo
    constrainedby
    Buildings.Experimental.DHC.CentralPlants.BaseClasses.PartialPlant(
      redeclare final package Medium = Medium,
      final m_flow_nominal=datDes.mPla_flow_nominal)
    "Cooling plant"
    annotation (Placement(transformation(
        extent={{-20,-20},{20,20}},
        rotation=90,
        origin={-160,-80})));
  Modelica.Blocks.Continuous.Integrator ESto(initType=Modelica.Blocks.Types.Init.InitialState)
    "Stored energy"
    annotation (Placement(transformation(extent={{200,-70},{220,-50}})));
  Modelica.Blocks.Continuous.Integrator EPumPla(initType=Modelica.Blocks.Types.Init.InitialState)
    "Plant pump energy"
    annotation (Placement(transformation(extent={{200,50},{220,70}})));
  Modelica.Blocks.Continuous.Integrator EFanPla(initType=Modelica.Blocks.Types.Init.InitialState)
    "Plant fan electric energy"
    annotation (Placement(transformation(extent={{200,90},{220,110}})));
equation
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
  connect(mDisWat_flow.m_flow, minFlo.u2) annotation (Line(points={{0,-169},{0,
          -120},{-300,-120},{-300,-144},{-282,-144}},
                                              color={0,0,127}));
  connect(masFloBorFie.y, minFlo.u1) annotation (Line(points={{-298,-160},{-294,
          -160},{-294,-156},{-282,-156}},
                                  color={0,0,127}));
  connect(minFlo.y, pumSto.m_flow_in) annotation (Line(points={{-258,-150},{
          -200,-150},{-200,-52}},
                            color={0,0,127}));
  connect(conPla.port_bCon,plaCoo. port_aSerAmb) annotation (Line(points={{-90,-90},
          {-100,-90},{-100,-108},{-162.667,-108},{-162.667,-100}},
                                                                color={0,127,255}));
  connect(plaCoo.port_bSerAmb, conPla.port_aCon) annotation (Line(points={{
          -162.667,-60},{-162.667,-54},{-100,-54},{-100,-84},{-90,-84}},
                                                                 color={0,127,255}));
  connect(plaCoo.weaBus, buiSpa.weaBus) annotation (Line(
      points={{-177.733,-79.9333},{-280,-79.9333},{-280,200},{50,200},{50,170}},
      color={255,204,51},
      thickness=0.5));

  connect(mDisWat_flow.m_flow,plaCoo. m_flow) annotation (Line(points={{0,-169},
          {0,-120},{-178,-120},{-178,-102.667},{-177.333,-102.667}},
                      color={0,0,127}));
  connect(conSto.dH_flow, ESto.u) annotation (Line(points={{-87,2},{-86,2},{-86,
          6},{180,6},{180,-60},{198,-60}},
                                color={215,215,215}));
  connect(plaCoo.PPum, EPumPla.u) annotation (Line(points={{-170.667,-57.3333},
          {-170.667,60},{198,60}},color={215,215,215}));
  connect(plaCoo.PFan, EFanPla.u) annotation (Line(points={{-173.333,-57.3333},
          {-173.333,100},{198,100}},color={215,215,215}));
  connect(EPumPla.y, EPum.u[4]) annotation (Line(points={{221,60},{240,60},{240,
          120},{258,120}}, color={0,0,127}));
  connect(conPla.dH_flow, EPla.u)
    annotation (Line(points={{-87,-78},{-87,-74},{-60,-74},{-60,-200},{198,-200}},
                                                         color={0,0,127}));
  connect(TDisWatRet.T, plaCoo.TWatEnt) annotation (Line(points={{69,
          8.88178e-16},{-40,8.88178e-16},{-40,-118},{-173.333,-118},{-173.333,
          -102.667}}, color={0,0,127}));
  connect(TDisWatBorEnt.T, plaCoo.TWatLvg) annotation (Line(points={{-91,-50},{
          -120,-50},{-120,-114},{-169.333,-114},{-169.333,-102.667}}, color={0,
          0,127}));
  annotation (
  Diagram(
  coordinateSystem(preserveAspectRatio=false, extent={{-360,-260},{360,260}})),
  experiment(
      StopTime=63244800,
      __Dymola_NumberOfIntervals=17520,
      Tolerance=1e-06,
      __Dymola_Algorithm="Cvode"),
    Documentation(revisions="<html>
<ul>
<li>
February 23, 2021, by Antoine Gautier:<br/>
First implementation.
</li>
</ul>
</html>", info="<html>
<p>
This model is identical to
<a href=\"Buildings.Experimental.DHC.Examples.Combined.Generation5.Examples.SeriesConstantFlow\">
Buildings.Experimental.DHC.Examples.Combined.Generation5.Examples.SeriesConstantFlow</a>
except for the energy transfer stations that are connected in parallel and
for the pipe sizing parameters that are adjusted consequently.
</p>
</html>"));
end ParallelSpawnCoolingTowersUpstream;
