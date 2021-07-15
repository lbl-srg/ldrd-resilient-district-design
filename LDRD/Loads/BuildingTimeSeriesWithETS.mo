within LDRD.Loads;
model BuildingTimeSeriesWithETS "Model of a building with loads provided as time series, connected to an ETS"
  extends BaseClasses.PartialBuildingWithETS(
    redeclare Buildings.Experimental.DHC.Loads.Examples.BaseClasses.BuildingTimeSeries bui(
      final filNam=filNam,
      have_hotWat=false,
      T_aHeaWat_nominal=THeaWatSup_nominal,
      T_bHeaWat_nominal=THeaWatSup_nominal-5,
      T_aChiWat_nominal=TChiWatSup_nominal,
      T_bChiWat_nominal=TChiWatSup_nominal+5,
      facMulHea=10*QHea_flow_nominal/(1.7E5),
      facMulCoo=40*QCoo_flow_nominal/(-1.5E5)),
    ets(
      have_hotWat=false,
      QChiWat_flow_nominal=QCoo_flow_nominal,
      QHeaWat_flow_nominal=QHea_flow_nominal));
  parameter String filNam
    "Library path of the file with thermal loads as time series";
  final parameter Modelica.SIunits.HeatFlowRate QCoo_flow_nominal(
    max=-Modelica.Constants.eps)=bui.facMul * bui.QCoo_flow_nominal
    "Space cooling design load (<=0)"
    annotation (Dialog(group="Design parameter"));
  final parameter Modelica.SIunits.HeatFlowRate QHea_flow_nominal(
    min=Modelica.Constants.eps)=bui.facMul * bui.QHea_flow_nominal
    "Space heating design load (>=0)"
    annotation (Dialog(group="Design parameter"));
  Buildings.Controls.OBC.CDL.Continuous.Gain loaHeaNor(
    k=1/bui.QHea_flow_nominal) "Normalized heating load"
    annotation (Placement(transformation(extent={{-200,-70},{-180,-50}})));
  Buildings.Controls.OBC.CDL.Continuous.Gain loaCooNor(
    k=1/bui.QCoo_flow_nominal) "Normalized cooling load"
    annotation (Placement(transformation(extent={{-200,-110},{-180,-90}})));
equation

  connect(bui.QReqHea_flow, loaHeaNor.u)
    annotation (Line(points={{20,4},{20,2},{-208,2},{-208,-60},{-202,-60}}, color={0,0,127}));
  connect(bui.QReqCoo_flow, loaCooNor.u)
    annotation (Line(points={{24,4},{24,0},{-206,0},{-206,-100},{-202,-100}}, color={0,0,127}));
  connect(loaHeaNor.y, resTHeaWatSup.u) annotation (Line(points={{-178,-60},{-132,-60}}, color={0,0,127}));
  connect(loaCooNor.y, resTChiWatSup.u)
    annotation (Line(points={{-178,-100},{-150,-100},{-150,-120},{-132,-120}}, color={0,0,127}));
  connect(loaCooNor.y, enaHeaCoo[2].u) annotation (Line(points={{-178,-100},{-80,-100},{-80,-138}}, color={0,0,127}));
  connect(loaHeaNor.y, enaHeaCoo[1].u)
    annotation (Line(points={{-178,-60},{-150,-60},{-150,-92},{-80,-92},{-80,-138}}, color={0,0,127}));
  annotation (Line(
      points={{-1,100},{0.1,100},{0.1,71.4}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{-3,6},{-3,6}},
      horizontalAlignment=TextAlignment.Right),
    Documentation(info="<html>
<p>
This model is composed of a heat pump based energy transfer station model 
<a href=\"modelica://Buildings.Experimental.DHC.EnergyTransferStations.Combined.Generation5.HeatPumpHeatExchanger\">
Buildings.Experimental.DHC.EnergyTransferStations.Combined.Generation5.HeatPumpHeatExchanger</a>
connected to a simplified building model where the space heating, cooling 
and hot water loads are provided as time series.
</p>
</html>", revisions="<html>
<ul>
<li>
February 23, 2021, by Antoine Gautier:<br/>
First implementation.
</li>
</ul>
</html>"),
    Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-300,-300},{
            300,300}})));
end BuildingTimeSeriesWithETS;
