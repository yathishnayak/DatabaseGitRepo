

CREATE PROCEDURE [dbo].[Get_CustomerOrderCount]
@CustKey INT= 0
AS
BEGIN	
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	DECLARE @MaxCount INT;

	--SELECT COUNT(1) AS cnt , getdate() as orderdate
	--FROM 
	--(select count(1) from dbo.Orderheader 
	--WHERE CustKey= @CustKey

	SELECT COUNT(1) AS cnt , getdate() as orderdate
	FROM 
	(select CustKey, OrderNo from OrderHeader where custkey = @CustKey 
	union all
	select CustKey,OrderNo  cnt from OrderHeader_Deleted where CustKey = @CustKey
	) A WHERE CustKey= @CustKey


--IF EXISTS(	SELECT cnt 
--			FROM
--				(	SELECT Custkey, COUNT(1) AS cnt 
--					FROM dbo.Orderheader 
--					GROUP BY custkey 
--				) AS customer
--			WHERE custkey = (	SELECT custkey 
--								FROM dbo.customer 
--								WHERE custkey=@CustKey
--							)
--		 )
--		SELECT cnt 
--		FROM 
--			(	SELECT Custkey, COUNT(1) AS cnt 
--				FROM dbo.Orderheader  
--				GROUP BY custkey 
--			) AS customer
--		WHERE custkey = (SELECT custkey FROM dbo.customer WHERE custkey=@CustKey); 

--		ELSE
--		SELECT 0 ;
END
