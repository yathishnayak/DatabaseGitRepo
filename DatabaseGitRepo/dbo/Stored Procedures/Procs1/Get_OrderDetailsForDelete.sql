/*
DECLARE @UserKey INT = 1144, @JSONString NVARCHAR(MAX),@Status BIT = 0,@Reason VARCHAR(1000)
SET @JSONString ='{"SearchString":"AGSS260413"}'
 
EXEC [Get_OrderDetailsForDelete] @UserKey, @JSONString, @Status OUTPUT, @Reason OUTPUT
SELECT @Status Status, @Reason Reason 
*/

CREATE PROCEDURE [dbo].[Get_OrderDetailsForDelete]
(
	@UserKey		int,
	@JSONString		nvarchar(max),
	@Status			bit	= 0 output,
	@Reason			varchar(1000) = '' output
)
AS
SET NOCOUNT ON;
SET FMTONLY OFF;
BEGIN
	
	DECLARE @SearchString			varchar(20)
	Select @SearchString = SearchString
	from OPENJSON(@JSONString, '$')
	WITH(
			SearchString	varchar(20)	'$.SearchString'
		)

	DECLARE @OrderKey INT=0
	SELECT @OrderKey=OrderKey from ORDERHEADER OH WITH (NOLOCK) WHERE OrderNo=@SearchString
	SELECT Orderkey INTo #TempOrderdetail from OrderDetail WITH (NOLOCK) WHERE Containerno=@SearchString OR OrderKey=@OrderKey

	SELECT DISTINCT OH.OrderKey,OH.OrderNo,OH.OrderDate,
		Stuff((SELECT ', ' + OD.ContainerNo 
         FROM OrderDetail OD WITH (NOLOCK)
           WHERE OD.OrderKey = OH.OrderKey 
         FOR XML PATH('')),1,1,'') AS ContainerNo,
		C.CustName,OH.BookingNo,OH.BrokerRefNo,OH.BillOfLading, U.UserName
	FROM OrderHeader OH WITH (NOLOCK)
	LEFT JOIN OrderDetail OD WITH (NOLOCK) ON OH.OrderKey=OD.OrderKey
	INNER JOIN Customer C WITH (NOLOCK) ON C.CustKey=OH.CustKey
	INNER JOIN [User] U WITH (NOLOCK) ON U.UserKey=OH.CreateUserKey
	INNER JOIN #TempOrderdetail TOD ON TOD.OrderKey=OH.OrderKey
	--WHERE OrderNo=@SearchString OR ContainerNo=@SearchString
	FOR JSON PATH
	SET @Status=1
	SET @Reason='Success'
	DROP TABLE #TempOrderdetail
END