CREATE PROCEDURE [dbo].[Get_MasterCustomerList]
@MarketLocationKey	INT=0
AS
BEGIN
	SELECT CustKey,CustID,CustName FROM Customer
	WHERE IsActive=1 AND IsDelete=0 AND IsMaster=1
	FOR JSON PATH;
END
