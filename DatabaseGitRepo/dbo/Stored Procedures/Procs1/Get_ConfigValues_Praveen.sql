CREATE PROCEDURE [dbo].[Get_ConfigValues_Praveen]  -- [Get_ConfigValues] 3,3,0
(
	--@FilterId	VARCHAR(50)='',
	@CompanyKey	INT=0,
	@MarketLocation INT,
	@IsFactored BIT
)
AS

BEGIN
	--SELECT ConfigName,ConfigValue1 
	--	FROM AppConfig 
	--WHERE ConfigValue2=@FilterId 
	--AND ConfigValue1<>'' AND ConfigValue1 IS NOT NULL 
	--AND CompanyKey=@CompanyKey
	--FOR JSON PATH
	DECLARE @FilterId	VARCHAR(50)=''

IF(@CompanyKey=2 AND @MarketLocation=3 AND @IsFactored=1)--Approve as JIL  Market Location: Chicago Factored
	BEGIN
		SET @FilterId='ALLALLF'
		SELECT 'Intermodal Power Group DBA: Junction Integrated Logistics' AS CompanyName, 
		'100 W Victoria St' AS Address1, 'Long Beach, CA 90805' AS Address2, '' AS Address3, '' AS Address4, 
		ConfigName,ConfigValue1 
			FROM AppConfig 
		WHERE ConfigValue2=@FilterId 
		AND ConfigValue1<>'' AND ConfigValue1 IS NOT NULL 
		--AND CompanyKey=@CompanyKey
		FOR JSON PATH
	END
ELSE IF(@CompanyKey=2 AND @MarketLocation=2 AND @IsFactored=1)--Approve as JIL  Market Location: Long Beach Factored
	BEGIN
		SET @FilterId='ALLALLF'
		SELECT 'Intermodal Power Group DBA: Junction Integrated Logistics' AS CompanyName, 
		'100 W Victoria St' AS Address1, 'Long Beach, CA 90805' AS Address2, '' AS Address3, '' AS Address4,
		ConfigName,ConfigValue1 
			FROM AppConfig 
		WHERE ConfigValue2=@FilterId 
		AND ConfigValue1<>'' AND ConfigValue1 IS NOT NULL 
		--AND CompanyKey=@CompanyKey
		FOR JSON PATH
	END
ELSE IF(@CompanyKey=2 AND @MarketLocation=3 AND @IsFactored=0)--Approve as JIL  Market Location: Chicago Non-Factored
	BEGIN
		SET @FilterId='JILCLBNF'
		SELECT 'Intermodal Power Group DBA: Junction Integrated Logistics' AS CompanyName, 
		'100 W Victoria St' AS Address1, 'Long Beach, CA 90805' AS Address2, '' AS Address3, '' AS Address4,
		ConfigName,ConfigValue1 
			FROM AppConfig 
		WHERE ConfigValue2=@FilterId 
		AND ConfigValue1<>'' AND ConfigValue1 IS NOT NULL 
		--AND CompanyKey=@CompanyKey
		FOR JSON PATH
	END
ELSE IF(@CompanyKey=2 AND @MarketLocation=2 AND @IsFactored=0)--Approve as JIL  Market Location: Long Beach Non-Factored
	BEGIN
		SET @FilterId='JILCLBNF'
		SELECT 'Intermodal Power Group DBA: Junction Integrated Logistics' AS CompanyName, 
		'100 W Victoria St' AS Address1, 'Long Beach, CA 90805' AS Address2, '' AS Address3, '' AS Address4,
		ConfigName,ConfigValue1 
			FROM AppConfig 
		WHERE ConfigValue2=@FilterId 
		AND ConfigValue1<>'' AND ConfigValue1 IS NOT NULL 
		--AND CompanyKey=@CompanyKey
		FOR JSON PATH
	END
ELSE IF(@CompanyKey=3 AND @MarketLocation=3 AND @IsFactored=1)--Approve as JCT INC  Market Location: Chicago Factored
	BEGIN
		SET @FilterId='ALLALLF'
		SELECT 'JUNCTION COLLABORATIVE TRANSPORTS INC' AS CompanyName, 
		'1781 Patterson Road' AS Address1, 'Joliet, IL 60436' AS Address2, '' AS Address3, '' AS Address4,
		ConfigName,ConfigValue1 
			FROM AppConfig 
		WHERE ConfigValue2=@FilterId 
		AND ConfigValue1<>'' AND ConfigValue1 IS NOT NULL 
		--AND CompanyKey=@CompanyKey
		FOR JSON PATH
	END
