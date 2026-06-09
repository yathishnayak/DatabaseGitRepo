
/**
DECLARE @UserKey		INT=512,
	@JsonString		VARCHAR(MAX)='{"ContainerNo":"FSCU8141690"}',
	@Status			BIT	= 0 ,
	@Reason			VARCHAR(1000) = '' 
exec Admin_GetContainerLogAll @UserKey, @JsonString,@Status output, @Reason output
**/
CREATE PROCEDURE [dbo].[Admin_GetContainerLogAll] --exec Get_ContainerLog_All 'ACBI2408137'
(
	@UserKey		INT=0,
	@JsonString		VARCHAR(MAX)='',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT
)
AS
BEGIN
SET NOCOUNT ON;
SET FMTONLY OFF;
SET ARITHABORT ON;

IF(ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
	BEGIN
		SET @Status = 0
		SET @Reason = 'Parameters not found'
		RETURN
	END

	CREATE TABLE #ContainerData
	(
		ContainerNo			VARCHAR(20)
	)

	INSERT INTO #ContainerData(ContainerNo)
	SELECT ContainerNo
	FROM OPENJSON(@JsonString, '$')
	WITH (
			ContainerNo VARCHAR(20)			'$.ContainerNo'
		)

DECLARE @OrderDetailKey INT =0, @ContainerNo VARCHAR(20)=''
--@JsonResult NVARCHAR(MAX)=''
SELECT @ContainerNo = ContainerNo FROM #ContainerData
--SELECT @OrderDetailKey = OrderDetailKey FROM OrderDetail WHERE ContainerNo=@ContainerNo


SELECT OrderDetailKey,ROW_NUMBER() OVER (Order by OrderDetailKey) AS SlNo into #tmpOrderDetailKeys FROM OrderDetail WHERE ContainerNo=@ContainerNo

CREATE TABLE #TmpAutitLog
(
	AuditKey INT,
	DateCreated DateTIME,
	CreateUser VARCHAR(100),
	RefType VARCHAR(100),
	RefId VARCHAR(100),
	RefKey INT,
	Stage VARCHAR(100),
	CommentType VARCHAR(50),
	Comments VARCHAR(MAX)
)

CREATE TABLE #TmpDocumentLog
(
	DocumentKey	INT
	,OriginalFileName varchar(200)
	,OriginalFileType varchar(200)
	,FileSizeinMB decimal
	,DocType varchar(200)
	,DocumentTypeKey INT
	,OrderDetailKey INT
	,Levl varchar(200)
	,LegID varchar(200)
	,LegTypeID varchar(200)
	,LegNo int
	,CreateDate datetime
	,LinkTo varchar(200)
	,StoragePath varchar(200)
	,OrderNo varchar(20)
	,ROUTEKEY int
	,OrderKey int
	,DocumentUserKey int
	,DocumentWithPath varchar(200)
	,UserName varchar(50)
	,DocSource	VARCHAR(20)
)

DECLARE @i INT = 1 , @n INT =(SELECT COUNT(*) FROM #tmpOrderDetailKeys)
		WHILE (@i < = @n)
		BEGIN
			SET @OrderDetailKey = (SELECT OrderDetailKey FROm #tmpOrderDetailKeys WHERE SlNo = @i)
			INSERT INTO #TmpAutitLog
			EXEC [Get_AuditLogDetail] 'Container', @OrderDetailKey 

			INSERT INTO #TmpDocumentLog
			EXEC Get_ContainerAllDocuments @OrderDetailKey
			SET @i = @i + 1
		END
--SET @JsonResult=(

SELECT OrderNo,ContainerNo,OrderDate ,MarketLocation,CustId,OD.BookingNo,BillOfLading,BrokerRefNo,
		CSR.CsrName AS CSRName,CSM.CsrName AS CSManagerName,S.SalesPersonName,
		RoutesData=(SELECT L.LegId,RT.LegNo,U.UserName,D.DriverId,OD.BookingNo,BrokerRefNo,ConfirmationNo,DelConfirmationNo 
			FROM ROUTES RT WITH (NOLOCK)
			INNER JOIN Leg L WITH (NOLOCK) ON L.LegKey=RT.LegKey
			LEFT JOIN [User] U WITH (NOLOCK) ON U.UserKey=RT.CreateUserKey
			LEFT JOIN Driver D WITH (NOLOCK) ON D.DriverKey=RT.DriverKey
			WHERE RT.OrderDetailKey=OD.OrderDetailKey
			ORDER BY RT.RouteKey
			FOR JSON PATH),
		AuditLog =(SELECT * FROM #TmpAutitLog WHERE RefKey=OD.OrderDetailKey FOR JSON PATH),
		RoutesLog=( SELECT L.LegId,RT.LegNo,U.UserName,RTL.ActionDate,RTL.ActionType FROM ROUTES RT WITH (NOLOCK)
			INNER JOIN Leg L WITH (NOLOCK) ON L.LegKey=RT.LegKey
			LEFT JOIN Routes_Log RTL WITH (NOLOCK) ON RTL.OrderDetailkey=RT.OrderDetailKey
			LEFT JOIN [User] U WITH (NOLOCK) ON U.UserKey=RTL.ActionUser
			WHERE RT.OrderDetailKey=OD.OrderDetailKey
			ORDER BY RTL.RouteKey,ActionDate
			FOR JSON PATH),
		DocumentsLog=( SELECT * FROM #TmpDocumentLog WHERE OrderDetailKey=OD.OrderDetailKey FOR JSON PATH)
FROM OrderHeader OH
INNER JOIN OrderDetail OD WITH (NOLOCK) ON OD.OrderKey=OH.OrderKey
INNER JOIN Customer C WITH (NOLOCK) ON C.CustKey=OH.CustKey
LEFT JOIN CSR CSR WITH (NOLOCK) ON CSR.CsrKey=OH.CsrKey
LEFT JOIN CSR CSM WITH (NOLOCK) ON CSM.CsrKey=OH.CSRManagerKey
LEFT JOIN MarketLocation M WITH (NOLOCK) ON M.MarketLocationKey=OH.MarketLocationkey
LEFT JOIN SalesPerson S WITH (NOLOCK) ON S.SalesPersonKey=OH.SalesPersonKey
WHERE OD.ContainerNo=@ContainerNo
FOR JSON PATH
--)

--SELECT @JsonResult AS JsonResult

SET @Status = 1
SET @Reason = 'Success'

DROP TABLE #TmpDocumentLog
DROP TABLE #TmpAutitLog
END
