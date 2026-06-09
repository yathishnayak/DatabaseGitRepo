CREATE PROCEDURE [dbo].[Get_CustomerRateType]

AS

BEGIN
	SELECT RateTypeKey,RateType FROM CustomerRateType
	WHERE IsActive=1 AND IsDeleted=0
	FOR JSON PATH
END
