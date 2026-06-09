/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"InvoiceNo" : "", "ContainerNo" : "HLBU2287419"}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [Get_DataForArchiveUnarchive_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	Select @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[Get_DataForArchiveUnarchive_V2]  
(
	@UserKey		INT = 0,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
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
		@InvoiceNo		VARCHAR(100)='',
		@ContainerNo	VARCHAR(20)=''

	SELECT
		@InvoiceNo			=	InvoiceNo	,
		@ContainerNo		=	ContainerNo
	FROM OPENJSON(@JSONString)
	WITH
	(
		InvoiceNo			VARCHAR(100)	'$.InvoiceNo',	
		ContainerNo			VARCHAR(20)		'$.ContainerNo'
	)

	SELECT AI.*,OD.ContainerNo,OH.OrderNo, OH.BookingNo, OH.BrokerRefNo,C.CustName,M.MarketLocation, 
		CASE WHEN C.IsFactored=1 THEN 'Factored' WHEN C.IsFactored=0 THEN  'Non-Factored' ELSE 'N/A' END AS Factored ,A.AddrName
	FROM ArchivedInvoiceHistory AI WITH (NOLOCK)
	INNER JOIN OrderDetail OD WITH (NOLOCK) ON OD.OrderDetailKey=AI.OrderDetailKey
	INNER JOIN OrderHeader OH WITH (NOLOCK) ON OH.OrderKey=OD.OrderKey
	INNER JOIN Customer C WITH (NOLOCK) ON C.CustKey=OH.CustKey
	LEFT JOIN MarketLocation M WITH (NOLOCK) ON M.MarketLocationKey=OH.MarketLocationKey
	INNER JOIN Address A WITH (NOLOCK) ON A.AddrKey=OH.DestinationAddrKey
	WHERE (invoiceno=@InvoiceNo OR ''=@InvoiceNo)
	AND (ContainerNo=@ContainerNo OR ''=@ContainerNo)

	UNION

	SELECT 0 as ArchivedKey,OH.OrderKey,ISNULL(IH.InvoiceKey,0),OD.OrderDetailKey,InvoiceNo,Od.Status,IH.StatusKey,'' as ArchivedDate,
		OD.ContainerNo,OH.OrderNo , OH.BookingNo, OH.BrokerRefNo, C.CustName,M.MarketLocation, 
		CASE WHEN C.IsFactored=1 THEN 'Factored' WHEN C.IsFactored=0 THEN  'Non-Factored' ELSE 'N/A' END  AS Factored,A.AddrName
	FROM OrderHeader OH WITH (NOLOCK) 
	INNER JOIN OrderDetail OD WITH (NOLOCK) ON OD.OrderKey=OH.OrderKey
	OUTER APPLY (	SELECT TOP 1 *
					FROM InvoiceDetail IDI WITH (NOLOCK)
					WHERE IDI.OrderDetailKey = OD.OrderDetailKey
				) ID
	LEFT JOIN InvoiceHeader IH WITH (NOLOCK) ON IH.InvoiceKey=ID.InvoiceKey
	INNER JOIN Customer C WITH (NOLOCK) ON C.CustKey=OH.CustKey
	LEFT JOIN MarketLocation M WITH (NOLOCK) ON M.MarketLocationKey=OH.MarketLocationKey
	INNER JOIN Address A WITH (NOLOCK) ON A.AddrKey=OH.DestinationAddrKey
	WHERE (invoiceno=@InvoiceNo OR ''=@InvoiceNo)
	AND (ContainerNo=@ContainerNo OR ''=@ContainerNo)
	AND OD.Status<>15
	FOR JSON PATH

	SET @Status = 1
	SET @Reason = 'Success'
END