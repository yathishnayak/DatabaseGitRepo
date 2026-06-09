
/*
DECLARE 
	@UserKey INT=952,
	@JSONString		NVARCHAR(MAX)=  '{"InvoiceNo":"M-100509"}',
	@Status			BIT=0, 
	@IsDebug		BIT = 0, 
	@Reason			VARCHAR(100)=''
	EXec [ManualInvoiceNo] @UserKey, @JSONString, @Status OUTPUT, @Reason OUTPUT, @IsDebug
	Select @Status, @Reason
*/
CREATE PROCEDURE [dbo].[Admin_UpdateManualInvoice]
(
	@UserKey      INT=0,
	@JSONString   NVARCHAR(MAX)='',
	@JSONOutput   NVARCHAR(MAX) = '' OUTPUT,
	@Status       BIT = 0 OUTPUT,
	@Reason       VARCHAR(1000) = '' OUTPUT
)
AS
SET NOCOUNT ON
SET FMTONLY OFF
SET ARITHABORT ON;
BEGIN
	DECLARE @InvoiceKey INT=0,@InvoiceNo VARCHAR(100)='';

	SELECT @InvoiceNo=InvoiceNo
	FROM OPENJSON(@JSONString,'$')
    WITH (
			InvoiceNo	VARCHAR(100)		'$.InvoiceNo'
		)

	CREATE TABLE #ManualInvoiceNo
	(
		InvoiceKey	INT,InvoiceNo VARCHAR(30)
	)
	 		
	INSERT INTO #ManualInvoiceNo(InvoiceKey,InvoiceNo)
	SELECT MInvoiceKey, MInvoiceNo
	FROM ManualInvoiceHeader WHERE MInvoiceNo LIKE '%'+ @InvoiceNo +'%'


	UPDATE #ManualInvoiceNo SET InvoiceNo=LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(InvoiceNo, CHAR(9), ''), CHAR(10), ''), CHAR(13), '')));

	SELECT @InvoiceKey=ISNULL(InvoiceKey,0) FROM #ManualInvoiceNo WHERE InvoiceNo=@InvoiceNo;

	IF @InvoiceKey>0
	BEGIN
	print 'hi';
	UPDATE ManualInvoiceHeader SET MInvoiceNo=@InvoiceNo  WHERE MInvoiceKey=@InvoiceKey;
	END

	SET @Status=1;
	SET @Reason='Success';

	DROP TABLE #ManualInvoiceNo;
END
