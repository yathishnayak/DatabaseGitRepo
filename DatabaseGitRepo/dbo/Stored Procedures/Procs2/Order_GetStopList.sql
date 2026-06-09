/**
DECLARE @UserKey INT=29,
	@JSONString NVARCHAR(MAX)='{"OrderDetailKey":0,"OrderKey":0,"MarketKey":0}',@Status BIT=0,@IsDebug		BIT = 1, 
	@JsonOutput nvarchar(max) ='', 	@Reason VARCHAR(100)=''
EXec Order_GetStopList @UserKey,@JSONString,@JsonOutput OUTPUT,@Status OUTPUT,@Reason OUTPUT, @IsDebug
Select @JsonOutput, @Status, @Reason
**/
CREATE PROC [dbo].[Order_GetStopList]
(
	@UserKey			int,
	@JsonString			nvarchar(max) = '',
	@JsonOutput			nvarchar(max) ='' OUTPUT,
	@Status				bit = 0 output,
	@Reason				varchar(500) = '' output,
	@IsDebug			bit = 0
)
As
BEGIN

	declare @OrderKey int

	SELECT @OrderKey = JSON_Value(@JsonString, '$.OrderKey')
	if(@IsDebug =1 )
	Begin
		select @OrderKey as ORderKey
	End

	Set @Status = 0
	SEt @Reason = 'ERROR'

	SET @JsonOutput=(
	Select orderstops = (
	SELECT OrderKey, stopdetails = (Select SM.StopTypeKey, StopTypeName, StopTypeShortcode, StopName, StopAddrKey,
	A.AddrName as StopAddress, A.Address1 as AddressLine1, A.Address2 as AddressLine2, City, State, ZipCode, Country, 
	StopNumber, LocationType, StatusKey, IsFoundationStop, OrderBy, OS.CreateDate, @OrderKey as OrderKey,
	U.UserName as CreateUserName, OS.UpdateDate, OS.UpdateUserKey, OS.OrderStopKey
	FROM StopsMaster SM with (nolock)
	LEFT JOIN OrderStops OS with (nolock) on SM.StopTypeKey = OS.StopTypeKey and OS.OrderKey = OH.OrderKey
	LEFT JOIN [Address] A with (nolock) on OS.StopAddrKey = A.AddrKey
	LEFT JOIN [User] U with (nolock) on SM.CreateUserKey = U.UserKey
	ORder By SM.OrderBy
	FOR JSON PATH
	) 
	From OrderHeader OH
	WHERE OrderKey = @OrderKey 

	FOR JSON PATH, without_array_wrapper
	) 
	)
	SELECT @JsonOutput
	set @Status = 1
	SEt @Reason = 'Success'
	
END
