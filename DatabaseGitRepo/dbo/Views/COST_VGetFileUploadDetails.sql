

CREATE   VIEW [dbo].[COST_VGetFileUploadDetails] AS
-- First SELECT Statement
SELECT        
    FU.FileProcessKey, 
    FU.RecordSL, 
    FU.Market, 
    FU.Terminal, 
    FU.City, 
    FU.State, 
    FU.ZipCode, 
    FU.Zone, 
    Prepulllocation1, 
    Prepullcost1, 
    Prepulllocation2, 
    Prepullcost2, 
    Stopofflocation1, 
    Stopoffcost1, 
    Stopofflocation2, 
    Stopoffcost2, 
    YardshuttledirectionTO1, 
    YardshuttledirectionFROM1, 
    Yardshuttlecost1, 
    YardshuttledirectionTO2, 
    YardshuttledirectionFROM2, 
    Yardshuttlecost2, 
    TruckTypeA, 
    CASE WHEN ISNULL(TruckTypeABaseCost1, '') = '' THEN CAST(0.00 AS DECIMAL(18, 2)) ELSE TruckTypeABaseCost1 END TruckTypeABaseCost1, 
    CASE WHEN ISNULL(TruckTypeAFSF1, '') = '' THEN CAST(0.00 AS DECIMAL(18, 2)) ELSE TruckTypeAFSF1 END TruckTypeAFSF1, 
    TruckTypeAFROM1, 
    CASE WHEN ISNULL(TruckTypeABaseCost2, '') = '' THEN CAST(0.00 AS DECIMAL(18, 2)) ELSE TruckTypeABaseCost2 END TruckTypeABaseCost2, 
    CASE WHEN ISNULL(TruckTypeAFSF2, '') = '' THEN CAST(0.00 AS DECIMAL(18, 2)) ELSE TruckTypeAFSF2 END TruckTypeAFSF2, 
    TruckTypeAFROM2, 
	CASE WHEN ISNULL(TruckTypeABaseCost3, '') = '' THEN CAST(0.00 AS DECIMAL(18, 2)) ELSE TruckTypeABaseCost3 END TruckTypeABaseCost3, 
    CASE WHEN ISNULL(TruckTypeAFSF3, '') = '' THEN CAST(0.00 AS DECIMAL(18, 2)) ELSE TruckTypeAFSF3 END TruckTypeAFSF3, 
    TruckTypeAFROM3,
    TruckTypeB, 
    CASE WHEN ISNULL(TruckTypeBBaseCost1, '') = '' THEN CAST(0.00 AS DECIMAL(18, 2)) ELSE TruckTypeBBaseCost1 END TruckTypeBBaseCost1, 
    CASE WHEN ISNULL(TruckTypeBFSC1, '') = '' THEN CAST(0.00 AS DECIMAL(18, 2)) ELSE TruckTypeBFSC1 END TruckTypeBFSC1, 
    TruckTypeBFROM1, 
    CASE WHEN ISNULL(TruckTypeBBaseCost2, '') = '' THEN CAST(0.00 AS DECIMAL(18, 2)) ELSE TruckTypeBBaseCost2 END TruckTypeBBaseCost2, 
    CASE WHEN ISNULL(TruckTypeBFSC2, '') = '' THEN CAST(0.00 AS DECIMAL(18, 2)) ELSE TruckTypeBFSC2 END TruckTypeBFSC2, 
    TruckTypeBFROM2, 
	CASE WHEN ISNULL(TruckTypeBBaseCost3, '') = '' THEN CAST(0.00 AS DECIMAL(18, 2)) ELSE TruckTypeBBaseCost3 END TruckTypeBBaseCost3, 
    CASE WHEN ISNULL(TruckTypeBFSC3, '') = '' THEN CAST(0.00 AS DECIMAL(18, 2)) ELSE TruckTypeBFSC3 END TruckTypeBFSC3, 
    TruckTypeBFROM3,
    TruckTypeC, 
    CASE WHEN ISNULL(TruckTypeCBaseCost1, '') = '' THEN CAST(0.00 AS DECIMAL(18, 2)) ELSE TruckTypeCBaseCost1 END TruckTypeCBaseCost1, 
    CASE WHEN ISNULL(TruckTypeCFSC1, '') = '' THEN CAST(0.00 AS DECIMAL(18, 2)) ELSE TruckTypeCFSC1 END TruckTypeCFSC1, 
    TruckTypeCFROM1, 
    CASE WHEN ISNULL(TruckTypeCBaseCost2, '') = '' THEN CAST(0.00 AS DECIMAL(18, 2)) ELSE TruckTypeCBaseCost2 END TruckTypeCBaseCost2, 
    CASE WHEN ISNULL(TruckTypeCFSC2, '') = '' THEN CAST(0.00 AS DECIMAL(18, 2)) ELSE TruckTypeCFSC2 END TruckTypeCFSC2, 
    TruckTypeCFROM2, 
	CASE WHEN ISNULL(TruckTypeCBaseCost3, '') = '' THEN CAST(0.00 AS DECIMAL(18, 2)) ELSE TruckTypeCBaseCost3 END TruckTypeCBaseCost3, 
    CASE WHEN ISNULL(TruckTypeCFSC3, '') = '' THEN CAST(0.00 AS DECIMAL(18, 2)) ELSE TruckTypeCFSC3 END TruckTypeCFSC3, 
    TruckTypeCFROM3,
    TruckTypeD, 
    CASE WHEN ISNULL(TruckTypeDBaseCost1, '') = '' THEN CAST(0.00 AS DECIMAL(18, 2)) ELSE TruckTypeDBaseCost1 END TruckTypeDBaseCost1, 
    CASE WHEN ISNULL(TruckTypeDFSC1, '') = '' THEN CAST(0.00 AS DECIMAL(18, 2)) ELSE TruckTypeDFSC1 END TruckTypeDFSC1,
	TruckTypeDFROM1, 
    CASE WHEN ISNULL(TruckTypeDBaseCost2, '') = '' THEN CAST(0.00 AS DECIMAL(18, 2)) ELSE TruckTypeDBaseCost2 END TruckTypeDBaseCost2, 
    CASE WHEN ISNULL(TruckTypeDFSC2, '') = '' THEN CAST(0.00 AS DECIMAL(18, 2)) ELSE TruckTypeDFSC2 END TruckTypeDFSC2, 
    TruckTypeDFROM2, 
	CASE WHEN ISNULL(TruckTypeDBaseCost3, '') = '' THEN CAST(0.00 AS DECIMAL(18, 2)) ELSE TruckTypeDBaseCost3 END TruckTypeDBaseCost3, 
    CASE WHEN ISNULL(TruckTypeDFSC3, '') = '' THEN CAST(0.00 AS DECIMAL(18, 2)) ELSE TruckTypeDFSC3 END TruckTypeDFSC3, 
    TruckTypeDFROM3,
    FU.EffectiveDate, 
    FU.EffectiveDateFrom
