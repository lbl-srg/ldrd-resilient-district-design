within LDRD.Examples;
model ParallelSpawnCoolingTowersNoWSE
  "Parallel connection with central cooling towers and Spawn office building, no WSE"
  extends ParallelSpawnCoolingTowers(
    bui(ets(each have_WSE=false)),
    buiSpa(ets(have_WSE=false)),
    uEnaChi(each table=[0,1; 31536000,1]));
  annotation (
    __Dymola_experimentSetupOutput(equidistant=true, events=false),
    experiment(
      StopTime=63244800,
      Tolerance=1e-06,
      __Dymola_NumberOfIntervals=17520,
      __Dymola_Algorithm="Cvode"));
end ParallelSpawnCoolingTowersNoWSE;
