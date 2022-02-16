within LDRD.CentralPlants.Controls;
block CoolingTowersIntegratedApproach "Cooling towers controller"
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
  parameter Real fraFreCon(min=0, max=1) = 0.125
    "Fraction of tower capacity in free convection regime";

  Buildings.Controls.OBC.CDL.Interfaces.RealInput TAir(final unit="K",
      displayUnit="degC")
    "Air temperature (dry or wet bulb depending on equipment)" annotation (
      Placement(transformation(extent={{-220,-60},{-180,-20}}),
        iconTransformation(extent={{-140,10},{-100,50}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput m_flow(final unit="kg/s")
    "Water mass flow rate in main line"
                           annotation (Placement(transformation(extent={{-220,80},
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
    annotation (Placement(transformation(extent={{70,30},{90,50}})));
  Buildings.Controls.OBC.CDL.Continuous.Add delT1(k2=-1) "Add delta-T"
    annotation (Placement(transformation(extent={{-150,-110},{-130,-90}})));
  Buildings.Controls.OBC.CDL.Continuous.LessThreshold delTemDis(t=dTDis)
    "Compare to threshold for disabling WSE"
    annotation (Placement(transformation(extent={{-70,-110},{-50,-90}})));
  EnergyTransferStations.Combined.Generation5.Controls.PredictLeavingTemperature calTemLvg(
    final dTApp_nominal=dTApp_nominal,
    final m2_flow_nominal=m_flow_nominal)
    "Compute predicted leaving water temperature"
    annotation (Placement(transformation(extent={{-150,-50},{-130,-30}})));
  Buildings.Controls.OBC.CDL.Continuous.Less delTemDis1
    "Compare to threshold for enabling"
    annotation (Placement(transformation(extent={{-60,-50},{-40,-30}})));
  inner Modelica.StateGraph.StateGraphRoot stateGraphRoot "Root of state graph"
    annotation (Placement(transformation(extent={{-90,40},{-70,60}})));
  Buildings.Controls.OBC.CDL.Logical.MultiAnd mulAnd(nin=3)
    "Enable if cooling enabled and temperature criterion verified"
    annotation (Placement(transformation(extent={{-10,-50},{10,-30}})));
  Buildings.Controls.OBC.CDL.Logical.Timer tim(t=1200)
    "True when WSE active for more than t" annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={50,-70})));
  Buildings.Controls.OBC.CDL.Logical.Timer tim1(t=1200)
    "True when WSE inactive for more than t"
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={-10,0})));
  Buildings.Controls.OBC.CDL.Logical.And and2
    "Cooling disabled or temperature criterion verified"
    annotation (Placement(transformation(extent={{50,-110},{70,-90}})));
  Buildings.Controls.OBC.CDL.Logical.Switch swiOff2
    "Switch between enabled and disabled mode"
    annotation (Placement(transformation(extent={{190,90},{210,110}})));

  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant zer(final k=0) "Zero"
    annotation (Placement(transformation(extent={{140,30},{160,50}})));
  Buildings.Controls.OBC.CDL.Continuous.Line comFanSig "Compute fan signal"
    annotation (Placement(transformation(extent={{150,-50},{170,-30}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant one(final k=1) "One"
    annotation (Placement(transformation(extent={{100,-30},{120,-10}})));
  Buildings.Controls.OBC.CDL.Continuous.GreaterThreshold comTLvgPre(t=TLvgMin + dTEna)
    "Compare to threshold for enabling"
    annotation (Placement(transformation(extent={{-60,-76},{-40,-56}})));
  Buildings.Controls.OBC.CDL.Logical.Switch swiOff1
    "Switch between enabled and disabled mode"
    annotation (Placement(transformation(extent={{190,-30},{210,-50}})));
  Buildings.Controls.OBC.CDL.Continuous.Line comPumSig "Compute pump signal"
    annotation (Placement(transformation(extent={{140,90},{160,110}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant masFlowNom(final k=
        m_flow_nominal) "Design mass flow rate"
    annotation (Placement(transformation(extent={{100,110},{120,130}})));
  EnergyTransferStations.Combined.Generation5.Controls.PIDWithEnable conPID(
    k=0.1,
    Ti=120,
    reverseActing=false)
    annotation (Placement(transformation(extent={{0,-150},{20,-130}})));
  Modelica.Blocks.Sources.RealExpression set(y=max(TLvgMin + dTEna, TAir +
        dTApp_nominal)) "Compute set point for leaving water temperature"
    annotation (Placement(transformation(extent={{-40,-150},{-20,-130}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant poiFiv(final k=0.5)
    "0.5" annotation (Placement(transformation(extent={{100,-70},{120,-50}})));
  Buildings.Controls.OBC.CDL.Continuous.LessThreshold comTLvg(t=TLvgMin)
    "Compare to threshold for disabling"
    annotation (Placement(transformation(extent={{-100,-130},{-80,-110}})));
  Buildings.Controls.OBC.CDL.Logical.MultiOr  mulOr(nin=2)
    "Enable if cooling enabled and temperature criterion verified"
    annotation (Placement(transformation(extent={{-18,-110},{2,-90}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant minT(final k=TLvgMin
         + dTEna)
               "Entering temperature for minimum speed"
    annotation (Placement(transformation(extent={{180,-110},{200,-90}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant maxT(final k=TEntMax)
    "Entering temperature for maximum speed"
    annotation (Placement(transformation(extent={{180,-160},{200,-140}})));
  Buildings.Controls.OBC.CDL.Continuous.GreaterThreshold comTAirFre(t=273.15)
    "Compare to freezing for enabling"
    annotation (Placement(transformation(extent={{-120,10},{-100,30}})));
  Buildings.Controls.OBC.CDL.Continuous.Add TLvgMax(k1=fraFreCon, k2=1 -
        fraFreCon) "Predicted maximum leaving temperature (in free convection)"
    annotation (Placement(transformation(extent={{-110,-76},{-90,-56}})));
equation
  connect(TWatEnt, delT1.u1) annotation (Line(points={{-200,-80},{-160,-80},{-160,
          -94},{-152,-94}}, color={0,0,127}));
  connect(TWatLvg, delT1.u2) annotation (Line(points={{-200,-120},{-160,-120},{-160,
          -106},{-152,-106}}, color={0,0,127}));
  connect(delT1.y,delTemDis. u) annotation (Line(points={{-128,-100},{-72,-100}},color={0,0,127}));
  connect(TAir, calTemLvg.T1Ent) annotation (Line(points={{-200,-40},{-160,-40},
          {-160,-45},{-152,-45}}, color={0,0,127}));
  connect(calTemLvg.T2Lvg, addDelTem.u)
    annotation (Line(points={{-128,-40},{-112,-40}}, color={0,0,127}));
  connect(addDelTem.y,delTemDis1. u1) annotation (Line(points={{-88,-40},{-62,-40}},
                                                                                  color={0,0,127}));
  connect(TWatEnt, delTemDis1.u2) annotation (Line(points={{-200,-80},{-80,-80},
          {-80,-48},{-62,-48}}, color={0,0,127}));
  connect(iniSta.outPort[1],ena. inPort) annotation (Line(points={{-19.5,40},{6,
          40}},                                                                         color={0,0,0}));
  connect(ena.outPort,actSta. inPort[1]) annotation (Line(points={{11.5,40},{39,
          40}},                                                                       color={0,0,0}));
  connect(actSta.outPort[1],dis. inPort) annotation (Line(points={{60.5,40},{76,
          40}},                                                                       color={0,0,0}));
  connect(dis.outPort,iniSta. inPort[1])
    annotation (Line(points={{81.5,40},{100,40},{100,60},{-50,60},{-50,40},{-41,
          40}},                                                                        color={0,0,0}));
  connect(mulAnd.y,ena. condition) annotation (Line(points={{12,-40},{16,-40},{16,
          20},{10,20},{10,28}},                                                         color={255,0,255}));
  connect(delTemDis1.y,mulAnd. u[1])
    annotation (Line(points={{-38,-40},{-12,-40},{-12,-35.3333}},                color={255,0,255}));
  connect(iniSta.active,tim1. u) annotation (Line(points={{-30,29},{-30,20},{-10,
          20},{-10,12}},                                                      color={255,0,255}));
  connect(tim1.passed,mulAnd. u[2])
    annotation (Line(points={{-18,-12},{-18,-36},{-12,-36},{-12,-40}}, color={255,0,255}));
  connect(actSta.active,tim. u) annotation (Line(points={{50,29},{50,-58}}, color={255,0,255}));
  connect(tim.passed,and2. u1) annotation (Line(points={{42,-82},{42,-100},{48,
          -100}},                                                                       color={255,0,255}));
  connect(and2.y,dis. condition) annotation (Line(points={{72,-100},{80,-100},{
          80,28}},                                                                      color={255,0,255}));
  connect(m_flow, calTemLvg.m2_flow) annotation (Line(points={{-200,100},{-160,100},
          {-160,-35},{-152,-35}}, color={0,0,127}));
  connect(swiOff2.y, yPumMasFlo)
    annotation (Line(points={{212,100},{240,100}}, color={0,0,127}));
  connect(actSta.active, swiOff2.u2) annotation (Line(points={{50,29},{50,20},{
          180,20},{180,100},{188,100}},
                                    color={255,0,255}));
  connect(zer.y, swiOff2.u3) annotation (Line(points={{162,40},{188,40},{188,92}},
                     color={0,0,127}));
  connect(zer.y, comFanSig.f1) annotation (Line(points={{162,40},{188,40},{188,
          0},{140,0},{140,-36},{148,-36}},
                           color={0,0,127}));
  connect(one.y, comFanSig.f2) annotation (Line(points={{122,-20},{126,-20},{
          126,-48},{148,-48}}, color={0,0,127}));
  connect(actSta.active, swiOff1.u2) annotation (Line(points={{50,29},{50,20},{
          180,20},{180,-40},{188,-40}}, color={255,0,255}));
  connect(swiOff1.y, yFan)
    annotation (Line(points={{212,-40},{240,-40},{240,-40}}, color={0,0,127}));
  connect(comFanSig.y, swiOff1.u1) annotation (Line(points={{172,-40},{176,-40},
          {176,-48},{188,-48}}, color={0,0,127}));
  connect(zer.y, swiOff1.u3) annotation (Line(points={{162,40},{188,40},{188,
          -32}},                     color={0,0,127}));
  connect(comPumSig.y, swiOff2.u1) annotation (Line(points={{162,100},{180,100},
          {180,108},{188,108}}, color={0,0,127}));
  connect(conPID.u_s, set.y)
    annotation (Line(points={{-2,-140},{-19,-140}}, color={0,0,127}));
  connect(TWatLvg, conPID.u_m) annotation (Line(points={{-200,-120},{-160,-120},
          {-160,-154},{10,-154},{10,-152}}, color={0,0,127}));
  connect(conPID.y, comFanSig.u) annotation (Line(points={{22,-140},{144,-140},
          {144,-40},{148,-40}}, color={0,0,127}));
  connect(poiFiv.y, comFanSig.x2) annotation (Line(points={{122,-60},{136,-60},
          {136,-44},{148,-44}}, color={0,0,127}));
  connect(zer.y, comFanSig.x1) annotation (Line(points={{162,40},{187.619,40},{
          187.619,-0},{140,-0},{140,-32},{148,-32}}, color={0,0,127}));
  connect(poiFiv.y, comPumSig.x1) annotation (Line(points={{122,-60},{130,-60},
          {130,108},{138,108}}, color={0,0,127}));
  connect(masFlowNom.y, comPumSig.f1) annotation (Line(points={{122,120},{126,
          120},{126,104},{138,104}}, color={0,0,127}));
  connect(m_flow, comPumSig.f2) annotation (Line(points={{-200,100},{0,100},{0,
          92},{138,92}}, color={0,0,127}));
  connect(one.y, comPumSig.x2) annotation (Line(points={{122,-20},{126,-20},{
          126,96},{138,96}}, color={0,0,127}));
  connect(actSta.active, conPID.uEna) annotation (Line(points={{50,29},{50,-40},
          {36,-40},{36,-160},{6,-160},{6,-152}}, color={255,0,255}));
  connect(TWatLvg, comTLvg.u)
    annotation (Line(points={{-200,-120},{-102,-120}}, color={0,0,127}));
  connect(comTLvg.y, mulOr.u[1]) annotation (Line(points={{-78,-120},{-30,-120},
          {-30,-96.5},{-20,-96.5}}, color={255,0,255}));
  connect(delTemDis.y, mulOr.u[2]) annotation (Line(points={{-48,-100},{-40,
          -100},{-40,-103.5},{-20,-103.5}}, color={255,0,255}));
  connect(TAir, comTAirFre.u) annotation (Line(points={{-200,-40},{-170,-40},{
          -170,20},{-122,20}}, color={0,0,127}));
  connect(comTAirFre.y, mulAnd.u[3]) annotation (Line(points={{-98,20},{-34,20},
          {-34,-44.6667},{-12,-44.6667}}, color={255,0,255}));
  connect(mulOr.y, and2.u2) annotation (Line(points={{4,-100},{28,-100},{28,
          -108},{48,-108}}, color={255,0,255}));
  connect(conPID.y, comPumSig.u) annotation (Line(points={{22,-140},{90,-140},{
          90,100},{138,100}}, color={0,0,127}));
  connect(calTemLvg.T2Lvg, TLvgMax.u1) annotation (Line(points={{-128,-40},{-120,
          -40},{-120,-60},{-112,-60}}, color={0,0,127}));
  connect(TWatEnt, TLvgMax.u2) annotation (Line(points={{-200,-80},{-160,-80},{-160,
          -72},{-112,-72}}, color={0,0,127}));
  connect(TLvgMax.y, comTLvgPre.u)
    annotation (Line(points={{-88,-66},{-62,-66}}, color={0,0,127}));
  annotation (Diagram(
        coordinateSystem(preserveAspectRatio=false, extent={{-180,-180},{220,
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
When enabled, 
<ul>
<li>
modulate fan speed between minimum when
entering water temperature equals <code>TLvgMin + dTEna</code>,
and maximum when entering water temperature equals <code>TEntMax</code>,
</li>
<li>
modulate water flow rate with direct acting PI tracking the water 
temperature drop, with the design approach as set point, 
bound by flow rate in main line.
</li>
</ul>
</li>
<li>
Disable if leaving temperature higher (with margin) than entering
or lower than <code>TLvgMin</code>.
</li>
</ul>
</html>"),
    Icon(coordinateSystem(extent={{-100,-100},{100,100}})));
end CoolingTowersIntegratedApproach;
