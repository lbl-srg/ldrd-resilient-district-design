within LDRD.Data;
record DesignDataParallelSpawn
  "Record with design data for parallel network with Spawn models"
  extends Modelica.Icons.Record;
  parameter Integer nBui = 3
    "Number of served buildings"
    annotation(Evaluate=true);
  parameter Integer idxBuiSpa
    "Index of Spawn building model"
    annotation (Evaluate=true);
  final parameter Integer idxBuiTim[nBui-1]=
    Modelica.Math.BooleanVectors.index({i<>idxBuiSpa for i in 1:nBui})
    "Indices of building models based on time series"
    annotation (Evaluate=true);

  parameter Real facDiv = 0.9
    "Load diversity factor (typically heating is limitingand higher than 0.9)";

  parameter Modelica.SIunits.MassFlowRate mPumDis_flow_nominal = facDiv *
    sum(mCon_flow_nominal)
    "Nominal mass flow rate of main distribution pump";
  parameter Modelica.SIunits.MassFlowRate mCon_flow_nominal[nBui]
    "Nominal mass flow rate in each connection line";
  parameter Modelica.SIunits.MassFlowRate mPla_flow_nominal = mPumDis_flow_nominal
    "Plant HX nominal mass flow rate (primary = secondary)";
  final parameter Modelica.SIunits.MassFlowRate mDisCon_flow_nominal[nBui]=
    {max(mCon_flow_nominal[nBui], facDiv * sum(mCon_flow_nominal[i:nBui])) for i in 1:nBui}
    "Nominal mass flow rate in the distribution line before each connection";
  parameter Modelica.SIunits.MassFlowRate mEnd_flow_nominal=
    0.05 * mPumDis_flow_nominal
    "Nominal mass flow rate in the end of the distribution line";
  parameter Modelica.SIunits.Temperature TLooMin = 273.15 + 6
    "Minimum loop temperature";
  parameter Modelica.SIunits.Temperature TLooMax = 273.15 + 17
    "Maximum loop temperature";
  parameter Real dp_length_nominal(final unit="Pa/m") = 250
    "Pressure drop per pipe length at nominal flow rate";
  parameter Modelica.SIunits.Length lDis[nBui] = fill(200, nBui)
    "Length of distribution pipe (only counting warm or cold line, but not sum)";
  parameter Modelica.SIunits.Length lCon[nBui] = fill(50, nBui)
    "Length of connection pipe (only counting warm or cold line, but not sum)";
  parameter Modelica.SIunits.Length lEnd = 0
    "Length of the end of the distribution line (supply only, not counting return line)";

  parameter Modelica.SIunits.PressureDifference dpPumDis_nominal=
    1.3 * (2 * sum(lDis) * dp_length_nominal + dpPumDisSet)
    "Nominal pump head";
  parameter Modelica.SIunits.PressureDifference dpPumDisSet
    "Differential pressure set point at remote location";

  annotation (
    defaultComponentName="datDes",
    defaultComponentPrefixes="inner",
    Documentation(info="<html>
<p>
This record contains parameter declarations used in example models of DHC systems.
</p>
</html>"));
end DesignDataParallelSpawn;
