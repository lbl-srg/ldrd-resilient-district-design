within LDRD.Loads;
model BuildingSpawnWithETS "Spawn model of building, connected to an ETS"
  extends BaseClasses.PartialBuildingWithETS(redeclare BaseClasses.BuildingSpawnMediumOfficeVAV bui(
      T_aHeaWat_nominal=THeaWatSup_nominal,
      T_bHeaWat_nominal=THeaWatSup_nominal - 5,
      T_aChiWat_nominal=TChiWatSup_nominal,
      T_bChiWat_nominal=TChiWatSup_nominal + 5), ets(
      have_hotWat=false,
      QChiWat_flow_nominal=QCoo_flow_nominal,
      QHeaWat_flow_nominal=QHea_flow_nominal));

  final parameter Modelica.SIunits.HeatFlowRate QCoo_flow_nominal(
    max=-Modelica.Constants.eps)=bui.facMul * bui.facMulTerUni * bui.QCoo_flow_nominal
    "Space cooling design load (<=0)"
    annotation (Dialog(group="Design parameter"));
  final parameter Modelica.SIunits.HeatFlowRate QHea_flow_nominal(
    min=Modelica.Constants.eps)=bui.facMul * bui.facMulTerUni * bui.QHea_flow_nominal
    "Space heating design load (>=0)"
    annotation (Dialog(group="Design parameter"));
  Buildings.Controls.OBC.CDL.Logical.Sources.Constant FIXME1[2](k=fill(true, 2))
    "Threshold comparison to enable heating and cooling"
    annotation (Placement(transformation(extent={{-260,-120},{-240,-100}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant FIXME(k=1) "One"
    annotation (Placement(transformation(extent={{-260,-80},{-240,-60}})));
equation
  connect(FIXME1[1].y, ets.uHea)
    annotation (Line(points={{-238,-110},{-40,-110},{-40,-48},{-34,-48}}, color={255,0,255}));
  connect(FIXME1[2].y, ets.uCoo)
    annotation (Line(points={{-238,-110},{-40,-110},{-40,-54},{-34,-54}}, color={255,0,255}));
  connect(FIXME.y, resTHeaWatSup.u)
    annotation (Line(points={{-238,-70},{-220,-70},{-220,-40},{-112,-40}}, color={0,0,127}));
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
            300,300}}), graphics={Text(
          extent={{-286,-78},{-180,-104}},
          lineColor={28,108,200},
          textString="FIXME: enable heating and cooling signal and TSup reset based on terminal valve demand")}));
end BuildingSpawnWithETS;
