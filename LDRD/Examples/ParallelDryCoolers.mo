within LDRD.Examples;
model ParallelDryCoolers
  "Parallel connection with central dry coolers"
  extends ParallelCoolingTowers(
    redeclare CentralPlants.DryCoolers plaCoo);
  annotation (
    experiment(
      StopTime=63244800,
      __Dymola_NumberOfIntervals=17520,
      Tolerance=1e-06,
      __Dymola_Algorithm="Cvode"),
    __Dymola_experimentSetupOutput(equidistant=true, events=false));
end ParallelDryCoolers;
