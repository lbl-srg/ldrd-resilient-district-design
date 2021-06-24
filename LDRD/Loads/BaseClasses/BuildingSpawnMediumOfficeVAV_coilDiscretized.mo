within LDRD.Loads.BaseClasses;
model BuildingSpawnMediumOfficeVAV_coilDiscretized "Spawn building model"
  extends Buildings.Experimental.DHC.Loads.BaseClasses.PartialBuilding(
    redeclare package Medium=Buildings.Media.Water,
    final have_heaWat=true,
    final have_chiWat=true,
    final have_eleHea=false,
    final have_eleCoo=false,
    final have_pum=true,
    final have_weaBus=false);

  outer replaceable Data.VAVData datVAV;

  final parameter String namZonCon[nZonCon] = datVAV.namZonCon
    "Name of conditioned zones"
    annotation(Dialog(group="Configuration"));
  parameter String namZonFre[nZonFre] = datVAV.namZonFre
    "Name of unconditioned zones"
    annotation(Dialog(group="Configuration"));
  parameter Boolean rouZon[nZonFre, nZonCon] = datVAV.rouZon
    "Air routing between zones"
    annotation(Dialog(group="Configuration"));

  package Medium2=Buildings.Media.Air
    "Medium model";
  final parameter Integer nZonCon = datVAV.numVAV
    "Number of conditioned zones";
  final parameter Integer nZonFre = datVAV.numRet
    "Number of free floating zones";
  parameter String idfName=
    "modelica://LDRD/Resources/EnergyPlus/RefBldgMediumOfficeNew2004_v1.4_7.2_5A_USA_IL_CHICAGO-OHARE.idf"
    "Name of the IDF file";
  parameter String weaName=
    "modelica://LDRD/Resources/WeatherData/USA_IL_Chicago-OHare.Intl.AP.725300_TMY3.mos"
    "Name of the weather file";

  parameter Modelica.SIunits.Temperature T_aHeaWat_nominal=313.15
    "Heating water inlet temperature at nominal conditions"
    annotation (Dialog(group="Nominal condition"));
  parameter Modelica.SIunits.Temperature T_bHeaWat_nominal(
    min=273.15,
    displayUnit="degC")=
    T_aHeaWat_nominal-5
    "Heating water outlet temperature at nominal conditions"
    annotation (Dialog(group="Nominal condition"));
  parameter Modelica.SIunits.Temperature T_aChiWat_nominal=280.15
    "Chilled water inlet temperature at nominal conditions "
    annotation (Dialog(group="Nominal condition"));
  parameter Modelica.SIunits.Temperature T_bChiWat_nominal(
    min=273.15,
    displayUnit="degC")=T_aChiWat_nominal+7
    "Chilled water outlet temperature at nominal conditions"
    annotation (Dialog(group="Nominal condition"));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant minTSet[nZonCon](
    k=fill(
      293.15,
      nZonCon),
    y(each final unit="K",
      each displayUnit="degC"))
    "Minimum temperature set point"
    annotation (Placement(transformation(extent={{-280,250},{-260,270}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant maxTSet[nZonCon](
    k=fill(
      297.15,
      nZonCon),
    y(each final unit="K",
      each displayUnit="degC")) "Maximum temperature set point"
    annotation (Placement(transformation(extent={{-280,210},{-260,230}})));
  Modelica.Blocks.Sources.Constant qConGai_flow[nZonCon](
    each k=0) "Convective heat gain"
    annotation (Placement(transformation(extent={{30,110},{50,130}})));
  Modelica.Blocks.Sources.Constant qRadGai_flow[nZonCon](
    each k=0) "Radiative heat gain"
    annotation (Placement(transformation(extent={{30,140},{50,160}})));
  Modelica.Blocks.Routing.Multiplex3 multiplex3_1[nZonCon]
    annotation (Placement(transformation(extent={{70,110},{90,130}})));
  Modelica.Blocks.Sources.Constant qLatGai_flow[nZonCon](
    each k=0) "Latent heat gain"
    annotation (Placement(transformation(extent={{30,80},{50,100}})));
  Buildings.ThermalZones.EnergyPlus.ThermalZone zon[nZonCon](
    redeclare each final package Medium = Medium2,
    final zoneName=namZonCon,
    each final nPorts=2)
    "Thermal zone - Conditioned"
    annotation (Placement(transformation(extent={{140,30},{180,70}})));
  inner Buildings.ThermalZones.EnergyPlus.Building building(
    idfName=Modelica.Utilities.Files.loadResource(
      idfName),
    weaName=Modelica.Utilities.Files.loadResource(
      weaName))
    "Building outer component"
    annotation (Placement(transformation(extent={{40,180},{62,200}})));
  Buildings.ThermalZones.EnergyPlus.ThermalZone zonFre[nZonFre](
    redeclare each final package Medium = Medium2,
    zoneName=namZonFre,
    each final nPorts=2)
    "Thermal zone - Free floating"
    annotation (Placement(transformation(extent={{0,30},{40,70}})));
  Modelica.Blocks.Sources.Constant qConGai_flow1[nZonFre](each k=0) "Convective heat gain"
    annotation (Placement(transformation(extent={{-100,110},{-80,130}})));
  Modelica.Blocks.Sources.Constant qRadGai_flow1[nZonFre](each k=0) "Radiative heat gain"
    annotation (Placement(transformation(extent={{-100,140},{-80,160}})));
  Modelica.Blocks.Routing.Multiplex3 multiplex3_2[nZonFre]
    annotation (Placement(transformation(extent={{-60,110},{-40,130}})));
  Modelica.Blocks.Sources.Constant qLatGai_flow1[nZonFre](each k=0) "Latent heat gain"
    annotation (Placement(transformation(extent={{-100,80},{-80,100}})));
  MultiZoneVAV.ASHRAE2006VAV_coilDiscretized vav "VAV system"
    annotation (Placement(transformation(extent={{90,-10},{110,10}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant FIXME(k=0)
    annotation (Placement(transformation(extent={{190,70},{210,90}})));
  Buildings.Experimental.DHC.Loads.Validation.BaseClasses.Distribution2Pipe disHeaWat(
    redeclare final package Medium=Medium,
    final mDis_flow_nominal=datVAV.mHeaWat_flow_nominal,
    final mCon_flow_nominal=cat(1, {datVAV.mLiqHeaCoi_flow}, datVAV.mLiqRehCoi_flow),
    final dpDis_nominal=datVAV.dpDisHeaWat_nominal,
    final nCon=nZonCon + 1)
    "Heating hot water distribution" annotation (Placement(transformation(extent={{20,-70},{60,-50}})));
  Buildings.Experimental.DHC.Loads.Validation.BaseClasses.Distribution2Pipe disChiWat(
    redeclare final package Medium =Medium,
    final mDis_flow_nominal=datVAV.mChiWat_flow_nominal,
    final mCon_flow_nominal={datVAV.mLiqCooCoi_flow},
    final dpDis_nominal=datVAV.dpDisChiWat_nominal,
    final nCon=1) "Chilled water distribution"
    annotation (Placement(transformation(extent={{80,-270},{120,-250}})));
  Buildings.Fluid.Movers.FlowControlled_dp pumChiWat(
    redeclare final package Medium = Medium,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    final m_flow_nominal=datVAV.mChiWat_flow_nominal,
    nominalValuesDefineDefaultPressureCurve=true,
    final dp_nominal=datVAV.dpPumChiWat_nominal)
    "Chilled water distribution pump" annotation (Placement(transformation(
        extent={{10,10},{-10,-10}},
        rotation=180,
        origin={-180,-260})));
  Buildings.Fluid.Movers.FlowControlled_dp pumHeaWat(
    redeclare final package Medium = Medium,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    final m_flow_nominal=datVAV.mHeaWat_flow_nominal,
    nominalValuesDefineDefaultPressureCurve=true,
    final dp_nominal=datVAV.dpPumHeaWat_nominal)
    "Heating hot water distribution pump" annotation (Placement(transformation(
        extent={{10,10},{-10,-10}},
        rotation=180,
        origin={-180,-60})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant FIXME3(k=30e4)
    "DP set point" annotation (Placement(transformation(extent={{-240,-30},{-220,-10}})));
equation
  for iFre in 1:nZonFre loop
    for iCon in 1:nZonCon loop
      if rouZon[iFre, iCon] then
        connect(zonFre[iFre].ports[2], zon[iCon].ports[2])
          annotation (Line(points={{22,30.9},{22,20},{162,20},{162,30.9}}, color={0,127,255}));
      end if;
    end for;
  end for;

  connect(disHeaWat.ports_bCon[1], vav.port_coiHeaSup)
    annotation (Line(points={{28,-50},{28,-16},{91,-16},{91,-10}}, color={0,127,255}));
  connect(vav.port_coiHeaRet, disHeaWat.ports_aCon[1])
    annotation (Line(points={{94,-10},{94,-40},{52,-40},{52,-50}},   color={0,127,255}));
  connect(disHeaWat.ports_bCon[2:(nZonCon + 1)], vav.port_coiRehSup)
    annotation (Line(points={{28,-50},{28,-16},{106,-16},{106,-10}}, color={0,127,255}));
  connect(vav.port_coiRehRet, disHeaWat.ports_aCon[2:(nZonCon + 1)])
    annotation (Line(points={{109,-10},{109,-40},{52,-40},{52,-50}},   color={0,127,255}));
  connect(disChiWat.ports_bCon[1], vav.port_coiCooSup)
    annotation (Line(points={{88,-250},{88,-240},{98,-240},{98,-10},{98.6,-10}}, color={0,127,255}));
  connect(vav.port_coiCooRet, disChiWat.ports_aCon[1])
    annotation (Line(points={{101.6,-10},{102,-10},{102,-240},{112,-240},{112,-250}}, color={0,127,255}));

  connect(disChiWat.port_bDisRet, mulChiWatOut[1].port_a)
    annotation (Line(points={{80,-266},{60,-266},{60,-280},{240,-280},{240,-260},{260,-260}}, color={0,127,255}));
  connect(disHeaWat.port_bDisRet, mulHeaWatOut[1].port_a)
    annotation (Line(points={{20,-66},{0,-66},{0,-80},{240,-80},{240,-60},{260,-60}},   color={0,127,255}));
  connect(qRadGai_flow.y,multiplex3_1.u1[1])
    annotation (Line(points={{51,150},{60,150},{60,128},{68,128},{68,127}},
       color={0,0,127},smooth=Smooth.None));
  connect(qConGai_flow.y,multiplex3_1.u2[1])
    annotation (Line(points={{51,120},{68,120}},  color={0,0,127},smooth=Smooth.None));
  connect(multiplex3_1.u3[1],qLatGai_flow.y)
    annotation (Line(points={{68,113},{68,112},{60,112},{60,90},{51,90}},
                                                                      color={0,0,127}));
  connect(multiplex3_1.y, zon.qGai_flow) annotation (Line(points={{91,120},{120,120},{120,60},{138,60}},
                                                                                                   color={0,0,127}));
  connect(qRadGai_flow1.y, multiplex3_2.u1[1]) annotation (Line(
      points={{-79,150},{-70,150},{-70,130},{-62,130},{-62,127}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(qConGai_flow1.y, multiplex3_2.u2[1])
    annotation (Line(
      points={{-79,120},{-62,120}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(multiplex3_2.u3[1], qLatGai_flow1.y)
    annotation (Line(points={{-62,113},{-62,114},{-70,114},{-70,90},{-79,90}},
                                                                       color={0,0,127}));
  connect(multiplex3_2.y, zonFre.qGai_flow)
    annotation (Line(points={{-39,120},{-20,120},{-20,60},{-2,60}},
                                                                 color={0,0,127}));
  connect(building.weaBus, vav.weaBus)
    annotation (Line(
      points={{62,190},{100,190},{100,8}},
      color={255,204,51},
      thickness=0.5));
  connect(vav.ports_b, zon.ports[1]) annotation (Line(points={{110,0},{158,0},{158,30.9}},      color={0,127,255}));
  connect(zon.TAir, vav.TRooAir)
    annotation (Line(points={{181,68},{184,68},{184,80},{80,80},{80,8},{89,8}},   color={0,0,127}));
  connect(vav.ports_a, zonFre.ports[1]) annotation (Line(points={{90,0},{18,0},{18,30.9}},      color={0,127,255}));
  connect(vav.QCoo_flow, mulQCoo_flow.u)
    annotation (Line(points={{111,7},{130,7},{130,240},{268,240}},     color={0,0,127}));
  connect(vav.QHea_flow, mulQHea_flow.u)
    annotation (Line(points={{111,9},{126,9},{126,280},{268,280}},     color={0,0,127}));
  connect(FIXME.y, mulPPum.u) annotation (Line(points={{212,80},{268,80}}, color={0,0,127}));
  connect(vav.PFan, mulPFan.u) annotation (Line(points={{111,5},{134,5},{134,120},{268,120}},     color={0,0,127}));

  connect(mulChiWatInl[1].port_b, pumChiWat.port_a)
    annotation (Line(points={{-260,-260},{-190,-260}}, color={0,127,255}));
  connect(pumChiWat.port_b, disChiWat.port_aDisSup)
    annotation (Line(points={{-170,-260},{80,-260}}, color={0,127,255}));

  connect(mulHeaWatInl[1].port_b, pumHeaWat.port_a)
    annotation (Line(points={{-260,-60},{-190,-60}}, color={0,127,255}));
  connect(pumHeaWat.port_b, disHeaWat.port_aDisSup) annotation (Line(points={{-170,-60},{20,-60}}, color={0,127,255}));
  connect(FIXME3.y, pumHeaWat.dp_in) annotation (Line(points={{-218,-20},{-180,-20},{-180,-48}}, color={0,0,127}));
  connect(FIXME3.y, pumChiWat.dp_in)
    annotation (Line(points={{-218,-20},{-200,-20},{-200,-240},{-180,-240},{-180,-248}}, color={0,0,127}));
  annotation (
    Documentation(
      info="
<html>
<p>
This is a simplified six-zone building model based on an EnergyPlus
building envelope model.
It was generated from translating a GeoJSON model specified within the URBANopt UI.
The heating and cooling loads are computed with a four-pipe
fan coil unit model derived from
<a href=\"modelica://Buildings.Experimental.DHC.Loads.BaseClasses.PartialTerminalUnit\">
Buildings.Experimental.DHC.Loads.BaseClasses.PartialTerminalUnit</a>
and connected to the room model by means of fluid ports. The <code>Attic</code> zone
is unconditionned, with a free floating temperature.
</p>
</html>",
      revisions="<html>
<ul>
<li>
February 21, 2020, by Antoine Gautier:<br/>
First implementation.
</li>
</ul>
</html>"),
    Icon(
      graphics={
        Bitmap(
          extent={{-108,-100},{92,100}},
          fileName="modelica://Buildings/Resources/Images/ThermalZones/EnergyPlus/EnergyPlusLogo.png")}));
end BuildingSpawnMediumOfficeVAV_coilDiscretized;
