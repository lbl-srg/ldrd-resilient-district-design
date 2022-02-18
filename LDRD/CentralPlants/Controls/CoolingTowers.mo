within LDRD.CentralPlants.Controls;
block CoolingTowers "Cooling towers controller"
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
    "Water mass flow rate" annotation (Placement(transformation(extent={{-220,80},
            {-180,120}}), iconTransformation(extent={{-140,40},{-100,80}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TDisWatLvg(final unit="K",
      displayUnit="degC") "District water leaving temperature" annotation (
      Placement(transformation(extent={{-220,-220},{-180,-180}}),
        iconTransformation(extent={{-140,-80},{-100,-40}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yPumMasFlo(final unit="kg/s")
    "Pump control signal" annotation (Placement(transformation(extent={{220,80},
            {260,120}}), iconTransformation(extent={{100,30},{140,70}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yFan(final unit="1")
    "Fan control signal" annotation (Placement(transformation(extent={{220,-60},
            {260,-20}}), iconTransformation(extent={{100,-70},{140,-30}})));

  Buildings.Controls.OBC.CDL.Continuous.AddParameter addDelTem(final p=dTEna,
      final k=1) "Add threshold for enabling"
    annotation (Placement(transformation(extent={{-100,-50},{-80,-30}})));
  Modelica.StateGraph.InitialStepWithSignal iniSta "Initial state "
    annotation (Placement(transformation(extent={{-40,30},{-20,50}})));
  Modelica.StateGraph.TransitionWithSignal ena "Transition to enabled state"
    annotation (Placement(transformation(extent={{0,30},{20,50}})));
  Modelica.StateGraph.StepWithSignal actSta "Active WSE"
    annotation (Placement(transformation(extent={{40,30},{60,50}})));
  Modelica.StateGraph.TransitionWithSignal dis "Transition to disabled state"
    annotation (Placement(transformation(extent={{80,30},{100,50}})));
  Buildings.Controls.OBC.CDL.Continuous.Add delT1(k2=-1) "Add delta-T"
    annotation (Placement(transformation(extent={{-120,-130},{-100,-110}})));
  Buildings.Controls.OBC.CDL.Continuous.LessThreshold delTemDis(t=dTDis)
    "Compare to threshold for disabling WSE"
    annotation (Placement(transformation(extent={{-10,-130},{10,-110}})));
  EnergyTransferStations.Combined.Generation5.Controls.PredictLeavingTemperature
                            calTemLvg(final dTApp_nominal=dTApp_nominal, final
      m2_flow_nominal=m_flow_nominal)
    "Compute predicted leaving water temperature"
    annotation (Placement(transformation(extent={{-150,-10},{-130,10}})));
  Buildings.Controls.OBC.CDL.Continuous.Less delTemEna
    "Compare to threshold for enabling"
    annotation (Placement(transformation(extent={{-70,-50},{-50,-30}})));
  inner Modelica.StateGraph.StateGraphRoot stateGraphRoot "Root of state graph"
    annotation (Placement(transformation(extent={{-100,40},{-80,60}})));
  Buildings.Controls.OBC.CDL.Logical.MultiAnd mulAnd(final nin=2)
    "Enable if cooling enabled and temperature criterion verified"
    annotation (Placement(transformation(extent={{-20,-50},{0,-30}})));
  Buildings.Controls.OBC.CDL.Logical.Timer tim(t=1200)
    "True when WSE active for more than t" annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={30,-60})));
  Buildings.Controls.OBC.CDL.Logical.Timer tim1(t=1200)
    "True when WSE inactive for more than t"
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={-30,0})));
  Buildings.Controls.OBC.CDL.Logical.And and2
    "Cooling disabled or temperature criterion verified"
    annotation (Placement(transformation(extent={{60,-90},{80,-70}})));

  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant one(final k=1) "One"
    annotation (Placement(transformation(extent={{20,142},{40,162}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.CalendarTime calTim(zerTim=
        Buildings.Controls.OBC.CDL.Types.ZeroTime.NY2017) "Calendar time"
    annotation (Placement(transformation(extent={{-140,130},{-120,150}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TWatLvgTow(final unit="K",
      displayUnit="degC") "Water leaving temperature"         annotation (
      Placement(transformation(
        extent={{-20,-20},{20,20}},
        rotation=0,
        origin={-200,-100}),
                          iconTransformation(extent={{-140,-20},{-100,20}})));
  Buildings.Controls.OBC.CDL.Continuous.Product pro
    "Modulate flow rate set point"
    annotation (Placement(transformation(extent={{190,90},{210,110}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant minPumSpe(final k=0.1)
    "Minimum pump speed (fractional)"
    annotation (Placement(transformation(extent={{20,190},{40,210}})));
  Buildings.Controls.OBC.CDL.Continuous.Line comPumSig "Compute pump signal"
    annotation (Placement(transformation(extent={{150,150},{170,170}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant zer2(final k=0) "Zero"
    annotation (Placement(transformation(extent={{20,110},{40,130}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant zer3(final k=0.5)
    "Zero"
    annotation (Placement(transformation(extent={{20,70},{40,90}})));
  Modelica.Blocks.Sources.RealExpression TDisWatSupSet_actual(y(
      final unit="K",
      displayUnit="degC") = if calTim.month >= 5 and calTim.month <= 9 then 4
       + 273.15 else TLvgMin)
                           "Actual TDisWatSup set point"
    annotation (Placement(transformation(extent={{-160,-90},{-140,-70}})));
  Buildings.Controls.OBC.CDL.Continuous.Line setTWatLvgTow
    "Compute TWatLvgTow set point"
    annotation (Placement(transformation(extent={{160,50},{180,70}})));
  Buildings.Experimental.DHC.EnergyTransferStations.Combined.Generation5.Controls.PIDWithEnable
    conFan(
    controllerType=Buildings.Controls.OBC.CDL.Types.SimpleController.P,
    k=1,
    Ti=0.1,
    reverseActing=false) "Control fan speed"
    annotation (Placement(transformation(extent={{180,-50},{200,-30}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant TWatLvgTow_min(final k=2
         + 273.15) "Minimum TWatLvgTow"
    annotation (Placement(transformation(extent={{100,-50},{120,-30}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant TWatLvgTow_max(k=TLvgMin
         - 2)
    "Maximum TWatLvgTow"
    annotation (Placement(transformation(extent={{100,-10},{120,10}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TDisWatEnt(final unit="K",
      displayUnit="degC") "District water entering temperature" annotation (
      Placement(transformation(extent={{-220,-180},{-180,-140}}),
        iconTransformation(extent={{-140,-50},{-100,-10}})));
  Buildings.Experimental.DHC.EnergyTransferStations.Combined.Generation5.Controls.PIDWithEnable
    dem(
    controllerType=Buildings.Controls.OBC.CDL.Types.SimpleController.P,
    k=1,
    Ti=0.1,
    reverseActing=false) "Demand from district loop"
    annotation (Placement(transformation(extent={{-10,-170},{10,-150}})));
  Buildings.Controls.OBC.CDL.Continuous.Max maxSet
    "Maximum between predicted and set point"
    annotation (Placement(transformation(extent={{-130,-50},{-110,-30}})));
  Buildings.Controls.OBC.CDL.Logical.Switch
                                         and1
    "Cooling disabled or temperature criterion verified"
    annotation (Placement(transformation(extent={{90,190},{110,210}})));
equation
  connect(TDisWatLvg, delT1.u2) annotation (Line(points={{-200,-200},{-160,-200},
          {-160,-126},{-122,-126}}, color={0,0,127}));
  connect(delT1.y,delTemDis. u) annotation (Line(points={{-98,-120},{-12,-120}}, color={0,0,127}));
  connect(TAir, calTemLvg.T1Ent) annotation (Line(points={{-200,-40},{-160,-40},
          {-160,-5},{-152,-5}},   color={0,0,127}));
  connect(addDelTem.y, delTemEna.u1)
    annotation (Line(points={{-78,-40},{-72,-40}}, color={0,0,127}));
  connect(iniSta.outPort[1],ena. inPort) annotation (Line(points={{-19.5,40},{6,
          40}},                                                                         color={0,0,0}));
  connect(ena.outPort,actSta. inPort[1]) annotation (Line(points={{11.5,40},{39,
          40}},                                                                       color={0,0,0}));
  connect(actSta.outPort[1],dis. inPort) annotation (Line(points={{60.5,40},{86,
          40}},                                                                       color={0,0,0}));
  connect(dis.outPort,iniSta. inPort[1])
    annotation (Line(points={{91.5,40},{100,40},{100,60},{-50,60},{-50,40},{-41,
          40}},                                                                        color={0,0,0}));
  connect(mulAnd.y,ena. condition) annotation (Line(points={{2,-40},{10,-40},{
          10,28}},                                                                      color={255,0,255}));
  connect(delTemEna.y, mulAnd.u[1]) annotation (Line(points={{-48,-40},{-18,-40},
          {-18,-41.75},{-22,-41.75}},
                         color={255,0,255}));
  connect(iniSta.active,tim1. u) annotation (Line(points={{-30,29},{-30,12}}, color={255,0,255}));
  connect(tim1.passed,mulAnd. u[2])
    annotation (Line(points={{-38,-12},{-38,-36},{-22,-36},{-22,-38.25}},
                                                                       color={255,0,255}));
  connect(actSta.active,tim. u) annotation (Line(points={{50,29},{50,-40},{30,-40},
          {30,-48}},                                                        color={255,0,255}));
  connect(tim.passed,and2. u1) annotation (Line(points={{22,-72},{22,-80},{58,-80}},    color={255,0,255}));
  connect(m_flow, calTemLvg.m2_flow) annotation (Line(points={{-200,100},{-160,
          100},{-160,5},{-152,5}},color={0,0,127}));
  connect(m_flow, pro.u2) annotation (Line(points={{-200,100},{180,100},{180,94},
          {188,94}}, color={0,0,127}));
  connect(zer2.y, comPumSig.x1) annotation (Line(points={{42,120},{144,120},{144,
          168},{148,168}}, color={0,0,127}));
  connect(zer3.y, comPumSig.x2) annotation (Line(points={{42,80},{120,80},{120,
          156},{148,156}},
                      color={0,0,127}));
  connect(pro.y, yPumMasFlo)
    annotation (Line(points={{212,100},{240,100}}, color={0,0,127}));
  connect(one.y, comPumSig.f2)
    annotation (Line(points={{42,152},{148,152}}, color={0,0,127}));
  connect(and2.y, dis.condition)
    annotation (Line(points={{82,-80},{90,-80},{90,28}}, color={255,0,255}));
  connect(actSta.active, conFan.uEna) annotation (Line(points={{50,29},{50,-60},
          {186,-60},{186,-52}}, color={255,0,255}));
  connect(setTWatLvgTow.y, conFan.u_s) annotation (Line(points={{182,60},{200,60},
          {200,-20},{160,-20},{160,-40},{178,-40}}, color={0,0,127}));
  connect(TWatLvgTow, conFan.u_m) annotation (Line(points={{-200,-100},{190,-100},
          {190,-52}}, color={0,0,127}));
  connect(conFan.y, yFan) annotation (Line(points={{202,-40},{212,-40},{212,-40},
          {240,-40}}, color={0,0,127}));
  connect(TDisWatEnt, delT1.u1) annotation (Line(points={{-200,-160},{-168,-160},
          {-168,-114},{-122,-114}}, color={0,0,127}));
  connect(TDisWatEnt, delTemEna.u2) annotation (Line(points={{-200,-160},{-168,
          -160},{-168,-60},{-76,-60},{-76,-48},{-72,-48}},
                                 color={0,0,127}));
  connect(zer3.y, setTWatLvgTow.x1) annotation (Line(points={{42,80},{120,80},{
          120,68},{158,68}}, color={0,0,127}));
  connect(TWatLvgTow_max.y, setTWatLvgTow.f1) annotation (Line(points={{122,0},
          {130,0},{130,64},{158,64}}, color={0,0,127}));
  connect(TWatLvgTow_min.y, setTWatLvgTow.f2) annotation (Line(points={{122,-40},
          {134,-40},{134,52},{158,52}}, color={0,0,127}));
  connect(one.y, setTWatLvgTow.x2) annotation (Line(points={{42,152},{134,152},
          {134,56},{158,56}}, color={0,0,127}));
  connect(delTemDis.y, and2.u2) annotation (Line(points={{12,-120},{40,-120},{
          40,-88},{58,-88}}, color={255,0,255}));
  connect(TDisWatLvg, dem.u_m)
    annotation (Line(points={{-200,-200},{0,-200},{0,-172}}, color={0,0,127}));
  connect(TDisWatSupSet_actual.y, dem.u_s) annotation (Line(points={{-139,-80},
          {-60,-80},{-60,-160},{-12,-160}}, color={0,0,127}));
  connect(actSta.active, dem.uEna) annotation (Line(points={{50,29},{50,-180},{
          -4,-180},{-4,-172}}, color={255,0,255}));
  connect(dem.y, setTWatLvgTow.u) annotation (Line(points={{12,-160},{140,-160},
          {140,60},{158,60}}, color={0,0,127}));
  connect(dem.y, comPumSig.u) annotation (Line(points={{12,-160},{140,-160},{
          140,160},{148,160}}, color={0,0,127}));
  connect(maxSet.y, addDelTem.u)
    annotation (Line(points={{-108,-40},{-102,-40}}, color={0,0,127}));
  connect(calTemLvg.T2Lvg, maxSet.u1) annotation (Line(points={{-128,0},{-120,0},
          {-120,-20},{-140,-20},{-140,-34},{-132,-34}}, color={0,0,127}));
  connect(TDisWatSupSet_actual.y, maxSet.u2) annotation (Line(points={{-139,-80},
          {-136,-80},{-136,-46},{-132,-46}}, color={0,0,127}));
  connect(and1.y, comPumSig.f1) annotation (Line(points={{112,200},{120,200},{
          120,164},{148,164}}, color={0,0,127}));
  connect(minPumSpe.y, and1.u1) annotation (Line(points={{42,200},{60,200},{60,
          208},{88,208}}, color={0,0,127}));
  connect(zer2.y, and1.u3) annotation (Line(points={{42,120},{84,120},{84,192},
          {88,192}}, color={0,0,127}));
  connect(actSta.active, and1.u2) annotation (Line(points={{50,29},{50,20},{80,
          20},{80,200},{88,200}}, color={255,0,255}));
  connect(comPumSig.y, pro.u1) annotation (Line(points={{172,160},{180,160},{
          180,106},{188,106}}, color={0,0,127}));
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
Control logic: see paper
</p>
<ul>
<li>
First, compute the actual minimum
leaving temperature <code>TLvgMin_actual</code> which is
equal to the parameter <code>TLvgMin</code> during the 
heating season and equal to 4°C otherwise. (For the sake 
of simplicity the heating season is defined based on the 
month of the calendar year: 1 to 4 and 10 to 12.)
</li>
</ul>
</html>"));
end CoolingTowers;
