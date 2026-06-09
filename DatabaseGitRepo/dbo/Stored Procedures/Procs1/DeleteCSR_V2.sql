/*
DECLARE @UserKey INT = 951, @JSONString NVARCHAR(MAX),@Status BIT = 0,@Reason VARCHAR(1000), @IsDebug BIT = 1 
SET @JSONString ='{"CsrKey":0}'
 
EXEC [DeleteCSR_V2] @UserKey, @JSONString, @Status OUTPUT, @Reason OUTPUT, @IsDebug
SELECT @Status Status, @Reason Reason 
*/

CREATE PROCEDURE [dbo].[DeleteCSR_V2]
(
	@UserKey	INT,
	@JSONString	NVARCHAR(MAX) = '',
	@Status		BIT OUTPUT,
	@Reason		NVARCHAR(MAX) OUTPUT,
	@IsDebug	BIT = 0
)
As
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	DECLARE @CSRKey			VARCHAR(50) = '',
			@CNTCSR			INT	= 0,
			@CNTCSRLink		INT = 0,
			@CSRManager		int = 0

	-- Initialize default output values
	SET @Reason  = 'Something went wrong, Contact system administrator';
	SET @Status = 0;

	SELECT @CSRKey =  CSRKey
	FROM OpenJSON(@JSONString, '$')
	WITH (
		CSRKey		VARCHAR(50)		'$.CsrKey'
	)

	SET @CNTCSR = (SELECT COUNT(csrname) FROM CSR WHERE CsrKey = @CsrKey )
	SET @CNTCSRLink = (SELECT COUNT(1) FROM OrderHeader WHERE CsrKey = @CsrKey)
	SELECT @CSRManager = COUNT(1) FROM CSR WHERE CSRManagerKey = @csrKey

	IF (ISNULL(@CNTCSR,0) = 0)
	BEGIN
	    SET @Status  = CONVERT(BIT,0);
		SET @Reason = 'No record  found for the given CSR'	
		RETURN
    END
	ELSE IF ISNULL(@CNTCSRLink,0) > 0
	BEGIN			
		SET @Status  = CONVERT(BIT,0);
		SET @Reason  = 'CSR linked to Order, can not be deleted';	
		RETURN;	
	END
	ELSE IF ISNULL(@CSRManager,0) > 0
	BEGIN			
		SET @Status  = CONVERT(BIT,0);
		SET @Reason  = 'CSR Manager Linked to CSRs, can not be deleted';	
		RETURN;	
	END
	ELSE
	BEGIN TRY
		UPDATE CSR 
		SET IsActive = 0 , IsDelete = 1
		WHERE CsrKey = @CsrKey
		SET @Reason = 'CSR Deleted Successfully';
		SET @Status = 1;
		RETURN;
	END TRY
	BEGIN CATCH
		SET @Reason = ERROR_MESSAGE();
		SET @Status = 0;
	END CATCH
END