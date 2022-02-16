within LDRD.CentralPlants.Controls;
block CoolingTowers_bck "Cooling towers controller"
  extends Modelica.Blocks.Icons.Block;

  parameter Boolean isCooTow=true
    "Set to true for cooling towers, false for dry coolers"
    annotation(Dialog(group = "Configuration"));
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
    "Water mass flow rate" annotation (Placement(transformation(extent={{-220,80},
            {-180,120}}), iconTransformation(extent={{-140,40},{-100,80}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TWatLvg(final unit="K",
      displayUnit="degC") "Water leaving temperature" annotation (Placement(
        transformation(extent={{-220,-160},{-180,-120}}), iconTransformation(
          extent={{-140,-50},{-100,-10}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TWatEnt(final unit="K",
      displayUnit="degC") "Water entering temperature" annotation (Placement(
        transformation(extent={{-220,-120},{-180,-80}}), iconTransformation(
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
    annotation (Placement(transformation(extent={{-150,-130},{-130,-110}})));
  Buildings.Controls.OBC.CDL.Continuous.LessThreshold delTemDis(t=dTDis)
    "Compare to threshold for disabling WSE"
    annotation (Placement(transformation(extent={{-70,-130},{-50,-110}})));
  EnergyTransferStations.Combined.Generation5.Controls.PredictLeavingTemperature
                            calTemLvg(final dTApp_nominal=dTApp_nominal, final
      m2_flow_nominal=m_flow_nominal)
    "Compute predicted leaving water temperature"
    annotation (Placement(transformation(extent={{-150,-50},{-130,-30}})));
  Buildings.Controls.OBC.CDL.Continuous.Less delTemDis1
    "Compare to threshold for enabling"
    annotation (Placement(transformation(extent={{-60,-50},{-40,-30}})));
  inner Modelica.StateGraph.StateGraphRoot stateGraphRoot "Root of state graph"
    annotation (Placement(transformation(extent={{-100,40},{-80,60}})));
  Buildings.Controls.OBC.CDL.Logical.MultiAnd mulAnd(final nin=2)
    "Enable if cooling enabled and temperature criterion verified"
    annotation (Placement(transformation(extent={{-10,-50},{10,-30}})));
  Buildings.Controls.OBC.CDL.Logical.Timer tim(t=1200)
    "True when WSE active for more than t" annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={34,-70})));
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
    annotation (Placement(transformation(extent={{60,70},{80,90}})));
  Buildings.Controls.OBC.CDL.Continuous.Line comFanSig "Compute fan signal"
    annotation (Placement(transformation(extent={{150,-50},{170,-30}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant one(final k=1) "One"
    annotation (Placement(transformation(extent={{100,-100},{120,-80}})));
  Buildings.Controls.OBC.CDL.Continuous.Less comTLvg
    "Compare to threshold for disabling"
    annotation (Placement(transformation(extent={{-110,-150},{-90,-130}})));
  Buildings.Controls.OBC.CDL.Logical.MultiOr  mulOr(nin=2)
    "Enable if cooling enabled and temperature criterion verified"
    annotation (Placement(transformation(extent={{-10,-130},{10,-110}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant maxT(final k=TEntMax)
    "Entering temperature for maximum speed"
    annotation (Placement(transformation(extent={{100,-70},{120,-50}})));
  Buildings.Controls.OBC.CDL.Logical.Switch swiOff1
    "Switch between enabled and disabled mode"
    annotation (Placement(transformation(extent={{190,-30},{210,-50}})));
  Buildings.Controls.OBC.CDL.Continuous.Add TLvgMax(k1=fraFreCon, k2=1 -
        fraFreCon) "Predicted maximum leaving temperature (in free convection)"
    annotation (Placement(transformation(extent={{-110,-90},{-90,-70}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.CalendarTime calTim(zerTim=
        Buildings.Controls.OBC.CDL.Types.ZeroTime.NY2017) "Calendar time"
    annotation (Placement(transformation(extent={{-140,130},{-120,150}})));
  Modelica.Blocks.Sources.RealExpression TLvgMin_actual(y(
      final unit="K",
      displayUnit="degC") = if calTim.month >= 5 and calTim.month <= 9 then 4 +
      273.15 else TLvgMin)
    "Actual TLvgMin"
    annotation (Placement(transformation(extent={{-100,130},{-80,150}})));
  Buildings.Controls.OBC.CDL.Continuous.AddParameter addDelTem1(final p=dTEna,
      final k=1) "Add threshold for enabling"
    annotation (Placement(transformation(extent={{-60,130},{-40,150}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TWatTowOut(final unit="K",
      displayUnit="degC")
    "Water temperature at tower outlet for freeze protection" annotation (
      Placement(transformation(
        extent={{-20,-20},{20,20}},
        rotation=90,
        origin={0,-240}), iconTransformation(extent={{-140,-100},{-100,-60}})));
  Buildings.Controls.OBC.CDL.Continuous.LessThreshold
                                             comTLvg1(t=2 + 273.15)
    "Compare to threshold for disabling"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=90,
        origin={0,-170})));
  Buildings.Controls.OBC.CDL.Logical.Or or1 "Freeze protection"
    annotation (Placement(transformation(extent={{66,-140},{86,-120}})));
  Buildings.Experimental.DHC.EnergyTransferStations.Combined.Generation5.Controls.PIDWithEnable
    conPID(
    controllerType=Buildings.Controls.OBC.CDL.Types.SimpleController.P,
    k=1,
    Ti=1,
    reverseActing=true)
    annotation (Placement(transformation(extent={{100,-180},{120,-160}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant frePro(final k=4 +
        273.15) "Limit for freez protection"
    annotation (Placement(transformation(extent={{60,-180},{80,-160}})));
  Buildings.Controls.OBC.CDL.Continuous.Min              min1
    "Min between control and freeze protection"
    annotation (Placement(transformation(extent={{164,-120},{184,-100}})));
  Buildings.Controls.OBC.CDL.Continuous.AddParameter rev(final p=1, final k=-1)
    "One minus PI output"
    annotation (Placement(transformation(extent={{130,-180},{150,-160}})));
equation
  connect(TWatEnt, delT1.u1) annotation (Line(points={{-200,-100},{-160,-100},{-160,
          -114},{-152,-114}},
                            color={0,0,127}));
  connect(TWatLvg, delT1.u2) annotation (Line(points={{-200,-140},{-160,-140},{-160,
          -126},{-152,-126}}, color={0,0,127}));
  connect(delT1.y,delTemDis. u) annotation (Line(points={{-128,-120},{-72,-120}},color={0,0,127}));
  connect(TAir, calTemLvg.T1Ent) annotation (Line(points={{-200,-40},{-160,-40},
          {-160,-45},{-152,-45}}, color={0,0,127}));
  connect(calTemLvg.T2Lvg, addDelTem.u) annotation (Line(points={{-128,-40},{-120,
          -40},{-120,-40},{-112,-40}}, color={0,0,127}));
  connect(addDelTem.y,delTemDis1. u1) annotation (Line(points={{-88,-40},{-62,-40}},
                                                                                  color={0,0,127}));
  connect(TWatEnt, delTemDis1.u2) annotation (Line(points={{-200,-100},{-80,-100},
          {-80,-48},{-62,-48}}, color={0,0,127}));
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
    annotation (Line(points={{-38,-40},{-12,-40},{-12,-41.75}},                  color={255,0,255}));
  connect(iniSta.active,tim1. u) annotation (Line(points={{-30,29},{-30,20},{-10,
          20},{-10,12}},                                                      color={255,0,255}));
  connect(tim1.passed,mulAnd. u[2])
    annotation (Line(points={{-18,-12},{-18,-36},{-12,-36},{-12,-38.25}},
                                                                       color={255,0,255}));
  connect(actSta.active,tim. u) annotation (Line(points={{50,29},{50,-50},{34,
          -50},{34,-58}},                                                   color={255,0,255}));
  connect(tim.passed,and2. u1) annotation (Line(points={{26,-82},{26,-92},{58,
          -92}},                                                                        color={255,0,255}));
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
  connect(zer.y, swiOff2.u3) annotation (Line(points={{82,80},{182,80},{182,92},
          {188,92}}, color={0,0,127}));
  connect(mulOr.y, and2.u2)
    annotation (Line(points={{12,-120},{36,-120},{36,-100},{58,-100}},
                                                   color={255,0,255}));
  connect(delTemDis.y, mulOr.u[1]) annotation (Line(points={{-48,-120},{-20,
          -120},{-20,-121.75},{-12,-121.75}},
                                 color={255,0,255}));
  connect(comTLvg.y, mulOr.u[2]) annotation (Line(points={{-88,-140},{-30,-140},
          {-30,-118.25},{-12,-118.25}},                      color={255,0,255}));
  connect(maxT.y, comFanSig.x2) annotation (Line(points={{122,-60},{130,-60},{130,
          -44},{148,-44}}, color={0,0,127}));
  connect(TWatEnt, comFanSig.u) annotation (Line(points={{-200,-100},{20,-100},{
          20,-40},{148,-40}},
                           color={0,0,127}));
  connect(zer.y, comFanSig.f1) annotation (Line(points={{82,80},{140,80},{140,-36},
          {148,-36}},      color={0,0,127}));
  connect(one.y, comFanSig.f2) annotation (Line(points={{122,-90},{140,-90},{
          140,-48},{148,-48}}, color={0,0,127}));
  connect(actSta.active, swiOff1.u2) annotation (Line(points={{50,29},{50,20},{
          180,20},{180,-40},{188,-40}}, color={255,0,255}));
  connect(swiOff1.y, yFan)
    annotation (Line(points={{212,-40},{240,-40},{240,-40}}, color={0,0,127}));
  connect(zer.y, swiOff1.u3) annotation (Line(points={{82,80},{140,80},{140,-20},
          {182,-20},{182,-32},{188,-32}},
                                     color={0,0,127}));
  connect(TWatEnt, TLvgMax.u2) annotation (Line(points={{-200,-100},{-160,-100},
          {-160,-86},{-112,-86}}, color={0,0,127}));
  connect(calTemLvg.T2Lvg, TLvgMax.u1) annotation (Line(points={{-128,-40},{-120,
          -40},{-120,-74},{-112,-74}}, color={0,0,127}));
  connect(TLvgMin_actual.y, addDelTem1.u)
    annotation (Line(points={{-79,140},{-62,140}}, color={0,0,127}));
  connect(addDelTem1.y, comFanSig.x1) annotation (Line(points={{-38,140},{120,140},
          {120,-32},{148,-32}}, color={0,0,127}));
  connect(TWatLvg, comTLvg.u1)
    annotation (Line(points={{-200,-140},{-112,-140}}, color={0,0,127}));
  connect(TLvgMin_actual.y, comTLvg.u2) annotation (Line(points={{-79,140},{-70,
          140},{-70,120},{-174,120},{-174,-148},{-112,-148}}, color={0,0,127}));
  connect(TWatTowOut, comTLvg1.u) annotation (Line(points={{0,-240},{0,-182},{
          -6.66134e-16,-182}}, color={0,0,127}));
  connect(and2.y, or1.u1) annotation (Line(points={{82,-92},{82,-114},{56,-114},
          {56,-130},{64,-130}}, color={255,0,255}));
  connect(comTLvg1.y, or1.u2) annotation (Line(points={{8.88178e-16,-158},{
          8.88178e-16,-138},{64,-138}}, color={255,0,255}));
  connect(or1.y, dis.condition)
    annotation (Line(points={{88,-130},{90,-130},{90,28}}, color={255,0,255}));
  connect(TWatTowOut, conPID.u_m) annotation (Line(points={{0,-240},{0,-200},{
          110,-200},{110,-182}}, color={0,0,127}));
  connect(frePro.y, conPID.u_s)
    annotation (Line(points={{82,-170},{98,-170}}, color={0,0,127}));
  connect(comFanSig.y, min1.u1) annotation (Line(points={{172,-40},{174,-40},{
          174,-80},{160,-80},{160,-104},{162,-104}}, color={0,0,127}));
  connect(min1.y, swiOff1.u1) annotation (Line(points={{186,-110},{190,-110},{
          190,-60},{180,-60},{180,-48},{188,-48}}, color={0,0,127}));
  connect(actSta.active, conPID.uEna) annotation (Line(points={{50,29},{50,-192},
          {106,-192},{106,-182}}, color={255,0,255}));
  connect(conPID.y, rev.u)
    annotation (Line(points={{122,-170},{128,-170}}, color={0,0,127}));
  connect(rev.y, min1.u2) annotation (Line(points={{152,-170},{160,-170},{160,
          -116},{162,-116}}, color={0,0,127}));
  annotation (Diagram(
        coordinateSystem(preserveAspectRatio=false, extent={{-180,-220},{220,220}})),
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
First, compute the actual minimum
leaving temperature <code>TLvgMin_actual</code> which is
equal to the parameter <code>TLvgMin</code> during the 
heating season and equal to 0°C otherwise. (For the sake 
of simplicity the heating season is defined based on the 
month of the calendar year: 1 to 4 and 10 to 12.)
</li>
<li>
Enable with similar logic as WSE:
based on predicted leaving water temperature that must
be lower (with margin) than entering and higher than minimum
leaving temperature <code>TLvgMin_actual</code>.
</li>
<li>
When enabled, modulate fan speed between minimum when
entering water temperature equals <code>TLvgMin_actual + dTEna</code>,
and maximum when entering water temperature equals <code>TEntMax</code>.
</li>
<li>
Disable if leaving temperature higher (with margin) than entering
or lower than <code>TLvgMin_actual</code>.
</li>
</ul>
</html>"));
end CoolingTowers_bck;
