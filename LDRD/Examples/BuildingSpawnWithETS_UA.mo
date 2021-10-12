within LDRD.Examples;
model BuildingSpawnWithETS_UA
  extends BuildingSpawnWithETS(
    bui(
      datVAV(
        dpLiqCooCoi=2E4 * UACooCoi_nominal / 27.5e3,
        dpAirCooCoi=200 * UACooCoi_nominal / 27.5e3),
      bui(
        pumChiWat(per(pressure(
          dp=(bui.datVAV.dpPumChiWat_nominal + (UACooCoi_nominal / 27.5e3 - 1) * 2e4) .*
            {1.2, 1, 0}))),
        vav(
          redeclare Buildings.Fluid.HeatExchangers.WetCoilEffectivenessNTU cooCoi(
            use_Q_flow_nominal=false,
            UA_nominal=UACooCoi_nominal),
          fanSup(per(pressure(
            dp=(bui.datVAV.dpTot + (UACooCoi_nominal / 27.5e3 - 1) * 200) .*
              {1.5, 1, 0})))))));

  parameter Modelica.SIunits.ThermalConductance UACooCoi_nominal = 20000
    "Thermal conductance at nominal flow, used to compute heat capacity"
    annotation(Dialog(group="Cooling coil design parameters"));


end BuildingSpawnWithETS_UA;
