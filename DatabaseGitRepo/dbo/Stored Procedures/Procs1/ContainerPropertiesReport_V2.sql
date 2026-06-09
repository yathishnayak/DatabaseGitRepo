/*
	DECLARE @UserKey INT = 953, @JSONString NVARCHAR(MAX),@Status BIT = 0,@Reason VARCHAR(1000), @IsDebug BIT = 0
	SET @JSONString ='{"CustKey":0,"OrderNo":"","ContainerNo":"","DateFrom":"2020-01-31T18:30:00Z","DateTo":"2051-01-30T18:30:00Z","CsrKey":0,"StatusKey":0}'
	EXEC [ContainerWithoutChassisReport_V2] @UserKey, @JSONString, @Status OUTPUT, @Reason OUTPUT, @IsDebug
	SELECT @Status Status, @Reason Reason 
*/

CREATE PROCEDURE [dbo].[ContainerPropertiesReport_V2]
(
	@UserKey		INT=953,
	@JsonString		NVARCHAR(MAX)='',
	@IsDebug		BIT = 1,
	@Status			BIT	= 0 OUTPUT,
	@Reason			NVARCHAR(1000) = '' OUTPUT
)
AS
BEGIN

	SET NOCOUNT ON;
	SET FMTONLY OFF
	SET ARITHABORT ON;

	DECLARE
    @CustKey INT = 0,
    @OrderNo VARCHAR(50) = '',
    @ContainerNo VARCHAR(50) = '',
    @DateFrom DATETIME = '2020-01-01',
    @DateTo DATETIME = '2050-12-31',
    @CsrKey INT = 0,
    @StatusKey INT = 0;

		IF (ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'JSONString cannot be empty'
			RETURN
		END	


		SELECT
			@CustKey = CustKey,@OrderNo = OrderNo,@ContainerNo = ContainerNo,	@DateFrom = DateFrom,@DateTo = DateTo,@CsrKey = CsrKey,@StatusKey = StatusKey
			FROM OPENJSON(@JsonString)
			WITH (
						CustKey INT						'$.CustKey' ,
						OrderNo VARCHAR(50)				'$.OrderNo',
						ContainerNo VARCHAR(50)			'$.ContainerNo',
						DateFrom DATETIME				'$.DateFrom',
						DateTo DATETIME					'$.DateTo',
						CsrKey INT						'$.CsrKey',
						StatusKey INT					'$.StatusKey'
					);
		Select OH.OrderKey, OH.OrderNo, OD.OrderDetailKey, OD.ContainerNo, OH.CustKey, C.CustID, C.CustName,
		OH.CsrKey, S.CsrName, OD.Status, ODS.Description AS StatusName, 
		--b.Genset, b.Hazard, b.NeedsToBeScaled, b.OTR, b.OverWeight, b.Permits, b.Transload, b.Triaxle, b.WeekendDelivery
		convert(bit, isnull(Genset,0)) as Genset,
			convert(bit, isnull(Hazard,0)) as Hazard,
			convert(bit,isnull([Needs to be scaled],0)) as 'NeedsToBeScaled',
			convert(bit,isnull(OTR,0)) as OTR, 
			convert(bit,isnull([Over weight],0)) as 'OverWeight',
			convert(bit,isnull(Permits,0)) as Permits, 
			convert(bit,isnull(Transload,0)) as Transload,
			convert(bit,isnull(Triaxle,0)) as Triaxle, 
			convert(bit,isnull([Weekend delivery],0)) as 'WeekendDelivery' 
	from OrderDetail OD WITH (NOLOCK)
	INNER JOIN OrderHeader OH  WITH (NOLOCK) ON OD.OrderKey = OH.OrderKey
	INNER JOIN Customer C  WITH (NOLOCK) ON OH.CustKey = C.CustKey
	LEFT JOIN CSR S  WITH (NOLOCK) ON OH.CsrKey = S.CsrKey
	LEFT JOIN OrderDetailStatus ODS  WITH (NOLOCK) ON OD.Status = ODS.Status
	lEFT JOIN (
		select OrderDetailKey, Genset, Hazard, [Needs to be scaled], OTR, [Over weight], Permits, Transload, Triaxle, [Weekend delivery]
			from (
		select CTL.OrderDetailKey,  CT.TypeID, convert(smallint, isnull(CTL.IsSelected,0)) as IsSelected
			from ContainerTypes CT WITH (NOLOCK)
			left join ContainerTypesLink CTL WITH (NOLOCK) ON CT.ContainerTypeKey = CTL.ContainerTypeKey 
		) A
		PIVOT
		(  
		  max(isSelected)
		  FOR Typeid IN (Genset,Hazard,[Needs to be scaled],OTR,[Over weight],Permits,Transload,Triaxle,[Weekend delivery])
		) AS Alias
	) B ON OD.OrderDetailKey = B.OrderDetailKey
	WHERE 1 = 1 AND
		( ISNULL(@CustKey,0) = 0 OR C.CustKey = @CustKey) AND
		( ISNULL(@OrderNo,'') = '' OR OH.OrderNo LIKE '%' + @OrderNo + '%') AND
		( ISNULL(@ContainerNo,'') = '' OR OD.ContainerNo LIKE '%' + @ContainerNo + '%') AND
		( ISNULL(@CsrKey,0) = 0 OR OH.CsrKey = @CsrKey) AND
		( ISNULL(@StatusKey,0) = 0 OR OD.Status = @StatusKey)
	order by OD.ContainerNo
	FOR JSON PATH;

	SET @Status=1;
	SET @reason='Success';
END