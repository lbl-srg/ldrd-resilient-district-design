within LDRD.Examples;
model ParallelSpawnDryCoolers
  "Parallel connection with central dry coolers and Spawn office building"
  extends ParallelSpawnCoolingTowers(
    redeclare CentralPlants.DryCoolers plaCoo);
  annotation (
    experiment(
      StopTime=63244800,
      Tolerance=1e-06,
      __Dymola_NumberOfIntervals=17520,
      __Dymola_Algorithm="Cvode",
      __Dymola_experimentSetupOutput(equidistant=true, events=false)));
end ParallelSpawnDryCoolers;
