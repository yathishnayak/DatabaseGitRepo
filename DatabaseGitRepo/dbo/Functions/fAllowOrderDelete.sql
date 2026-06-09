CREATE function dbo.fAllowOrderDelete
(
	@OrderKey	int
)
returns bit
as
Begin

	DECLARE @CNT INT = 0, @RouteCnt int = 0, @returnVal bit =0

	SELECT @CNT = COUNT(1) FROM OrderHeader H
		INNER JOIN OrderDetail D ON H.OrderKey = D.OrderKey
		LEft join OrderDetailStatus S on D.Status = S.Status and StatusType = 'dispatch'
		WHERE  H.OrderKey = @OrderKey AND H.Status in (1, 12)

	SELECT @RouteCnt = COUNT(1) FROM OrderHeader H
		INNER JOIN OrderDetail D ON H.OrderKey = D.OrderKey
		INNER JOIN Routes RT ON D.OrderDetailKey = RT.OrderDetailKey
		LEft join OrderDetailStatus S on D.Status = S.Status and StatusType = 'dispatch'
		WHERE  H.OrderKey = @OrderKey AND  RT.Status <> 1

	if(isnull(@CNT,0) > 0 and isnull(@RouteCnt,0) = 0)
	begin
		set @returnVal = 1
	end
	return @returnVal
end
