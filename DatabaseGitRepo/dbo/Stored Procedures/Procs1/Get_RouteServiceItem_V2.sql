/** 
Declare 
	@UserKey		INT,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING		NVARCHAR(Max) = '{"RouteKey" : 366331}'
	EXEC [Get_RouteServiceItem_V2] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
**/
CREATE PROCEDURE [dbo].[Get_RouteServiceItem_V2]		-- [Get_RouteServiceItem] 366331
-- @RouteKey INT=0
(
	@UserKey		INT = 1144,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0 
)
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;
	SET NOCOUNT ON;
	SET FMTONLY OFF;

		IF ISNULL(@JSONString, '') = ''
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'Parameters not found'
			RETURN
		END	
		
	IF (@IsDebug = 1)
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'In Debug Mode'
		END	

	DECLARE @RouteKey INT=382

	SELECT 
	@RouteKey = RouteKey
	FROM OPENJSON(@JSONString)
	WITH
	(
	RouteKey		INT		'$.RouteKey'
	)

	SELECT OE.Itemkey,RouteKey,I.ItemID,I.[Description] AS ItemDescription,OE.Qty,DateFrom,DateTo
	FROM dbo.OrderExpense OE WITH (NOLOCK)
		INNER JOIN dbo.Item I WITH (NOLOCK) ON I.ItemKey=OE.Itemkey
		INNER JOIN dbo.ItemType IT WITH (NOLOCK)  ON IT.ItemTypeKey=I.ItemTypeKey
	WHERE RouteKey= @RouteKey AND IT.ItemType in ('Service','Expense + Service')
	FOR JSON PATH;

	SET @Status = 1
	SET @Reason = 'Success'
END