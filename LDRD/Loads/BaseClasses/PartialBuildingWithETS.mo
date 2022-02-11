within LDRD.Loads.BaseClasses;
model PartialBuildingWithETS "Partial model with ETS model and partial building model"
  extends
    Buildings.Experimental.DHC.Loads.BaseClasses.PartialBuildingWithPartialETS(
    nPorts_heaWat=1,
    nPorts_chiWat=1,
    redeclare EnergyTransferStations.Combined.Generation5.ChillerBorefield ets(
      hex(show_T=true),
      WSE(show_T=true),
      conCon=LDRD.EnergyTransferStations.Types.ConnectionConfiguration.TwoWayValve,
      dp1Hex_nominal=20E3,
      dp2Hex_nominal=20E3,
      QHex_flow_nominal=abs(QChiWat_flow_nominal),
      T_a1Hex_nominal=282.15,
      T_b1Hex_nominal=278.15,
      T_a2Hex_nominal=276.15,
      T_b2Hex_nominal=280.15,
      have_WSE=true,
      QWSE_flow_nominal=QChiWat_flow_nominal,
      dpCon_nominal=15E3,
      dpEva_nominal=15E3,
      final datChi=datChi,
      T_a1WSE_nominal=281.15,
      T_b1WSE_nominal=286.15,
      T_a2WSE_nominal=288.15,
      T_b2WSE_nominal=283.15));
  final parameter Modelica.SIunits.MassFlowRate mCon_flow_nominal(min=0)=
    abs(QChiWat_flow_nominal)*(1+1/datChi.COP_nominal)/5/4186
    "Condenser water mass flow rate"
    annotation (Dialog(group="ETS model parameters"));
  /*
  To size the service water mass flow rate, we add 20% to the max of 
  WSE and main HX primary flow rates, considering that the peak loads on those 
  2 pieces of equipment are not coincident.
  This might be wrong and needs to be checked by simulation.
  */
  final parameter Modelica.SIunits.MassFlowRate mSerWat_flow_nominal(min=0)=
    1.2 * max(ets.hex.m1_flow_nominal, ets.m1WSE_flow_nominal)
    "Service water mass flow rate"
    annotation (Dialog(group="ETS model parameters"));
  parameter Buildings.Fluid.Chillers.Data.ElectricEIR.Generic datChi(
    QEva_flow_nominal=QChiWat_flow_nominal,
    COP_nominal=3.8,
    PLRMax=1,
    PLRMinUnl=0.3,
    PLRMin=0.3,
    etaMotor=1,
    mEva_flow_nominal=abs(QChiWat_flow_nominal)/4/4186,
    mCon_flow_nominal=mCon_flow_nominal*4/8,
    TEvaLvg_nominal=276.15,
    capFunT={1.72,0.02,0,-0.02,0,0},
    EIRFunT={0.28,-0.02,0,0.02,0,0},
    EIRFunPLR={0.1,0.9,0},
    TEvaLvgMin=276.15,
    TEvaLvgMax=288.15,
    TConEnt_nominal=315.15,
    TConEntMin=291.15,
    TConEntMax=328.15)
    "Chiller performance data"
    annotation (Placement(transformation(extent={{20,180},{40,200}})));
  parameter Modelica.SIunits.Temperature TChiWatSup_nominal=7+273.15
    "Chilled water supply temperature"
    annotation(Dialog(group="ETS model parameters"));
  parameter Modelica.SIunits.Temperature THeaWatSup_nominal=50+273.15
    "Heating water supply temperature"
    annotation(Dialog(group="ETS model parameters"));
  // IO CONNECTORS
  // COMPONENTS
  Buildings.Controls.OBC.CDL.Continuous.Gain mulPPumETS(u(final unit="W"), final k=facMul) if have_pum "Scaling"
    annotation (Placement(transformation(extent={{270,-10},{290,10}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput PPumETS(final unit="W") if have_pum "ETS pump power" annotation (
      Placement(transformation(extent={{300,-20},{340,20}}), iconTransformation(
        extent={{-20,-20},{20,20}},
        rotation=90,
        origin={70,120})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant THeaWatSupSetMin(k=30 + 273.15) "Min HHWST set point"
    annotation (Placement(transformation(extent={{-250,30},{-230,50}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant THeaWatSupSetMax(k=THeaWatSup_nominal) "Max HHWST set point"
    annotation (Placement(transformation(extent={{-220,10},{-200,30}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant TChiWatSupSetMin(k=TChiWatSup_nominal) "Min CHWST set point"
    annotation (Placement(transformation(extent={{-220,-170},{-200,-150}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant TChiWatSupSetMax(k=18 + 273.15) "Max CHWST set point"
    annotation (Placement(transformation(extent={{-250,-150},{-230,-130}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant zer(k=0) "Zero"
    annotation (Placement(transformation(extent={{-252,-30},{-232,-10}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant one(k=1) "One"
    annotation (Placement(transformation(extent={{-252,-90},{-232,-70}})));
  Buildings.Controls.OBC.CDL.Continuous.Line resTHeaWatSup "HHW supply temperature reset"
    annotation (Placement(transformation(extent={{-130,-70},{-110,-50}})));
  Buildings.Controls.OBC.CDL.Continuous.Line resTChiWatSup "CHW supply temperature reset"
    annotation (Placement(transformation(extent={{-130,-130},{-110,-110}})));
  Buildings.Controls.OBC.CDL.Continuous.GreaterThreshold enaHeaCoo[2](each t=
        2e-2, each h=1e-2)
    "Threshold comparison to enable heating and cooling"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={-80,-150})));
equation
  connect(mulPPumETS.y, PPumETS)
    annotation (Line(points={{292,0},{320,0}},   color={0,0,127}));
  connect(ets.PPum, mulPPumETS.u) annotation (Line(points={{34,-60},{240,-60},{
          240,0},{268,0}},   color={0,0,127}));
  connect(THeaWatSupSetMin.y, resTHeaWatSup.f1)
    annotation (Line(points={{-228,40},{-140,40},{-140,-56},{-132,-56}}, color={0,0,127}));
  connect(THeaWatSupSetMax.y, resTHeaWatSup.f2)
    annotation (Line(points={{-198,20},{-142,20},{-142,-68},{-132,-68}}, color={0,0,127}));
  connect(zer.y, resTHeaWatSup.x1)
    annotation (Line(points={{-230,-20},{-138,-20},{-138,-52},{-132,-52}}, color={0,0,127}));
  connect(one.y, resTHeaWatSup.x2)
    annotation (Line(points={{-230,-80},{-136,-80},{-136,-64},{-132,-64}}, color={0,0,127}));
  connect(zer.y, resTChiWatSup.x1)
    annotation (Line(points={{-230,-20},{-138,-20},{-138,-112},{-132,-112}}, color={0,0,127}));
  connect(one.y, resTChiWatSup.x2)
    annotation (Line(points={{-230,-80},{-136,-80},{-136,-124},{-132,-124}}, color={0,0,127}));
  connect(resTHeaWatSup.y, ets.THeaWatSupSet) annotation (Line(points={{-108,-60},{-34,-60}}, color={0,0,127}));
  connect(resTChiWatSup.y, ets.TChiWatSupSet)
    annotation (Line(points={{-108,-120},{-60,-120},{-60,-66},{-34,-66}}, color={0,0,127}));
  connect(enaHeaCoo[1].y, ets.uHea)
    annotation (Line(points={{-80,-162},{-80,-180},{-40,-180},{-40,-48},{-34,-48}}, color={255,0,255}));
  connect(enaHeaCoo[2].y, ets.uCoo)
    annotation (Line(points={{-80,-162},{-80,-180},{-40,-180},{-40,-54},{-34,-54}}, color={255,0,255}));
  connect(TChiWatSupSetMin.y, resTChiWatSup.f2) annotation (Line(points={{-198,
          -160},{-136,-160},{-136,-128},{-132,-128}}, color={0,0,127}));
  connect(TChiWatSupSetMax.y, resTChiWatSup.f1) annotation (Line(points={{-228,
          -140},{-140,-140},{-140,-116},{-132,-116}}, color={0,0,127}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false)),
    Documentation(info="<html>
<p>
This model is composed of a heat pump based energy transfer station model 
<a href=\"modelica://Buildings.Experimental.DHC.EnergyTransferStations.Combined.Generation5.HeatPumpHeatExchanger\">
Buildings.Experimental.DHC.EnergyTransferStations.Combined.Generation5.HeatPumpHeatExchanger</a>
connected to a repleacable building load model. 
</p>
<p>
Chiller performance representative of Carrier 30XWH-Opt.150 802
</p>
</html>", revisions="<html>
<ul>
<li>
February 23, 2021, by Antoine Gautier:<br/>
First implementation.
</li>
</ul>
</html>"));
end PartialBuildingWithETS;
