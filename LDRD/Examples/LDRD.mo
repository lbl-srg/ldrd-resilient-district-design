within LDRD.Examples;
model LDRD "Example of parallel connection with constant district water mass flow rate"
  extends BaseClasses.PartialParallelSpawn(
    final facMulTim={1, 10},
    final facMulSpa=10,
    redeclare
      Loads.BuildingTimeSeriesWithETS bui[nBui-1](final filNam=filNam),
    datDes(
      idxBuiSpa=3,
      dp_length_nominal=250,
      dpPumDisSet=2 * max(buiSpa.ets.dp1Hex_nominal, buiSpa.ets.dp1WSE_nominal)),
    dis(show_entFlo=true));
  /*
  Differential pressure set point takes valve + HX nominal pressure drop,
  assuming 50% authority for the control valve.
  */

  parameter String filNam[nBui-1]={
    "modelica://LDRD/Resources/Loads/RefBldgHospitalNew2004_v1.4_7.2_5A_USA_IL_CHICAGO-OHARE.mos",
    "modelica://LDRD/Resources/Loads/RefBldgMidriseApartmentNew2004_v1.4_7.2_5A_USA_IL_CHICAGO-OHARE.mos"}
    "Library paths of the files with thermal loads as time series";

  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant dpDisSet(
    final k=datDes.dpPumDisSet) "DP set point"
                   annotation (Placement(transformation(extent={{-20,-70},{0,-50}})));
  Buildings.Controls.OBC.CDL.Continuous.PID conPumDis(
    k=0.01,
    Ti=600,
    r=datDes.dpPumDisSet) "Distribution pump controller"
    annotation (Placement(transformation(extent={{30,-70},{50,-50}})));
  Buildings.Fluid.FixedResistances.PressureDrop bypEnd(
    redeclare final package Medium = Medium,
    final m_flow_nominal=0.05*datDes.mPumDis_flow_nominal,
    from_dp=true,
    final dp_nominal=datDes.dpPumDisSet)
    "End of the line bypass (optional)"
    annotation (Placement(transformation(extent={{50,130},{70,150}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant masFloBorFie(final k=
        pumSto.m_flow_nominal) "Borefield nominal flow rate"
    annotation (Placement(transformation(extent={{-260,-50},{-240,-30}})));
  Buildings.Controls.OBC.CDL.Continuous.Min minFlo
    "Minimum between main flow and borefield nominal flow"
    annotation (Placement(transformation(extent={{-210,-50},{-190,-30}})));
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
  connect(mDisWat_flow.m_flow, minFlo.u2) annotation (Line(points={{0,-109},{0,-106},
          {-220,-106},{-220,-46},{-212,-46}}, color={0,0,127}));
  connect(masFloBorFie.y, minFlo.u1) annotation (Line(points={{-238,-40},{-220,-40},
          {-220,-34},{-212,-34}}, color={0,0,127}));
  connect(minFlo.y, pumSto.m_flow_in) annotation (Line(points={{-188,-40},{-180,
          -40},{-180,-68}}, color={0,0,127}));
  annotation (
  Diagram(
  coordinateSystem(preserveAspectRatio=false, extent={{-360,-260},{360,260}})),
  experiment(
      StopTime=31622400,
      __Dymola_NumberOfIntervals=8760,
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
end LDRD;