FROM COST_FileUploadData_LongBeach FU
INNER JOIN 
    (SELECT fileProcesskey, RecordSL, Market, Terminal, City, State, Zipcode, Zone, EffectiveDate, EffectivedateFrom
     FROM 
         (SELECT FP.fileProcesskey, RecordSL, Market, Terminal, City, State, Zipcode, Zone, EffectiveDate, EffectivedateFrom, 
                 ROW_NUMBER() OVER (PARTITION BY FP.fileProcesskey,Market, Terminal, City, State, Zipcode, Zone ORDER BY EffectiveDate DESC, FP.FileProcessKey DESC) AS RecKey
          FROM COST_FileUploadData_LongBeach FU
          INNER JOIN COST_FileProcessInfo FP 
          ON FU.FileProcessKey = FP.FileProcessKey
          WHERE FP.FileProcessStatus = 1) A
     WHERE Reckey = 1) FUC 
ON FU.FileProcessKey = FUC.FileProcessKey AND FU.RecordSL = FUC.RecordSL

UNION ALL

-- Second SELECT Statement (Chicago)
SELECT        
    -- Same columns as the first SELECT, including new columns
    FU.FileProcessKey, 
    FU.RecordSL, 
    FU.Market, 
    FU.Terminal, 
    FU.City, 
    FU.State, 
    FU.ZipCode, 
    FU.Zone, 
    Prepulllocation1, 
    Prepullcost1, 
    Prepulllocation2, 
    Prepullcost2, 
    Stopofflocation1, 
    Stopoffcost1, 
    Stopofflocation2, 
    Stopoffcost2, 
    YardshuttledirectionTO1, 
    YardshuttledirectionFROM1, 
    Yardshuttlecost1, 
    YardshuttledirectionTO2, 
    YardshuttledirectionFROM2, 
    Yardshuttlecost2, 
    TruckTypeA, 
    CASE WHEN ISNULL(TruckTypeABaseCost1, '') = '' THEN CAST(0.00 AS DECIMAL(18, 2)) ELSE TruckTypeABaseCost1 END TruckTypeABaseCost1, 
    CASE WHEN ISNULL(TruckTypeAFSF1, '') = '' THEN CAST(0.00 AS DECIMAL(18, 2)) ELSE TruckTypeAFSF1 END TruckTypeAFSF1, 
    TruckTypeAFROM1, 
    CASE WHEN ISNULL(TruckTypeABaseCost2, '') = '' THEN CAST(0.00 AS DECIMAL(18, 2)) ELSE TruckTypeABaseCost2 END TruckTypeABaseCost2, 
    CASE WHEN ISNULL(TruckTypeAFSF2, '') = '' THEN CAST(0.00 AS DECIMAL(18, 2)) ELSE TruckTypeAFSF2 END TruckTypeAFSF2, 
    TruckTypeAFROM2, 
	CASE WHEN ISNULL(TruckTypeABaseCost3, '') = '' THEN CAST(0.00 AS DECIMAL(18, 2)) ELSE TruckTypeABaseCost3 END TruckTypeABaseCost3, 
    CASE WHEN ISNULL(TruckTypeAFSF3, '') = '' THEN CAST(0.00 AS DECIMAL(18, 2)) ELSE TruckTypeAFSF3 END TruckTypeAFSF3, 
    TruckTypeAFROM3,
    TruckTypeB, 
    CASE WHEN ISNULL(TruckTypeBBaseCost1, '') = '' THEN CAST(0.00 AS DECIMAL(18, 2)) ELSE TruckTypeBBaseCost1 END TruckTypeBBaseCost1, 
    CASE WHEN ISNULL(TruckTypeBFSC1, '') = '' THEN CAST(0.00 AS DECIMAL(18, 2)) ELSE TruckTypeBFSC1 END TruckTypeBFSC1, 
    TruckTypeBFROM1, 
    CASE WHEN ISNULL(TruckTypeBBaseCost2, '') = '' THEN CAST(0.00 AS DECIMAL(18, 2)) ELSE TruckTypeBBaseCost2 END TruckTypeBBaseCost2, 
    CASE WHEN ISNULL(TruckTypeBFSC2, '') = '' THEN CAST(0.00 AS DECIMAL(18, 2)) ELSE TruckTypeBFSC2 END TruckTypeBFSC2, 
    TruckTypeBFROM2, 
	CASE WHEN ISNULL(TruckTypeBBaseCost3, '') = '' THEN CAST(0.00 AS DECIMAL(18, 2)) ELSE TruckTypeBBaseCost3 END TruckTypeBBaseCost3, 
    CASE WHEN ISNULL(TruckTypeBFSC3, '') = '' THEN CAST(0.00 AS DECIMAL(18, 2)) ELSE TruckTypeBFSC3 END TruckTypeBFSC3,
    TruckTypeBFROM3,
    TruckTypeC, 
    CASE WHEN ISNULL(TruckTypeCBaseCost1, '') = '' THEN CAST(0.00 AS DECIMAL(18, 2)) ELSE TruckTypeCBaseCost1 END TruckTypeCBaseCost1, 
    CASE WHEN ISNULL(TruckTypeCFSC1, '') = '' THEN CAST(0.00 AS DECIMAL(18, 2)) ELSE TruckTypeCFSC1 END TruckTypeCFSC1, 
    TruckTypeCFROM1, 
    CASE WHEN ISNULL(TruckTypeCBaseCost2, '') = '' THEN CAST(0.00 AS DECIMAL(18, 2)) ELSE TruckTypeCBaseCost2 END TruckTypeCBaseCost2, 
    CASE WHEN ISNULL(TruckTypeCFSC2, '') = '' THEN CAST(0.00 AS DECIMAL(18, 2)) ELSE TruckTypeCFSC2 END TruckTypeCFSC2, 
    TruckTypeCFROM2, 
	CASE WHEN ISNULL(TruckTypeCBaseCost3, '') = '' THEN CAST(0.00 AS DECIMAL(18, 2)) ELSE TruckTypeCBaseCost3 END TruckTypeCBaseCost3, 
    CASE WHEN ISNULL(TruckTypeCFSC3, '') = '' THEN CAST(0.00 AS DECIMAL(18, 2)) ELSE TruckTypeCFSC3 END TruckTypeCFSC3, 
    TruckTypeCFROM3,
    TruckTypeD, 
    CASE WHEN ISNULL(TruckTypeDBaseCost1, '') = '' THEN CAST(0.00 AS DECIMAL(18, 2)) ELSE TruckTypeDBaseCost1 END TruckTypeDBaseCost1, 
    CASE WHEN ISNULL(TruckTypeDFSC1, '') = '' THEN CAST(0.00 AS DECIMAL(18, 2)) ELSE TruckTypeDFSC1 END TruckTypeDFSC1,
	TruckTypeDFROM1, 
    CASE WHEN ISNULL(TruckTypeDBaseCost2, '') = '' THEN CAST(0.00 AS DECIMAL(18, 2)) ELSE TruckTypeDBaseCost2 END TruckTypeDBaseCost2, 
    CASE WHEN ISNULL(TruckTypeDFSC2, '') = '' THEN CAST(0.00 AS DECIMAL(18, 2)) ELSE TruckTypeDFSC2 END TruckTypeDFSC2, 
    TruckTypeDFROM2, 
	CASE WHEN ISNULL(TruckTypeDBaseCost3, '') = '' THEN CAST(0.00 AS DECIMAL(18, 2)) ELSE TruckTypeDBaseCost3 END TruckTypeDBaseCost3, 
    CASE WHEN ISNULL(TruckTypeDFSC3, '') = '' THEN CAST(0.00 AS DECIMAL(18, 2)) ELSE TruckTypeDFSC3 END TruckTypeDFSC3, 
    TruckTypeDFROM3, 
    FU.EffectiveDate, 
    FU.EffectiveDateFrom
FROM COST_FileUploadData_Chicago FU
INNER JOIN 
    (SELECT fileProcesskey, RecordSL, Market, Terminal, City, State, Zipcode, Zone, EffectiveDate, EffectivedateFrom
     FROM 
         (SELECT FP.fileProcesskey, RecordSL, Market, Terminal, City, State, Zipcode, Zone, EffectiveDate, EffectivedateFrom, 
                 ROW_NUMBER() OVER (PARTITION BY FP.fileProcesskey,Market, Terminal, City, State, Zipcode, Zone ORDER BY EffectiveDate DESC, FP.FileProcessKey DESC) AS RecKey
          FROM COST_FileUploadData_Chicago FU
          INNER JOIN COST_FileProcessInfo FP 
          ON FU.FileProcessKey = FP.FileProcessKey
          WHERE FP.FileProcessStatus = 1) A
     WHERE Reckey = 1) FUC 
ON FU.FileProcessKey = FUC.FileProcessKey AND FU.RecordSL = FUC.RecordSL;
