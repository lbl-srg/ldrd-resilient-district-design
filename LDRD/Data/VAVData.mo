within LDRD.Data;
record VAVData "Sizing parameters for VAV system"
  extends Modelica.Icons.Record;

  parameter Integer numVAV(min=2, start=5)
    "Number of served VAV boxes"
    annotation(Dialog(group="Configuration"));
  parameter Integer numRet(min=1, start=numVAV)
    "Number of return air inlets"
    annotation(Dialog(group="Configuration"));

  parameter Modelica.SIunits.Volume VRoo[numVAV](each start=1500)
    "Room volumes of each zone"
    annotation(Dialog(group="Zone parameters"));
  parameter Modelica.SIunits.Area AFlo[numVAV](each start=500)
    "Floor area of each zone"
    annotation(Dialog(group="Zone parameters"));

  parameter Modelica.SIunits.MassFlowRate m_flow_nominalVAV[numVAV](
    start=VRoo * 6 * 1.2 / 3600)
    "Design mass flow rate of each VAV box"
    annotation(Dialog(group="Air flow rates"));
  parameter Modelica.SIunits.MassFlowRate m_flow_nominalRet[numRet](
    each start=sum(m_flow_nominalVAV)/numRet)
    "Design mass flow rate of each return air inlet"
    annotation(Dialog(group="Air flow rates"));
  parameter Modelica.SIunits.MassFlowRate m_flow_nominal = 0.7 * sum(m_flow_nominalVAV)
    "Nominal mass flow rate"
    annotation(Dialog(group="Air flow rates"));

  parameter Real ratVFloHea[numVAV](each final unit="1", each start=0.3)
    "VAV box maximum air flow rate ratio in heating mode"
    annotation(Dialog(group="Air flow rates"));
  parameter Real ratOAFlo_A[numVAV](each final unit="m3/(s.m2)", each start=0.3e-3)
    "Outdoor airflow rate required per unit area"
    annotation(Dialog(group="Air flow rates"));
  parameter Real ratOAFlo_P[numVAV](each start=2.5e-3)
    "Outdoor airflow rate required per person"
    annotation(Dialog(group="Air flow rates"));
  parameter Real ratP_A[numVAV](each start=5e-2)
    "Occupant density"
    annotation(Dialog(group="Air flow rates"));
  parameter Real effZ(final unit="1") = 0.8
    "Zone air distribution effectiveness (limiting value) (Ez)"
    annotation(Dialog(group="Air flow rates"));
  parameter Real divP(final unit="1") = 0.7
    "Occupant diversity ratio (D)"
    annotation(Dialog(group="Air flow rates"));

  parameter Modelica.SIunits.HeatFlowRate QCooCoi_flow
    "Capacity (total)"
    annotation(Dialog(group="Cooling coil design parameters"));
  parameter Modelica.SIunits.Temperature TLiqEntCooCoi
    "Liquid entering temperature"
    annotation(Dialog(group="Cooling coil design parameters"));
  parameter Modelica.SIunits.MassFlowRate mLiqCooCoi_flow
    "Liquid mass flow rate"
    annotation(Dialog(group="Cooling coil design parameters"));
  parameter Modelica.SIunits.PressureDifference dpLiqCooCoi = 2e4
    "Liquid pressure drop"
    annotation(Dialog(group="Cooling coil design parameters"));
  parameter Modelica.SIunits.Temperature TAirEntCooCoi
    "Air entering temperature"
    annotation(Dialog(group="Cooling coil design parameters"));
  parameter Modelica.SIunits.Temperature wAirEntCooCoi
    "Air entering humidity ratio"
    annotation(Dialog(group="Cooling coil design parameters"));
  parameter Modelica.SIunits.MassFlowRate mAirCooCoi_flow = m_flow_nominal
    "Air mass flow rate"
    annotation(Dialog(group="Cooling coil design parameters"));
  parameter Modelica.SIunits.PressureDifference dpAirCooCoi = 200
    "Air pressure drop"
    annotation(Dialog(group="Cooling coil design parameters"));

  parameter Modelica.SIunits.HeatFlowRate QHeaCoi_flow
    "Capacity"
    annotation(Dialog(group="Heating coil design parameters"));
  parameter Modelica.SIunits.Temperature TLiqEntHeaCoi
    "Liquid entering temperature"
    annotation(Dialog(group="Heating coil design parameters"));
  parameter Modelica.SIunits.MassFlowRate mLiqHeaCoi_flow
    "Liquid mass flow rate"
    annotation(Dialog(group="Heating coil design parameters"));
  parameter Modelica.SIunits.PressureDifference dpLiqHeaCoi = 0.5e4
    "Liquid pressure drop"
    annotation(Dialog(group="Heating coil design parameters"));
  parameter Modelica.SIunits.PressureDifference dpValHeaCoi = dpLiqHeaCoi
    "Valve pressure drop"
    annotation(Dialog(group="Heating coil design parameters"));
  parameter Modelica.SIunits.Temperature TAirEntHeaCoi
    "Air entering temperature"
    annotation(Dialog(group="Heating coil design parameters"));
  parameter Modelica.SIunits.MassFlowRate mAirHeaCoi_flow = m_flow_nominal
    "Air mass flow rate"
    annotation(Dialog(group="Heating coil design parameters"));
  parameter Modelica.SIunits.PressureDifference dpAirHeaCoi = 50
    "Air pressure drop"
    annotation(Dialog(group="Heating coil design parameters"));

  parameter Modelica.SIunits.HeatFlowRate QRehCoi_flow[numVAV]
    "Capacity"
    annotation(Dialog(group="Reheat coil design parameters"));
  parameter Modelica.SIunits.Temperature TLiqEntRehCoi[numVAV] = fill(TLiqEntHeaCoi, numVAV)
    "Liquid entering temperature"
    annotation(Dialog(group="Reheat coil design parameters"));
  parameter Modelica.SIunits.MassFlowRate mLiqRehCoi_flow[numVAV] = QRehCoi_flow / 10 / 4186
    "Liquid mass flow rate"
    annotation(Dialog(group="Reheat coil design parameters"));
  parameter Modelica.SIunits.PressureDifference dpLiqRehCoi[numVAV] = fill(0.2e4, numVAV)
    "Liquid pressure drop"
    annotation(Dialog(group="Reheat coil design parameters"));
  parameter Modelica.SIunits.Temperature TAirEntRehCoi[numVAV]
    "Air entering temperature"
    annotation(Dialog(group="Reheat coil design parameters"));
  final parameter Modelica.SIunits.MassFlowRate mAirRehCoi_flow[numVAV] = ratVFloHea .* m_flow_nominalVAV
    "Air mass flow rate"
    annotation(Dialog(group="Reheat coil design parameters"));


annotation(defaultComponentName="datVAV");
end VAVData;
