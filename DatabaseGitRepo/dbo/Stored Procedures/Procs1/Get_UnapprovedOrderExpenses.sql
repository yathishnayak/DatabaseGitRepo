CREATE proc [dbo].[Get_UnapprovedOrderExpenses] -- [Get_UnapprovedOrderExpenses] 58600, '212287:212288'
(
	@OrderDetailKey		int,
	@RouteKeyStr		varchar(200) -- Colon Seperated RouteKeys
)
as
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF
	SELECT * INTO #Routes FROM dbo.Fn_SplitParamCol(@RouteKeyStr)

	select OE.OrderExpenseKey, OE.RouteKey, L.LegID, OE.Itemkey, I.ItemID, I.Description, OE.Qty, OE.UnitCost, RT.IsRateVerified,  
	OH.CustKey,ISNULL(A.CityKey,LD.CityKey) CityKey,CustName,ISNULL(A.City,LD.City) CityName,
		OD.OrderDetailKey,  isnull(OE.Qty,0) *  ISNULL( OE.UnitCost,0) as ExtAmt, CAST(ISNULL(RT.IsChargesApproved,0) AS BIT) AS IsChargesApproved,
		ISNULL(ItemTypeMappingKey,0) ItemTypeMappingKey,
		CASE WHEN CIR.UnitPrice<>0 THEN CAST(1 AS BIT) ELSE CAST(0 AS bit) END AS IsCustPriceExist,
		I.PriceBasisKey, PB.Description as PriceBasisDescription, OE.DateFrom, OE.DateTo
	FROM OrderExpense OE
	INNER JOIN Routes RT on OE.RouteKey = RT.RouteKey
	INNER JOIN OrderDetail OD on RT.OrderDetailKey = OD.OrderDetailKey
	INNER JOIN OrderHeader OH ON (OH.OrderKey=OD.OrderKey)
	INNER JOIN Customer CUST ON CUST.CustKey=OH.CustKey
	INNER JOIN #Routes TR on RT.RouteKey = TR.Value
	INNER JOIN Item I on OE.Itemkey = I.ItemKey
	inner join ItemPriceBasis PB on I.PriceBasisKey = PB.PriceBasisKey
	INNER JOIN ItemType T on I.ItemTypeKey = T.ItemTypeKey
	LEFT join Leg L on RT.LegKey = L.LegKey
	LEFT JOIN ADDRESS A ON OH.DestinationAddrKey=A.AddrKey
	LEFT JOIN LocationData LD ON A.ZipCode=LD.ZipCode AND A.City=LD.City AND LD.State=A.State AND A.Country=LD.Country
	LEFT JOIN (
	select   DISTINCT AA.CustomerKey, AA.CityKey, AA.Itemkey, AA.EffectiveDate, AA.UnitPrice from CustomerItemRate  AA
	INNER join (SELECT Customerkey,citykey, itemkey,MAX(effectivedate) effectivedate,max(LastUpdateDate) AS LastUpdateddate from CustomerItemRate 
	Group by Customerkey,citykey, itemkey) B ON AA.CustomerKey=B.CustomerKey AND AA.CityKey=B.CityKey AND AA.Itemkey=B.Itemkey AND AA.LastUpdateDate=B.LastUpdateddate AND AA.EffectiveDate=B.EffectiveDate
	
	)CIR ON CIR.CustomerKey=OH.CustKey AND CIR.CityKey=ISNULL(A.CityKey,LD.CityKey) AND CIR.Itemkey=I.ItemTypeMappingKey
	--LEFT JOIN (
	--select  CustomerKey, CityKey, Itemkey, EffectiveDate, UnitPrice 
	--from (
	--select CustomerKey, CityKey, Itemkey, EffectiveDate, UnitPrice, LastUpdateDate, 
	--ROW_NUMBER() over (partition by  CustomerKey, CityKey, Itemkey, EffectiveDate  order by  CustomerKey, CityKey, Itemkey, EffectiveDate, LastUpdateDate desc ) as RowNum
	--from CustomerItemRate
	--where UnitPrice <> 0 and isnull(CustomerKey ,0) >0
	--)A WHERE RowNum =1 )CIR ON CIR.CustomerKey=OH.CustKey AND CIR.CityKey=ISNULL(A.CityKey,LD.CityKey) AND CIR.Itemkey=I.ItemTypeMappingKey
	where OD.OrderDetailKey = @OrderDetailKey and T.ItemType in('Expense','Expense + Service') --and ContainerStatusKey = 5 -- and OD.Status = 6
END
