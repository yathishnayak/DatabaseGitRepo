
/**
DECLARE @UserKey		INT=512,
	@JsonString		VARCHAR(MAX)='{"ContainerNo":"ZMOU8851717"}',
	@Status			BIT	= 0 ,
	@Reason			VARCHAR(1000) = '' 
exec Admin_GetRouteAddrDetails @UserKey, @JsonString,@Status output, @Reason output
**/
CREATE PROCEDURE [dbo].[Admin_GetRouteAddrDetails]
(
	@UserKey		INT=0,
	@JSONString		VARCHAR(MAX)='{"ContainerNo":"JCTU031609"}',
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
	FROM OPENJSON(@JSONString, '$')
	WITH (
			ContainerNo VARCHAR(20)			'$.ContainerNo'
		)
	DECLARE @OrderDetailKey INT =0, @ContainerNo VARCHAR(20)='', @JSONResult NVARCHAR(MAX)=''
	SELECT @ContainerNo = ContainerNo FROM #ContainerData
 
	SELECT OrderDetailKey,ROW_NUMBER() OVER (Order by OrderDetailKey) AS SlNo into #tmpOrderDetailKeys FROM OrderDetail WHERE ContainerNo=@ContainerNo
 
	SELECT L.LegId, RT.SourceAddrKey,RT.DestinationAddrKey,RT.RouteKey,RT.OrderdetailKey,
	CAST(0 AS INT) UpdatedSourceAddrKey,CAST(0 AS INT) UpdatedDestinationAddrKey,
	DA.AddrName+'-'+DA.Address1+'-'+DA.Address2+'-'+DA.City+'-'+DA.State+'-'+DA.Country As DestinationAddress ,
	SA.AddrName+'-'+SA.Address1+'-'+SA.Address2+'-'+SA.City+'-'+SA.State+'-'+SA.Country As SourceAddress ,
	RouteAddr=(select RTI.SourceAddrKey ,RTI.DestinationAddrKey ,RTI.RouteKey,RTI.OrderDetailKey  ,
		DAI.AddrName+'-'+DAI.Address1+'-'+DAI.Address2+'-'+DAI.City+'-'+DAI.State+'-'+DAI.Country As DestinationAddress ,
	SAI.AddrName+'-'+SAI.Address1+'-'+SAI.Address2+'-'+SAI.City+'-'+SAI.State+'-'+SAI.Country As SourceAddress 
	from Routes RTI
				RIGHT JOIN Address DAI WITH (NOLOCK) ON DAI.AddrKey=RTI.DestinationAddrKey
				RIGHT JOIN Address SAI WITH (NOLOCK) ON SAI.AddrKey=RTI.SourceAddrKey
				WHERE RTI.RouteKey<>RT.RouteKey AND RTI.OrderDetailKey=RT.OrderDetailKey for json path
				)
	FROM Routes RT
	INNER JOIN Leg L WITH (NOLOCK) ON L.LegKey=RT.LegKey
	LEFT JOIN Address DA WITH (NOLOCK) ON DA.AddrKey=RT.DestinationAddrKey
	LEFT JOIN Address SA WITH (NOLOCK) ON SA.AddrKey=RT.SourceAddrKey
	INNER JOIN #tmpOrderDetailKeys TMP ON (tmp.OrderDetailKey=RT.OrderDetailKey)
	--WHERE OrderDetailKey=@OrderDetailKey
	FOR JSON PATH

	SET @Status = 1
	SET @Reason = 'Success'
END
