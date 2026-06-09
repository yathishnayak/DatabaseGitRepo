CREATE PROCEDURE [dbo].[MoveToandFromArchiveInvoice]
(
	@InvoiceKey		INT,
	@OrderKey		INT,
	@OrderDetailKey	INT,
	@Type			INT
)
AS
BEGIN
	SET NOCOUNT ON;
	SET ANSI_NULLS OFF;
		--@Type 1 Archive   2 unarchive
	IF(@Type=1)
	BEGIN
		Insert into ArchivedInvoiceHistory 
		(OrderKey,Invoicekey,OrderDetailKey,Invoiceno,PrevOrderDetailStatus,PrevInvoiceStatus,ArchivedDate)
		SELECT OH.OrderKey,IH.InvoiceKey,OD.OrderDetailKey,InvoiceNo,OD.Status,IH.StatusKey, Getdate()
		FROM OrderHeader OH
		INNER JOIN OrderDetail OD WITH (NOLOCK) ON OH.OrderKey=OD.OrderKey
		LEFT JOIN InvoiceDetail ID WITH (NOLOCK) ON (ID.OrderDetailKey=OD.OrderDetailKey)
		LEFT JOIN InvoiceHeader IH WITH (NOLOCK) ON IH.InvoiceKey=ID.InvoiceKey
		WHERE OD.OrderDetailKey=ISNULL(@OrderDetailKey,0) OR IH.InvoiceKey=ISNULL(@InvoiceKey,0)

		UPDATE OrderDetail 
		SET Status=15
		WHERE OrderDetailKey=@OrderDetailKey

	END
	ELSE
	BEGIN
		UPDATE OD 
		SET OD.Status=AI.PrevOrderDetailStatus
		FROM OrderDetail OD
		INNER JOIN ArchivedInvoiceHistory AI WITH (NOLOCK) ON AI.OrderDetailKey=OD.OrderDetailKey
		WHERE AI.OrderDetailKey=@OrderDetailKey

		DELETE FROM ArchivedInvoiceHistory WHERE OrderDetailKey=@OrderDetailKey
	END
END
