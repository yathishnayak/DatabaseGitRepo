CREATE PROCEDURE DeleteWarehouse  --DeleteWarehouse 0
(
	@WarehouseKey		INT,
	@OutPut				BIT = 0 OUTPUT,
	@Reason				VARCHAR(100) = '' OUTPUT
)
AS

BEGIN
	DECLARE @CNT INT=0
	SET @CNT=(SELECT COUNT(WarehouseID) FROM Warehouse WHERE WarehouseKey=@WarehouseKey)
	IF(@CNT=0)
		BEGIN
			SET @Reason='No record found for the given warehouse data';
			SET @OutPut=0;
			return;
		END
	ELSE
		BEGIN
			DELETE FROM Warehouse
			WHERE (WarehouseKey=@WarehouseKey)
			SET @Reason='Warehouse Deleted Successfully';
			SET @OutPut=1;
			return;
		END
END