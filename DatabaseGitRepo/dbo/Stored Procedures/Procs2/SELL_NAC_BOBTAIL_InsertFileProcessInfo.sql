
CREATE PROCEDURE [dbo].[SELL_NAC_BOBTAIL_InsertFileProcessInfo] -- [SELL_NAC_BOBTAIL_InsertFileProcessInfo] 'ert','',''
(
	@FileName			VARCHAR(100),
	@CustKey			VARCHAR(50),
	@UserKey			INT
)
AS
BEGIN

	DECLARE		@ISSuccess BIT = 1, 
				@Remarks VARCHAR(100) = 'Record Saved Successfully', 
				@ErrorMessage VARCHAR(100) = 'Something went wrong, Contact System Administrator. Error Code : '
	DECLARE		@FileProcessKey INT = 0

	If(ISNULL(@FileName,'') = '')
		BEGIN
			SET @ISSuccess = 0
			SET @Remarks = @ErrorMessage + '101'
		END
	ELSE IF (@UserKey = 0)
		BEGIN
			SET @ISSuccess = 0
			SET @Remarks = @ErrorMessage + '103'
		END

	IF(@ISSuccess = 1)
		BEGIN
			INSERT INTO		SELL_NAC_BOBTAIL_FileProcessInfo
							(FileName,DateUploaded,CustKey, FileUploadStatus,FileProcessStatus,IsEmailSent,UserKey)
			SELECT			@FileName,GETDATE(),@CustKey,0,0,0,@UserKey

			SET				@FileProcessKey = @@IDENTITY
		END

	SELECT @ISSuccess AS ISSuccess, @Remarks AS Remarks, @FileProcessKey AS FileProcessKey
END
