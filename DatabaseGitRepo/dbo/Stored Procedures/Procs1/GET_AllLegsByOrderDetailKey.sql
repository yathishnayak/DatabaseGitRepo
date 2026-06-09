CREATE PROCEDURE [dbo].[GET_AllLegsByOrderDetailKey] 
(
	@OrderDetailKey		int
)
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	declare @OrderType smallint

	select @OrderType = ISNULL(OD.OrderTypeKey,OH.OrderTypeKey ) 
	from OrderHeader OH
	inner join OrderDetail OD on OH.OrderKey = OD.OrderKey
	where OrderDetailKey = @OrderDetailKey


	SELECT MIN(C.LegKey) AS LegKey ,C.LegID AS [Description]
	FROM [LegType] A 
		  INNER JOIN [Leg] C		ON C.LegtypeKey=A.LegtypeKey
		  INNER JOIN ordertype X	ON X.OrderTypeKey=A.OrderTypeKey
		  INNER JOIN [Status] S		ON S.StatusKey=A.StatusKey
	WHERE S.StatusName='Active' and X.OrderTypeKey = @OrderType
	GROUP BY C.LegID	
END
