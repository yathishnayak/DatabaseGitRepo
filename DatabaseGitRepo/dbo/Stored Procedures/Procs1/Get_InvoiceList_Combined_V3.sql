/**
DECLARE 
	@UserKey INT=714,
	@JSONString NVARCHAR(MAX)='{"BookingNo":"NAM9436021","BOL":"","CustKey":0,"CustRefNo":""}'--'{"BOL":"","BookingNo":"NAM9436021"}'
	,@Status BIT=0,@IsDebug		BIT = 1
	,@Reason VARCHAR(100)=''
EXEC Get_InvoiceList_Combined_V3 @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT,@IsDebug
Select @Status, @Reason
**/

CREATE  Procedure [dbo].[Get_InvoiceList_Combined_V3] -- Get_InvoiceList_Combined_V3 @StatusKey=2, @PageNo = 1,@SearchText='WHSU5296890'
(
	@UserKey		INT = 714,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS
BEGIN

	SET NOCOUNT ON
	SET FMTONLY OFF
	SET ARITHABORT ON
	SET Concat_null_Yields_null ON

	SET @Status = 0
	SET @Reason = 'FAILED';
	DECLARE
		@CustomerKey			VARCHAR(MAX),
		@BOL					VARCHAR(30)	,
		@BookingNo				VARCHAR(30)	,
		@CustRefNo				VARCHAR(30)

	SELECT  @CustomerKey	= CustomerKey,
			@bol			= BOL,
			@BookingNo		= BookingNo,
			@CustRefNo		= CustRefNo
	FROM	OPENJSON(@JsonString, '$')
	WITH (
			CustomerKey			int				'$.CustKey',
			BOL					VARCHAR(30)		'$.BOL',
			BookingNo			VARCHAR(30)		'$.BookingNo',
			CustRefNo			VARCHAR(30)		'$.CustRefNo'
	);

	IF (@IsDebug = 1)
	BEGIN
		SET		@Status = 0
		SET		@Reason = 'In Debug Mode'
	END	


	IF (@IsDebug = 1)
	BEGIN
		Select @CustomerKey as CustomerKey, @BOL as BOL, @BookingNo as BookingNo, @CustRefNo AS CustRefNo
	END	
	--SELECT	InvoiceList = (
		select ih.InvoiceKey, IH.InvoiceNo, IH.InvoiceDate, IH.InvoiceAmount,cu.CustKey, 
				CU.CustID, CU.CustName, ML.MarketLocationKey,ML.MarketLocation,
				ad.AddrName, ad.City, ad.State, ad.Country, ad.ZipCode, ins.Description as Status,
				oh.BookingNo, oh.BillOfLading,OH.OrderNo,
				CIC.ContCount, CIC.Containers, MIL.MasterInvoiceNo,
				CASE WHEN ISNULL(MIL.InvoiceKey,0)=0 THEN CAST(0 AS BIT) ELSE CAST(1 AS BIT) END AS HasMasterInvoice,
				Documents = (
					SELECT CIC.ContainerNo, CD.DocumentKey,CD.OriginalFileName, CD.OriginalFileType ,
							CD.DocType, CD.LegID, CD.LegNo,CD.DocumentWithPath , Levl
					FROM (select * from InvoiceContainers WITH (NOLOCK) where invoicekey = IH.invoicekey) CIC 
					INNER JOIN vContainerDocuments_V2 CD WITH (NOLOCK) on Cd.OrderDetailKey = CIC.OrderDetailsKey
					WHERE  cd.OriginalFileType in ('JPG','JPEG','PNG','TIFF')
					order by ContainerNo, LegNo
					FOR JSON PATH
				)
		from InvoiceHeader IH WITH (NOLOCK) 
		inner Join OrderHeader OH WITH (NOLOCK) on IH.OrderKey = oh.OrderKey
		INNER JOIN CUSTOMER CU WITH (NOLOCK) ON IH.CustKey = CU.CustKey
		INNER JOIN Address AD WITH(NOLOCK) ON CU.AddrKey = ad.Addrkey
		LEFT JOIN  InvoiceStatus INS WITH (NOLOCK) ON INS.[StatusKey]=IH.[StatusKey]
		LEFT JOIN  MarketLocation ML WITH (NOLOCK) ON OH.MarketLocationKey =  ML.MarketLocationKey
		LEFT JOIN  (
			Select distinct CIH.invoicekey, Count(1) as ContCount , STRING_AGG(ContainerNo,', ') as Containers
			FROM InvoiceHeader CIH WITH (NOLOCK)
			LEFT JOIN InvoiceContainers CIC WITH (NOLOCK) on CIH.invoicekey = CIC.InvoiceKey
			Group by CIH.InvoiceKey
		) CIC on IH.InvoiceKey = CIC.InvoiceKey
		LEFT JOIN MasterInvoiceLink MIL WITH (NOLOCK) ON MIL.InvoiceKey=IH.InvoiceKey
		WHERE	(ISNULL(@CustomerKey,0)=0 OR ih.CustKey = @CustomerKey) AND
				(ISNULL(@BOL,'')='' OR OH.BillOfLading = @BOL) AND
				(ISNULL(@BookingNo,'')='' OR OH.BookingNo = @BookingNo) AND
				(ISNULL(@CustRefNo,'')='' OR OH.BrokerRefNo = @CustRefNo)
			AND IH.StatusKey IN (2,3) AND IH.CUSTKEY = OH.CustKey
		ORDER BY IH.InvoiceNo
		FOR JSON PATH
	--)
	set @Status = 1
	SET @Reason = 'SUCCESS'
END
