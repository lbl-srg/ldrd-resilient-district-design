within LDRD.Examples;
model BuildingSpawnWithETS_UA
  extends BuildingSpawnWithETS(
    bui(bui(vav(redeclare Buildings.Fluid.HeatExchangers.WetCoilEffectivenessNTU cooCoi(
      use_Q_flow_nominal=false,
      UA_nominal=UACooCoi_nominal)))));

  parameter Modelica.SIunits.ThermalConductance UACooCoi_nominal = 20000
    "Thermal conductance at nominal flow, used to compute heat capacity"
    annotation(Dialog(group="Cooling coil design parameters"));
end BuildingSpawnWithETS_UA;