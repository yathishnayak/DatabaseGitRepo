/*
Declare @UserKey int=951,@JSONString nvarchar(max),@Status 	bit	= 0,@Reason	varchar(1000) = '' 
set @JsonString = '{
	"ScreenName": "ChargeManagement",
	"ColumnStatus": [
		{
			"ColumnID": "AgingDays",
			"ColumnName": "Aging Days",
			"IsSelected": true
		},
		{
			"ColumnID": "BrokerRefNo",
			"ColumnName": "BrokerRef#",
			"IsSelected": true
		},
		{
			"ColumnID": "isChargesSharedWithCust",
			"ColumnName": "Charges Shared With Customer?",
			"IsSelected": true
		},
		{
			"ColumnID": "D_City",
			"ColumnName": "City/State",
			"IsSelected": true
		},
		{
			"ColumnID": "ContainerNo",
			"ColumnName": "ContainerNo",
			"IsSelected": true
		},
		{
			"ColumnID": "CsrName",
			"ColumnName": "CsrName",
			"IsSelected": false
		},
		{
			"ColumnID": "CustName",
			"ColumnName": "Customer Name",
			"IsSelected": false
		},
		{
			"ColumnID": "D_Address1",
			"ColumnName": "Delivery Address",
			"IsSelected": true
		},
		{
			"ColumnID": "D_AddrName",
			"ColumnName": "Delivery Location",
			"IsSelected": true
		},
		{
			"ColumnID": "DispatchCompleteDate",
			"ColumnName": "Dispatch Complete Date",
			"IsSelected": true
		},
		{
			"ColumnID": "OrderNo",
			"ColumnName": "OrderNo",
			"IsSelected": true
		},
		{
			"ColumnID": "isWhseChargesConfirmed",
			"ColumnName": "Whse Charges Confirmed?",
			"IsSelected": true
		}
	]
}'
exec Columns_InsertUpdateUserScreenColumns @UserKey, @JSONString, @Status output, @Reason output
select @Status, @Reason
*/
CREATE proc [dbo].[Columns_InsertUpdateUserScreenColumns]
(
	@UserKey		int,
	@JSONString		nvarchar(max),
	@Status			bit	= 0 output,
	@Reason			varchar(1000) = '' output
)	
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	declare @Screen		varchar(100),
			@ColumnStatus	varchar(max)
	if(len(isnull(@JSONString,''))=0)
	Begin
		set @Status = 0
		SEt @Reason = 'Required parameters not received'
		Return
	End

	SELECT @Screen = Screen, @ColumnStatus = ColumnStatus 
	from OpenJSON(@JsonString, '$')
	WITH (
		Screen				varchar(100)	'$.ScreenName',
		ColumnStatus		nvarchar(max)	'$.ColumnStatus' as JSON
	)

	if(len(isnull(@Screen,''))=0)
	Begin
		set @Status = 0
		SEt @Reason = 'Screen Name not received'
		Return
	End
	
	if(len(isnull(@ColumnStatus,''))=0)
	Begin
		set @Status = 0
		SEt @Reason = 'Column Status not received'
		Return
	End

	if(Len(@Screen) > 0 and Len(@ColumnStatus)>0)
	Begin
		if((Select count(1) from UserScreenColumns WITH (NOLOCK) where UserKey = @UserKey and ScreenName = @Screen) = 0 )
		Begin
			INSERT INTO UserScreenColumns (UserKey, ScreenName, COlumnsStatus, CreateDate )
			SELECT @UserKey, @Screen, @ColumnStatus, GETdATE()
		End
		else
		Begin
			uPDATE UserScreenColumns SET
				ColumnsStatus = @ColumnStatus,
				UpdateDate = GETdATE()
			WHERE UserKey = @UserKey AND ScreenName = @Screen
		End
	End

	SEt @Status = 1
	SEt @Reason = 'SUCCESS'
END