ELSE IF(@CompanyKey=1 AND @MarketLocation=2 AND @IsFactored=1)--Approve as JCT  Market Location: Long Beach Factored
	BEGIN
		SET @FilterId='ALLALLF'
		SELECT 'JUNCTION COLLABORATIVE TRANSPORTS' AS CompanyName, 
		'100 W Victoria St' AS Address1, 'Long Beach, CA 90805' AS Address2, '' AS Address3, '' AS Address4,ConfigName,ConfigValue1 
			FROM AppConfig 
		WHERE ConfigValue2=@FilterId 
		AND ConfigValue1<>'' AND ConfigValue1 IS NOT NULL 
		--AND CompanyKey=@CompanyKey
		FOR JSON PATH
	END
ELSE IF(@CompanyKey=3 AND @MarketLocation=3 AND @IsFactored=0)--Approve as JCT INC  Market Location: Chicago Non-Factored
	BEGIN
		SET @FilterId='JCTICNF'
		SELECT 'JUNCTION COLLABORATIVE TRANSPORTS INC' AS CompanyName, 
		'1781 Patterson Road' AS Address1, 'Joliet, IL 60436' AS Address2, '' AS Address3, '' AS Address4,ConfigName,ConfigValue1 
			FROM AppConfig 
		WHERE ConfigValue2=@FilterId 
		AND ConfigValue1<>'' AND ConfigValue1 IS NOT NULL 
		--AND CompanyKey=@CompanyKey
		FOR JSON PATH
	END
ELSE IF(@CompanyKey=1 AND @MarketLocation=2 AND @IsFactored=0)--Approve as JCT  Market Location: Long Beach Non-Factored
	BEGIN
		SET @FilterId='JCTLBNF'
		SELECT 'JUNCTION COLLABORATIVE TRANSPORTS' AS CompanyName, 
		'100 W Victoria St' AS Address1, 'Long Beach, CA 90805' AS Address2, '' AS Address3, '' AS Address4,ConfigName,ConfigValue1 
			FROM AppConfig 
		WHERE ConfigValue2=@FilterId 
		AND ConfigValue1<>'' AND ConfigValue1 IS NOT NULL 
		--AND CompanyKey=@CompanyKey
		FOR JSON PATH
	END
	-----new----
ELSE IF(@CompanyKey=2 AND @IsFactored=1)--Approve as JIL  Market Location: Chicago Factored
	BEGIN
		SET @FilterId='ALLALLF'
		SELECT 'Intermodal Power Group DBA: Junction Integrated Logistics' AS CompanyName, 
		'100 W Victoria St' AS Address1, 'Long Beach, CA 90805' AS Address2, '' AS Address3, '' AS Address4, 
		ConfigName,ConfigValue1 
			FROM AppConfig 
		WHERE ConfigValue2=@FilterId 
		AND ConfigValue1<>'' AND ConfigValue1 IS NOT NULL 
		--AND CompanyKey=@CompanyKey
		FOR JSON PATH
	END
ELSE IF(@CompanyKey=2 AND @IsFactored=1)--Approve as JIL  Market Location: Long Beach Factored
	BEGIN
		SET @FilterId='ALLALLF'
		SELECT 'Intermodal Power Group DBA: Junction Integrated Logistics' AS CompanyName, 
		'100 W Victoria St' AS Address1, 'Long Beach, CA 90805' AS Address2, '' AS Address3, '' AS Address4,
		ConfigName,ConfigValue1 
			FROM AppConfig 
		WHERE ConfigValue2=@FilterId 
		AND ConfigValue1<>'' AND ConfigValue1 IS NOT NULL 
		--AND CompanyKey=@CompanyKey
		FOR JSON PATH
	END
ELSE IF(@CompanyKey=2 AND @IsFactored=0)--Approve as JIL  Market Location: Chicago Non-Factored
	BEGIN
		SET @FilterId='JILCLBNF'
		SELECT 'Intermodal Power Group DBA: Junction Integrated Logistics' AS CompanyName, 
		'100 W Victoria St' AS Address1, 'Long Beach, CA 90805' AS Address2, '' AS Address3, '' AS Address4,
		ConfigName,ConfigValue1 
			FROM AppConfig 
		WHERE ConfigValue2=@FilterId 
		AND ConfigValue1<>'' AND ConfigValue1 IS NOT NULL 
		--AND CompanyKey=@CompanyKey
		FOR JSON PATH
	END
