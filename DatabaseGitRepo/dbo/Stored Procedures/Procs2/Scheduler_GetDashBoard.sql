

create PROCEDURE [dbo].[Scheduler_GetDashBoard] --  Scheduler_GetDashBoard @CSRKey=7
@PickupDateFrom		DATE='01/01/2020',
@PickupDateTo		DATE='01/12/2099',
@DeleveryDateFrom	DATE='01/01/2020',
@DeleveryDateTo		DATE='01/12/2099',
@CSRKey				INT=0
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;
	
	SELECT
		ODH.[Description],
		ODH.[Status] AS StatusKey,
		COUNT(DISTINCT OrderDetailKey) AS OrderCount,
		'I' as Level
	FROM
		dbo.OrderDetailStatus ODH
		LEFT JOIN 
		(	
			SELECT OD.OrderDetailKey ,OD.[Status]
			FROM dbo.OrderDetail OD WITH (NOLOCK)
				INNER JOIN dbo.OrderHeader OH WITH (NOLOCK)	ON OH.OrderKey=OD.OrderKey
				INNER JOIN dbo.OrderStatus OS WITH (NOLOCK) ON OS.[Status]=OH.[Status]		
				LEFT JOIN dbo.CSR CR WITH (NOLOCK)			ON CR.CsrKey=OH.CsrKey
				LEFT JOIN dbo.[Priority] PT WITH (NOLOCK)	ON PT.PriorityKey=OH.PriorityKey
				LEft join dbo.routes RT WITH (NOLOCK)		ON OD.CurrentRouteKey = RT.RouteKey 
				--LEFT JOIN  
				--		(	SELECT MAX(PickupDateFrom) AS PickupDate ,MAX(DeliveryDateFrom) AS DeliveryDate ,OrderDetailKey
				--			FROM dbo.Routes 
				--			GROUP BY OrderDetailKey
				--		) RT ON RT.OrderDetailKey=OD.OrderDetailKey
			WHERE   
				    ( @PickupDateFrom	IS NULL OR RT.PickupDateFrom IS NULL OR RT.PickupDateFrom>=@PickupDateFrom)
				AND ( @PickupDateTo		IS NULL OR RT.PickupDateFrom IS NULL OR RT.PickupDateFrom<=@PickupDateTo)
				AND ( @DeleveryDateFrom	IS NULL OR RT.DeliveryDateFrom IS NULL OR RT.DeliveryDateFrom>=@DeleveryDateFrom)
				AND ( @DeleveryDateTo	IS NULL OR RT.DeliveryDateFrom IS NULL OR RT.DeliveryDateFrom<=@DeleveryDateTo)			
				AND ( @CSRKey			IS NULL OR @CSRKey= 0 OR CR.CsrKey= @CSRKey)
			
			)OH ON OH.[Status]=ODH.[Status] 
	WHERE ODH.[IsActive] = 1
	GROUP BY ODH.[Description], ODH.[Status]
	UNION ALL
	--********************Get All Orders Count****************
	SELECT 'Total Containers', 0 , COUNT(DISTINCT OrderDetailKey), 'S'  	
	FROM
		dbo.OrderDetailStatus ODH
		LEFT JOIN 
		(	
			SELECT OD.OrderDetailKey ,OD.[Status]
			FROM dbo.OrderDetail OD  WITH (NOLOCK)
				INNER JOIN dbo.OrderHeader OH WITH (NOLOCK)	ON OH.OrderKey=OD.OrderKey
				INNER JOIN dbo.OrderStatus OS WITH (NOLOCK) ON OS.[Status]=OH.[Status]
				LEFT JOIN dbo.CSR CR WITH (NOLOCK)			ON CR.CsrKey=OH.CsrKey
				LEFT JOIN dbo.[Priority] PT WITH (NOLOCK)	ON PT.PriorityKey=OH.PriorityKey	
				LEFT JOIN DBO.ROUTES RT  WITH (NOLOCK) ON OD.CurrentRouteKey = RT.RouteKey
				--LEFT JOIN  
				--		(	SELECT MAX(PickupDateFrom) AS PickupDate ,MAX(DeliveryDateFrom) AS DeliveryDate ,OrderDetailKey
				--			FROM dbo.Routes 
				--			GROUP BY OrderDetailKey
				--		) RT ON RT.OrderDetailKey=OD.OrderDetailKey
			WHERE   ( @PickupDateFrom   IS NULL OR RT.PickupDateFrom   IS NULL OR RT.PickupDateFrom>=@PickupDateFrom)
				AND ( @PickupDateTo		IS NULL OR RT.PickupDateFrom   IS NULL OR RT.PickupDateFrom<=@PickupDateTo)
				AND ( @DeleveryDateFrom	IS NULL OR RT.DeliveryDateFrom IS NULL OR RT.DeliveryDateFrom>=@DeleveryDateFrom)
				AND ( @DeleveryDateTo	IS NULL OR RT.DeliveryDateFrom IS NULL OR RT.DeliveryDateFrom<=@DeleveryDateTo)			
				AND ( @CSRKey			IS NULL OR @CSRKey= 0 OR CR.CsrKey= @CSRKey)			
			)OH ON OH.[Status]=ODH.[Status] 
	WHERE ODH.[IsActive] = 1		

END
