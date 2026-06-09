/*
DECLARE @UserKey INT = 488, @JSONString NVARCHAR(MAX),@Status BIT = 0,@Reason VARCHAR(1000), @IsDebug BIT = 1 
SET @JSONString ='{"WarehouseKey":22}'
 
EXEC [DeleteWarehouse_V2] @UserKey, @JSONString, @Status OUTPUT, @Reason OUTPUT, @IsDebug
SELECT @Status Status, @Reason Reason 
*/

CREATE PROCEDURE [dbo].[DeleteWarehouse_V2]
(
	@UserKey		INT = 488,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE @WarehouseKey INT,
	        @CNT INT=0

			SELECT @WarehouseKey = WarehouseKey
			FROM OPENJSON(@JSONString)
			WITH (
				WarehouseKey INT '$.WarehouseKey'
			)


		 SET @CNT=(SELECT COUNT(WarehouseID) FROM Warehouse WITH (NOLOCK) WHERE WarehouseKey=@WarehouseKey)
	IF(@CNT=0)
		BEGIN
			SET @Reason='No record found for the given warehouse data';
			SET @Status=0;
			return;
		END
	ELSE
		BEGIN
			DELETE FROM Warehouse
			WHERE (WarehouseKey=@WarehouseKey)
			SET @Reason='Warehouse Deleted Successfully';
			SET @Status=1;
			return;
		END

END