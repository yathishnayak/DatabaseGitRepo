CREATE PROCEDURE [dbo].[GetDriverNonDriverCostItemGroup]
AS
BEGIN
	SELECT DriverNonDriverCostKey,DriverNonDriverCostId,DriverNonDriverCostDesc 
	FROM DriverNonDriverCostItems WHERE ISActive=1 AND IsDeleted=0
	FOR JSON PATH
END
