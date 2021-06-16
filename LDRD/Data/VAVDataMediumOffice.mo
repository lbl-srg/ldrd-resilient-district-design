within LDRD.Data;
record VAVDataMediumOffice "Sizing parameters for VAV system"
  extends VAVData(
    numVAV=15,
    numRet=3,
    namZonCon={
    "Core_bottom",
"Core_mid",
"Core_top",
"Perimeter_bot_ZN_1",
"Perimeter_bot_ZN_2",
"Perimeter_bot_ZN_3",
"Perimeter_bot_ZN_4",
"Perimeter_mid_ZN_1",
"Perimeter_mid_ZN_2",
"Perimeter_mid_ZN_3",
"Perimeter_mid_ZN_4",
"Perimeter_top_ZN_1",
"Perimeter_top_ZN_2",
"Perimeter_top_ZN_3",
"Perimeter_top_ZN_4"},
    namZonFre={"FirstFloor_Plenum",
"MidFloor_Plenum",
"TopFloor_Plenum"},
    rouZon={{ true, false, false,  true,  true,  true,  true, false, false,
        false, false, false, false, false, false},
       {false,  true, false, false, false, false, false,  true,  true,
         true,  true, false, false, false, false},
       {false, false,  true, false, false, false, false, false, false,
        false, false,  true,  true,  true,  true}},
    VRoo={
    2698.04, 2698.04, 2698.04,  568.77,  360.08,  568.77,  360.05,
    568.77,  360.08,  568.77,  360.05,  568.77,  360.08,  568.77,
    360.05},
    AFlo={
    983.54, 983.54, 983.54, 207.34, 131.26, 207.34, 131.25, 207.34,
    131.26, 207.34, 131.25, 207.34, 131.26, 207.34, 131.25},
    ratP_A=fill(0.05382, numVAV),
    ratOAFlo_P=fill(2.5e-3, numVAV),
    ratOAFlo_A=fill(0.3e-3, numVAV),
    mAirBox_flow_nominal={
      2.96, 2.94, 2.89, 0.89, 0.85, 0.88, 0.94, 1.07, 0.98, 0.95, 1.05,
        1.35, 0.97, 1.35, 1.11},
    mAirRet_flow_nominal={
      6.52, 6.99, 7.67},
    ratVFloHea={
      0.3,  0.3,  0.85, 1.,   0.7,  1.,   0.63, 0.9,  0.65, 1.,   0.61,
        1.,   0.91, 1.,   0.8});
annotation(defaultComponentName="datVAV");
end VAVDataMediumOffice;
