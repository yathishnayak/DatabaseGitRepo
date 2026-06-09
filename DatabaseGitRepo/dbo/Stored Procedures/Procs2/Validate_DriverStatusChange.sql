CREATE Procedure [dbo].[Validate_DriverStatusChange]
(
	@DriverKey		int,
	@Output			SMALLINT OUTPUT,
	@OutputStatus	varchar(100) OUTPUT
)
as
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	DECLARE @CNT INT = 0

	--// Check Driver exists
	SELECT @CNT = COUNT(1) FROM Driver WHERE DriverKey = @DriverKey
	IF(ISNULL(@CNT,0) = 0)
	BEGIN
		SET @Output = 9 
		SET @OutputStatus = 'Driver Not Found'
	END
	ELSE
	BEGIN
		--// check pending deliveries
		SET @CNT = 0
		SELECT @CNT = COUNT(1) 
		FROM Routes RT
		WHERE RT.DriverKey = @DriverKey AND RT.Status <> 5 -- LEG COMPLETED STATUS
			AND (RT.ActualArrival IS NULL OR RT.ActualDeparture IS NULL)

		IF(@CNT > 0)
		BEGIN
			SET @Output = 8
			SET @OutputStatus = 'Can''t make Inactive as some Assigned Legs are still pending to delivery'
			return
		END
		ELSE
		BEGIN
			--// Check Voucher Pending for the Driver
			set @CNT = 0
			select @cnt =  Count(1)
			from VoucherHeader VH
			inner join VoucherDetail VD on VH.VoucherKey = VD.Voucherkey
			inner join Routes RT on VD.RouteKey = RT.RouteKey
			where RT.DriverKey = @DriverKey and VH.StatusKey in (1,2)

			if(@CNT > 0)
			Begin
				SET @Output = 7
				set @OutputStatus = 'Can''t make Inactive as some Vouchers Pending against this Carrier'
				return
			END
			ELSE
			BEGIN
				--//Check Route Complete, but Voucher not Created for the Driver
				set @CNT = 0
				select @CNT = count(1)
				from Routes RT
				LEft join VoucherDetail VD on RT.RouteKey = VD.RouteKey
				where RT.Status = 5 and RT.DriverKey = @DriverKey
						AND VD.RouteKey is null

				IF(@CNT > 0)
				begin
					set @Output = 6
					set @OutputStatus = 'Can''t make Inactive as some Voucher Creation Pending against this Carrier'
					return
				end
				ELSE
				BEGIN
					set @Output = 1
					set @OutputStatus = 'Carrier Status can be changed'
				END
			END
		END
	END
END
