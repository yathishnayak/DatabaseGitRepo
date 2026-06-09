/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"CreditKey" : 1}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [GetInvoiceCreditListByKey] @UserKey,@JSONString, @IsDebug, @Status OUTPUT, @Reason OUTPUT
	SELECT @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[GetInvoiceCreditListByKey] 
(
	@UserKey		INT=488,
	@JsonString		VARCHAR(MAX)='',
	@IsDebug		BIT = 1,
	@Status			BIT	= 0 OUTPUT,
	@Reason			NVARCHAR(1000) = '' OUTPUT
)
AS

BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF
	SET ARITHABORT ON;

	IF(ISNULL(@JsonString,'')='')
	BEGIN
		SET @Status=0;
		SET @Reason='Parameter not found';
		RETURN;
	END

	SET @Status=1;
	SET @Reason='Success';
	DECLARE @CreditKey INT =	0
	SELECT @CreditKey = CreditKey
	FROM OPENJSON(@JsonString, '$')
	WITH(	
			CreditKey			INT			'$.CreditKey'
		)

	SELECT	        IC.CreditKey,IC.CreditTypeKey,IC.CreditNo,IC.CreditAmount,IC.CreditDate,IC.CreditAppliedBy,IC.CreditAppliedDate,
					U.UserName as 'User',IC.CreditStatus,IC.CreatedUserKey,IC.CreatedDate,
					ISNULL(IH.CustKey, MIH.CustomerKey) AS CustKeys,
					ISNULL(C1.CustName, C2.CustName) AS CustomerNames,
					ISNULL(ICL.InvoiceKey,ICL.MInvoiceKey) AS Invoicekeys,
					ISNULL(IH.InvoiceNo, MIH.MInvoiceNo) AS InvoiceNumbers
	FROM            InvoiceCredits IC
	INNER JOIN InvoiceCreditLink ICL WITH (NOLOCK) ON IC.CreditKey = ICL.CreditKey
	LEFT JOIN InvoiceHeader IH WITH (NOLOCK) ON ICL.InvoiceKey = IH.InvoiceKey
	LEFT JOIN ManualInvoiceHeader MIH WITH (NOLOCK) ON ICL.MInvoiceKey = MIH.MInvoiceKey
	LEFT JOIN Customer C1 WITH (NOLOCK) ON IH.CustKey = C1.CustKey
	LEFT JOIN Customer C2 WITH (NOLOCK) ON MIH.CustomerKey = C2.CustKey
	INNER JOIN [User] U WITH (NOLOCK) ON IC.CreditAppliedBy = U.UserKey
	INNER JOIN [User] CU WITH (NOLOCK) ON IC.CreatedUserKey = CU.UserKey
	INNER JOIN [User] UU WITH (NOLOCK) ON IC.UpdatedUserKey = UU.UserKey
	WHERE        IC.CreditKey = @CreditKey
	
				 FOR JSON PATH, WITHOUT_ARRAY_WRAPPER

END



