
CREATE PROCEDURE [dbo].[COSTACC_InsertFileProcessInfo] -- COSTACC_InsertFileProcessInfo 'ert','',''
(
	@FileName			VARCHAR(100),
	@UserKey			INT
)
AS
BEGIN
	DECLARE			@ISSuccess BIT = 1, 
					@Remarks VARCHAR(100) = 'Record Saved Successfully', 
					@ErrorMessage VARCHAR(100) = 'Something went wrong, Contact System Administrator. Error Code : '
	DECLARE			@FileProcessKey INT = 0

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
			INSERT INTO		COSTACC_FileProcessInfo
							(FileName,DateUploaded,FileUploadStatus,FileProcessStatus,IsEmailSent,UserKey)
			SELECT			@FileName,GETDATE(),0,0,0,@UserKey

			SET				@FileProcessKey = @@IDENTITY
		END

	SELECT @ISSuccess AS ISSuccess, @Remarks AS Remarks, @FileProcessKey AS FileProcessKey
END
