/** 
Declare 
	@UserKey		INT,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING		NVARCHAR(Max) = '{"Type":"0"}'
	EXEC [Sell_GetCustomerList_V2] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason 
**/
CREATE PROCEDURE [dbo].[Sell_GetCustomerList_V2]
(
	@UserKey		INT = 1144,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0 
)
AS
BEGIN
	
	IF ISNULL(@JSONString, '') = ''
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'Parameters not found'
			RETURN
		END	

	DECLARE
	@Type	VARCHAR(100)=''

	SELECT 
		@Type	=	Type
	FROM OPENJSON(@JSONString)
	WITH
		(
			Type	VARCHAR(100)		'$.Type'
		)

	IF(@Type='1')
	BEGIN
		SELECT Distinct ISNULL(C.CustId,'') CustID,A.CustName, ISNULL(C.CustKey,0) CustKey  
		FROM SELL_NAC_Accessorial_FinalDataOutput A WITH (NOLOCK)
		LEFT JOIN Customer C WITH (NOLOCK) ON A.CustName=C.CustName
		WHERE C.CustKey IS NOT NULL 
		FOR JSON PATH
		SET @Status = 1
		SET @Reason = 'Success'
	END
	ELSE
	BEGIN
		SELECT Distinct ISNULL(C.CustId,'') CustID,A.CustName, ISNULL(C.CustKey,0) CustKey 
		FROM SELL_NAC_DrayBase_FinalDataOutput A WITH (NOLOCK)
		LEFT JOIN Customer C WITH (NOLOCK) ON A.CustName=C.CustName
		WHERE C.CustKey IS NOT NULL 
		FOR JSON PATH
		SET @Status = 1
		SET @Reason = 'Success'
	END
END