ELSE IF(@CompanyKey=2 AND @IsFactored=0)--Approve as JIL  Market Location: Long Beach Non-Factored
	BEGIN
		SET @FilterId='JILCLBNF'
		SELECT 'Intermodal Power Group DBA: Junction Integrated Logistics' AS CompanyName, 
		'100 W Victoria St' AS Address1, 'Long Beach, CA 90805' AS Address2, '' AS Address3, '' AS Address4,
		ConfigName,ConfigValue1 
			FROM AppConfig 
		WHERE ConfigValue2=@FilterId 
		AND ConfigValue1<>'' AND ConfigValue1 IS NOT NULL 
		--AND CompanyKey=@CompanyKey
		FOR JSON PATH
	END
ELSE IF(@CompanyKey=3 AND @IsFactored=1)--Approve as JCT INC  Market Location: Chicago Factored
	BEGIN
		SET @FilterId='ALLALLF'
		SELECT 'JUNCTION COLLABORATIVE TRANSPORTS INC' AS CompanyName, 
		'1781 Patterson Road' AS Address1, 'Joliet, IL 60436' AS Address2, '' AS Address3, '' AS Address4,
		ConfigName,ConfigValue1 
			FROM AppConfig 
		WHERE ConfigValue2=@FilterId 
		AND ConfigValue1<>'' AND ConfigValue1 IS NOT NULL 
		--AND CompanyKey=@CompanyKey
		FOR JSON PATH
	END
ELSE IF(@CompanyKey=1 AND @IsFactored=1)--Approve as JCT  Market Location: Long Beach Factored
	BEGIN
		SET @FilterId='ALLALLF'
		SELECT 'JUNCTION COLLABORATIVE TRANSPORTS' AS CompanyName, 
		'100 W Victoria St' AS Address1, 'Long Beach, CA 90805' AS Address2, '' AS Address3, '' AS Address4,ConfigName,ConfigValue1 
			FROM AppConfig 
		WHERE ConfigValue2=@FilterId 
		AND ConfigValue1<>'' AND ConfigValue1 IS NOT NULL 
		--AND CompanyKey=@CompanyKey
		FOR JSON PATH
	END
ELSE IF(@CompanyKey=3 AND @IsFactored=0)--Approve as JCT INC  Market Location: Chicago Non-Factored
	BEGIN
		SET @FilterId='JCTICNF'
		SELECT 'JUNCTION COLLABORATIVE TRANSPORTS INC' AS CompanyName, 
		'1781 Patterson Road' AS Address1, 'Joliet, IL 60436' AS Address2, '' AS Address3, '' AS Address4,ConfigName,ConfigValue1 
			FROM AppConfig 
		WHERE ConfigValue2=@FilterId 
		AND ConfigValue1<>'' AND ConfigValue1 IS NOT NULL 
		--AND CompanyKey=@CompanyKey
		FOR JSON PATH
	END
ELSE IF(@CompanyKey=1 AND @IsFactored=0)--Approve as JCT  Market Location: Long Beach Non-Factored
	BEGIN
		SET @FilterId='JCTLBNF'
		SELECT 'JUNCTION COLLABORATIVE TRANSPORTS' AS CompanyName, 
		'100 W Victoria St' AS Address1, 'Long Beach, CA 90805' AS Address2, '' AS Address3, '' AS Address4,ConfigName,ConfigValue1 
			FROM AppConfig 
		WHERE ConfigValue2=@FilterId 
		AND ConfigValue1<>'' AND ConfigValue1 IS NOT NULL 
		--AND CompanyKey=@CompanyKey
		FOR JSON PATH
	END
ELSE
	BEGIN
		SET @FilterId='JCTLBNF'
		SELECT 'JUNCTION COLLABORATIVE TRANSPORTS' AS CompanyName, 
		'100 W Victoria St' AS Address1, 'Long Beach, CA 90805' AS Address2, '' AS Address3, '' AS Address4,ConfigName,ConfigValue1 
			FROM AppConfig 
		WHERE ConfigValue2=@FilterId 
		AND ConfigValue1<>'' AND ConfigValue1 IS NOT NULL 
		--AND CompanyKey=@CompanyKey
		FOR JSON PATH
	END
END