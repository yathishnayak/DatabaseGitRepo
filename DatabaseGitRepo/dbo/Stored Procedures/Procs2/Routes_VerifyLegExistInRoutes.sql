/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"OrderDetailKey" : 47903, "LegKey" : 35}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXec [Routes_VerifyLegExistInRoutes] @UserKey,@JSONString, @IsDebug, @Status OUTPUT,@Reason OUTPUT
	Select @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[Routes_VerifyLegExistInRoutes]
(
	@UserKey		INT=512,
	@JsonString		VARCHAR(MAX)='',
	@IsDebug		BIT = 1,
	@Status			BIT	= 0 OUTPUT,
	@Reason			NVARCHAR(1000) = '' OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;
	SET ARITHABORT ON;

	IF(ISNULL(@JsonString,'')='')
	BEGIN
		SET @Status=0;
		SET @Reason='Parameter not found';
		RETURN;
	END
	DECLARE @OrderDetailKey INT, @LegKey  INT

	SELECT @OrderDetailKey=OrderDetailKey,@LegKey=LegKey
	FROM OPENJSON(@JsonString, '$')
	WITH(	
			OrderDetailKey		INT		'$.OrderDetailKey',
			LegKey				INT		'$.LegKey'
		)


	SELECT LegKey,RouteKey,OrderDetailKey
	FROM Routes WITH (NOLOCK)
	WHERE OrderDetailKey= @OrderDetailKey AND LegKey= @LegKey
	FOR JSON PATH

	--IF (@@ROWCOUNT=0)
	--BEGIN
	--	SET @Status = 0;
	--	SET @Reason='No records found';
	--	RETURN
	--END

	SET @Reason='Success'
	SET @Status = 1
END