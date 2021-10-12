within LDRD.Examples;
model BuildingSpawnWithETS_fan
  extends BuildingSpawnWithETS(
    bui(
      bui(
        vav(
          fanSup(per(pressure(
            V_flow=coeSizFan * bui.bui.vav.m_flow_nominal / 1.2 .* {0, 1, 1.4},
            dp=coeSizFan^2 * bui.datVAV.dpTot .* {1.5, 1, 0})))))));

  parameter Modelica.SIunits.ThermalConductance coeSizFan = 1.0
    "Fan sizing coefficient";

end BuildingSpawnWithETS_fan;
