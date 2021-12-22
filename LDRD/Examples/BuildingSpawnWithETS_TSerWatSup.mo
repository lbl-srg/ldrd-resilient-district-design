within LDRD.Examples;
model BuildingSpawnWithETS_TSerWatSup
  extends BuildingSpawnWithETS(
    bouSerWatSup(T=TSerWatSup));

  parameter Modelica.SIunits.Temperature TSerWatSup = 16+273.15
    "Service water supply temperature";

end BuildingSpawnWithETS_TSerWatSup;
