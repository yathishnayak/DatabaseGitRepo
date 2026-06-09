/*
DECLARE 
	@UserKey INT=952,
	@JSONString		NVARCHAR(MAX)=  '{"InvoiceNo1":"12","InvoiceNo2":"12"}',
	@Status			BIT=0, 
	@IsDebug		BIT = 0, 
	@Reason			VARCHAR(100)=''
	EXec [SwapInvoices] @UserKey, @JSONString, @Status OUTPUT, @Reason OUTPUT, @IsDebug
	Select @Status, @Reason
*/

CREATE PROCEDURE [dbo].[Admin_SwapInvoiceNo]
(
	@UserKey		INT = 0,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF
	SET ARITHABORT ON

	Declare
		@InvoiceNo1 VARCHAR(50),	
		@InvoiceNo2 VARCHAR(50)

	IF (ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'Parameters not found'
			RETURN
		END	
		
	IF (@IsDebug = 1)
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'In Debug Mode'
		END

	SELECT 
		@InvoiceNo1		=	InvoiceNo1,		
		@InvoiceNo2		=	InvoiceNo2
	FROM	OPENJSON(@JsonString, '$')
	WITH (
			InvoiceNo1		VARCHAR(50)		'$.InvoiceNo1',
			InvoiceNo2		VARCHAR(50)		'$.InvoiceNo2'
		)

	IF(@IsDebug = 1)
	BEGIN
		SELECT 'Parameters' AS Params,
		@InvoiceNo1		AS	InvoiceNo1,		
		@InvoiceNo2		AS	InvoiceNo2
	END

	IF @InvoiceNo1=@InvoiceNo2
	BEGIN
		PRINT 'Both invoices are same.'
		SET @Status = 0
		SET @Reason = 'Both invoices are same.'
		RETURN
	END


    -- Check if both invoice numbers exist in the table
	IF NOT EXISTS (
		SELECT 1 
		FROM InvoiceHeader
		WHERE InvoiceNo = @InvoiceNo1
	) OR NOT EXISTS (
		SELECT 1 
		FROM InvoiceHeader
		WHERE InvoiceNo = @InvoiceNo2
	)
	BEGIN
		PRINT 'Both invoices are required for swapping, but one or both are missing.'
		SET @Status = 0
		SET @Reason = 'Both invoices are required for swapping, but one or both are missing.'
		RETURN
	END

    -- Check if either InvoiceNo has duplicates
    IF EXISTS (
        SELECT InvoiceNo
        FROM InvoiceHeader
        GROUP BY InvoiceNo
        HAVING InvoiceNo IN (@InvoiceNo1, @InvoiceNo2) AND COUNT(InvoiceKey) > 1
    )
    BEGIN
        PRINT 'One or both invoice numbers have duplicates. Cannot proceed with swap.'
		SET @Status = 0
		SET @Reason = 'One or both invoice numbers have duplicates. Cannot proceed with swap.'
        RETURN
    END

	IF (@IsDebug = 1)
	BEGIN
		--PRINT 'Before Swap:'
		SELECT 'Before Swap:', * FROM InvoiceHeader WHERE InvoiceNo IN (@InvoiceNo1, @InvoiceNo2) Order By InvoiceKey
	END

    -- Perform the swap
    UPDATE InvoiceHeader
    SET InvoiceNo = CASE
        WHEN InvoiceNo = @InvoiceNo1 THEN @InvoiceNo2
        WHEN InvoiceNo = @InvoiceNo2 THEN @InvoiceNo1
    END
    WHERE InvoiceNo IN (@InvoiceNo1, @InvoiceNo2)

	IF (@IsDebug = 1)
	BEGIN
		--PRINT 'After Swap:'
		SELECT 'After Swap:', * FROM InvoiceHeader WHERE InvoiceNo IN (@InvoiceNo1, @InvoiceNo2) Order By InvoiceKey
	END

	SET @Status = 1
	SET @Reason = 'Success'
	
END

