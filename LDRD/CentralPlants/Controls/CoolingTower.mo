within LDRD.CentralPlants.Controls;
block CoolingTower
  "Cooling tower controller"
  extends Modelica.Blocks.Icons.Block;

  parameter Modelica.SIunits.MassFlowRate m_flow_nominal
    "Nominal mass flow rate"
    annotation(Dialog(group = "Nominal condition"));
  parameter Modelica.SIunits.TemperatureDifference TLvgMin
    "Minimum leaving temperature";
  parameter Modelica.SIunits.TemperatureDifference TEntMax
    "Entering temperature for maximum fan speed";
  parameter Modelica.SIunits.TemperatureDifference dTApp_nominal
    "Approach"
    annotation (Dialog(group="Nominal condition"));
  parameter Modelica.SIunits.TemperatureDifference dTEna = 1
    "Minimum delta-T above predicted leaving water temperature to enable operation";
  parameter Modelica.SIunits.TemperatureDifference dTDis = 0.5
    "Minimum delta-T across CT before disabling operation";

  Buildings.Controls.OBC.CDL.Interfaces.RealInput TAir(final unit="K",
      displayUnit="degC")
    "Air temperature (dry or wet bulb depending on equipment)" annotation (
      Placement(transformation(extent={{-220,-60},{-180,-20}}),
        iconTransformation(extent={{-140,10},{-100,50}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput m_flow(final unit="kg/s")
    "Water mass flow rate" annotation (Placement(transformation(extent={{-220,80},
            {-180,120}}), iconTransformation(extent={{-140,40},{-100,80}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TWatLvg(final unit="K",
      displayUnit="degC") "Water leaving temperature" annotation (Placement(
        transformation(extent={{-220,-140},{-180,-100}}), iconTransformation(
          extent={{-140,-50},{-100,-10}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TWatEnt(final unit="K",
      displayUnit="degC") "Water entering temperature" annotation (Placement(
        transformation(extent={{-220,-100},{-180,-60}}), iconTransformation(
          extent={{-140,-20},{-100,20}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yPumMasFlo(final unit="kg/s")
    "Pump control signal" annotation (Placement(transformation(extent={{220,80},
            {260,120}}), iconTransformation(extent={{100,30},{140,70}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yFan(final unit="1")
    "Fan control signal" annotation (Placement(transformation(extent={{220,-60},
            {260,-20}}), iconTransformation(extent={{100,-70},{140,-30}})));

  Buildings.Controls.OBC.CDL.Continuous.AddParameter addDelTem(final p=dTEna,
      final k=1) "Add threshold for enabling"
    annotation (Placement(transformation(extent={{-110,-50},{-90,-30}})));
  Modelica.StateGraph.InitialStepWithSignal iniSta "Initial state "
    annotation (Placement(transformation(extent={{-40,30},{-20,50}})));
  Modelica.StateGraph.TransitionWithSignal ena "Transition to enabled state"
    annotation (Placement(transformation(extent={{0,30},{20,50}})));
  Modelica.StateGraph.StepWithSignal actSta "Active WSE"
    annotation (Placement(transformation(extent={{40,30},{60,50}})));
  Modelica.StateGraph.TransitionWithSignal dis "Transition to disabled state"
    annotation (Placement(transformation(extent={{80,30},{100,50}})));
  Buildings.Controls.OBC.CDL.Continuous.Add delT1(k2=-1) "Add delta-T"
    annotation (Placement(transformation(extent={{-150,-110},{-130,-90}})));
  Buildings.Controls.OBC.CDL.Continuous.LessThreshold delTemDis(t=dTDis)
    "Compare to threshold for disabling WSE"
    annotation (Placement(transformation(extent={{-70,-110},{-50,-90}})));
  EnergyTransferStations.Combined.Generation5.Controls.PredictLeavingTemperature
                            calTemLvg(final dTApp_nominal=dTApp_nominal, final
      m2_flow_nominal=m_flow_nominal)
    "Compute predicted leaving water temperature"
    annotation (Placement(transformation(extent={{-150,-50},{-130,-30}})));
  Buildings.Controls.OBC.CDL.Continuous.Less delTemDis1
    "Compare to threshold for enabling"
    annotation (Placement(transformation(extent={{-60,-50},{-40,-30}})));
  inner Modelica.StateGraph.StateGraphRoot stateGraphRoot "Root of state graph"
    annotation (Placement(transformation(extent={{-90,40},{-70,60}})));
  Buildings.Controls.OBC.CDL.Logical.MultiAnd mulAnd(nu=3)
    "Enable if cooling enabled and temperature criterion verified"
    annotation (Placement(transformation(extent={{-10,-50},{10,-30}})));
  Buildings.Controls.OBC.CDL.Logical.Timer tim(t=1200)
    "True when WSE active for more than t" annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={40,-70})));
  Buildings.Controls.OBC.CDL.Logical.Timer tim1(t=1200)
    "True when WSE inactive for more than t"
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={-10,0})));
  Buildings.Controls.OBC.CDL.Logical.And and2
    "Cooling disabled or temperature criterion verified"
    annotation (Placement(transformation(extent={{60,-102},{80,-82}})));
  Buildings.Controls.OBC.CDL.Logical.Switch swiOff2
    "Switch between enabled and disabled mode"
    annotation (Placement(transformation(extent={{190,90},{210,110}})));

  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant zer(final k=0) "Zero"
    annotation (Placement(transformation(extent={{100,70},{120,90}})));
  Buildings.Controls.OBC.CDL.Continuous.Line comFanSig "Compute fan signal"
    annotation (Placement(transformation(extent={{150,-50},{170,-30}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant one(final k=1) "One"
    annotation (Placement(transformation(extent={{100,-100},{120,-80}})));
  Buildings.Controls.OBC.CDL.Continuous.GreaterThreshold
                                             comTLvgPre(t=TLvgMin + dTEna)
    "Compare to threshold for enabling"
    annotation (Placement(transformation(extent={{-110,-10},{-90,10}})));
  Buildings.Controls.OBC.CDL.Continuous.LessThreshold comTLvg(t=TLvgMin)
    "Compare to threshold for disabling"
    annotation (Placement(transformation(extent={{-110,-130},{-90,-110}})));
  Buildings.Controls.OBC.CDL.Logical.MultiOr  mulOr(nu=2)
    "Enable if cooling enabled and temperature criterion verified"
    annotation (Placement(transformation(extent={{-10,-110},{10,-90}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant minT(final k=TLvgMin +
        dTEna) "Entering temperature for minimum speed"
    annotation (Placement(transformation(extent={{100,-20},{120,0}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant maxT(final k=TEntMax)
    "Entering temperature for maximum speed"
    annotation (Placement(transformation(extent={{100,-70},{120,-50}})));
  Buildings.Controls.OBC.CDL.Logical.Switch swiOff1
    "Switch between enabled and disabled mode"
    annotation (Placement(transformation(extent={{190,-30},{210,-50}})));
equation
  connect(TWatEnt, delT1.u1) annotation (Line(points={{-200,-80},{-160,-80},{-160,
          -94},{-152,-94}}, color={0,0,127}));
  connect(TWatLvg, delT1.u2) annotation (Line(points={{-200,-120},{-160,-120},{-160,
          -106},{-152,-106}}, color={0,0,127}));
  connect(delT1.y,delTemDis. u) annotation (Line(points={{-128,-100},{-72,-100}},color={0,0,127}));
  connect(TAir, calTemLvg.T1WatEnt) annotation (Line(points={{-200,-40},{-190,-40},
          {-190,-45},{-152,-45}}, color={0,0,127}));
  connect(calTemLvg.T2WatLvg,addDelTem. u) annotation (Line(points={{-128,-40},{
          -112,-40}},                                                                      color={0,0,127}));
  connect(addDelTem.y,delTemDis1. u1) annotation (Line(points={{-88,-40},{-62,-40}},
                                                                                  color={0,0,127}));
  connect(TWatEnt, delTemDis1.u2) annotation (Line(points={{-200,-80},{-90,-80},
          {-90,-48},{-62,-48}}, color={0,0,127}));
  connect(iniSta.outPort[1],ena. inPort) annotation (Line(points={{-19.5,40},{6,
          40}},                                                                         color={0,0,0}));
  connect(ena.outPort,actSta. inPort[1]) annotation (Line(points={{11.5,40},{39,
          40}},                                                                       color={0,0,0}));
  connect(actSta.outPort[1],dis. inPort) annotation (Line(points={{60.5,40},{86,
          40}},                                                                       color={0,0,0}));
  connect(dis.outPort,iniSta. inPort[1])
    annotation (Line(points={{91.5,40},{110,40},{110,60},{-50,60},{-50,40},{-41,
          40}},                                                                        color={0,0,0}));
  connect(mulAnd.y,ena. condition) annotation (Line(points={{12,-40},{16,-40},{16,
          20},{10,20},{10,28}},                                                         color={255,0,255}));
  connect(delTemDis1.y,mulAnd. u[1])
    annotation (Line(points={{-38,-40},{-12,-40},{-12,-35.3333}},                color={255,0,255}));
  connect(iniSta.active,tim1. u) annotation (Line(points={{-30,29},{-30,20},{-10,
          20},{-10,12}},                                                      color={255,0,255}));
  connect(tim1.passed,mulAnd. u[2])
    annotation (Line(points={{-18,-12},{-18,-36},{-12,-36},{-12,-40}}, color={255,0,255}));
  connect(actSta.active,tim. u) annotation (Line(points={{50,29},{50,-40},{40,-40},
          {40,-58}},                                                        color={255,0,255}));
  connect(tim.passed,and2. u1) annotation (Line(points={{32,-82},{32,-92},{58,-92}},    color={255,0,255}));
  connect(and2.y,dis. condition) annotation (Line(points={{82,-92},{90,-92},{90,
          28}},                                                                         color={255,0,255}));
  connect(m_flow, calTemLvg.m2_flow) annotation (Line(points={{-200,100},{-160,100},
          {-160,-35},{-152,-35}}, color={0,0,127}));
  connect(swiOff2.y, yPumMasFlo)
    annotation (Line(points={{212,100},{240,100}}, color={0,0,127}));
  connect(actSta.active, swiOff2.u2) annotation (Line(points={{50,29},{50,20},{
          180,20},{180,100},{188,100}},
                                    color={255,0,255}));
  connect(m_flow, swiOff2.u1) annotation (Line(points={{-200,100},{160,100},{
          160,108},{188,108}},
                           color={0,0,127}));
  connect(zer.y, swiOff2.u3) annotation (Line(points={{122,80},{188,80},{188,92}},
                     color={0,0,127}));
  connect(comTLvgPre.y, mulAnd.u[3]) annotation (Line(points={{-88,0},{-30,0},{
          -30,-44.6667},{-12,-44.6667}},
                        color={255,0,255}));
  connect(calTemLvg.T2WatLvg,comTLvgPre. u) annotation (Line(points={{-128,-40},
          {-120,-40},{-120,0},{-112,0}},
                                     color={0,0,127}));
  connect(TWatLvg, comTLvg.u)
    annotation (Line(points={{-200,-120},{-112,-120}},color={0,0,127}));
  connect(mulOr.y, and2.u2)
    annotation (Line(points={{12,-100},{58,-100}}, color={255,0,255}));
  connect(delTemDis.y, mulOr.u[1]) annotation (Line(points={{-48,-100},{-24,-100},
          {-24,-96.5},{-12,-96.5}},
                                 color={255,0,255}));
  connect(comTLvg.y, mulOr.u[2]) annotation (Line(points={{-88,-120},{-30,-120},
          {-30,-103.5},{-12,-103.5}},                        color={255,0,255}));
  connect(minT.y, comFanSig.x1) annotation (Line(points={{122,-10},{130,-10},{130,
          -32},{148,-32}}, color={0,0,127}));
  connect(maxT.y, comFanSig.x2) annotation (Line(points={{122,-60},{130,-60},{130,
          -44},{148,-44}}, color={0,0,127}));
  connect(TWatEnt, comFanSig.u) annotation (Line(points={{-200,-80},{20,-80},{20,
          -40},{148,-40}}, color={0,0,127}));
  connect(zer.y, comFanSig.f1) annotation (Line(points={{122,80},{140,80},{140,
          -36},{148,-36}}, color={0,0,127}));
  connect(one.y, comFanSig.f2) annotation (Line(points={{122,-90},{140,-90},{
          140,-48},{148,-48}}, color={0,0,127}));
  connect(actSta.active, swiOff1.u2) annotation (Line(points={{50,29},{50,20},{
          180,20},{180,-40},{188,-40}}, color={255,0,255}));
  connect(swiOff1.y, yFan)
    annotation (Line(points={{212,-40},{240,-40},{240,-40}}, color={0,0,127}));
  connect(comFanSig.y, swiOff1.u1) annotation (Line(points={{172,-40},{176,-40},
          {176,-48},{188,-48}}, color={0,0,127}));
  connect(zer.y, swiOff1.u3) annotation (Line(points={{122,80},{140,80},{140,
          -20},{188,-20},{188,-32}}, color={0,0,127}));
  annotation (Diagram(
        coordinateSystem(preserveAspectRatio=false, extent={{-180,-160},{220,
            160}})),
    Documentation(info="<html>
<p>
The cooling towers will typically be off at peak cooling load.
They are rather used to reduce heat rejection to the borefield
at low wet bulb T.
Optionally, if piped in the borefield loop they may be used
in short circuit for additional night cooling without circulating
water through the whole DHC network.
</p>
<p> 
Control logic
</p>
<ul> 
<li>
Enable with similar logic as WSE: 
based on predicted leaving water temperature that must
be lower (with margin) than entering and higher than minimum 
leaving temperature.
</li>
<li>
When enabled, modulate fan speed between minimum when 
entering water temperature equals <code>TLvgMin + dTEna</code>, 
and maximum when entering water temperature equals <code>TEntMax</code>. 
</li>
<li>
Disable if leaving temperature higher (with margin) than entering
or lower than <code>TLvgMin</code>.
</li>
</ul>
</html>"),
    Icon(coordinateSystem(extent={{-180,-160},{220,160}})));
end CoolingTower;
