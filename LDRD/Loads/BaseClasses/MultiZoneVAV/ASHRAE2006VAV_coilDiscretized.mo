within LDRD.Loads.BaseClasses.MultiZoneVAV;
model ASHRAE2006VAV_coilDiscretized "Variable air volume flow system with terminal reheat"
  extends PartialOpenLoop_coilDiscretized(
    amb(nPorts=3));

  parameter Real ratVFloMin[numVAV](final unit="1")=
    {max(1.5 * VOABox_flow_nominal[i], 0.15 * mAirBox_flow_nominal[i] / 1.2) /
    (mAirBox_flow_nominal[i] / 1.2) for i in 1:numVAV}
    "Minimum discharge air flow rate ratio";

  Buildings.Examples.VAVReheat.Controls.FanVFD conFanSup(
    xSet_nominal(displayUnit="Pa") = 410,
    r_N_min=yFanMin)
    "Controller for fan"
    annotation (Placement(transformation(extent={{240,-10},{260,10}})));
  Buildings.Examples.VAVReheat.Controls.ModeSelector modeSelector
    annotation (Placement(transformation(extent={{-200,-320},{-180,-300}})));
  Buildings.Examples.VAVReheat.Controls.ControlBus controlBus
    annotation (Placement(transformation(extent={{-80,20},{-60,40}}),
        iconTransformation(extent={{-10,30},{10,50}})));

  Buildings.Examples.VAVReheat.Controls.Economizer conEco(
    have_reset=true,
    have_frePro=true,
    VOut_flow_min=VOut_flow_nominal)
    "Controller for economizer"
    annotation (Placement(transformation(extent={{-80,140},{-60,160}})));
  Buildings.Examples.VAVReheat.Controls.RoomTemperatureSetpoint
    TSetRoo(
    final THeaOn=THeaOn,
    final THeaOff=THeaOff,
    final TCooOn=TCooOn,
    final TCooOff=TCooOff)
    annotation (Placement(transformation(extent={{-300,-358},{-280,-338}})));
  DuctStaticPressureSetpoint
    pSetDuc(nin=numVAV, pMin=50) "Duct static pressure setpoint"
    annotation (Placement(transformation(extent={{160,-10},{180,10}})));
  Buildings.Examples.VAVReheat.Controls.RoomVAV conVAV[numVAV](
    final ratVFloMin=ratVFloMin,
    final ratVFloHea=ratVFloHea,
    each kCoo=0.05,
    each kHea=0.01)
    "Controller for terminal unit of each zone"
    annotation (Placement(transformation(extent={{460,60},{480,80}})));

  Buildings.Controls.OBC.CDL.Logical.Or or2
    annotation (Placement(transformation(extent={{-60,-250},{-40,-230}})));
  Buildings.Examples.VAVReheat.Controls.SupplyAirTemperature
    conTSup "Supply air temperature controller"
    annotation (Placement(transformation(extent={{30,-230},{50,-210}})));
  Buildings.Examples.VAVReheat.Controls.SupplyAirTemperatureSetpoint
    TSupSet(TSetVal(final k=datVAV.TSupSet))
    "Supply air temperature set point"
    annotation (Placement(transformation(extent={{-200,-230},{-180,-210}})));

  Buildings.Utilities.Math.Min min(nin=numVAV) "Computes lowest room temperature"
    annotation (Placement(transformation(extent={{-300,260},{-280,280}})));
  Buildings.Utilities.Math.Average ave(nin=numVAV) "Compute average of room temperatures"
    annotation (Placement(transformation(extent={{-300,220},{-280,240}})));

  Buildings.Fluid.Actuators.Dampers.Exponential damExh(
    from_dp=true,
    riseTime=15,
    final dpDamper_nominal=datVAV.dpEcoDam,
    final dpFixed_nominal=datVAV.dpEcoFix,
    redeclare final package Medium = MediumA,
    final m_flow_nominal=m_flow_nominal)  "Exhaust air damper"
    annotation (Placement(transformation(extent={{-30,-20},{-50,0}})));

  Buildings.Controls.OBC.CDL.Continuous.MultiSum mulSum(nin=16)
    annotation (Placement(transformation(extent={{770,270},{790,290}})));
  Modelica.Blocks.Sources.RealExpression heaCoiHeaFlo(y=heaCoi.Q2_flow) "Access coil heat flow rate"
    annotation (Placement(transformation(extent={{718,276},{738,296}})));
  Modelica.Blocks.Sources.RealExpression cooCoiHeaFlo(y=cooCoi.Q2_flow) "Access coil heat flow rate"
    annotation (Placement(transformation(extent={{720,230},{740,250}})));
