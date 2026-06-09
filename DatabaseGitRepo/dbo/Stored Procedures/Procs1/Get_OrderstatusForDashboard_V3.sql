/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"CustomerKey" : 0, "OrderDateFrom" : "", "OrderDateTo" : "", "CsrKey" : 0, "MarketLocationKey" : 0}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [Get_OrderstatusForDashboard_V3] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[Get_OrderstatusForDashboard_V3]
(
	@UserKey		INT = 1144,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
/*
Order Screen Dashboard Count
*/

AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	IF (ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
	BEGIN
		SET		@Status = 0
		SET		@Reason = 'Parameters not found'
		RETURN
	END	

	DECLARE
		@CustomerKey		INT=0,
		@OrderDateFrom		DATE='2021-01-01',
		@OrderDateTo		DATE='2099-01-01',
		@CSRKey				INT = 0,
		@MarketLocationKey	INT = 0

	SELECT
	@CustomerKey					=		CustomerKey		,
	@OrderDateFrom				=		OrderDateFrom	,	
	@OrderDateTo					=		OrderDateTo		,
	@CSRKey						=		CSRKey			,	
	@MarketLocationKey			=		MarketLocationKey	
	FROM OPENJSON(@JSONString)
	WITH
	(
	CustomerKey					INT			'$.CustomerKey',		
	OrderDateFrom				DATE		'$.OrderDateFrom',		
	OrderDateTo					DATE		'$.OrderDateTo',	
	CSRKey						INT			'$.CsrKey',				
	MarketLocationKey			INT			'$.MarketLocationKey'
	)

	--*******************Status wise order Count***********
	
	SELECT		Osh.[Description],
				OSH.[Status] AS StatusKey,
				COUNT(DISTINCT OrderKey) AS OrderCount,
				'I' as Level
	FROM		dbo.OrderStatus OSH with(nolock)
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
	FROM		dbo.OrderHeader with(nolock)
	WHERE		( @OrderDateFrom    IS NULL OR OrderDate IS NULL OR OrderDate>=@OrderDateFrom)
				AND ( @OrderDateTo		IS NULL OR OrderDate IS NULL OR OrderDate<=@OrderDateTo)
				AND ( ISNULL(@CustomerKey,0)=0 OR CustKey= @CustomerKey)
				AND ( ISNULL(@MarketLocationKey,0)=0 OR MarketLocationKey= @MarketLocationKey)
				AND ( ISNULL(@CSRKey,0)=0 OR CsrKey IS NULL OR CsrKey= @CSRKey )
	FOR JSON PATH

	SET @Status = 1
	SET @Reason = 'Success'
END
