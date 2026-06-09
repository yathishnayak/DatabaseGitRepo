CREATE PROCEDURE [dbo].[Select_CustomerOrderCount]
@CustKey INT
AS
BEGIN
	SELECT cnt 
	FROM 
		(	SELECT Custkey, COUNT(1) AS cnt 
			FROM dbo.orderheader  
			GROUP BY custkey 
		) AS customer
	WHERE custkey = (select custkey from dbo.customer where custkey=@CustKey)
END
