
create Proc [dbo].[Get_BrokerRefByOrderNo]
(
	@CustKey	int,
	@OrderNo		varchar(50)
)
as
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	SELECT BrokerRefNo
	FROM OrderHeader OH
	WHERE CustKey = @CustKey AND OrderNo = @OrderNo
END
