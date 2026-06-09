/**
DECLARE 
	@UserKey INT=512,
	@JSONString NVARCHAR(MAX)='{"ContainerNo":"FSCU4959760","DriverKey":778,"IsRetroPay":true}',
	@Status BIT=0, @IsDebug int = 1,@Reason VARCHAR(100)=''
EXec DriverVoucher_ValidateContainerNo @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
Select @Status, @Reason
**/
CREATE PROCEDURE [dbo].[DriverVoucher_ValidateContainerNo]
(
	@UserKey		int,
	@JSONString		nvarchar(max),
	@Status			bit	= 0 output,
	@Reason			varchar(1000) = '' output,
	@IsDebug		bit = 0
)
WITH RECOMPILE
AS
BEGIN
	set nocount on
	SET FMTONLY OFF
	SET @Status = 0
	SET @Reason='Failure'
	DECLARE @CNT INT = 0, 
			@ContainerNo	VARCHAR(20) = '',
			@DriverKey	INT = 0,
			@IsRetroPay BIT=0;

	Select	@ContainerNo = Isnull(ContainerNo,''),	@DriverKey = DriverKey, @IsRetroPay = IsRetroPay
	from OpenJSON(@JsonString, '$')
	WITH (
			ContainerNo		varchar(20)		'$.ContainerNo',
			DriverKey		INT				'$.DriverKey',
			IsRetroPay		BIT				'$.IsRetroPay'
		)

	SELECT OrderDetailKey, OrderKey INTO #OrderDetailKey_DriverPey 
		FROM OrderDetail WHERE ContainerNo = @ContainerNo;

	IF(@IsDebug = 1)
	Begin
		select '#OrderDetailKey_DriverPey', * from #OrderDetailKey_DriverPey
	End

	SELECT DISTINCT RT.RouteKey, OrderDetailKey,LegKey, LinkedContainer,
		CASE WHEN ISNULL(LinkedContainer,'')<>'' THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS HasLinkedContainer
		INTO #RouteKeys_DriverVoucher 
		FROM Routes RT
		LEFT JOIN VOUCHERDETAIL VD on RT.RouteKey = VD.RouteKey
		WHERE DriverKey=@DriverKey AND OrderDetailKey IN (SELECT OrderDetailKey FROM #OrderDetailKey_DriverPey)
		and (VD.RouteKey is null OR ISNULL(@IsRetroPay,0)=1)
			--AND RouteKey NOT IN (SELECT RouteKey FROM VoucherDetail)

	IF(@IsDebug = 1)
	Begin
		select '#RouteKeys_DriverVoucher', * from #RouteKeys_DriverVoucher
	End

	SELECT @CNT = COUNT(1) FROM #OrderDetailKey_DriverPey
	IF(@CNT > 0)
	BEGIN
		SELECT L.LegId+' - '+OH.OrderNo  AS LegID, RouteKey,LinkedContainer,HasLinkedContainer
			FROM #OrderDetailKey_DriverPey OD WITH (NOLOCK) 
			INNER JOIN #RouteKeys_DriverVoucher RT WITH (NOLOCK) ON RT.OrderDetailKey=OD.OrderDetailKey
			INNER JOIN Leg L WITH (NOLOCK) ON L.LegKey=RT.LegKey
			INNER JOIN OrderHeader OH WITH (NOLOCK) ON OH.OrderKey=OD.OrderKey
			FOR JSON PATH;
		SET @Status = 1
		SET @Reason='Success'
	END
END