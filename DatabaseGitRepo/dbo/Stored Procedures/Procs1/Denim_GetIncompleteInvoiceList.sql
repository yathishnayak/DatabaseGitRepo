/*
DECLARE @UserKey INT = 488, @JSONString NVARCHAR(MAX),@Status BIT = 0,@Reason VARCHAR(1000)
SET @JSONString =''
EXEC [Denim_GetIncompleteInvoiceList] @UserKey, @JSONString, @Status OUTPUT, @Reason OUTPUT
SELECT @Status Status, @Reason Reason
*/

CREATE PROCEDURE [dbo].[Denim_GetIncompleteInvoiceList]
(
    @UserKey		int,
	@JSONString		nvarchar(max),
	@Status			bit	= 0 output,
	@Reason			varchar(1000) = '' output
)
AS 
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;
	SET @Status =1
	SET @Reason ='Success' 

	SELECT DSD.DenimInvoiceKey, DSD.Invoiceno, DSD.Createddate,DSD.IsComplete,DSD.DenimRefno		
	FROM Denim_SentInvoiceDetails DSD WITH (NOLOCK)
	WHERE ISNULL(IsComplete, 0) = 0
	
	FOR JSON PATH
	
END
