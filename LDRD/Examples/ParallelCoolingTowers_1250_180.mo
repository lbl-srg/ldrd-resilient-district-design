within LDRD.Examples;
model ParallelCoolingTowers_1250_180
  "Example of parallel connection with constant district water mass flow rate"
  extends ParallelCoolingTowers(
    redeclare LDRD.ThermalStorages.BoreField_1250_180 borFie);

end ParallelCoolingTowers_1250_180;
