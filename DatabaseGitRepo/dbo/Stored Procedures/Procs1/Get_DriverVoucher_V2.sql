/*
DECLARE 
	@UserKey INT=952,
	@JSONString NVARCHAR(MAX)='{"DriverVoucherKey":19427}',
	@Status BIT=0,
	@Reason VARCHAR(100)='',
	@IsDebug BIT=1
EXEC [Get_DriverVoucher_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
Select @Status, @Reason
*/
CREATE PROCEDURE [dbo].[Get_DriverVoucher_V2]
(
	@UserKey		INT,
	@JSONString		NVARCHAR(MAX),
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS 
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF
	SET ARITHABORT ON

	DECLARE 
		@DriverVoucherKey	INT = 0,
		@RowCount			INT = 0

	IF(ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
	BEGIN
		SET @Status = 0
		SET @Reason = 'Parameters not found'
		RETURN
	END

	Select	
		@DriverVoucherKey		=		DriverVoucherKey
	from OpenJSON(@JsonString, '$')
	WITH (
		DriverVoucherKey				INT				'$.DriverVoucherKey'
	)

	SELECT  DVD.DriverVoucherKey, DVD.DriverVoucherNumber, DVD.DriverVoucherdate, DVD.WeekNumber, 
		DVD.DriverKey,
		D.DriverID, ISNULL(D.FirstName,'') + ' '+ ISNULL(D.LastName,'') AS DriverName,  
		DVD.DriverVoucherAmount, D.DrivingLicenseNo, D.DrivingLicenseExpiryDate,
		DVD.PaymentApprover, DVD.CreateUser, DVD.UpdateUser,
		ISNULL(ContainerNo,0) AS ContainerNo,DVD.RouteKey, L.LegId,DVD.StatusKey,
		CASE WHEN VH.StatusKey = 1 THEN CAST(0 AS BIT) ELSE Cast(1 AS BIT) END AS IsOpenVoucher,
		ISNULL(IsRetroPay,0) AS IsRetroPay,

			JSON_QUERY((
						SELECT 
							DDD.DriverVoucherLineKey, 
							DVD.DriverVoucherKey, 
							DDD.ItemKey, 
							I.[Description], 
							DDD.UnitCost, 
							DDD.Qty, 
							DDD.ExtCost,
							DDD.CreateUser, 
							DDD.UpdateUser
						FROM DriverVoucher DVD
						LEFT JOIN DriverVoucherDetail DDD ON DDD.DriverVoucherKey = DVD.DriverVoucherKey 
						LEFT JOIN Driver D ON D.DriverKey = DVD.DriverKey
						LEFT JOIN Item I ON I.ItemKey = DDD.ItemKey
						WHERE DVD.DriverVoucherKey = @DriverVoucherKey	
						FOR JSON PATH, INCLUDE_NULL_VALUES
					)) AS DeductionDetails

	FROM DriverVoucher DVD WITH (NOLOCK)
	LEFT JOIN Driver D WITH (NOLOCK) ON D.DriverKey = DVD.DriverKey
	INNER JOIN [Routes] RT WITH (NOLOCK) ON RT.RouteKey=DVD.RouteKey
	INNER JOIN Leg L WITH (NOLOCK) ON L.LegKey=RT.LegKey
	LEFT JOIN VoucherHeader VH WITH (NOLOCK) ON VH.VoucherKey=DVD.LinkedVoucherKey
	WHERE DVD.DriverVoucherKey = @DriverVoucherKey
	FOR JSON PATH, Without_Array_Wrapper

	SET @RowCount = @@ROWCOUNT

	IF(@RowCount=0)
	BEGIN
		SET @Status = 0;
		SET @Reason = 'No records found';
		SET ARITHABORT OFF;
		Return
	END

		SET @Status = 1
		SET @Reason = 'Success'
		SET ARITHABORT OFF;
END