/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"OrderDetailKey" : 47701, "ContainerNo" : "CAIU8891465"}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [VerifyDuplicateContainer_V3] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[VerifyDuplicateContainer_V3]
(
	@UserKey		INT = 0,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS
BEGIN

	IF (ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
	BEGIN
		SET		@Status = 0
		SET		@Reason = 'Parameters not found'
		RETURN
	END	

	DECLARE
		@OrderDetailKey INT,
		@ContainerNo	VARCHAR(20)
	SELECT
		@OrderDetailKey 		=		OrderDetailKey ,
		@ContainerNo			=		ContainerNo	
	FROM OPENJSON(@JSONString)
	WITH
	(
		OrderDetailKey		INT				'$.OrderDetailKey' ,
		ContainerNo			VARCHAR(20)		'$.ContainerNo'	
	)

	DECLARE @cnt int = 0
	SELECT @cnt = Count(1)  
	FROM OrderDetail OD WITH(NOLOCK)
	WHERE ContainerNo = @ContainerNo
	AND ( ISNULL(@OrderDetailKey,0) = 0 OR OD.OrderDetailKey <> @OrderDetailKey )
		
	-- Set @IsExists = CASE WHEN ISNULL(@cnt,0) = 0 THEN 0 ELSE 1 END
	IF ISNULL(@cnt, 0) = 0
	BEGIN
		SET @Status = 0
		SET @Reason = 'Container number is unique'
	END
	ELSE
	BEGIN
		SET @Status = 1
		SET @Reason = 'Duplicate container number exists'
	END
END