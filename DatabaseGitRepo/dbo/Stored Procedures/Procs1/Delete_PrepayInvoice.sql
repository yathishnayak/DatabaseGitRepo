CREATE PROCEDURE [dbo].[Delete_PrepayInvoice]
	@PPInvoicekey			INT,
	@UserKey				INT,
	@OutPut					BIT OUTPUT
AS
BEGIN	
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SET @OutPut=0;

	BEGIN TRY

		BEGIN TRAN

			INSERT INTO PrepayInvoiceDetail_Delete
				(PPInvoiceKey, PPInvoiceLineKey, ItemKey, UnitPrice, Quantity, ExtCost, CreatedDate, CreatedUserKey,
				UpdateDate, UpdatedUserKey, ContainerNo, DeletedBy, DeletedOn)
			SELECT PPInvoiceKey, PPInvoiceLineKey, ItemKey, UnitPrice, Quantity, ExtCost, CreatedDate, CreatedUserKey,
				UpdateDate, UpdatedUserKey, ContainerNo, @UserKey,GETDATE() FROM PrepayInvoiceDetail
				WHERE PPInvoiceKey=@PPInvoicekey

			INSERT INTO PrepayInvoiceHeader_Delete
				(PPInvoiceKey,PPInvoiceNo,PPInvoiceDate,PPInvoiceAmount,OrderKey,CustomerKey,BillToAddressKey,PPInvoiceSentDate,
				PPInvoiceConfirmDate,CreatedDate,CreatedUserKey,UpdateDate,UpdatedUserKey,OrderNo,
				StatusKey,InternalNotes,CustomerNotes,RevisionDate,RevisionUserKey,InternalNote,DeletedBy,DeletedDate)
			SELECT PPInvoiceKey,PPInvoiceNo,PPInvoiceDate,PPInvoiceAmount,OrderKey,CustomerKey,BillToAddressKey,PPInvoiceSentDate,
				PPInvoiceConfirmDate,CreatedDate,CreatedUserKey,UpdateDate,UpdatedUserKey,OrderNo,
				StatusKey,InternalNotes,CustomerNotes,RevisionDate,RevisionUserKey,InternalNote,@UserKey,GETDATE() FROM PrepayInvoiceHeader
				WHERE PPInvoiceKey=@PPInvoicekey


			DELETE 
			FROM dbo.PrepayInvoiceDetail
			WHERE PPInvoicekey =@PPInvoicekey;

			DELETE FROM dbo.PrepayInvoiceHeader
			WHERE PPInvoiceKey=@PPInvoicekey;

			IF @@ROWCOUNT>0
			BEGIN
				SET @OutPut=1
			END	;

		COMMIT TRAN

	END TRY

	BEGIN CATCH
		ROLLBACK TRAN
		SET @OutPut=0
	END CATCH
END