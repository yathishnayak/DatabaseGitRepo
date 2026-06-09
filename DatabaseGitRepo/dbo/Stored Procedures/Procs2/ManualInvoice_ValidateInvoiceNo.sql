
CREATE proc [dbo].[ManualInvoice_ValidateInvoiceNo]
(
	@MInvoiceNo	varchar(50),
	@Output		BIT = 0 OUTPUT
)
as
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF
	SET @Output = 0 

	IF(ISNULL(@MInvoiceNo,'') = '')
	BEGIN
		RETURN @OUTPUT
	END
	ELSE
	BEGIN
		DECLARE @CNT INT = 0
		
			SELECT @CNT = COUNT(1)
			FROM ManualInvoiceHeader
			WHERE MInvoiceNo = @MInvoiceNo

			IF(ISNULL(@CNT,0) = 0)
			BEGIN
				SET @Output = 1
			END
			RETURN @CNT
	END
END
