
/*
declare @WarehouseKey	INT = 0,
	@WarehouseID		VARCHAR(100) = 'Warehouse',
	@OutPut     BIT = 0  ,
	@Reason     VARCHAR(50) 
exec	Warehouse_ValidateIdName @WarehouseKey,  @WarehouseID , @OutPut output ,@Reason output
select @OutPut,@Reason

*/

CREATE PROCEDURE [dbo].[Warehouse_ValidateIdName]
(
	@WarehouseKey  INT = 0,
	@WarehouseID   VARCHAR(100) = '',
	@OutPut        BIT = 0 OUTPUT,
	@Reason        VARCHAR(100) OUTPUT
)
AS
 BEGIN
  SET NOCOUNT ON;
  SET FMTONLY OFF;

  DECLARE @CNTId INT = 0

  SELECT @CNTId = COUNT(1) FROM Warehouse W WHERE W.WarehouseKey <> @WarehouseKey AND W.WarehouseID = @WarehouseID

  IF ISNULL(@CNTId,0) = 0
	BEGIN
		SET @OutPut = 1
		SET @Reason = 'Success'
	END
  ELSE
	BEGIN
		IF ISNULL(@CNTId,0) > 0
			BEGIN
				SET @OutPut = 0
				SET @Reason = 'Warehouse Id Already Exist'
			END
	END
 END

 --SELECT * FROM Warehouse
