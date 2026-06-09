/** 
Declare 
	@UserKey		INT,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING		NVARCHAR(Max) = ''
	EXEC [GET_AllLegs_V2] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
**/
CREATE PROCEDURE [dbo].[GET_AllLegs_V2] 
(
	@UserKey		INT = 1144,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0 
)
/*
Scheduler Screen/Dispatch Screen
*/
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SELECT MIN(C.LegKey) AS LegKey ,C.LegID AS [Description]
	FROM [LegType] A  WITH (NOLOCK)
		  INNER JOIN [Leg] C WITH (NOLOCK)		ON C.LegtypeKey=A.LegtypeKey
		  INNER JOIN ordertype X WITH (NOLOCK)	ON X.OrderTypeKey=A.OrderTypeKey
		  INNER JOIN [Status] S WITH (NOLOCK)		ON S.StatusKey=A.StatusKey
	WHERE S.StatusName='Active'
	GROUP BY C.LegID	

	FOR JSON PATH;

	SET @Status = 1
	SET @Reason = 'Success'
END