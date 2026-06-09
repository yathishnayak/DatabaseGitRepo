
CREATE PROCEDURE [dbo].[Get_ContainerStatusDashBoard_Wrk] --  Get_ContainerStatusDashBoard @LoggedUserKey=488
@PickupDateFrom		DATE='01/01/2020',
@PickupDateTo		DATE='01/12/2099',
@DeleveryDateFrom	DATE='01/01/2020',
@DeleveryDateTo		DATE='01/12/2099',
@CSRKey				INT=0,
@CSRManagerKey		int = 0,
@SalesPersonKey		int = 0,
@LoggedUserKey		int = 0,
@isShowAll			bit = 0
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	--set @isShowAll = 1


	declare  @UserCount int = 0 

	select @UserCount = count(1)
	from (
	select LinkedUserKey from CSR where LinkedUserKey is not null
	union all
	select LinkedUserKey from SalesPerson where LinkedUserKey is not null
	) A where LinkedUserKey = @LoggedUserKey 

	select @isShowAll = case when isnull(@UserCount ,0) = 0 then 1 else 0 end
	
	SELECT OD.OrderDetailKey ,OD.[Status],ISNULL(OH.CsrKey, CU.CSRKey) CsrKey, 
		isnull(ISNULL(OH.CSRManagerKey,CU.CSRManagerKey),CR.CsrKey) CSRManagerKey, 
		ISNULL( OH.SalesPersonKey, CU.SalesPersonKey) SalesPersonKey,
		CR.LinkedUserKey AS CSRUser, CM.LinkedUserKey AS CMUser, SP.LinkedUserKey AS SPUser
	into #Temp
	FROM dbo.OrderDetail OD WITH (NOLOCK)
		INNER JOIN dbo.OrderHeader OH WITH (NOLOCK)	ON OH.OrderKey=OD.OrderKey
		INNER JOIN dbo.OrderStatus OS WITH (NOLOCK) ON OS.[Status]=OH.[Status]	
		LEFT JOIN DBO.Customer CU				WITH (NOLOCK)	ON OH.CustKey = CU.CustKey
		LEFT JOIN dbo.CSR CR WITH (NOLOCK)			ON CR.CsrKey= ISNULL(OH.CsrKey, CU.CSRKey)
		LEFT JOIN dbo.[Priority] PT WITH (NOLOCK)	ON PT.PriorityKey=OH.PriorityKey
		LEft join dbo.routes RT WITH (NOLOCK)		ON OD.CurrentRouteKey = RT.RouteKey 
		LEft Join CSR CM WITH (NOLOCK) ON CM.CsrKey = isnull(ISNULL(OH.CSRManagerKey,CU.CSRManagerKey),CR.CsrKey)
		LEFT JOIN SalesPerson SP WITH (NOLOCK) ON SP.SalesPersonKey =  ISNULL( OH.SalesPersonKey, CU.SalesPersonKey)
	WHERE   
			( @PickupDateFrom	IS NULL OR RT.PickupDateFrom IS NULL OR RT.PickupDateFrom>=@PickupDateFrom)
		AND ( @PickupDateTo		IS NULL OR RT.PickupDateFrom IS NULL OR RT.PickupDateFrom<=@PickupDateTo)
		AND ( @DeleveryDateFrom	IS NULL OR RT.DeliveryDateFrom IS NULL OR RT.DeliveryDateFrom>=@DeleveryDateFrom)
		AND ( @DeleveryDateTo	IS NULL OR RT.DeliveryDateFrom IS NULL OR RT.DeliveryDateFrom<=@DeleveryDateTo)			
		AND ( @CSRKey			IS NULL OR @CSRKey= 0 OR CR.CsrKey= @CSRKey)
		AND (  ISNULL(@CSRKey,0) = 0 OR ISNULL(ISNULL(OH.CsrKey, CU.CSRKey), CR.CsrKey) =  @CSRKey )	
		AND (  ISNULL(@CSRManagerKey,0) = 0 OR isnull(ISNULL(OH.CSRManagerKey,CU.CSRManagerKey),CR.CsrKey) =@CSRManagerKey ) 
		AND (  ISNULL(@SalesPersonKey,0) = 0 OR ISNULL( OH.SalesPersonKey, CU.SalesPersonKey) = @SalesPersonKey ) 
		
	select A.*
	into #Temp2
	from #Temp A
	LEft join CSR M with (nolock) on A.CSRManagerKey = M.CsrKey
		where isnull(@isShowAll,0) = 1 OR (
			@LoggedUserKey = A.CSRUser OR @LoggedUserKey = M.LinkedUserKey OR @LoggedUserKey = A.SPUser
		)

	SELECT
		ODH.[Description],
		ODH.[Status] AS StatusKey,
		COUNT(DISTINCT OrderDetailKey) AS OrderCount,
		'I' as Level
	FROM
		dbo.OrderDetailStatus ODH WITH (NOLOCK)
		LEFT JOIN 
		(	
			select * from #Temp2
		)OH ON OH.[Status]=ODH.[Status] 
	WHERE ODH.[IsActive] = 1
	GROUP BY ODH.[Description], ODH.[Status]
	UNION ALL
	--********************Get All Orders Count****************
	SELECT 'Total Containers', 0 , COUNT(DISTINCT OrderDetailKey), 'S'  	
	FROM
		dbo.OrderDetailStatus ODH WITH (NOLOCK)
		LEFT JOIN 
		(	
			select * from #Temp2
		)OH ON OH.[Status]=ODH.[Status] 
	WHERE ODH.[IsActive] = 1		

	DROP TABLE #Temp
	DROP TABLE #Temp2		
END
