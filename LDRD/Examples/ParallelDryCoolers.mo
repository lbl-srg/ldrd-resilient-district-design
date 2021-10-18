within LDRD.Examples;
model ParallelDryCoolers
  "Parallel connection with central dry coolers"
  extends ParallelCoolingTowers(
    plaCoo(isCooTow=false));
  annotation (
    experiment(
      StopTime=63244800,
      Tolerance=1e-06,
      __Dymola_NumberOfIntervals=17520,
      __Dymola_Algorithm="Cvode",
      __Dymola_experimentSetupOutput(equidistant=true, events=false)));
end ParallelDryCoolers;
