


CREATE VIEW [dbo].[COST_VCostDataOutput] -- SELECT * FROM COST_VCostDataOutput

AS
	




	SELECT				Market, Terminal,City, State, ZipCode, Zone,  DriverType, YardPortType, Cost
						, FSF AS FSFCost
						, CASE WHEN FSF = 0 THEN 0.00 ELSE CAST((Cost *  FSF)/ 100 AS DECIMAL(18,2)) END FSF
						,  CAST((Cost * CASE WHEN FSF = 0 THEN 1 ELSE CAST((Cost *  FSF)/ 100 AS DECIMAL(18,2)) END) AS DECIMAL(18,2)) DrayBase
						, CONVERT(VARCHAR,EffectiveDate,110)EffectiveDate , EffectiveDateFrom
	FROM				COST_CostDataOutput
