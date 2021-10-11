within LDRD.Examples;
model ParallelCoolingTowers_1450_180
  "Example of parallel connection with constant district water mass flow rate"
  extends ParallelCoolingTowers(
    redeclare LDRD.ThermalStorages.BoreField_1450_180 borFie);
  annotation (
    experiment(
      StopTime=63244800,
      Tolerance=1e-06,
      __Dymola_NumberOfIntervals=17520,
      __Dymola_Algorithm="Cvode",
      __Dymola_experimentSetupOutput(equidistant=true, events=false)));
end ParallelCoolingTowers_1450_180;
