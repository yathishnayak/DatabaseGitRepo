/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"CompanyKey" : 2, "MarketLocation" : 2, "IsFactored" : 1}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [Get_ConfigValues_V3] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[Get_ConfigValues_V3]  -- [Get_ConfigValues] 2, 2, 1
(
	@UserKey		INT = 1144,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS

BEGIN
	--SELECT ConfigName,ConfigValue1 
	--	FROM AppConfig 
	--WHERE ConfigValue2=@FilterId 
	--AND ConfigValue1<>'' AND ConfigValue1 IS NOT NULL 
	--AND CompanyKey=@CompanyKey
	--FOR JSON PATH

	IF (ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
	BEGIN
		SET		@Status = 0
		SET		@Reason = 'Parameters not found'
		RETURN
	END	

	DECLARE
		@CompanyKey			INT=0,
		@MarketLocation		INT,
		@IsFactored			BIT

	SELECT 
		@CompanyKey			=	CompanyKey		,
		@MarketLocation		=	MarketLocation	,
		@IsFactored			=	IsFactored		
	FROM OPENJSON(@JSONString)
	WITH
	(
		CompanyKey				INT			'$.CompanyKey',
		MarketLocation			INT			'$.MarketLocation',
		IsFactored				BIT			'$.IsFactored'
	)

	DECLARE @FilterId	VARCHAR(50)=''

IF(@CompanyKey=2 AND @MarketLocation=3 AND @IsFactored=1)--Approve as JIL  Market Location: Chicago Factored
	BEGIN
		SET @FilterId='ALLALLF'
		SELECT 'Intermodal Power Group, LLC DBA: Junction Integrated Logistics' AS CompanyName, 
		'Busbot Incorporated dba Denim' AS Address1, 'PO Box 737606' AS Address23, 'Dallas, TX 75373-7606' AS Address3, '' AS Address4, 
		ConfigName,ConfigValue1 
			FROM AppConfig WITH(NOLOCK)
		WHERE ConfigValue2=@FilterId 
		AND ConfigValue1<>'' AND ConfigValue1 IS NOT NULL 
		--AND CompanyKey=@CompanyKey
		FOR JSON PATH
		SET @Status=1
		SET @Reason = 'Success'
	END
ELSE IF(@CompanyKey=2 AND @MarketLocation=2 AND @IsFactored=1)--Approve as JIL  Market Location: Long Beach Factored
	BEGIN
		SET @FilterId='ALLALLF'
		SELECT 'Intermodal Power Group, LLC DBA: Junction Integrated Logistics' AS CompanyName, 
		'Busbot Incorporated dba Denim' AS Address1,'PO Box 737606' AS Address2, 'Dallas, TX 75373-7606' AS Address3, '' AS Address4,
		ConfigName,ConfigValue1 
			FROM AppConfig WITH(NOLOCK)
		WHERE ConfigValue2=@FilterId 
		AND ConfigValue1<>'' AND ConfigValue1 IS NOT NULL 
		--AND CompanyKey=@CompanyKey
		FOR JSON PATH
		SET @Status=1
		SET @Reason = 'Success'
	END
ELSE IF(@CompanyKey=2 AND @MarketLocation=3 AND @IsFactored=0)--Approve as JIL  Market Location: Chicago Non-Factored
	BEGIN
		SET @FilterId='JILCLBNF'
		SELECT 'Intermodal Power Group, LLC DBA: Junction Integrated Logistics' AS CompanyName, 
		'100 W Victoria St' AS Address1, 'Long Beach, CA 90805' AS Address2, '' AS Address3, '' AS Address4,
		ConfigName,ConfigValue1 
			FROM AppConfig WITH(NOLOCK)
		WHERE ConfigValue2=@FilterId 
		AND ConfigValue1<>'' AND ConfigValue1 IS NOT NULL 
		--AND CompanyKey=@CompanyKey
		FOR JSON PATH
		SET @Status=1
		SET @Reason = 'Success'
	END
ELSE IF(@CompanyKey=2 AND @MarketLocation=2 AND @IsFactored=0)--Approve as JIL  Market Location: Long Beach Non-Factored
	BEGIN
		SET @FilterId='JILCLBNF'
		SELECT 'Intermodal Power Group, LLC DBA: Junction Integrated Logistics' AS CompanyName, 
		'100 W Victoria St' AS Address1, 'Long Beach, CA 90805' AS Address2, '' AS Address3, '' AS Address4,
		ConfigName,ConfigValue1 
			FROM AppConfig WITH(NOLOCK)
		WHERE ConfigValue2=@FilterId 
		AND ConfigValue1<>'' AND ConfigValue1 IS NOT NULL 
		--AND CompanyKey=@CompanyKey
		FOR JSON PATH
		SET @Status=1
		SET @Reason = 'Success'
	END
ELSE IF(@CompanyKey=3 AND @MarketLocation=3 AND @IsFactored=1)--Approve as JCT INC  Market Location: Chicago Factored
	BEGIN
		SET @FilterId='ALLALLF'
		SELECT 'JUNCTION COLLABORATIVE TRANSPORTS INC' AS CompanyName, 
		'Busbot Incorporated dba Denim' AS Address1,'PO Box 737606' AS Address2, 'Dallas, TX 75373-7606' AS Address3, '' AS Address4,
		ConfigName,ConfigValue1 
			FROM AppConfig WITH(NOLOCK)
		WHERE ConfigValue2=@FilterId 
		AND ConfigValue1<>'' AND ConfigValue1 IS NOT NULL 
		--AND CompanyKey=@CompanyKey
		FOR JSON PATH
		SET @Status=1
		SET @Reason = 'Success'
	END
ELSE IF(@CompanyKey=1 AND @MarketLocation=2 AND @IsFactored=1)--Approve as JCT  Market Location: Long Beach Factored
	BEGIN
		SET @FilterId='ALLALLF'
		SELECT 'JUNCTION COLLABORATIVE TRANSPORTS' AS CompanyName, 
		'Busbot Incorporated dba Denim' AS Address1,'PO Box 737606' AS Address2, 'Dallas, TX 75373-7606' AS Address3, '' AS Address4,ConfigName,ConfigValue1 
			FROM AppConfig WITH(NOLOCK)
		WHERE ConfigValue2=@FilterId 
		AND ConfigValue1<>'' AND ConfigValue1 IS NOT NULL 
		--AND CompanyKey=@CompanyKey
		FOR JSON PATH
		SET @Status=1
		SET @Reason = 'Success'
	END
ELSE IF(@CompanyKey=3 AND @MarketLocation=3 AND @IsFactored=0)--Approve as JCT INC  Market Location: Chicago Non-Factored
	BEGIN
		SET @FilterId='JCTICNF'
		SELECT 'JUNCTION COLLABORATIVE TRANSPORTS INC' AS CompanyName, 
		'1781 Patterson Road' AS Address1, 'Joliet, IL 60436' AS Address2, '' AS Address3, '' AS Address4,ConfigName,ConfigValue1 
			FROM AppConfig WITH(NOLOCK)
		WHERE ConfigValue2=@FilterId 
		AND ConfigValue1<>'' AND ConfigValue1 IS NOT NULL 
		--AND CompanyKey=@CompanyKey
		FOR JSON PATH
		SET @Status=1
		SET @Reason = 'Success'
	END
ELSE IF(@CompanyKey=1 AND @MarketLocation=2 AND @IsFactored=0)--Approve as JCT  Market Location: Long Beach Non-Factored
	BEGIN
		SET @FilterId='JCTLBNF'
		SELECT 'JUNCTION COLLABORATIVE TRANSPORTS' AS CompanyName, 
		'100 W Victoria St' AS Address1, 'Long Beach, CA 90805' AS Address2, '' AS Address3, '' AS Address4,ConfigName,ConfigValue1 
			FROM AppConfig WITH(NOLOCK)
		WHERE ConfigValue2=@FilterId 
		AND ConfigValue1<>'' AND ConfigValue1 IS NOT NULL 
		--AND CompanyKey=@CompanyKey
		FOR JSON PATH
		SET @Status=1
		SET @Reason = 'Success'
	END
	-----new----
ELSE IF(@CompanyKey=2 AND @IsFactored=1)--Approve as JIL  Market Location: Chicago Factored
	BEGIN
		SET @FilterId='ALLALLF'
		SELECT 'Intermodal Power Group, LLC DBA: Junction Integrated Logistics' AS CompanyName, 
		'Busbot Incorporated dba Denim' AS Address1,'PO Box 737606' AS Address2, 'Dallas, TX 75373-7606' AS Address3, '' AS Address4, 
		ConfigName,ConfigValue1 
			FROM AppConfig WITH(NOLOCK)
		WHERE ConfigValue2=@FilterId 
		AND ConfigValue1<>'' AND ConfigValue1 IS NOT NULL 
		--AND CompanyKey=@CompanyKey
		FOR JSON PATH
		SET @Status=1
		SET @Reason = 'Success'
	END
ELSE IF(@CompanyKey=2 AND @IsFactored=1)--Approve as JIL  Market Location: Long Beach Factored
	BEGIN
		SET @FilterId='ALLALLF'
		SELECT 'Intermodal Power Group, LLC DBA: Junction Integrated Logistics' AS CompanyName, 
		'Busbot Incorporated dba Denim' AS Address1,'PO Box 737606' AS Address2, 'Dallas, TX 75373-7606' AS Address3, '' AS Address4,
		ConfigName,ConfigValue1 
			FROM AppConfig WITH(NOLOCK)
		WHERE ConfigValue2=@FilterId 
		AND ConfigValue1<>'' AND ConfigValue1 IS NOT NULL 
		--AND CompanyKey=@CompanyKey
		FOR JSON PATH
		SET @Status=1
		SET @Reason = 'Success'
	END
ELSE IF(@CompanyKey=2 AND @IsFactored=0)--Approve as JIL  Market Location: Chicago Non-Factored
	BEGIN
		SET @FilterId='JILCLBNF'
		SELECT 'Intermodal Power Group, LLC DBA: Junction Integrated Logistics' AS CompanyName, 
		'100 W Victoria St' AS Address1, 'Long Beach, CA 90805' AS Address2, '' AS Address3, '' AS Address4,
		ConfigName,ConfigValue1 
			FROM AppConfig WITH(NOLOCK)
		WHERE ConfigValue2=@FilterId 
		AND ConfigValue1<>'' AND ConfigValue1 IS NOT NULL 
		--AND CompanyKey=@CompanyKey
		FOR JSON PATH
		SET @Status=1
		SET @Reason = 'Success'
	END
ELSE IF(@CompanyKey=2 AND @IsFactored=0)--Approve as JIL  Market Location: Long Beach Non-Factored
	BEGIN
		SET @FilterId='JILCLBNF'
		SELECT 'Intermodal Power Group, LLC DBA: Junction Integrated Logistics' AS CompanyName, 
		'100 W Victoria St' AS Address1, 'Long Beach, CA 90805' AS Address2, '' AS Address3, '' AS Address4,
		ConfigName,ConfigValue1 
			FROM AppConfig WITH(NOLOCK)
		WHERE ConfigValue2=@FilterId 
		AND ConfigValue1<>'' AND ConfigValue1 IS NOT NULL 
		--AND CompanyKey=@CompanyKey
		FOR JSON PATH
		SET @Status=1
		SET @Reason = 'Success'
	END
ELSE IF(@CompanyKey=3 AND @IsFactored=1)--Approve as JCT INC  Market Location: Chicago Factored
	BEGIN
		SET @FilterId='ALLALLF'
		SELECT 'JUNCTION COLLABORATIVE TRANSPORTS INC' AS CompanyName, 
		'Busbot Incorporated dba Denim' AS Address1,'PO Box 737606' AS Address2, 'Dallas, TX 75373-7606' AS Address3, '' AS Address4,
		ConfigName,ConfigValue1 
			FROM AppConfig WITH(NOLOCK)
		WHERE ConfigValue2=@FilterId 
		AND ConfigValue1<>'' AND ConfigValue1 IS NOT NULL 
		--AND CompanyKey=@CompanyKey
		FOR JSON PATH
		SET @Status=1
		SET @Reason = 'Success'
	END
ELSE IF(@CompanyKey=1 AND @IsFactored=1)--Approve as JCT  Market Location: Long Beach Factored
	BEGIN
		SET @FilterId='ALLALLF'
		SELECT 'JUNCTION COLLABORATIVE TRANSPORTS' AS CompanyName, 
		'Busbot Incorporated dba Denim' AS Address1,'PO Box 737606' AS Address2, 'Dallas, TX 75373-7606' AS Address3, '' AS Address4,ConfigName,ConfigValue1 
			FROM AppConfig WITH(NOLOCK)
		WHERE ConfigValue2=@FilterId 
		AND ConfigValue1<>'' AND ConfigValue1 IS NOT NULL 
		--AND CompanyKey=@CompanyKey
		FOR JSON PATH
		SET @Status=1
		SET @Reason = 'Success'
	END
ELSE IF(@CompanyKey=3 AND @IsFactored=0)--Approve as JCT INC  Market Location: Chicago Non-Factored
	BEGIN
		SET @FilterId='JCTICNF'
		SELECT 'JUNCTION COLLABORATIVE TRANSPORTS INC' AS CompanyName, 
		'1781 Patterson Road' AS Address1, 'Joliet, IL 60436' AS Address2, '' AS Address3, '' AS Address4,ConfigName,ConfigValue1 
			FROM AppConfig  WITH(NOLOCK)
		WHERE ConfigValue2=@FilterId 
		AND ConfigValue1<>'' AND ConfigValue1 IS NOT NULL 
		--AND CompanyKey=@CompanyKey
		FOR JSON PATH
		SET @Status=1
		SET @Reason = 'Success'
	END
ELSE IF(@CompanyKey=1 AND @IsFactored=0)--Approve as JCT  Market Location: Long Beach Non-Factored
	BEGIN
		SET @FilterId='JCTLBNF'
		SELECT 'JUNCTION COLLABORATIVE TRANSPORTS' AS CompanyName, 
		'100 W Victoria St' AS Address1, 'Long Beach, CA 90805' AS Address2, '' AS Address3, '' AS Address4,ConfigName,ConfigValue1 
			FROM AppConfig WITH(NOLOCK)
		WHERE ConfigValue2=@FilterId 
		AND ConfigValue1<>'' AND ConfigValue1 IS NOT NULL 
		--AND CompanyKey=@CompanyKey
		FOR JSON PATH
		SET @Status=1
		SET @Reason = 'Success'
	END
ELSE
	BEGIN
		SET @FilterId='JCTLBNF'
		SELECT 'JUNCTION COLLABORATIVE TRANSPORTS' AS CompanyName, 
		'100 W Victoria St' AS Address1, 'Long Beach, CA 90805' AS Address2, '' AS Address3, '' AS Address4,ConfigName,ConfigValue1 
			FROM AppConfig  WITH(NOLOCK)
		WHERE ConfigValue2=@FilterId 
		AND ConfigValue1<>'' AND ConfigValue1 IS NOT NULL 
		--AND CompanyKey=@CompanyKey
		FOR JSON PATH
		SET @Status=1
		SET @Reason = 'Success'
	END
END