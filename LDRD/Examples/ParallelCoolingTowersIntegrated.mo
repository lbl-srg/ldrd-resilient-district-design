within LDRD.Examples;
model ParallelCoolingTowersIntegrated
  "Example of parallel connection with constant district water mass flow rate"
  extends BaseClasses.PartialParallel(
    final facMulTim={1, 10, 10},
    redeclare
      Loads.BuildingTimeSeriesWithETS bui[nBui](final filNam=filNam),
    datDes(
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
    2 * (max(bui[nBui].ets.dp1Hex_nominal, bui[nBui].ets.dp1WSE_nominal) +
    datDes.dp_length_nominal * datDes.lCon[nBui])
    "Differential pressure set point at remote location";

  parameter String filNam[nBui]={
    "modelica://LDRD/Resources/Loads/RefBldgHospitalNew2004_v1.4_7.2_5A_USA_IL_CHICAGO-OHARE.mos",
    "modelica://LDRD/Resources/Loads/RefBldgMidriseApartmentNew2004_v1.4_7.2_5A_USA_IL_CHICAGO-OHARE.mos",
    "modelica://LDRD/Resources/Loads/RefBldgMediumOfficeNew2004_v1.4_7.2_5A_USA_IL_CHICAGO-OHARE.mos"}
    "Library paths of the files with thermal loads as time series";

  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant dpDisSet(
    final k=datDes.dpPumDisSet)
    "DP set point"
    annotation (Placement(transformation(extent={{-20,-70},{0,-50}})));
  Buildings.Controls.OBC.CDL.Continuous.PID conPumDis(
    k=0.01,
    Ti=600,
    r=datDes.dpPumDisSet)
    "Distribution pump controller"
    annotation (Placement(transformation(extent={{30,-70},{50,-50}})));
  Buildings.Fluid.FixedResistances.PressureDrop bypEnd(
    redeclare final package Medium = Medium,
    final m_flow_nominal=datDes.mEnd_flow_nominal,
    from_dp=true,
    final dp_nominal=datDes.dpPumDisSet)
    "End of the line bypass (optional)"
    annotation (Placement(transformation(extent={{50,130},{70,150}})));
  CentralPlants.CoolingTowers cooTow(
    redeclare final package Medium = Medium,
    redeclare LDRD.CentralPlants.Controls.CoolingTowersIntegrated con,
    final m_flow_nominal=datDes.mPla_flow_nominal) "Cooling towers"
    annotation (Placement(transformation(
        extent={{-20,-20},{20,20}},
        rotation=90,
        origin={-160,-20})));
  Modelica.Blocks.Continuous.Integrator ESto(initType=Modelica.Blocks.Types.Init.InitialState)
    "Stored energy"
    annotation (Placement(transformation(extent={{200,-70},{220,-50}})));
  Modelica.Blocks.Continuous.Integrator EPumPla(initType=Modelica.Blocks.Types.Init.InitialState)
    "Plant pump energy"
    annotation (Placement(transformation(extent={{200,50},{220,70}})));
  Modelica.Blocks.Continuous.Integrator EFanPla(initType=Modelica.Blocks.Types.Init.InitialState)
    "Plant fan electric energy"
    annotation (Placement(transformation(extent={{200,90},{220,110}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant masFloBorFie(final k=
        pumSto.m_flow_nominal) "Borefield nominal flow rate"
    annotation (Placement(transformation(extent={{-300,-190},{-280,-170}})));
  Buildings.Controls.OBC.CDL.Continuous.Min min1
    "Minimum between main flow and borefield nominal flow"
    annotation (Placement(transformation(extent={{-260,-150},{-240,-170}})));
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

  connect(mDisWat_flow.m_flow, cooTow.m_flow) annotation (Line(points={{0,-109},
          {0,-104},{-177.333,-104},{-177.333,-42.6667}},
                      color={0,0,127}));
  connect(conSto.dH_flow, ESto.u) annotation (Line(points={{-87,-78},{180,-78},
          {180,-60},{198,-60}}, color={215,215,215}));
  connect(cooTow.PPum, EPumPla.u) annotation (Line(points={{-170.667,2.66667},{
          -170.667,60},{198,60}}, color={215,215,215}));
  connect(cooTow.PFan, EFanPla.u) annotation (Line(points={{-173.333,2.66667},{
          -173.333,100},{198,100}}, color={215,215,215}));
  connect(EPumPla.y, EPum.u[4]) annotation (Line(points={{221,60},{240,60},{240,
          120},{258,120}}, color={0,0,127}));
  connect(conCoo.port_bCon, cooTow.port_aSerAmb) annotation (Line(points={{-150,
          -70},{-150,-60},{-162.667,-60},{-162.667,-40}}, color={0,127,255}));
  connect(TCooEnt.T, cooTow.TWatEnt) annotation (Line(points={{-200,-69},{-200,
          -60},{-173.333,-60},{-173.333,-42.6667}}, color={0,0,127}));
  connect(TCooLvg.T, cooTow.TWatLvg) annotation (Line(points={{-120,-69},{-120,
          -64},{-169.333,-64},{-169.333,-42.6667}}, color={0,0,127}));
  connect(min1.y, pumSto.m_flow_in) annotation (Line(points={{-238,-160},{-200,-160},
          {-200,-132}}, color={0,0,127}));
  connect(weaDat.weaBus, cooTow.weaBus) annotation (Line(
      points={{-320,0},{-200,0},{-200,-19.9333},{-177.733,-19.9333}},
      color={255,204,51},
      thickness=0.5));
  connect(cooTow.port_bSerAmb, conCoo.port_aCon) annotation (Line(points={{
          -162.667,0},{-164,0},{-164,20},{-120,20},{-120,-60},{-144,-60},{-144,
          -70}},
        color={0,127,255}));
  connect(cooTow.m_flowBorFieMin, min1.u2) annotation (Line(points={{-149.333,
          2.66667},{-149.333,10},{-280,10},{-280,-154},{-262,-154}},
                                                            color={0,0,127}));
  connect(masFloBorFie.y, min1.u1) annotation (Line(points={{-278,-180},{-270,-180},
          {-270,-166},{-262,-166}}, color={0,0,127}));
  connect(conCoo.dH_flow, EPla.u) annotation (Line(points={{-138,-73},{-130,-73},
          {-130,10},{198,10}}, color={0,0,127}));
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
end ParallelCoolingTowersIntegrated;
