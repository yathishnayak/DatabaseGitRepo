/**
DECLARE @output BIT=0
exec Update_ApproveRouteRate '212302:212303', 58607, 512, @output OUTPUT
SELECT @output
**/

CREATE PROCEDURE [dbo].[Update_ApproveRouteRate]  -- Update_ApproveRouteRate '212302,212303', 58607, 512,
@RouteKeyStr   VARCHAR(500),
@OrderDetailKey	INT,
@UserKey	INT,
@OutPut		BIT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;
	SELECT * INTO #Routes FROM dbo.Fn_SplitParamCol(@RouteKeyStr)
	SET @OutPut=0;

	select * from #Routes

	----**************** Temp data to remove duplicate *****------------------
	select DISTINCT I.ItemTypeMappingKey,OE.RouteKey,ISNULL(CIR.UnitPrice,0) AS UnitPrice,isnull(OE.Qty,0) AS Qty,ISNULL(CIR.UnitPrice,0) NewUnitPrice,GETDATE() CreatedDate,
	@UserKey CreatedUser,I.ItemKey, OD.OrderDetailKey INTO #TempData
	from OrderExpense OE
	inner join Routes RT on OE.RouteKey = RT.RouteKey
	inner join OrderDetail OD on RT.OrderDetailKey = OD.OrderDetailKey
	INNER JOIN OrderHeader OH ON (OH.OrderKey=OD.OrderKey)
	inner join #Routes TR on RT.RouteKey = TR.Value
	inner join Item I on OE.Itemkey = I.ItemKey
	inner join ItemType T on I.ItemTypeKey = T.ItemTypeKey
	LEFT join Leg L on RT.LegKey = L.LegKey
	LEFT JOIN ADDRESS A ON OH.DestinationAddrKey=A.AddrKey
	LEFT JOIN LocationData LD ON A.ZipCode=LD.ZipCode AND A.City=LD.City  AND LD.State=A.State AND A.Country=LD.Country
	LEFT JOIN (
	select   DISTINCT AA.CustomerKey, AA.CityKey, AA.Itemkey, AA.EffectiveDate, AA.UnitPrice from CustomerItemRate  AA
	INNER join (SELECT Customerkey,citykey, itemkey,MAX(effectivedate) effectivedate,max(LastUpdateDate) AS LastUpdateddate from CustomerItemRate 
	Group by Customerkey,citykey, itemkey) B ON AA.CustomerKey=B.CustomerKey AND AA.CityKey=B.CityKey AND AA.Itemkey=B.Itemkey AND AA.LastUpdateDate=B.LastUpdateddate AND AA.EffectiveDate=B.EffectiveDate
	
	)CIR ON CIR.CustomerKey=OH.CustKey AND CIR.CityKey=ISNULL(A.CityKey,LD.CityKey) AND CIR.Itemkey=I.ItemTypeMappingKey
	
	where OD.OrderDetailKey = @OrderDetailKey and T.ItemType in ( 'Expense','Expense + Service') AND ISNULL(I.ItemTypeMappingKey,0)>0 --AND I.ItemTypeMappingKey NOT IN ( SELECT ItemKey FROM OrderExpense WHERE RouteKey IN (SELECT RouteKey FROM #Routes))
	--- *************************** END  *****************************------

	--Select * FROM #TempData WHERE RouteKey in(SELECt RouteKey FROM OrderExpense) 
	--AND ItemTypeMappingKey in(SELECt Itemkey FROM OrderExpense) 
	--Select * FROM #TempData

	--DELETE FROM #TempData 
	--WHERE RouteKey in(SELECt RouteKey FROM OrderExpense where RouteKey in (Select Value From #Routes)) 
	--AND ItemTypeMappingKey in(SELECt Itemkey FROM OrderExpense where RouteKey in (Select Value From #Routes))
	
	Delete Tdata FROM #TempData Tdata
	inner join OrderExpense OE ON (OE.Itemkey=Tdata.ItemTypeMappingKey AND Tdata.RouteKey=OE.RouteKey)
	where OE.Itemkey in (SELECT ItemTypeMappingKey FROM #TempData)

	--Select * FROM #TempData

	INSERT INTO OrderExpense
	(Itemkey,RouteKey,UnitCost,Qty,NewUnitCost,CreateDate,CreateUserKey, ExpenseItemKey, OrderDetailKey)
	SELECT ItemTypeMappingKey,RouteKey,UnitPrice,Qty,NewUnitPrice,CreatedDate,CreatedUser,ItemKey , OrderDetailKey
	FROM #TempData
	--select I.ItemTypeMappingKey,OE.RouteKey,ISNULL(CIR.UnitPrice,0),isnull(OE.Qty,0),ISNULL(CIR.UnitPrice,0),GETDATE(),@UserKey,I.ItemKey
	--from OrderExpense OE
	--inner join Routes RT on OE.RouteKey = RT.RouteKey
	--inner join OrderDetail OD on RT.OrderDetailKey = OD.OrderDetailKey
	--INNER JOIN OrderHeader OH ON (OH.OrderKey=OD.OrderKey)
	--inner join #Routes TR on RT.RouteKey = TR.Value
	--inner join Item I on OE.Itemkey = I.ItemKey
	--inner join ItemType T on I.ItemTypeKey = T.ItemTypeKey
	--LEFT join Leg L on RT.LegKey = L.LegKey
	--LEFT JOIN ADDRESS A ON RT.DestinationAddrKey=A.AddrKey
	--LEFT JOIN LocationData LD ON A.ZipCode=LD.ZipCode AND A.City=LD.City  AND LD.State=A.State AND A.Country=LD.Country
	--LEFT JOIN (
	--select  CustomerKey, CityKey, Itemkey, EffectiveDate, UnitPrice 
	--from (
	--select CustomerKey, CityKey, Itemkey, EffectiveDate, UnitPrice, LastUpdateDate, 
	--ROW_NUMBER() over (partition by  CustomerKey, CityKey, Itemkey, EffectiveDate  order by  CustomerKey, CityKey, Itemkey, EffectiveDate, LastUpdateDate desc ) as RowNum
	--from CustomerItemRate
	--where UnitPrice <> 0 and isnull(CustomerKey ,0) >0
	--)A WHERE RowNum =1 )CIR ON CIR.CustomerKey=OH.CustKey AND CIR.CityKey=ISNULL(A.CityKey,LD.CityKey) AND CIR.Itemkey=I.ItemTypeMappingKey
	--where OD.OrderDetailKey = @OrderDetailKey and T.ItemType = 'Expense' AND ISNULL(I.ItemTypeMappingKey,0)>0

	UPDATE dbo.[Routes] 
	SET IsChargesApproved= 1, 
		ChargesApprovedDate = GETDATE(),
		ChargesApprovedBy= @UserKey
	WHERE OrderDetailKey=@OrderDetailKey--RouteKey = @Routekey;

	IF @@ROWCOUNT>0
	BEGIN
		SET @OutPut=1;
	END;	
END
