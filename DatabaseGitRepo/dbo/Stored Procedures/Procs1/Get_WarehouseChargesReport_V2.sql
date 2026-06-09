/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"CustKey":0,"InvoiceNo":"","ContainerNo":"","OrderNo":"","InvFromDate":"2016-02-03","InvToDate":"2025-08-07"}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXec [Get_WarehouseChargesReport_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	Select @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[Get_WarehouseChargesReport_V2]  --Get_WarehouseChargesReport_V2 @CustomerKey =1575
(
	@UserKey		INT = 488,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS
BEGIN

	SET NOCOUNT ON;
	
	DECLARE @CustomerKey INT=0,
			@InvoiceNo VARCHAR(50) = '',	
			@InvFromDate    datetime = '2022-01-01',
			@InvToDate		datetime	= '2022-12-31',
			@OrderNo		varchar(50) = '',
	        @ContainerNo	varchar(50) = ''
			
	IF ISNULL(@JSONString,'') = '' OR ISJSON(@JSONString) <> 1
	BEGIN
		SET @Status = 0
		SET @Reason = 'Invalid JSON input'
		RETURN
	END

    SELECT @CustomerKey = CustomerKey, @InvoiceNo = InvoiceNo, @InvFromDate = InvFromDate, @InvToDate = InvToDate, @OrderNo =OrderNo , @ContainerNo =ContainerNo
	FROM OPENJSON(@JSONString,'$')
	WITH (
			CustomerKey			 INT				'$.CustKey',
			InvoiceNo			VARCHAR(50)			'$.InvoiceNo',
			InvFromDate			 datetime			'$.InvFromDate',	
			InvToDate		     datetime	        '$.InvToDate',
			OrderNo				 VARCHAR(50)	    '$.OrderNo',
			ContainerNo			 VARCHAR(50)	    '$.ContainerNo'
		 )

		SELECT CustomerID, CustomerName, InvoiceNo, InvoiceDate, OrderNumber, 
			Container, city AS City , BrokerRefNo, InvoiceAmount, Status, 
			ItemID, UnitPrice, NoOfDays, ExtAmt, CustKey
	    FROM [vInvoiceReportByWarehouseCharges] A WITH (NOLOCK)
	    WHERE
		(@CustomerKey = 0 OR A.CustKey = @CustomerKey) AND 
		--(@InvoiceNo = 0 OR A.InvoiceNo = @InvoiceNo) AND
		(@InvoiceNo = '' OR CAST(A.InvoiceNo AS VARCHAR(50)) = @InvoiceNo) AND
		(@InvFromDate =  '2022-01-01' OR A.[InvoiceDate] >= @InvFromDate) AND
		(@InvToDate = '2022-12-31' OR A.[InvoiceDate] <= @InvToDate) AND
		(@ContainerNo = '' OR A.Container = @ContainerNo) AND
		(@OrderNo = '' OR A.OrderNumber = @OrderNo)

		FOR JSON PATH;

		SET @Status = 1
		SET @Reason = 'Success'

END