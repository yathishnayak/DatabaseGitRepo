CREATE PROCEDURE [dbo].[GetCustomerSegment] 
AS
BEGIN
	SELECT CustomerSegmentKey,CustomerSegment,BasePercent, U.UserName AS Createdby, U2.UserName AS Updatedby,
	IsNacCustomer,CS.MarketKey,FSFPercent,EffectiveDate, EffectiveFrom
	FROM CustomerSegments CS
	LEFT JOIN [User] U ON CS.CreatedUser = U.UserKey
	LEFT JOIN [User] U2 ON CS.UpdateUser = U2.UserKey
	WHERE isnull(CS.IsDeleted,0)=0 
	FOR JSON PATH
END
