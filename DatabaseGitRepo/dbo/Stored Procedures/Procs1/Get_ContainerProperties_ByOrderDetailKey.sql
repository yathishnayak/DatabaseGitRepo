/*
DECLARE @UserKey INT = 951, @JSONString NVARCHAR(MAX),@Status BIT = 0,@Reason VARCHAR(1000), @IsDebug BIT = 1 
SET @JSONString ='{"OrderDetailKey":0}'
 
EXEC [Get_ContainerProperties_ByOrderDetailKey] @UserKey, @JSONString, @Status OUTPUT, @Reason OUTPUT, @IsDebug
SELECT @Status Status, @Reason Reason 
*/

CREATE PROCEDURE [dbo].[Get_ContainerProperties_ByOrderDetailKey]
(
	@UserKey	INT,
	@JSONString	NVARCHAR(MAX) = '',
	@Status		BIT OUTPUT,
	@Reason		NVARCHAR(MAX) OUTPUT,
	@IsDebug	BIT = 0
)
AS

BEGIN
	SET NOCOUNT ON;

	DECLARE @OrderDetailKey	INT;
 
	-- Initialize default output values
	SET @Reason  = 'Something went wrong, Contact system administrator';
	SET @Status = 0;

	IF(ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
	BEGIN
		SET @OrderDetailKey = 0
	END
	ELSE
	BEGIN
		SELECT @OrderDetailKey =  OrderDetailKey
		FROM OpenJSON(@JSONString, '$')
		WITH (
			OrderDetailKey			INT				'$.OrderDetailKey'
		)
	END
 
	-- ================================
	-- Main Business Logic goes here
	-- ================================

	DECLARE @JSONResult NVARCHAR(MAX) = ''

	SET @JSONResult = (
		SELECT ContainerProperties=ISNULL(STUFF((
            SELECT ',' + TypeID
            FROM ContainerTypesLink CTLI
			INNER JOIN ContainerTypes CTI ON CTI.ContainerTypeKey=CTLI.ContainerTypeKey
			WHERE CTLI.OrderDetailKey = @OrderDetailKey
            FOR XML PATH('')
            ), 1, 1, ''),'')
            
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
	);
 
	SELECT @JSONResult AS JSONResult

	SET @Status = 1;
	SET @Reason = 'Success';

END
