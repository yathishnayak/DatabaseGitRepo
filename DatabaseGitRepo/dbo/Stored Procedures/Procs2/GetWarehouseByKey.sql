CREATE PROCEDURE GetWarehouseByKey
(
	@WarehouseKey		INT
)
AS

BEGIN
	SELECT WarehouseKey,WarehouseID,AddrKey,StatusKey,CompanyKey 
		FROM Warehouse
	WHERE (WarehouseKey=@WarehouseKey)
END