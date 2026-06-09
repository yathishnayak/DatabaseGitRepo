/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"InvoiceKey" : 0, "OrderKey" : 182011, "OrderDetailKey" : 222511, "Type" : 2}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [MoveToandFromArchiveInvoice_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	Select @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[MoveToandFromArchiveInvoice_V2]
(
	@UserKey		INT = 0,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS
BEGIN
	SET NOCOUNT ON;
	SET ANSI_NULLS OFF;

	IF (ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
	BEGIN
		SET		@Status = 0
		SET		@Reason = 'Parameters not found'
		RETURN
	END	

	DECLARE
	@InvoiceKey		INT,
	@OrderKey		INT,
	@OrderDetailKey	INT,
	@Type			INT

	SELECT 
	@InvoiceKey			=		InvoiceKey		,
	@OrderKey			=		OrderKey		,
	@OrderDetailKey		=		OrderDetailKey	,
	@Type				=		Type	
	FROM OPENJSON(@JSONString)
	WITH
	(
	InvoiceKey			INT		'$.InvoiceKey',		
	OrderKey			INT		'$.OrderKey',		
	OrderDetailKey		INT		'$.OrderDetailKey',	
	Type				INT		'$.Type'
	)

		--@Type 1 Archive   2 unarchive
	IF(@Type=1)
	BEGIN
		Insert into ArchivedInvoiceHistory 
		(OrderKey,Invoicekey,OrderDetailKey,Invoiceno,PrevOrderDetailStatus,PrevInvoiceStatus,ArchivedDate)
		SELECT OH.OrderKey,IH.InvoiceKey,OD.OrderDetailKey,InvoiceNo,OD.Status,IH.StatusKey, Getdate()
		FROM OrderHeader OH WITH(NOLOCK)
		INNER JOIN OrderDetail OD WITH (NOLOCK) ON OH.OrderKey=OD.OrderKey
		--LEFT JOIN InvoiceDetail ID WITH (NOLOCK) ON (ID.OrderDetailKey=OD.OrderDetailKey)
		LEFT JOIN InvoiceHeader IH WITH (NOLOCK) ON IH.OrderKey=OH.OrderKey
		WHERE OD.OrderDetailKey=ISNULL(@OrderDetailKey,0) OR IH.InvoiceKey=ISNULL(@InvoiceKey,0)

		UPDATE OrderDetail 
		SET Status=15
		WHERE OrderDetailKey=@OrderDetailKey

		
		SET @Status = 1
		SET @Reason = 'Success'

	END
	ELSE
	BEGIN
		UPDATE OD 
		SET OD.Status=AI.PrevOrderDetailStatus
		FROM OrderDetail OD
		INNER JOIN ArchivedInvoiceHistory AI WITH (NOLOCK) ON AI.OrderDetailKey=OD.OrderDetailKey
		WHERE AI.OrderDetailKey=@OrderDetailKey

		DELETE FROM ArchivedInvoiceHistory WHERE OrderDetailKey=@OrderDetailKey

		SET @Status = 1
		SET @Reason = 'Success'
	END
END
