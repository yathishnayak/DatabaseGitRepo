CREATE PROCEDURE GetWarehouse
AS

BEGIN
	SELECT WarehouseKey,WarehouseID,W.AddrKey,AddrName,Address1,Address2,City,State,ZipCode,Country,StatusKey,CompanyKey 
		FROM Warehouse W
		INNER JOIN Address A ON (A.AddrKey=W.AddrKey)
END