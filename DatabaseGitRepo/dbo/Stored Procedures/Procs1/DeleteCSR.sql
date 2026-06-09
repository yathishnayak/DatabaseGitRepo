CREATE PROCEDURE [dbo].[DeleteCSR]
(
	@CsrKey    INT,
	@UserKey   INT,
	@OutPut    bit = 0 OUTPUT,
	@Reason    varchar(100) = '' OUTPUT
)
AS
BEGIN 
   SET NOCOUNT ON;
	SET FMTONLY OFF;

	DECLARE @CNTCSR      INT= 0,
			@CNTCSRLink	 INT = 0,
			@CSRManager	 int = 0
		

	SET @CNTCSR = (SELECT COUNT(csrname) FROM CSR WHERE CsrKey = @CsrKey )
	SET @CNTCSRLink = (SELECT COUNT(1) FROM OrderHeader WHERE CsrKey = @CsrKey)
	select @CSRManager = COUNT(1) from CSR where CSRManagerKey = @csrKey

	IF (ISNULL(@CNTCSR,0) = 0)
	BEGIN
	    SET @output  = CONVERT(BIT,0);
		SET @Reason = 'No record  found for the given CSR'	
		RETURN
    END
	ELSE IF ISNULL(@CNTCSRLink,0) > 0
	BEGIN			
		SET @output  = CONVERT(BIT,0);
		SET @Reason  = 'CSR linked to Order, can not be deleted';
	
		RETURN;	
	END
	ELSE IF ISNULL(@CSRManager,0) > 0
	BEGIN			
		SET @output  = CONVERT(BIT,0);
		SET @Reason  = 'CSR Manager Linked to CSRs, can not be deleted';
	
		RETURN;	
	END
	ELSE
	begin
		UPDATE CSR 
		SET IsActive = 0 , IsDelete = 1
		WHERE CsrKey = @CsrKey
		SET @Reason = 'CSR Deleted Successfully';
		SET @OutPut = 1;
		RETURN;
	END
END 
