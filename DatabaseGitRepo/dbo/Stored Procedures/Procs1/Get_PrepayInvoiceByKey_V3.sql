/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"InvoiceKey" : 6}',
	@Status	BIT = 0, 
	@JSONOutput	VARCHAR(MAX) = '',
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [Get_PrepayInvoiceByKey_V3] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @JSONOutput OUTPUT, @IsDebug
	SELECT @JSONOutput AS JSONText, @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[Get_PrepayInvoiceByKey_V3] 
(
	@UserKey		INT = 1144,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@JSONOutput		VARCHAR(MAX) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS
BEGIN

	IF (ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'Parameters not found'
			RETURN
		END	

	DECLARE
		@PrepayInvoiceKey	INT = 1

	SELECT 
		@PrepayInvoiceKey		=		PrepayInvoiceKey
	FROM OPENJSON(@JSONString)
	WITH
	(
		PrepayInvoiceKey		INT		'$.InvoiceKey'
	)

	IF(@PrepayInvoiceKey > 0)
	BEGIN
		DECLARE @DetailText varchar(max) 

		SELECT @JSONOutput = (
			SELECT PPInvoiceKey,PPInvoiceNo, PPInvoiceDate, PPInvoiceAmount,H.OrderKey, 
			isnull(H.OrderNo,'') as OrderNo, CustomerKey as CustKey,
				OrderHeader.OrderDate as OrderDate,
				BillToAddressKey, PPInvoiceSentDate, PPInvoiceConfirmDate, 
				InternalNotes, H.CustomerNotes,
				CreatedDate, CreatedUserKey, UpdateDate, UpdatedUserKey,  IsFactored,
					PrepayInvoiceDetail = (
					SELECT PPInvoiceKey, PPInvoiceLineKey, ContainerNo, PID.ItemKey, UnitPrice, Quantity, 
					ExtCost, CreatedDate, CreatedUserKey, UpdateDate, UpdatedUserKey, I.InvoiceItemDesc, I.Description as ItemDesc
					FROM PrepayInvoiceDetail PID WITH (NOLOCK)
					inner join Item I WITH (NOLOCK) on PID.ItemKey = I.ItemKey
					WHERE PPInvoiceKey = @PrepayInvoiceKey
					FOR JSON PATH
				)
			FROM PrepayInvoiceHeader H WITH (NOLOCK)
			LEft join OrderHeader OrderHeader With (NoLock) on H.OrderKey = OrderHeader.OrderKey
			LEFT Join Customer C with (nolock) on H.CustomerKey = C.CustKey
			WHERE PPInvoiceKey = @PrepayInvoiceKey
			FOR JSON PATH
		)
	END

	SELECT @JSONOutput AS JSONOutput
	SET @Status = 1
	SET @Reason = 'Success'
END