
CREATE proc [dbo].[ManualInvoice_ValidateInvoiceNoEdit]
(
	@MInvoiceNo		varchar(50),
	@MInvoiceKey	int,
	@Output			BIT = 0 OUTPUT
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
	ELSE IF (ISNULL(@MInvoiceKey,0) = 0)
	BEGIN
		return @output
	END
	ELSE IF(LEFT(@MInvoiceNo,2) <> 'M-')
	BEGIN
		return @output
	END
	BEGIN
		DECLARE @CNT INT = 0
		
		SELECT @CNT = COUNT(1)
		FROM ManualInvoiceHeader
		WHERE MInvoiceNo = @MInvoiceNo and MInvoiceKey <> @MInvoiceKey

		IF(ISNULL(@CNT,0) = 0)
		BEGIN
			update ManualInvoiceHeader Set MInvoiceNo = @MInvoiceNo
			where MInvoiceKey = @MInvoiceKey
			SET @Output = 1
		END
		RETURN @CNT
	END
END
