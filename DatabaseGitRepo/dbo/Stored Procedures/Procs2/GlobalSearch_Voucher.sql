/*
Declare @UserKey INT = 486, @JsonString NVARCHAR(MAX) = '', @Status BIT = 0, @Reason VARCHAR(100) = '', @IsDebug BIT = 0
Set @JsonString = '[{"VoucherNo":"126676"}]' 
Exec GlobalSearch_Voucher @UserKey, @JsonString, @Status output, @Reason output, @IsDebug
Select @Status Status, @Reason Reason
*/

CREATE PROCEDURE [dbo].[GlobalSearch_Voucher]
(
	@UserKey	 INT = 0,
	@JSONString  NVARCHAR(MAX) = '',
	@Status      BIT = 0 OUTPUT,
	@Reason		 VARCHAR(100) = '' OUTPUT,
	@IsDebug     BIT = 0
)AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	DECLARE @VoucherNo VARCHAR(50);

	IF(@IsDebug = 1)
	BEGIN
		SET @Status = 0
		SET @Reason = 'In Debug mode'
	END

	SELECT @VoucherNo = VoucherNo
	FROM OPENJSON(@JSONString, '$')
	WITH ( VoucherNo	VARCHAR(50)	 '$.VoucherNo' )

	IF(ISNULL(@VoucherNo, '') = '')
	BEGIN
		SET @Status = 0
		SET @Reason = 'filter is null'
		Print @Reason
	  RETURN
	END
	  
	SELECT distinct OH.OrderKey,OH.OrderNo,OD.OrderDetailKey,OD.ContainerNo, VH.VoucherKey ,VoucherNo,VoucherAmount,'WK-' +  CONVERT(VARCHAR,DATEPART(iso_week,A.MinArrival)) AS WeekNum,
		   CU.UserName AS VoucherCreatedBy,VH.VoucherDate as VoucherCreatedDate,UU.UserName AS VoucherApprovedBy,VH.UpdateDate AS VoucherUpdatedDate,
		   VU.UserName AS PmtApprovedBy,PU.UserName AS PaidBy,PaidDate,(D.FirstName + D.LastName) AS DriverName, VS.[Description] AS VoucherStatus,
		  VH.InternalNote,CA.UserName AS Dispatchers,
		   --ItemInfo= (
		   --   SELECT ItemID,Description 
			  --FROM OrderExpense OE WITH (NOLOCK)		
	    --      INNER JOIN Item I WITH (NOLOCK) on OE.ItemKey = I.ItemKey		  
			  --WHERE OE.Routekey = RT.Routekey
			  --FOR JSON PATH
		   --)
		   LegInfo=(
				SELECT L.LegKey, L.LegID,L.[Description] 
				FROM LEG L WITH(NOLOCK)
				INNER JOIN [Routes] R WITH (NOLOCK) ON L.LegKey = R.LegKey
				INNER JOIN VoucherDetail V WITH(NOLOCK) ON V.RouteKey = R.RouteKey
				WHERE V.Voucherkey = VH.VoucherKey
				FOR JSON PATH
		   )
	FROM VoucherHeader VH WITH (NOLOCK)
	INNER JOIN VoucherDetail VD WITH(NOLOCK) ON VD.Voucherkey = VH.VoucherKey
	INNER JOIN [Routes] RT WITH (NOLOCK) ON VD.RouteKey= RT.RouteKey
	left JOIN [User] CA WITH(NOLOCK) ON CA.UserKey = RT.CarrierAssignedBy
	LEFT JOIN OrderDetail OD WITH (NOLOCK) ON RT.OrderDetailKey = od.OrderDetailkey
	LEFT JOIN OrderHeader OH WITH (NOLOCK) ON oh.OrderKey = od.OrderKey
	LEFT JOIN Driver D WITH (NOLOCK) ON d.DriverKey = RT.DriverKey
	LEFT JOIN VoucherStatus VS	WITH (NOLOCK) ON VS.StatusKey=VH.StatusKey
	LEFT JOIN vVoucherWeekNums A WITH (NOLOCK) on A.VoucherKey = VH.VoucherKey
	LEFT JOIN [USER] CU WITH(NOLOCK) ON CU.UserKey = VH.CreateUserKey
	LEFT JOIN [User] UU WITH(NOLOCK) ON UU.UserKey = VH.UpdateUserKey	 
	LEFT JOIN [User] VU WITH(NOLOCK) ON VU.UserKey = VH.PmtApprovedUser
	LEFT JOIN [User] PU WITH(NOLOCK) ON PU.UserKey = VH.PaidUserKey
	
	WHERE VH.VoucherNo LIKE '%' + @VoucherNo + '%'
	FOR JSON PATH

	SET @Status = 1
	SET @Reason = 'Success'
END

--SELECT * FROM VoucherHeader WHERE VoucherNo = '126672' 
--SELECT * FROM VoucherDetail WHERE Voucherkey = 251615