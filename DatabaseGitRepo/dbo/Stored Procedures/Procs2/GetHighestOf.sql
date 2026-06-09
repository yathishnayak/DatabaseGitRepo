CREATE PROCEDURE [dbo].[GetHighestOf]
AS
BEGIN
	SELECT DISTINCT TruckTypeKey DriverTypeKey, TruckType DriverTypeName FROM TruckType WHERE TruckType IS NOT NULL FOR JSON PATH
END
