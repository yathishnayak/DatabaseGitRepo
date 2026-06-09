-- Exec DeleteDrayBase 

CREATE PROC [dbo].[DeleteDrayBaseForTL]
(
@OrderDetailKey	Int = 0,
@IsDebug		bit = 0
)
AS
BEGIN
DECLARE @TL					bit = 0, 
		@TLExists			bit = 0,
		@LineHaulItemKey	int = 357

	SELECT CTL.OrderDetailKey,CTL.ContainerTypeKey,CT.TypeDescription
	INTO #TEMP
	FROM ContainerTypesLink CTL WITH (NOLOCK)
	inner JOIN ContainerTypes CT WITH (NOLOCK) on CTL.ContainerTypeKey = CT.ContainerTypeKey
	WHERE orderdetailkey = @OrderDetailKey

	SELECT @TL = COUNT(1) FROM #TEMP WHERE ContainerTypeKey = 11

	SELECT @TLExists = count(1) FROM OrderExpense OE WITH (NOLOCK) 
	inner join Item I  WITH (NOLOCK) on OE.Itemkey = I.ItemKey
	inner join Item M  WITH (nolock) on I.MasterItemKey = M.ItemKey
	WHERE OrderDetailKey = @OrderDetailKey AND  M.ITEMKEY = @LineHaulItemKey

if(@TL = 1 and @TLExists = 1)
	BEGIN
		DECLARE @DrayOrderExpenseKey int, @DrayBaseItemKey int = 18
		SELECT @DrayOrderExpenseKey = OrderExpenseKey from OrderExpense where OrderDetailKey = @OrderDetailKey and Itemkey = 18
		if((select count(1) from OrderExpense where OrderDetailKey = @OrderDetailKey and Itemkey = @DrayBaseItemKey) >0)
		BEGIN
			DELETE from OrderExpense where OrderExpenseKey = @DrayOrderExpenseKey
		END
	END
END
