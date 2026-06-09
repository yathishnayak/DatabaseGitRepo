/*
DECLARE 
	@UserKey INT=952,
	@JSONString NVARCHAR(MAX)= '{"RouteKey":688203}',
	@JSONOutput   NVARCHAR(MAX) = '',
	@Status			BIT=0, @Reason			VARCHAR(100)=''
	EXec [Get_ContainerFor_LinkNextLoad] @UserKey,@JSONString,@JSONOutput output,@Status OUTPUT,@Reason OUTPUT
	Select @Status, @Reason

*/

CREATE Proc [dbo].[Get_ContainerFor_LinkNextLoad]
(
	@UserKey      INT = 0,
	@JSONString   NVARCHAR(MAX)='',
	@JSONOutput   NVARCHAR(MAX) = '' OUTPUT,
	@Status       BIT = 0 OUTPUT,
	@Reason       VARCHAR(1000) = '' OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF
	SET ARITHABORT ON

	Declare @IsDebug BIT = 0;

	Declare @ZipCode		Varchar(100)	=	'',
			@OrderDetailKey	Varchar(250)	=	'',
			@RouteKey		Int

	IF(ISNULL(LTRIM(RTRIM(@JSONString)),'')= '')
	BEGIN
		SET @Status = 0
		SET @Reason = 'Parameters Not Found'
	END

	SELECT
		@RouteKey = RouteKey
	FROM OPENJSON(@JSONString, '$')
	WITH
	(
		RouteKey INT '$.RouteKey'
	)

	IF(@IsDebug = 1)
	Begin
		SELECT @RouteKey AS RouteKey
	END

	Select @ZipCode = DTA.ZipCode, @OrderDetailKey = OD.OrderDetailKey from OrderDetail OD
	Inner Join Routes RT ON OD.OrderDetailKey = RT.OrderDetailKey
	Left JOIN [Address] DTA ON RT.DestinationAddrKey = DTA.AddrKey
	Where RT.RouteKey = @RouteKey

	IF(@IsDebug = 1)
	BEGIN
		Select @ZipCode	ZipCode, @OrderDetailKey OrderDetailKey
	END

	SET @JSONOutput = (
	Select DISTINCT OD.ContainerNo,OD.OrderDetailKey, RT.DestinationAddrKey, RT.IsEmpty,OH.OrderNo
	from OrderDetail OD WITH (NOLOCK)
	Inner Join Routes RT WITH (NOLOCK) ON OD.OrderDetailKey = RT.OrderDetailKey
	Left JOIN [Address] DTA WITH (NOLOCK) ON RT.DestinationAddrKey = DTA.AddrKey
	INNER JOIN OrderHeader OH WITH (NOLOCK) ON OH.OrderKey=OD.OrderKey
	Where RT.[Status] = 5 
	--AND DTA.ZipCode = @ZipCode 
	AND OD.[Status] = 6
	AND OD.OrderDetailKey != @OrderDetailKey
	For JSON PATH
	) 
	SET @Status=1;
	SET @Reason='Success';
	SELECT @JSONOutput
	SET ARITHABORT OFF
END