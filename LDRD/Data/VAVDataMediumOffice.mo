within LDRD.Data;
record VAVDataMediumOffice "Sizing parameters for VAV system"
  extends VAVData(
    numVAV=15,
    numRet=3,
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
    m_flow_nominalVAV={
    2.9268, 2.8536, 2.8032, 0.882,  0.8436, 0.5556, 0.9276, 1.0548,
    0.9708, 0.7128, 1.0428, 1.0848, 0.9564, 0.8196, 1.1004},
    m_flow_nominalRet={6.1356, 6.6348, 6.7644},
    ratVFloHea={
    0.87804, 0.85608, 0.9408,  0.3396,  0.25308, 0.3348,  0.27828,
    0.3684,  0.29124, 0.3636,  0.31284, 0.5172,  0.336,   0.5136,
    0.3384});
annotation(defaultComponentName="datVAV");
end VAVDataMediumOffice;
