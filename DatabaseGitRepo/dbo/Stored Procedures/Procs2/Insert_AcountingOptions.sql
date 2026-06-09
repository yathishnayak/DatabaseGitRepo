CREATE PROCEDURE [dbo].[Insert_AcountingOptions]
/*
 dbo.fn_insert_accountingoptions
*/
@ItemKey		INT,
@OrderDetailKey INT,
@CreateUserKey	INT
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	INSERT INTO dbo.itemsforaccounting(itemkey, orderdetailkey, createdate, createuserkey)
	VALUES (@ItemKey, @OrderDetailKey, GETDATE(), @CreateUserKey)	
END
