within LDRD.EnergyTransferStations.BaseClasses;
model Header "Model of a header with zero pressure drop between connections"
  extends
    Buildings.Experimental.DHC.Networks.BaseClasses.PartialDistribution1Pipe(
    mDis_flow_nominal=max(mCon_flow_nominal),
    final allowFlowReversal=true,
    redeclare Connection1PipeLossless con[nCon](each final show_TOut=show_TOut,
        each final show_entFlo=show_entFlo),
    redeclare model Model_pipDis =
        Buildings.Fluid.FixedResistances.LosslessPipe);
  annotation (
    defaultComponentName="colDis",
    Documentation(
      info="<html>
<p>
This model represents a collector/distributor which connects
<code>nCon</code> hydronic circuits in parallel.
The pressure drop between each connection is assumed negligible
compared to the pressure drop in each circuit, and is set to zero
in the model.
By default,
</p>
<ul>
<li>
there is no bypass flow (which can be added later by connecting
the ports <code>port_bDisSup</code> and <code>port_aDisRet</code>),
</li>
<li>
the nominal distribution mass flow rate
<code>mDis_flow_nominal</code> is equal to the sum
of the nominal mass flow rate in each circuit.
However, this parameter assigment is not final and it can be set
for instance to a higher value to represent a primary overflow
in a supply through loop.
</li>
</ul>
</html>",
      revisions="<html>
<ul>
<li>
July 31, 2020, by Antoine Gautier:<br/>
First implementation.
</li>
</ul>
</html>"));
end Header;
