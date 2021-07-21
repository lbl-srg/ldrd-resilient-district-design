within LDRD.CentralPlants;
package Controls
  block CoolingTower
    "Cooling tower controller"
    extends Modelica.Blocks.Icons.Block;

    parameter Modelica.SIunits.MassFlowRate m_flow_nominal
      "Nominal mass flow rate"
      annotation(Dialog(group = "Nominal condition"));
    parameter Modelica.SIunits.TemperatureDifference TLvgMin
      "Minimum leaving temperature";
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
        Placement(transformation(extent={{-200,-60},{-160,-20}}),
          iconTransformation(extent={{-140,10},{-100,50}})));
    Buildings.Controls.OBC.CDL.Interfaces.RealInput m_flow(final unit="kg/s")
      "Water mass flow rate" annotation (Placement(transformation(extent={{-200,80},
              {-160,120}}), iconTransformation(extent={{-140,40},{-100,80}})));
    Buildings.Controls.OBC.CDL.Interfaces.RealInput TWatLvg(final unit="K",
        displayUnit="degC") "Water leaving temperature" annotation (Placement(
          transformation(extent={{-200,-140},{-160,-100}}), iconTransformation(
            extent={{-140,-50},{-100,-10}})));
    Buildings.Controls.OBC.CDL.Interfaces.RealInput TWatEnt(final unit="K",
        displayUnit="degC") "Water entering temperature" annotation (Placement(
          transformation(extent={{-200,-100},{-160,-60}}), iconTransformation(
            extent={{-140,-20},{-100,20}})));
    Buildings.Controls.OBC.CDL.Interfaces.RealOutput yPumMasFlo(final unit="kg/s")
      "Pump control signal" annotation (Placement(transformation(extent={{220,80},
              {260,120}}), iconTransformation(extent={{100,30},{140,70}})));
    Buildings.Controls.OBC.CDL.Interfaces.RealOutput yFan(final unit="1")
      "Fan control signal" annotation (Placement(transformation(extent={{220,-60},
              {260,-20}}), iconTransformation(extent={{100,-70},{140,-30}})));
    Buildings.Controls.OBC.CDL.Interfaces.RealInput TBorWatEnt(final unit="K",
        displayUnit="degC") "Borefield water entering temperature" annotation (
        Placement(transformation(extent={{-200,-180},{-160,-140}}),
          iconTransformation(extent={{-140,-80},{-100,-40}})));

    Buildings.Controls.OBC.CDL.Continuous.AddParameter addDelTem(final p=dTEna,
        final k=1) "Add threshold for enabling"
      annotation (Placement(transformation(extent={{-80,-50},{-60,-30}})));
    Modelica.StateGraph.InitialStepWithSignal iniSta "Initial state "
      annotation (Placement(transformation(extent={{-10,30},{10,50}})));
    Modelica.StateGraph.TransitionWithSignal ena "Transition to enabled state"
      annotation (Placement(transformation(extent={{30,30},{50,50}})));
    Modelica.StateGraph.StepWithSignal actSta "Active WSE"
      annotation (Placement(transformation(extent={{70,30},{90,50}})));
    Modelica.StateGraph.TransitionWithSignal dis "Transition to disabled state"
      annotation (Placement(transformation(extent={{110,30},{130,50}})));
    Buildings.Controls.OBC.CDL.Continuous.Add delT1(k2=-1) "Add delta-T"
      annotation (Placement(transformation(extent={{-120,-110},{-100,-90}})));
    Buildings.Controls.OBC.CDL.Continuous.LessThreshold delTemDis(t=dTDis)
      "Compare to threshold for disabling WSE"
      annotation (Placement(transformation(extent={{-30,-110},{-10,-90}})));
    EnergyTransferStations.Combined.Generation5.Controls.PredictLeavingTemperature
                              calTemLvg(final dTApp_nominal=dTApp_nominal, final
        m2_flow_nominal=m_flow_nominal)
      "Compute predicted leaving water temperature"
      annotation (Placement(transformation(extent={{-120,-50},{-100,-30}})));
    Buildings.Controls.OBC.CDL.Continuous.Less delTemDis1
      "Compare to threshold for enabling"
      annotation (Placement(transformation(extent={{-30,-50},{-10,-30}})));
    inner Modelica.StateGraph.StateGraphRoot stateGraphRoot "Root of state graph"
      annotation (Placement(transformation(extent={{-60,40},{-40,60}})));
    Buildings.Controls.OBC.CDL.Logical.MultiAnd mulAnd(nu=4)
      "Enable if cooling enabled and temperature criterion verified"
      annotation (Placement(transformation(extent={{20,-50},{40,-30}})));
    Buildings.Controls.OBC.CDL.Logical.Timer tim(t=1200)
      "True when WSE active for more than t" annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=-90,
          origin={70,-70})));
    Buildings.Controls.OBC.CDL.Logical.Timer tim1(t=1200)
      "True when WSE inactive for more than t"
      annotation (Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=-90,
          origin={20,0})));
    Buildings.Controls.OBC.CDL.Logical.And and2
      "Cooling disabled or temperature criterion verified"
      annotation (Placement(transformation(extent={{90,-102},{110,-82}})));
    Buildings.Controls.OBC.CDL.Logical.Switch swiOff2
      "Switch between enabled and disabled mode"
      annotation (Placement(transformation(extent={{160,90},{180,110}})));

    Buildings.Controls.OBC.CDL.Continuous.Add delTBor(k2=-1)
      "delta-T across borefield"
      annotation (Placement(transformation(extent={{-120,-130},{-100,-150}})));
    Buildings.Controls.OBC.CDL.Continuous.LessThreshold
                                               delTemDis2(t=dTEna)
      "Compare to threshold for enabling WSE"
      annotation (Placement(transformation(extent={{-30,-150},{-10,-130}})));
    Buildings.Controls.OBC.CDL.Continuous.Sources.Constant zer(final k=0) "Zero"
      annotation (Placement(transformation(extent={{110,70},{130,90}})));
    Buildings.Controls.OBC.CDL.Continuous.Line comFanSig "Compute fan signal"
      annotation (Placement(transformation(extent={{180,-50},{200,-30}})));
    Buildings.Controls.OBC.CDL.Continuous.Sources.Constant one(final k=1) "One"
      annotation (Placement(transformation(extent={{130,-100},{150,-80}})));
    Buildings.Controls.OBC.CDL.Continuous.Sources.Constant dTFanMax(final k=-2)
      "DeltaT for maximum fan speed"
      annotation (Placement(transformation(extent={{130,-30},{150,-10}})));
    Buildings.Controls.OBC.CDL.Continuous.Sources.Constant dTFanMin(final k=1)
      "DeltaT for minimum fan speed"
      annotation (Placement(transformation(extent={{130,-70},{150,-50}})));
    Buildings.Controls.OBC.CDL.Continuous.GreaterThreshold
                                               comTLvgPre(t=TLvgMin + dTEna)
      "Compare to threshold for enabling"
      annotation (Placement(transformation(extent={{-80,-10},{-60,10}})));
    Buildings.Controls.OBC.CDL.Continuous.LessThreshold comTLvg(t=TLvgMin)
      "Compare to threshold for disabling"
      annotation (Placement(transformation(extent={{-80,-130},{-60,-110}})));
    Buildings.Controls.OBC.CDL.Logical.MultiOr  mulOr(nu=2)
      "Enable if cooling enabled and temperature criterion verified"
      annotation (Placement(transformation(extent={{20,-110},{40,-90}})));
  equation
    connect(TWatEnt, delT1.u1) annotation (Line(points={{-180,-80},{-140,-80},{-140,
            -94},{-122,-94}}, color={0,0,127}));
    connect(TWatLvg, delT1.u2) annotation (Line(points={{-180,-120},{-130,-120},{-130,
            -106},{-122,-106}}, color={0,0,127}));
    connect(delT1.y,delTemDis. u) annotation (Line(points={{-98,-100},{-32,-100}}, color={0,0,127}));
    connect(TAir, calTemLvg.T1WatEnt) annotation (Line(points={{-180,-40},{-140,-40},
            {-140,-45},{-122,-45}}, color={0,0,127}));
    connect(calTemLvg.T2WatLvg,addDelTem. u) annotation (Line(points={{-98,-40},{-82,
            -40}},                                                                           color={0,0,127}));
    connect(addDelTem.y,delTemDis1. u1) annotation (Line(points={{-58,-40},{-32,-40}},
                                                                                    color={0,0,127}));
    connect(TWatEnt, delTemDis1.u2) annotation (Line(points={{-180,-80},{-40,-80},
            {-40,-48},{-32,-48}}, color={0,0,127}));
    connect(iniSta.outPort[1],ena. inPort) annotation (Line(points={{10.5,40},{36,
            40}},                                                                         color={0,0,0}));
    connect(ena.outPort,actSta. inPort[1]) annotation (Line(points={{41.5,40},{69,
            40}},                                                                       color={0,0,0}));
    connect(actSta.outPort[1],dis. inPort) annotation (Line(points={{90.5,40},{116,
            40}},                                                                       color={0,0,0}));
    connect(dis.outPort,iniSta. inPort[1])
      annotation (Line(points={{121.5,40},{140,40},{140,60},{-20,60},{-20,40},{-11,
            40}},                                                                        color={0,0,0}));
    connect(mulAnd.y,ena. condition) annotation (Line(points={{42,-40},{50,-40},{50,
            18},{40,18},{40,28}},                                                         color={255,0,255}));
    connect(delTemDis1.y,mulAnd. u[1])
      annotation (Line(points={{-8,-40},{18,-40},{18,-34.75}},                     color={255,0,255}));
    connect(iniSta.active,tim1. u) annotation (Line(points={{0,29},{0,20},{20,20},
            {20,12}},                                                           color={255,0,255}));
    connect(tim1.passed,mulAnd. u[2])
      annotation (Line(points={{12,-12},{12,-36},{18,-36},{18,-38.25}},  color={255,0,255}));
    connect(actSta.active,tim. u) annotation (Line(points={{80,29},{80,-40},{70,-40},
            {70,-58}},                                                        color={255,0,255}));
    connect(tim.passed,and2. u1) annotation (Line(points={{62,-82},{62,-92},{88,-92}},    color={255,0,255}));
    connect(and2.y,dis. condition) annotation (Line(points={{112,-92},{120,-92},{120,
            28}},                                                                         color={255,0,255}));
    connect(m_flow, calTemLvg.m2_flow) annotation (Line(points={{-180,100},{-140,100},
            {-140,-35},{-122,-35}}, color={0,0,127}));
    connect(swiOff2.y, yPumMasFlo)
      annotation (Line(points={{182,100},{240,100}}, color={0,0,127}));
    connect(TBorWatEnt, delTBor.u1) annotation (Line(points={{-180,-160},{-140,-160},
            {-140,-146},{-122,-146}}, color={0,0,127}));
    connect(TWatEnt, delTBor.u2) annotation (Line(points={{-180,-80},{-140,-80},{-140,
            -134},{-122,-134}}, color={0,0,127}));
    connect(delTBor.y, delTemDis2.u)
      annotation (Line(points={{-98,-140},{-32,-140}}, color={0,0,127}));
    connect(delTemDis2.y, mulAnd.u[3]) annotation (Line(points={{-8,-140},{10,-140},
            {10,-41.75},{18,-41.75}},    color={255,0,255}));
    connect(actSta.active, swiOff2.u2) annotation (Line(points={{80,29},{80,20},{150,
            20},{150,100},{158,100}}, color={255,0,255}));
    connect(m_flow, swiOff2.u1) annotation (Line(points={{-180,100},{140,100},{140,
            108},{158,108}}, color={0,0,127}));
    connect(zer.y, swiOff2.u3) annotation (Line(points={{132,80},{140,80},{140,92},
            {158,92}}, color={0,0,127}));
    connect(comFanSig.y, yFan)
      annotation (Line(points={{202,-40},{240,-40}}, color={0,0,127}));
    connect(delTBor.y, comFanSig.u) annotation (Line(points={{-98,-140},{-40,-140},
            {-40,-120},{170,-120},{170,-40},{178,-40}}, color={0,0,127}));
    connect(dTFanMin.y, comFanSig.x2) annotation (Line(points={{152,-60},{160,-60},
            {160,-44},{178,-44}}, color={0,0,127}));
    connect(dTFanMax.y, comFanSig.x1) annotation (Line(points={{152,-20},{160,-20},
            {160,-32},{178,-32}}, color={0,0,127}));
    connect(one.y, comFanSig.f1) annotation (Line(points={{152,-90},{166,-90},{166,
            -36},{178,-36}}, color={0,0,127}));
    connect(zer.y, comFanSig.f2) annotation (Line(points={{132,80},{174,80},{174,-48},
            {178,-48}}, color={0,0,127}));
    connect(comTLvgPre.y, mulAnd.u[4]) annotation (Line(points={{-58,0},{0,0},{0,-45.25},
            {18,-45.25}}, color={255,0,255}));
    connect(calTemLvg.T2WatLvg,comTLvgPre. u) annotation (Line(points={{-98,-40},{
            -90,-40},{-90,0},{-82,0}}, color={0,0,127}));
    connect(TWatLvg, comTLvg.u)
      annotation (Line(points={{-180,-120},{-82,-120}}, color={0,0,127}));
    connect(mulOr.y, and2.u2)
      annotation (Line(points={{42,-100},{88,-100}}, color={255,0,255}));
    connect(delTemDis.y, mulOr.u[1]) annotation (Line(points={{-8,-100},{6,-100},
            {6,-96.5},{18,-96.5}}, color={255,0,255}));
    connect(comTLvg.y, mulOr.u[2]) annotation (Line(points={{-58,-120},{-52,
            -120},{-52,-114},{0,-114},{0,-103.5},{18,-103.5}}, color={255,0,255}));
    annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
          coordinateSystem(preserveAspectRatio=false, extent={{-160,-200},{220,200}})),
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
be lower (with margin) than entering and higher than minimum district 
water temperature, and deltaT across borefield is lower than 1 K.
</li>
<li>
When enabled, modulate fan speed between minimum when deltaT 
across borefield is 1 K and maximum when -2 K. 
</li>
<li>
Disable if leaving temperature higher (with margin) than entering
or lower than minimum district water temperature.
</li>
</ul>
</html>"));
  end CoolingTower;
end Controls;
