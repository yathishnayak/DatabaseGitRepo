/*
DECLARE 
	@UserKey INT = 953,
	@JSONString NVARCHAR(MAX)= '{"ManualInvoiceKey" : 1}',
	@Status	BIT = 0, 
	@JSONOutput	VARCHAR(MAX) = '',
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [Get_ManualInvoiceByKey_V3] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @JSONOutput OUTPUT, @IsDebug
	SELECT @JSONOutput AS JSONText, @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[Get_ManualInvoiceByKey_V3]
(
	@UserKey		INT = 0,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@JSONOutput		VARCHAR(MAX) = '' OUTPUT,
	@IsDebug		BIT = 0
)
as
Begin

	IF (ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'Parameters not found'
			RETURN
		END	

	DECLARE
		@ManualInvoiceKey	INT = 1

	SELECt
		@ManualInvoiceKey	= ManualInvoiceKey
	FROM OPENJSON(@JSONString)
	WITH
	(
		ManualInvoiceKey		INT		'$.ManualInvoiceKey'
	)

	if(@ManualInvoiceKey > 0)
	BEGIN
		
			SELECT MInvoiceKey,MInvoiceNo, MInvoiceDate, ISNULL(MInvoiceAmount, 0) AS MInvoiceAmount,H.OrderKey, H.OrderNo, CustomerKey  AS CustKey,
				BillToAddressKey, MInvoiceSentDate, MInvoiceConfirmDate, 
				InternalNotes, H.CustomerNotes, H.StatusKey, H.BrokerRef,
				CreatedDate, CreatedUserKey, H.UpdateDate, UpdatedUserKey, IsFactored ,
				H.SteamShipLineKey, SteamShipLineRef,SSL.LineName AS SteamShipLineName,H.OriginalInvoiceNo,
				ManualInvoiceDetail =	(
					SELECT MInvoiceKey, MInvoiceLineKey, ContainerNo, MID.ItemKey, UnitPrice, Quantity, ExtCost,
						I.Description as itemdesc,
						CreatedDate, CreatedUserKey, UpdateDate, UpdatedUserKey, I.InvoiceItemDesc
					FROM ManualInvoiceDetail MID WITH (NOLOCK)
					INNER JOIN Item I WITH (NOLOCK) ON MID.ItemKey = I.ItemKey
					WHERE MInvoiceKey = @ManualInvoiceKey
					FOR JSON PATH
				),InvoiceCompanyKey,ISNULL(OrderHeader.MarketLocationKey,Customer.MarketLocationKey) MarketLocationKey
			FROM ManualInvoiceHeader H WITH (NOLOCK)
			LEFT JOIN OrderHeader OrderHeader With (NoLock) on H.OrderKey = OrderHeader.OrderKey
			LEFT JOIN Customer Customer WITH (NOLOCK) on H.CustomerKey = Customer.CustKey
			LEFT JOIN SteamShipLine SSL WITH (NOLOCK) ON H.SteamShipLineKey = SSL.LineKey
			WHERE MInvoiceKey = @ManualInvoiceKey
			FOR JSON PATH
		
	END
	SET @Status=1
	SET @Reason = 'Success'
End