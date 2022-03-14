within LDRD.Examples;
model BuildingSpawnWithETS_airSystem
  extends BuildingSpawnWithETS(
    bui(datVAV(divAirFlo=1.0)));

  parameter Modelica.SIunits.ThermalConductance coeSizFan = 1.0
    "Fan sizing coefficient";

end BuildingSpawnWithETS_airSystem;