equation
  connect(controlBus, modeSelector.cb) annotation (Line(
      points={{-70,30},{-152,30},{-152,-303.182},{-196.818,-303.182}},
      color={255,204,51},
      thickness=0.5,
      smooth=Smooth.None), Text(
      textString="%first",
      index=-1,
      extent={{-6,3},{-6,3}}));
  connect(min.y, controlBus.TRooMin) annotation (Line(
      points={{-279,270},{-212,270},{-212,30},{-70,30}},
      color={0,0,127},
      smooth=Smooth.None,
      pattern=LinePattern.Dash), Text(
      textString="%second",
      index=1,
      extent={{6,3},{6,3}}));
  connect(ave.y, controlBus.TRooAve) annotation (Line(
      points={{-279,230},{-212,230},{-212,30},{-70,30}},
      color={0,0,127},
      smooth=Smooth.None,
      pattern=LinePattern.Dash), Text(
      textString="%second",
      index=1,
      extent={{6,3},{6,3}}));
  connect(TRet.T, conEco.TRet) annotation (Line(
      points={{100,151},{100,174},{-94,174},{-94,153.333},{-81.3333,153.333}},
      color={0,0,127},
      smooth=Smooth.None,
      pattern=LinePattern.Dash));
  connect(TSetRoo.controlBus, controlBus) annotation (Line(
      points={{-288,-342},{-180,-342},{-180,30},{-70,30}},
      color={255,204,51},
      thickness=0.5,
      smooth=Smooth.None));
  connect(dpDisSupFan.p_rel, conFanSup.u_m) annotation (Line(
      points={{311,4.44089e-16},{304,4.44089e-16},{304,-16},{250,-16},{250,-12}},
      color={0,0,127},
      smooth=Smooth.None,
      pattern=LinePattern.Dash));

  connect(pSetDuc.y, conFanSup.u) annotation (Line(
      points={{181,0},{238,0}},
      color={0,0,127},
      smooth=Smooth.None,
      pattern=LinePattern.Dash));
  connect(conEco.VOut_flow, VOut1.V_flow) annotation (Line(
      points={{-81.3333,142.667},{-90,142.667},{-90,80},{-80,80},{-80,-29}},
      color={0,0,127},
      smooth=Smooth.None,
      pattern=LinePattern.Dash));

  connect(VAVBox.yVAV,conVAV.yDam) annotation (Line(points={{576,52},{556,52},{556,74.8},{481,74.8}},
                                 color={0,0,127}));

  for i in 1:numVAV loop
    connect(conVAV[i].TRooHeaSet, controlBus.TRooSetHea)
      annotation (Line(points={{458,77},{436,77},{436,30},{-70,30}},
      color={0,0,127}));
    connect(conVAV[i].TRooCooSet, controlBus.TRooSetCoo)
      annotation (Line(points={{458,70},{436,70},{436,30},{-70,30}},
      color={0,0,127}));
  end for;

  connect(occSch.tNexOcc, controlBus.dTNexOcc) annotation (Line(
      points={{-297,-204},{-70,-204},{-70,30}},
      color={0,0,127},
      smooth=Smooth.None), Text(
      textString="%second",
      index=1,
      extent={{6,3},{6,3}}));
  connect(occSch.occupied, controlBus.occupied) annotation (Line(
      points={{-297,-216},{-70,-216},{-70,30}},
      color={255,0,255},
      smooth=Smooth.None), Text(
      textString="%second",
      index=1,
      extent={{6,3},{6,3}}));
  connect(TOut.y, controlBus.TOut) annotation (Line(points={{-279,180},{-70,180},{-70,
          30}},                                    color={0,0,127}), Text(
      textString="%second",
      index=1,
      extent={{6,3},{6,3}}));
  connect(conEco.controlBus, controlBus) annotation (Line(
      points={{-70.6667,141.467},{-70.6667,120},{-70,120},{-70,30}},
      color={255,204,51},
      thickness=0.5));
  connect(modeSelector.yFan, conFanSup.uFan) annotation (Line(points={{-179.091,-305.455},{260,-305.455},{260,-30},{226,
          -30},{226,6},{238,6}},                                 color={255,0,
          255}));
  connect(conFanSup.y, fanSup.y) annotation (Line(points={{261,0},{280,0},{280,
          -20},{310,-20},{310,-28}}, color={0,0,127}));
  connect(or2.u2, modeSelector.yFan) annotation (Line(points={{-62,-248},{-30,-248},{-30,-305.455},{-179.091,-305.455}},
                                     color={255,0,255}));
  connect(VAVBox[:].y_actual, pSetDuc.u[:]) annotation (Line(points={{624,42},{640,42},{640,160},{140,160},{140,0},{158,
          0}},                                      color={0,0,127}));
  connect(TSup.T, conTSup.TSup) annotation (Line(
      points={{340,-29},{340,-20},{360,-20},{360,-280},{16,-280},{16,-214},{28,
          -214}},
      color={0,0,127},
      pattern=LinePattern.Dash));
  connect(conTSup.yOA, conEco.uOATSup) annotation (Line(
      points={{52,-220},{60,-220},{60,170},{-86,170},{-86,158.667},{-81.3333,158.667}},
      color={0,0,127},
      pattern=LinePattern.Dash));
  connect(or2.y, conTSup.uEna) annotation (Line(points={{-38,-240},{20,-240},{
          20,-226},{28,-226}}, color={255,0,255}));
  connect(modeSelector.yEco, conEco.uEna) annotation (Line(points={{-179.091,-314.545},{-160,-314.545},{-160,100},{
          -73.3333,100},{-73.3333,137.333}},
        color={255,0,255}));
  connect(TMix.T, conEco.TMix) annotation (Line(points={{40,-29},{40,166},{-90,166},{-90,148},{-81.3333,148}},
                                          color={0,0,127}));
  connect(controlBus, TSupSet.controlBus) annotation (Line(
      points={{-70,30},{-70,-228},{-190,-228}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));
  connect(TSupSet.TSet, conTSup.TSupSet)
    annotation (Line(points={{-178,-220},{28,-220}}, color={0,0,127}));

  connect(TRooAir, conVAV.TRoo) annotation (Line(
      points={{-350,250},{448,250},{448,63},{459,63}},
      color={0,0,127},
      pattern=LinePattern.Dash));
  connect(TRooAir, min.u) annotation (Line(
      points={{-350,250},{-320,250},{-320,270},{-302,270}},
      color={0,0,127},
      pattern=LinePattern.Dash));
  connect(TRooAir, ave.u) annotation (Line(
      points={{-350,250},{-320,250},{-320,230},{-302,230}},
      color={0,0,127},
      pattern=LinePattern.Dash));

  connect(damRet.y, conEco.yRet) annotation (Line(points={{-12,-10},{-18,-10},{-18,146.667},{-58.6667,146.667}},
                                        color={0,0,127}));
  connect(damExh.y, conEco.yOA) annotation (Line(points={{-40,2},{-40,152},{-58.6667,152}},
                 color={0,0,127}));
  connect(damOut.y, conEco.yOA) annotation (Line(points={{-40,-28},{-40,-20},{-22,-20},{-22,152},{-58.6667,152}},
                                          color={0,0,127}));
  connect(damExh.port_a, TRet.port_b) annotation (Line(points={{-30,-10},{-26,-10},
          {-26,140},{90,140}}, color={0,127,255}));
  connect(damExh.port_b, amb.ports[3]) annotation (Line(points={{-50,-10},{-100,-10},{-100,-41},{-120,-41}},
                                       color={0,127,255}));
  connect(freSta.y, or2.u1) annotation (Line(points={{-38,-90},{-30,-90},{-30,
          -240},{-62,-240}}, color={255,0,255}));
  connect(fanSup.P, PFan) annotation (Line(points={{321,-31},{332,-31},{332,200},{820,200}}, color={0,0,127}));
  connect(mulSum.y, QHea_flow) annotation (Line(points={{792,280},{820,280}}, color={0,0,127}));
  connect(heaCoiHeaFlo.y, mulSum.u[1])
    annotation (Line(points={{739,286},{760,286},{760,281.875},{768,281.875}}, color={0,0,127}));
  connect(VAVBox.QHea_flow, mulSum.u[2:16])
    annotation (Line(points={{624,34},{644,34},{644,278.125},{768,278.125}}, color={0,0,127}));
  connect(cooCoiHeaFlo.y, QCoo_flow) annotation (Line(points={{741,240},{820,240}}, color={0,0,127}));
  connect(conTSup.yHea, valHea.y) annotation (Line(points={{52,-214},{56,-214},{56,-100},{68,-100}}, color={0,0,127}));
  connect(conTSup.yCoo, valCoo.y)
    annotation (Line(points={{52,-226},{160,-226},{160,-100},{168,-100}}, color={0,0,127}));
  connect(conVAV.yVal, valReh.y) annotation (Line(points={{481,65},{540,65},{540,40}}, color={0,0,127}));
  annotation (
    Documentation(info="<html>
<p>
This model consist of an HVAC system, a building envelope model and a model
for air flow through building leakage and through open doors.
</p>
<p>
The HVAC system is a variable air volume (VAV) flow system with economizer
and a heating and cooling coil in the air handler unit. There is also a
reheat coil and an air damper in each of the five zone inlet branches.
The figure below shows the schematic diagram of the HVAC system
</p>
<p>
<img alt=\"image\" src=\"modelica://Buildings/Resources/Images/Examples/VAVReheat/vavSchematics.png\" border=\"1\"/>
</p>
<p>
See the model
<a href=\"modelica://Buildings.Examples.VAVReheat.BaseClasses.PartialOpenLoop\">
Buildings.Examples.VAVReheat.BaseClasses.PartialOpenLoop</a>
for a description of the HVAC system and the building envelope.
</p>
<p>
The control is an implementation of the control sequence
<i>VAV 2A2-21232</i> of the Sequences of Operation for
Common HVAC Systems (ASHRAE, 2006). In this control sequence, the
supply fan speed is modulated based on the duct static pressure.
The return fan controller tracks the supply fan air flow rate.
The duct static pressure set point is adjusted so that at least one
VAV damper is 90% open.
The heating coil valve, outside air damper, and cooling coil valve are
modulated in sequence to maintain the supply air temperature set point.
The economizer control provides the following functions:
freeze protection, minimum outside air requirement, and supply air cooling,
see
<a href=\"modelica://Buildings.Examples.VAVReheat.Controls.Economizer\">
Buildings.Examples.VAVReheat.Controls.Economizer</a>.
The controller of the terminal units tracks the room air temperature set point
based on a \"dual maximum with constant volume heating\" logic, see
<a href=\"modelica://Buildings.Examples.VAVReheat.Controls.RoomVAV\">
Buildings.Examples.VAVReheat.Controls.RoomVAV</a>.
</p>
<p>
There is also a finite state machine that transitions the mode of operation
of the HVAC system between the modes
<i>occupied</i>, <i>unoccupied off</i>, <i>unoccupied night set back</i>,
<i>unoccupied warm-up</i> and <i>unoccupied pre-cool</i>.
In the VAV model, all air flows are computed based on the
duct static pressure distribution and the performance curves of the fans.
Local loop control is implemented using proportional and proportional-integral
controllers, while the supervisory control is implemented
using a finite state machine.
</p>
<p>
A similar model but with a different control sequence can be found in
<a href=\"modelica://Buildings.Examples.VAVReheat.Guideline36\">
Buildings.Examples.VAVReheat.Guideline36</a>.
</p>
<h4>References</h4>
<p>
ASHRAE.
<i>Sequences of Operation for Common HVAC Systems</i>.
ASHRAE, Atlanta, GA, 2006.
</p>
</html>", revisions="<html>
<ul>
<li>
April 30, 2021, by Michael Wetter:<br/>
Reformulated replaceable class and introduced floor areas in base class
to avoid access of components that are not in the constraining type.<br/>
This is for <a href=\"https://github.com/lbl-srg/modelica-buildings/issues/2471\">issue #2471</a>.
</li>
<li>
April 16, 2021, by Michael Wetter:<br/>
Refactored model to implement the economizer dampers directly in
<code>Buildings.Examples.VAVReheat.BaseClasses.PartialOpenLoop</code> rather than through the
model of a mixing box. Since the version of the Guideline 36 model has no exhaust air damper,
this leads to simpler equations.<br/>
This is for <a href=\"https://github.com/lbl-srg/modelica-buildings/issues/2454\">issue #2454</a>.
</li>
<li>
March 15, 2021, by David Blum:<br/>
Update documentation graphic to include relief damper.<br/>
This is for
<a href=\"https://github.com/lbl-srg/modelica-buildings/issues/2399\">#2399</a>.
</li>
<li>
October 27, 2020, by Antoine Gautier:<br/>
Refactored the supply air temperature control sequence.<br/>
This is for
<a href=\"https://github.com/lbl-srg/modelica-buildings/issues/2024\">#2024</a>.
</li>
<li>
July 10, 2020, by Antoine Gautier:<br/>
Changed design and control parameters for outdoor air flow.<br/>
This is for
<a href=\"https://github.com/lbl-srg/modelica-buildings/issues/2019\">#2019</a>.
</li>
<li>
April 20, 2020, by Jianjun Hu:<br/>
Exported actual VAV damper position as the measured input data for
defining duct static pressure setpoint.<br/>
This is
for <a href=\"https://github.com/lbl-srg/modelica-buildings/issues/1873\">#1873</a>.
</li>
<li>
May 19, 2016, by Michael Wetter:<br/>
Changed chilled water supply temperature to <i>6&deg;C</i>.
This is
for <a href=\"https://github.com/ibpsa/modelica-ibpsa/issues/509\">#509</a>.
</li>
<li>
April 26, 2016, by Michael Wetter:<br/>
Changed controller for freeze protection as the old implementation closed
the outdoor air damper during summer.
This is
for <a href=\"https://github.com/ibpsa/modelica-ibpsa/issues/511\">#511</a>.
</li>
<li>
January 22, 2016, by Michael Wetter:<br/>
Corrected type declaration of pressure difference.
This is
for <a href=\"https://github.com/ibpsa/modelica-ibpsa/issues/404\">#404</a>.
</li>
<li>
September 24, 2015 by Michael Wetter:<br/>
Set default temperature for medium to avoid conflicting
start values for alias variables of the temperature
of the building and the ambient air.
This is for
<a href=\"https://github.com/lbl-srg/modelica-buildings/issues/426\">issue 426</a>.
</li>
</ul>
</html>"), Icon(coordinateSystem(preserveAspectRatio=false)));
end ASHRAE2006VAV_coilDiscretized;
