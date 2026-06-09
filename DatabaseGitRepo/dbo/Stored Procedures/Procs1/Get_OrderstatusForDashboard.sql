CREATE PROCEDURE [dbo].[Get_OrderstatusForDashboard]
/*
Order Screen Dashboard Count
*/
	@CustomerKey		INT=0,
	@OrderDateFrom		DATE='2021-01-01',
	@OrderDateTo		DATE='2099-01-01',
	@CSRKey				INT = 0,
	@MarketLocationKey	INT = 0
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	--*******************Status wise order Count***********
	
	SELECT		Osh.[Description],
				OSH.[Status] AS StatusKey,
				COUNT(DISTINCT OrderKey) AS OrderCount,
				'I' as Level
	FROM		dbo.OrderStatus OSH
	LEFT JOIN	(SELECT		OrderKey ,[Status]
				FROM		dbo.OrderHeader --ON OSH.[Status]= OH.[Status]
				WHERE		( @OrderDateFrom	IS NULL OR OrderDate IS NULL OR OrderDate>=@OrderDateFrom)
							AND ( @OrderDateTo		IS NULL OR OrderDate IS NULL OR OrderDate<=@OrderDateTo)
							AND ( ISNULL(@CustomerKey,0)=0 OR CustKey IS NULL OR CustKey= @CustomerKey)
							AND ( ISNULL(@MarketLocationKey,0)=0 OR MarketLocationKey= @MarketLocationKey)
							AND ( ISNULL(@CSRKey,0)=0 OR CsrKey IS NULL OR CsrKey= @CSRKey )	
				)OH ON OH.[Status]=OSH.[Status] 
	WHERE		OSH.[IsActive] = 1
	GROUP BY	Osh.[Description], OSH.[Status]

	UNION ALL
	--********************Get All Orders Count****************
	SELECT		'Total Orders', 0 , COUNT(DISTINCT Orderkey), 'S'  
	FROM		dbo.OrderHeader
	WHERE		( @OrderDateFrom    IS NULL OR OrderDate IS NULL OR OrderDate>=@OrderDateFrom)
				AND ( @OrderDateTo		IS NULL OR OrderDate IS NULL OR OrderDate<=@OrderDateTo)
				AND ( ISNULL(@CustomerKey,0)=0 OR CustKey= @CustomerKey)
				AND ( ISNULL(@MarketLocationKey,0)=0 OR MarketLocationKey= @MarketLocationKey)
				AND ( ISNULL(@CSRKey,0)=0 OR CsrKey IS NULL OR CsrKey= @CSRKey )
END
