/*
DECLARE @UserKey		INT=488,
	@JsonString		VARCHAR(MAX)='{"WarehouseKey":3}',
	@IsDebug		BIT = 1,
	@Status			BIT	= 0 ,
	@Reason			NVARCHAR(1000) = '' 
	exec GetWarehouseByKey_V2 @UserKey,@JsonString,@IsDebug,@Status OUTPUT,@Reason OUTPUT
	select @Status,@Reason
	*/
CREATE PROCEDURE [dbo].[GetWarehouseByKey_V2]  --GetWarehouseByKey_V2 488
(
	@UserKey		INT=488,
	@JsonString		VARCHAR(MAX)='',
	@IsDebug		BIT = 1,
	@Status			BIT	= 0 OUTPUT,
	@Reason			NVARCHAR(1000) = '' OUTPUT
)
AS

BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF
	SET ARITHABORT ON;

	IF(ISNULL(@JsonString,'')='')
	BEGIN
		SET @Status=0;
		SET @Reason='Parameter not found';
		RETURN;
	END

	SET @Status=1;
	SET @Reason='Success';
	DECLARE @WarehouseKey INT =	0
	SELECT @WarehouseKey = WarehouseKey
	FROM OPENJSON(@JsonString, '$')
	WITH(	
			WarehouseKey			INT			'$.WarehouseKey'
		)

    SELECT WarehouseKey,WarehouseID,AddrKey,StatusKey,CompanyKey 
		FROM Warehouse WITH(NOLOCK)
	WHERE (WarehouseKey=@WarehouseKey)
	
   FOR JSON PATH, WITHOUT_ARRAY_WRAPPER

END