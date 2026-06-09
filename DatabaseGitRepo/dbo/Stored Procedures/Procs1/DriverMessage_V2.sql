/** 
Declare 
	@UserKey		INT,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING		NVARCHAR(Max) = '{"RouteKey":690755}'
	EXEC [DriverMessage_V2] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
	SELECT @Status, @Reason
**/
CREATE PROCEDURE [dbo].[DriverMessage_V2] -- DriverMessage 171659
(
	@UserKey		INT = 1144,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0 
)
as
Begin
	SET NOCOUNT ON
	SET FMTONLY OFF

	IF ISNULL(@JSONString, '') = ''
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'Parameters not found'
			RETURN
		END	
		
	IF (@IsDebug = 1)
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'In Debug Mode'
		END	

	DECLARE 
		@RouteKey		int = 100,
		@Message		varchar(MAX) = '',
		@Title			varchar(100)=''

	SELECT 
		@RouteKey		=		RouteKey
		-- @Message		=		Message,
		-- @Title			=		Title
	FROM OPENJSON(@JSONString)
	WITH
	(
		RouteKey			INT				'$.RouteKey'
		-- Message				VARCHAR(MAX)	'$.Message',
		-- Title				VARCHAR(100)	'$.Title'
	)

	DECLARE @OrderDetailKey	int,
			@OrderKey		int,
			@OrderTypeKey	smallint,
			@Ordertype		varchar(10),
			@LegID			varchar(200),
			@MEssageTemplate	nvarchar(2000),
			@FromLoation	varchar(20),
			@ToLocation		varchar(20)


	select	@OrderDetailKey = OD.OrderDetailKey, 
			@OrderKey = OD.OrderKey, 
			@OrderTypeKey = OH.OrderTypeKey, 
			@Ordertype = OT.OrderType,
			@LegID = L.LegID,
			@FromLoation = L.FromLocation,
			@ToLocation = L.ToLocation,
			@MEssageTemplate = L.DriverMessageTemplate
	from Routes R WITH (NOLOCK)
	inner join OrderDetail OD WITH (NOLOCK) on R.OrderDetailKey = OD.OrderDetailKey
	inner join OrderHeader OH WITH (NOLOCK) on OD.OrderKey = OH.OrderKey
	inner join OrderType OT WITH (NOLOCK) on Oh.OrderTypeKey = OT.OrderTypeKey
	inner join Leg L WITH (NOLOCK) on r.LegKey = L.LegKey
	where R.RouteKey = @RouteKey

	print @OrderDetailKey
	print @OrderKey
	print @OrderTypeKey
	print @Ordertype
	print @LegID
	print @MEssageTemplate

	if(isnull(@MessageTemplate,'') = '')
	begin
		set @status = 0
		set @Reason = 'Message Template not defined'
		return
	end
	/*
	{{FROMLOCATION}} = 58
	{{TOLOCATION}}  = 58
	{{PICKUPTIME}}  = 57
	{{DELIVERYTIME}} = 5
	{{DELIVERYCONF}}  = 47
	{{PICKUPCONF}} = 10
	{{FROMADDRESS}
	{{TOADDRESS}} = 9
	{{CONTAINER#}} {{SIZE}}
	*/
	set @Title = 'Message from JCB'

	set @status = 1
	set @Reason = 'Message Created Successfully'

	select	@Message =
		replace(
			replace(
				replace(
					replace(
						replace(
							replace(
								replace(
									replace(
										replace(
											REPLACE(@MEssageTemplate,'{{FROMLOCATION}}',isnull(F.AddrName,'NA'))
										, '{{TOLOCATION}}', isnull(D.AddrName,'NA'))
									, '{{PICKUPTIME}}',case when  R.PickupDateFrom is null then 'NA' else convert(varchar, R.PickupDateFrom, 101) + ' ' +  left(convert(varchar, r.PickupDateFrom, 108),5) end)
								, '{{DELIVERYTIME}}', case when R.DeliveryDateFrom is null then 'NA' else convert(varchar, R.DeliveryDateFrom, 101) + ' ' +  left(convert(varchar, r.DeliveryDateFrom, 108),5) end)
							, '{{DELIVERYCONF}}', isnull(r.DelConfirmationNo,'NA'))
						, '{{PICKUPCONF}}', isnull(r.ConfirmationNo,'NA'))
					, '{{TOADDRESS}}', ( ISNULL(D.ADDRESS1,'') + ', ' + ISNULL(D.ADDRESS2,'') + ', ' + ISNULL(D.CITY,'') + ', ' + ISNULL(D.STATE,'')  + '-' + ISNULL(D.ZIPCODE,'') + ISNULL(D.COUNTRY,'')))
				, '{{CONTAINER#}}', isnull(OD.ContainerNo,'NA'))
			, '{{SIZE}}', isnull(Cs.Description,'NA'))
		, '{{FROMADDRESS}}', ( ISNULL(F.ADDRESS1,'') + ', ' + ISNULL(F.ADDRESS2,'') + ', ' + ISNULL(F.CITY,'') + ', ' + ISNULL(F.STATE,'')  + '-' + ISNULL(F.ZIPCODE,'') + ISNULL(F.COUNTRY,'')))
	from Routes R WITH (NOLOCK)
	inner join OrderDetail OD WITH (NOLOCK) on R.OrderDetailKey = OD.OrderDetailKey
	inner join OrderHeader OH WITH (NOLOCK) on OD.OrderKey = OH.OrderKey
	inner join OrderType OT WITH (NOLOCK) on Oh.OrderTypeKey = OT.OrderTypeKey
	inner join Leg L WITH (NOLOCK) on r.LegKey = L.LegKey
	inner join Address F WITH (NOLOCK) on R.SourceAddrKey = F.AddrKey
	inner join Address D WITH (NOLOCK) on R.DestinationAddrKey = D.AddrKey
	inner join ContainerSize CS WITH (NOLOCK) on OD.ContainerSizeKey = CS.ContainerSizeKey
	where R.RouteKey = @RouteKey

	SELECT @Message [Message], @Title Title FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
		


	print @Message
END