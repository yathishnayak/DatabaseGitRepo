CREATE PROCEDURE InsertUpdate_Warehouse
(
	@WarehouseKey		INT OUTPUT,
	@WarehouseID		VARCHAR(50),
	@AddrKey			INT,
	@StatusKey			SMALLINT,
	@CompanyKey			SMALLINT
)
AS

BEGIN
	IF @WarehouseKey=0
		BEGIN
			INSERT INTO Warehouse
				(WarehouseID, AddrKey, StatusKey, CompanyKey)
			SELECT @WarehouseID, @AddrKey, @StatusKey, @CompanyKey
			SET @WarehouseKey = SCOPE_IDENTITY()
		END
	ELSE
		BEGIN
			UPDATE Warehouse
				SET
					WarehouseID=@WarehouseID,
					AddrKey=@AddrKey,
					StatusKey=@StatusKey,
					CompanyKey=@CompanyKey
				WHERE WarehouseKey=@WarehouseKey
		END
END