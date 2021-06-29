within LDRD.Loads;
model BuildingSpawnWithETS "Spawn model of building, connected to an ETS"
  extends BaseClasses.PartialBuildingWithETS(
    redeclare BaseClasses.BuildingSpawnMediumOfficeVAV_speedControl bui(
      T_aHeaWat_nominal=THeaWatSup_nominal,
      T_bHeaWat_nominal=THeaWatSup_nominal - 5,
      T_aChiWat_nominal=TChiWatSup_nominal,
      T_bChiWat_nominal=TChiWatSup_nominal + 5), ets(
      have_hotWat=false,
      QChiWat_flow_nominal=QCoo_flow_nominal,
      QHeaWat_flow_nominal=QHea_flow_nominal));

  inner replaceable Data.VAVDataMediumOffice datVAV
    constrainedby LDRD.Data.VAVData(
      have_WSE=ets.have_WSE,
      dp2WSE_nominal=if ets.have_WSE then ets.dp2WSE_nominal else 0)
    "VAV system parameters"
    annotation (Placement(transformation(extent={{-40,180},{-20,202}})));

  final parameter Modelica.SIunits.HeatFlowRate QCoo_flow_nominal(
    max=-Modelica.Constants.eps)=datVAV.QCooCoi_flow
    "Space cooling design load (<=0)"
    annotation (Dialog(group="Design parameter"));
  final parameter Modelica.SIunits.HeatFlowRate QHea_flow_nominal(
    min=Modelica.Constants.eps)=datVAV.QHeaCoi_flow + sum(datVAV.QRehCoi_flow)
    "Space heating design load (>=0)"
    annotation (Dialog(group="Design parameter"));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant opeValMax(k=0.9) "Maximum valve opening"
    annotation (Placement(transformation(extent={{-290,-90},{-270,-70}})));
  Buildings.Controls.OBC.CDL.Continuous.PIDWithReset
                                            conResHeaWat(
    k=0.1,
    Ti=600,
    reverseActing=false,
    y_reset=1)           "Controller for HHWST reset"
    annotation (Placement(transformation(extent={{-210,-70},{-190,-50}})));
  Buildings.Controls.OBC.CDL.Continuous.PIDWithReset
                                            conResChiWat(
    k=0.1,
    Ti=600,
    y_reset=0)                                                          "Controller for CHWST reset"
    annotation (Placement(transformation(extent={{-210,-130},{-190,-110}})));
equation
  connect(opeValMax.y, conResHeaWat.u_s)
    annotation (Line(points={{-268,-80},{-260,-80},{-260,-60},{-212,-60}}, color={0,0,127}));
  connect(opeValMax.y, conResChiWat.u_s)
    annotation (Line(points={{-268,-80},{-260,-80},{-260,-120},{-212,-120}}, color={0,0,127}));
  connect(bui.yValHeaMax_actual, conResHeaWat.u_m)
    annotation (Line(points={{22.2,6},{22,6},{22,2},{-180,2},{-180,-80},{-200,-80},{-200,-72}}, color={0,0,127}));
  connect(bui.yValCooMax_actual, conResChiWat.u_m)
    annotation (Line(points={{26.2,6},{26,6},{26,0},{-178,0},{-178,-136},{-200,-136},{-200,-132}}, color={0,0,127}));
  connect(conResChiWat.y, resTChiWatSup.u) annotation (Line(points={{-188,-120},{-132,-120}}, color={0,0,127}));
  connect(conResHeaWat.y, resTHeaWatSup.u) annotation (Line(points={{-188,-60},{-132,-60}}, color={0,0,127}));
  connect(bui.yValHeaMax_actual, enaHeaCoo[1].u)
    annotation (Line(points={{22.2,6},{22,6},{22,2},{-80,2},{-80,-138}}, color={0,0,127}));
  connect(bui.yValCooMax_actual, enaHeaCoo[2].u)
    annotation (Line(points={{26.2,6},{26,6},{26,0},{-80,0},{-80,-138}}, color={0,0,127}));
  connect(enaHeaCoo[1].y, conResHeaWat.trigger) annotation (Line(points={{-80,
          -162},{-80,-180},{-182,-180},{-182,-76},{-206,-76},{-206,-72}}, color
        ={255,0,255}));
  connect(enaHeaCoo[2].y, conResChiWat.trigger) annotation (Line(points={{-80,
          -162},{-80,-180},{-182,-180},{-182,-144},{-206,-144},{-206,-132}},
        color={255,0,255}));
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
end BuildingSpawnWithETS;
