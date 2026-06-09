

CREATE Procedure [dbo].[DeleteCarrier] -- DRIVER  DELETE
(
	@DriverKey INT,
	@UserKey   INT,
	@OutPut bit = 0 OUTPUT,
	@Reason varchar(100) = '' OUTPUT
)
AS
BEGIN
	DECLARE @CNTDriver INT=0
		  --  @CNTDriverDocuments INT=0,
		   -- @CNTDriverLicences INT = 0
	
	SET @CNTDriver = (select count(DriverID) FROM Driver WHERE DriverKey= @DriverKey)
	--SET @CNTDriverDocuments = (SELECT COUNT(1) FROM DriverDocuments WHERE DriverKey = @DriverKey)
	--SET @CNTDriverLicences = (SELECT COUNT(1) FROM DriverLicences WHERE DriverKey = @DriverKey)
	 
	IF(@CNTDriver =0)
	BEGIN
		SET @Reason = 'No record found for the given Driver'
		SET @OutPut = 0;
		RETURN
	END
	--ELSE IF ISNULL(@CNTDriverDocuments,0) > 0
	--BEGIN			
	--	SET @output  = CONVERT(BIT,0);
	--	SET @Reason  = 'Driver linked to Driver Documents, can not be deleted';
	--	RETURN;	
	--END
	--ELSE IF ISNULL(@CNTDriverLicences,0) > 0
	--BEGIN			
	--	SET @output  = CONVERT(BIT,0);
	--	SET @Reason  = 'Driver linked to Driver Licences, can not be deleted';
	--	RETURN;	
	--END
ELSE
	BEGIN
		UPDATE			Driver 
		SET				IsActive = 0 , IsDelete = 1, LastUpdateDate = GETDATE(), LastUpdateUserKey = @UserKey 
		WHERE			DriverKey= @DriverKey
		SET				@Reason = 'Driver Deleted Sucessfully'
		SET				@OutPut = 1;
		RETURN
	END
END


--select * from driver
