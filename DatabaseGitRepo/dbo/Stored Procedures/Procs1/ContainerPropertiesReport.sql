
CREATE proc [dbo].[ContainerPropertiesReport]
(
	@CustKey		int = 0,
	@OrderNo		varchar(50) = '',
	@ContainerNo	varchar(50) = '',
	@DateFrom		DateTime = '2020-01-01',
	@DateTo			Datetime = '2050-12-31',
	@CSRKey			int	= 0,
	@StatusKey		int = 0
)
as
BEGIN
	select OH.OrderKey, OH.OrderNo, OD.OrderDetailKey, OD.ContainerNo, OH.CustKey, C.CustID, C.CustName,
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
		( ISNULL(@CSRKey,0) = 0 OR OH.CsrKey = @CSRKey) AND
		( ISNULL(@StatusKey,0) = 0 OR OD.Status = @StatusKey)
	order by OD.ContainerNo

END
