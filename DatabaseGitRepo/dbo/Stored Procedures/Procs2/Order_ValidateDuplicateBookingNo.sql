CREATE Proc Order_ValidateDuplicateBookingNo
(
	@BookingNo	varchar(50)='',
	@IsDuplicate	bit = 0 output
)
as
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	DECLARE @CNT INT = 0
	SELECT @CNT = COUNT(1) FROM OrderHeader WHERE LTRIM(RTRIM(BookingNo)) = LTRIM(RTRIM(@BookingNo))

	IF(@CNT > 0)
	BEGIN
		SET @IsDuplicate = 1
	END

END
