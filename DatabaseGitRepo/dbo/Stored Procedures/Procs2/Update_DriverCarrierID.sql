create procedure [dbo].[Update_DriverCarrierID]
(
  @DriverKey  int,
  @DriverID   varchar(50),
  @Output     bit = 0 OUTPUT,
  @Reason     varchar(100) = '' OUTPUT
)
as
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	IF(@DriverKey = 0)
	BEGIN 
		SET @Output = 0
		SET @Reason = 'Driver Key required'
		RETURN;
    END

	IF(ISNULL(@DriverID,'') = '')
	BEGIN
		SET @Output = 0
		SET @Reason = 'Driver ID Can''t be blank'
		RETURN;
	END

	DECLARE @CNT INT = 0
	SELECT @CNT = COUNT(1) FROM Driver WHERE DriverID = @DriverID AND DriverKey <> @DriverKey

	IF(@CNT > 0)
	BEGIN
	   SET @Output = 0
	   SET @Reason = 'Driver ID already exists'
	   return;
	END

	UPDATE Driver SET DriverID = @DriverID
	WHERE DriverKey = @DriverKey
	SET @Output = 1
	SET @Reason = 'Updated Successfully'
	return;
END
