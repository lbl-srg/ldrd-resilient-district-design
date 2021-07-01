within LDRD.Examples;
model LDRD "Example of parallel connection with constant district water mass flow rate"
  extends BaseClasses.PartialParallelSpawn(
    redeclare
      Loads.BuildingTimeSeriesWithETS bui[nBui-1](final filNam=filNam),
    datDes(
      idxBuiSpa=3,
      mPumDis_flow_nominal=150,
      mPipDis_flow_nominal=150,
      dp_length_nominal=250,
      epsPla=0.91),
    dis(show_entFlo=true));
  parameter String filNam[nBui-1]={
    "modelica://Buildings/Resources/Data/Experimental/DHC/Loads/Examples/SwissHospital_20190916.mos",
    "modelica://Buildings/Resources/Data/Experimental/DHC/Loads/Examples/SwissResidential_20190916.mos"}
    "Library paths of the files with thermal loads as time series";
  Modelica.Blocks.Sources.Constant masFloMaiPum(
    k=datDes.mPumDis_flow_nominal)
    "Distribution pump mass flow rate"
    annotation (Placement(transformation(extent={{-280,-70},{-260,-50}})));
  Modelica.Blocks.Sources.Constant masFloDisPla(k=datDes.mPla_flow_nominal)
    "District water mass flow rate to plant"
    annotation (Placement(transformation(extent={{-250,10},{-230,30}})));

equation
  connect(masFloMaiPum.y, pumDis.m_flow_in) annotation (Line(points={{-259,-60},
          {60,-60},{60,-60},{68,-60}}, color={0,0,127}));
  connect(pumSto.m_flow_in, masFloMaiPum.y) annotation (Line(points={{-180,-68},
          {-180,-60},{-259,-60}}, color={0,0,127}));
  connect(masFloDisPla.y, pla.mPum_flow) annotation (Line(points={{-229,20},{
          -184,20},{-184,4.66667},{-161.333,4.66667}},
                                                  color={0,0,127}));
  connect(dis.port_bDisSup, dis.port_aDisRet) annotation (Line(points={{20,140},
          {40,140},{40,134},{20,134}}, color={0,127,255}));
  annotation (
  Diagram(
  coordinateSystem(preserveAspectRatio=false, extent={{-360,-260},{360,260}})),
  experiment(
      StopTime=31536000,
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
