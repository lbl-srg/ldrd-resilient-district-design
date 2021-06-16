within LDRD.Data;
record VAVData "Sizing parameters for VAV system"
  extends Modelica.Icons.Record;

  parameter Integer numVAV(min=2, start=5)
    "Number of served VAV boxes"
    annotation(Dialog(group="Configuration"));
  parameter Integer numRet(min=1, start=numVAV)
    "Number of return air inlets"
    annotation(Dialog(group="Configuration"));

  parameter String namZonCon[numVAV]
    "Name of conditioned zones"
    annotation(Dialog(group="Configuration"));
  parameter String namZonFre[numRet]
    "Name of unconditioned zones"
    annotation(Dialog(group="Configuration"));
  parameter Boolean rouZon[numRet, numVAV]
    "Air routing between zones"
    annotation(Dialog(group="Configuration"));

  parameter Modelica.SIunits.Temperature THeaOn = 20 + 273.15
    "Heating setpoint during on"
    annotation(Dialog(group="Set points"));
  parameter Modelica.SIunits.Temperature THeaOff = TSupSet[1]
    "Heating setpoint during off"
    annotation(Dialog(group="Set points"));
  parameter Modelica.SIunits.Temperature TCooOn = 24 + 273.15
    "Cooling setpoint during on"
    annotation(Dialog(group="Set points"));
  parameter Modelica.SIunits.Temperature TCooOff = 30 + 273.15
    "Cooling setpoint during off"
    annotation(Dialog(group="Set points"));
  parameter Modelica.SIunits.Temperature TSupSet[6] = {13,13,35,35,13,7} .+ 273.15
    "Supply air temperature set point for different operating mode: 1=occupied"
    annotation(Dialog(group="Set points"));
  parameter Modelica.SIunits.Temperature TDisMax = THeaOn + 11
    "Maximum air discharge temperature"
    annotation(Dialog(group="Set points"));

  parameter Modelica.SIunits.PressureDifference dpDucSup(min=0) = 250
    "Supply duct design pressure drop"
    annotation(Dialog(group="Pressure drops"));
  parameter Modelica.SIunits.PressureDifference dpDucRet(min=0) = 250
    "Return duct design pressure drop"
    annotation(Dialog(group="Pressure drops"));
  parameter Modelica.SIunits.PressureDifference dpFil(min=0) = 80
    "Filter pressure drop"
    annotation(Dialog(group="Pressure drops"));
  parameter Modelica.SIunits.PressureDifference dpEcoDam(min=0) = 10
    "Economizer dampers design pressure drop"
    annotation(Dialog(group="Pressure drops"));
  parameter Modelica.SIunits.PressureDifference dpEcoFix(min=0) = dpEcoDam
    "Economizer fixed design pressure drop"
    annotation(Dialog(group="Pressure drops"));
  parameter Modelica.SIunits.PressureDifference dpBuiStaSet(min=0) = 12
    "Building static pressure"
    annotation(Dialog(group="Pressure drops"));
  final parameter Modelica.SIunits.PressureDifference dpTot(min=0)=
    dpEcoDam + dpEcoFix + dpFil + dpAirCooCoi + dpAirHeaCoi + dpDucSup + max(dpAirBox) + dpDucRet
    "Total design pressure drop"
    annotation(Dialog(group="Pressure drops"));

  parameter Modelica.SIunits.Volume VRoo[numVAV](each start=1500)
    "Room volumes of each zone"
    annotation(Dialog(group="Zone parameters"));
  parameter Modelica.SIunits.Area AFlo[numVAV](each start=500)
    "Floor area of each zone"
    annotation(Dialog(group="Zone parameters"));

  parameter Modelica.SIunits.MassFlowRate mAirRet_flow_nominal[numRet]
    "Design mass flow rate of each return air inlet"
    annotation(Dialog(group="System level air flow parameters"));
  parameter Real divLoa(min=0, max=1) = 0.7
    "Cooling load diversity"
    annotation(Dialog(group="System level air flow parameters"));
  final parameter Modelica.SIunits.MassFlowRate m_flow_nominal = divLoa * sum(mAirBox_flow_nominal)
    "Nominal air mass flow rate"
    annotation(Dialog(group="System level air flow parameters"));

  final parameter Modelica.SIunits.MassFlowRate mHeaWat_flow_nominal=
    mLiqHeaCoi_flow + sum(mLiqRehCoi_flow)
    "Heating hot water mass flow rate"
    annotation(Dialog(group="System level hydronic parameters"));
  final parameter Modelica.SIunits.MassFlowRate mChiWat_flow_nominal=
    mLiqCooCoi_flow
    "Chilled water mass flow rate"
    annotation(Dialog(group="System level hydronic parameters"));
  parameter Modelica.SIunits.PressureDifference dpDisHeaWat_nominal[numVAV+1]=
    fill(1500, numVAV+1)
    "Nominal pressure drop in heating hot water distribution system"
    annotation(Dialog(group="System level hydronic parameters"));
  final parameter Modelica.SIunits.PressureDifference dpDisChiWat_nominal[1]=
    fill(1500, 1)
    "Nominal pressure drop in chilled water distribution system"
    annotation(Dialog(group="System level hydronic parameters"));
  parameter Modelica.SIunits.PressureDifference dpPumHeaWat_nominal=
    (sum(dpDisHeaWat_nominal) + dpLiqHeaCoi + dpValHeaCoi) * 1.2
    "Nominal head of hot water distribution pump"
    annotation(Dialog(group="System level hydronic parameters"));
  parameter Modelica.SIunits.PressureDifference dpPumChiWat_nominal=
    (sum(dpDisChiWat_nominal) + dpLiqCooCoi + dpValCooCoi) * 1.2
    "Nominal head of chilled water distribution pump"
    annotation(Dialog(group="System level hydronic parameters"));

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

  parameter Modelica.SIunits.HeatFlowRate QCooCoi_flow=
    1.3 * QSenCooCoi_flow
    "Capacity (total)"
    annotation(Dialog(group="Cooling coil design parameters"));
  parameter Modelica.SIunits.HeatFlowRate QSenCooCoi_flow=
    mAirCooCoi_flow * 1020 * (TAirEntCooCoi - TSupSet[1])
    "Sensible heat flow rate (used for verification)"
    annotation(Dialog(group="Cooling coil design parameters"));
  parameter Modelica.SIunits.Temperature TLiqEntCooCoi=
    7 + 273.15
    "Liquid entering temperature"
    annotation(Dialog(group="Cooling coil design parameters"));
  parameter Modelica.SIunits.MassFlowRate mLiqCooCoi_flow=
    QCooCoi_flow / 1020 / 5
    "Liquid mass flow rate"
    annotation(Dialog(group="Cooling coil design parameters"));
  parameter Modelica.SIunits.PressureDifference dpLiqCooCoi=
    2e4
    "Liquid pressure drop"
    annotation(Dialog(group="Cooling coil design parameters"));
  parameter Modelica.SIunits.PressureDifference dpValCooCoi=
    dpLiqCooCoi
    "Valve pressure drop"
    annotation(Dialog(group="Cooling coil design parameters"));
  parameter Modelica.SIunits.Temperature TAirEntCooCoi=
    30 + 273.15
    "Air entering temperature"
    annotation(Dialog(group="Cooling coil design parameters"));
  parameter Modelica.SIunits.Temperature wAirEntCooCoi=
    0.011
    "Air entering humidity ratio"
    annotation(Dialog(group="Cooling coil design parameters"));
  final parameter Modelica.SIunits.MassFlowRate mAirCooCoi_flow=
    m_flow_nominal
    "Air mass flow rate"
    annotation(Dialog(group="Cooling coil design parameters"));
  parameter Modelica.SIunits.PressureDifference dpAirCooCoi=
    200
    "Air pressure drop"
    annotation(Dialog(group="Cooling coil design parameters"));

  parameter Modelica.SIunits.HeatFlowRate QHeaCoi_flow=
    mAirHeaCoi_flow * 1020 * (TSupSet[1] - TAirEntHeaCoi)
    "Capacity"
    annotation(Dialog(group="Heating coil design parameters"));
  parameter Modelica.SIunits.Temperature TLiqEntHeaCoi=
    55+273.15
    "Liquid entering temperature"
    annotation(Dialog(group="Heating coil design parameters"));
  parameter Modelica.SIunits.MassFlowRate mLiqHeaCoi_flow=
    QHeaCoi_flow / 10 / 4186
    "Liquid mass flow rate"
    annotation(Dialog(group="Heating coil design parameters"));
  parameter Modelica.SIunits.PressureDifference dpLiqHeaCoi=
    0.5e4
    "Liquid pressure drop"
    annotation(Dialog(group="Heating coil design parameters"));
  parameter Modelica.SIunits.PressureDifference dpValHeaCoi=
    dpLiqHeaCoi
    "Valve pressure drop"
    annotation(Dialog(group="Heating coil design parameters"));
  parameter Modelica.SIunits.Temperature TAirEntHeaCoi = 4 + 273.15
    "Air entering temperature"
    annotation(Dialog(group="Heating coil design parameters"));
  final parameter Modelica.SIunits.MassFlowRate mAirHeaCoi_flow=
    m_flow_nominal
    "Air mass flow rate"
    annotation(Dialog(group="Heating coil design parameters"));
  parameter Modelica.SIunits.PressureDifference dpAirHeaCoi=
    50
    "Air pressure drop"
    annotation(Dialog(group="Heating coil design parameters"));

  parameter Modelica.SIunits.MassFlowRate mAirBox_flow_nominal[numVAV]
    "Air mass flow rate"
    annotation(Dialog(group="VAV box design parameters"));
  parameter Modelica.SIunits.PressureDifference dpAirBox[numVAV]=
    fill(120, numVAV)
    "Air total pressure drop"
    annotation(Dialog(group="VAV box design parameters"));
  final parameter Modelica.SIunits.HeatFlowRate QRehCoi_flow[numVAV]=
    mAirRehCoi_flow * 1020 * (TDisMax - TSupSet[1])
    "Reheat coil capacity"
    annotation(Dialog(group="VAV box design parameters"));
  parameter Modelica.SIunits.Temperature TLiqEntRehCoi[numVAV]=
    fill(TLiqEntHeaCoi, numVAV)
    "Reheat coil liquid entering temperature"
    annotation(Dialog(group="VAV box design parameters"));
  parameter Modelica.SIunits.MassFlowRate mLiqRehCoi_flow[numVAV]=
    QRehCoi_flow / 10 / 4186
    "Reheat coil liquid mass flow rate"
    annotation(Dialog(group="VAV box design parameters"));
  parameter Modelica.SIunits.PressureDifference dpLiqRehCoi[numVAV]=
    fill(0.2e4, numVAV)
    "Reheat coil liquid pressure drop"
    annotation(Dialog(group="VAV box design parameters"));
  parameter Modelica.SIunits.PressureDifference dpValRehCoi[numVAV]=
    dpLiqRehCoi
    "Reheat coil valve pressure drop"
    annotation(Dialog(group="VAV box design parameters"));
  parameter Modelica.SIunits.Temperature TAirEntRehCoi[numVAV]=
    fill(TSupSet[1], numVAV)
    "Reheat coil air entering temperature"
    annotation(Dialog(group="VAV box design parameters"));
  final parameter Modelica.SIunits.MassFlowRate mAirRehCoi_flow[numVAV]=
    ratVFloHea .* mAirBox_flow_nominal
    "Reheat coil air mass flow rate"
    annotation(Dialog(group="VAV box design parameters"));


annotation(defaultComponentName="datVAV");
end VAVData;
