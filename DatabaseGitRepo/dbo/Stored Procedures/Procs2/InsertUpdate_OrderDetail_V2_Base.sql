/**
DECLARE @UserKey INT=29,
	@JSONString NVARCHAR(MAX)='[{"OrderKey":144871,"ContainerId":"FL.012502XXX_ABCD1234577","Containerno":"ABCD1234577","ContainerSize":3,"Chassis":"","Sealno":"1234","Weight":1200.00,"WeightUnit":0,"Comment":"Hazard, Transload, ","CreateUserKey":29,"OrderType":1,"BookingNo":"Booking-1234","Ref":"CUSTREF-1234"}]',
	@Status BIT=0,@IsDebug		BIT = 0, 
	@JsonOutput nvarchar(max) ='', 	@Reason VARCHAR(100)=''
Exec [InsertUpdate_OrderDetail_V2] @UserKey,@JSONString,@JsonOutput OUTPUT,@Status OUTPUT,@Reason OUTPUT, @IsDebug
Select @JsonOutput, @Status, @Reason
**/
CREATE PROC [dbo].[InsertUpdate_OrderDetail_V2_Base]
(
	@UserKey			int,
	@JsonString			nvarchar(max) = '',
	@JsonOutput			nvarchar(max) ='' OUTPUT,
	@Status				bit = 0 output,
	@Reason				varchar(500) = '' OUTPUT,
	@IsDebug			bit = 0
)
As
BEGIN
	Declare
	@Orderkey		INT,
	@OrderDetailKey INT,
	@ContainerId    VARCHAR(50),
	@Containerno	VARCHAR(30),
	@ContainerSize	SMALLINT,
	@Chassis		VARCHAR(30)=NUll,
	@Sealno			VARCHAR(30)=NULL,
	@Weight			DECIMAL(18,2)=Null,
	@WeightUnit		SMALLINT=0,
	@Comment		VARCHAR(500)=NULL,
	@CreateUserKey	INT,
	@VesselETA		DateTime = null,
	@IsHazardus		BIT=0,
	@OrderType			int			,
	@BookingNo			varchar(50)	,
	@Ref				varchar(50)	,
	@DropOrLive			varchar(10)	,
	@PriorityKey		int			,
	@StopDetailKeySF	int,
	@StopDetailKeyST	int,
	@StopDetailKeyRT	int,
	@StopDetailKeySTA	int,
	@StopDetailKeySTB	int,
	@LocTypeSF			varchar(50),	
	@LocTypeST			varchar(50),	
	@LocTypeRT			varchar(50),	
	@LocTypeSTA			varchar(50),	
	@LocTypeSTB			varchar(50),	
	@ODStopKeySF			bigint,		
	@ODStopKeyST			bigint,		
	@ODStopKeyRT			bigint,		
	@ODStopKeySTA			bigint,	
	@ODStopKeySTB			bigint,		
	@Containerprops		nvarchar(max),
	@CSRKey					INT,
	@DropLive			VARCHAR(10)


	DECLARE @UnspecifiedAddrKey	INT=38953;
	SET NOCOUNT ON
	SET FMTONLY OFF

	IF ISNULL(@JSONString, '') = ''
    BEGIN
        SET @Status = 0;
        SET @Reason = 'Invalid JSON input';
        RETURN;
    END

	SELECT 
		@Orderkey			= Orderkey	,
		@OrderDetailKey		= OrderDetailKey,
		@ContainerId		= ContainerId   , 
		@Containerno		= Containerno	,
		@ContainerSize		= ContainerSize,	
		@Chassis			= Chassis		,
		@Sealno				= Sealno		,	
		@Weight				= Weight		,	
		@WeightUnit			= WeightUnit	,	
		@Comment			= Comment		,
		@CreateUserKey		= CreateUserKey,	
		@VesselETA			= VesselETA	,	
		@IsHazardus			= IsHazardus	,
		@OrderType			=	OrderType	,
		@BookingNo			=	BookingNo	,
		@Ref				=	Ref			,	
		@DropOrLive			=	DropOrLive	,
		@PriorityKey		=	PriorityKey	,	
		@StopDetailKeySF	= StopDetailKeySF,	
		@StopDetailKeyST	= StopDetailKeyST,	
		@StopDetailKeyRT	= StopDetailKeyRT,	
		@StopDetailKeySTA	= StopDetailKeySTA,	
		@StopDetailKeySTB	= StopDetailKeySTB,
		@LocTypeSF			= LocTypeSF	,
		@LocTypeST			= LocTypeST	,	
		@LocTypeRT			= LocTypeRT	,	
		@LocTypeSTA			= LocTypeSTA,		
		@LocTypeSTB			= LocTypeSTB,		
		@ODStopKeySF		= ODStopKeySF,			
		@ODStopKeyST		= ODStopKeyST,			
		@ODStopKeyRT		= ODStopKeyRT,			
		@ODStopKeySTA		= ODStopKeySTA,	
		@ODStopKeySTB		= ODStopKeySTB,	
		@Containerprops		= Containerprops	,
		@CSRKey				= CSRKey,
		@DropLive			= DropLive
    FROM OPENJSON(@JSONString)
    WITH (
        OrderKey			INT				'$.OrderKey',
		OrderDetailKey		INT				'$.OrderDetailKey',
		ContainerId			VARCHAR(50)		'$.ContainerId',
		Containerno			VARCHAR(30)		'$.Containerno',
		ContainerSize		SMALLINT		'$.ContainerSize',
		Chassis				VARCHAR(30)		'$.Chassis',
		Sealno				VARCHAR(30)		'$.Sealno',
		Weight				DECIMAL(18,2)	'$.Weight',
		WeightUnit			SMALLINT		'$.WeightUnit',
		Comment				VARCHAR(500)	'$.Comment',
		CreateUserKey		INT				'$.CreateUserKey',
		VesselETA			varchar(50)		'$.VesselETA',
		IsHazardus			BIT				'$.IsHazardus',
		OrderType			int				'$.OrderType',
		BookingNo			varchar(50)		'$.BookingNo',
		Ref					varchar(50)		'$.Ref',
		DropOrLive			varchar(10)		'$.DropOrLive',
		PriorityKey			int				'$.PriorityKey',
		StopDetailKeySF		int				'$.StopDetailKeySF',
		StopDetailKeyST		int				'$.StopDetailKeyST',
		StopDetailKeyRT		int				'$.StopDetailKeyRT',
		StopDetailKeySTA	int				'$.StopDetailKeySTA',
		StopDetailKeySTB	int				'$.StopDetailKeySTB',
		LocTypeSF			varchar(50)		'$.LocTypeSF',
		LocTypeST			varchar(50)		'$.LocTypeST',
		LocTypeRT			varchar(50)		'$.LocTypeRT',
		LocTypeSTA			varchar(50)		'$.LocTypeSTA',
		LocTypeSTB			varchar(50)		'$.LocTypeSTB',
		ODStopKeySF			bigint			'$.ODStopKeySF',		
		ODStopKeyST			bigint			'$.ODStopKeyST',		
		ODStopKeyRT			bigint			'$.ODStopKeyRT',		
		ODStopKeySTA		bigint			'$.ODStopKeySTA',		
		ODStopKeySTB		bigint			'$.ODStopKeySTB',		
		Containerprops		nvarchar(max)	'$.Containerprops',-- as JSON,
		CSRKEy				INT				'$.CSRKey',
		DropLive			VARCHAR(10)		'$.DropLive'
	)

	SET @DropLive=CASE WHEN @DropOrLive='Drop' THEN 'D' WHEN @DropOrLive='Live' THEN 'L' ELSE '' END;

    DECLARE 
		@NewOrderDetailKey	INT,
		@New_CommentKey		INT,
		@SourceAddrKey		INT,
		@DestAddrKey		INT,
		@Ouput				BIT,
		@OrderDetailStatus  SMALLINT,
		@New_Ordetail_StopKey INT

		SET @Comment= LTRIM(RTRIM(@Comment))

		SET @Ouput=0

		if(isnull(@OrderDetailKey ,0) = 0)
		Begin
			SET @OrderDetailStatus= (  SELECT CASE WHEN [Status]=8 THEN 11 ELSE 1 END  FROM dbo.OrderHeader WHERE OrderKey= @Orderkey )
			
			IF @OrderDetailStatus=11
			BEGIN
				UPDATE dbo.OrderDetail
				SET [Status]=11
				WHERE OrderKey=@Orderkey and [Status]<>11
			END
		End
		SELECT @OrderType= CASE WHEN ISNULL(@OrderType,0)=0 THEN 
				(  SELECT OrderTypeKey  FROM dbo.OrderHeader WHERE OrderKey= @Orderkey )
				ELSE @OrderType END

		if(isnull(@OrderDetailKey ,0) = 0)
		Begin

			INSERT INTO dbo.OrderDetail(OrderKey,ContainerID,ContainerNo,ContainerSizeKey,
				Chassis,SealNo,[Weight],WeightUnit,[Status],StatusDate,CreateUserKey,SourceAddrKey,
				DestinationAddrKey,CreateDate,IsHazardus, VesselETA, 
				BookingNo, CustRefNo, DropOrLive, PriorityKey, OrderTypeKey,
				ShipFromStopKey, ShipToStopKey, ReturnToStopKey, StopOffA_StopKey, StopOffB_StopKey,CSRKey) 
			VALUES  ( @Orderkey , @ContainerId,@Containerno , @ContainerSize ,
				@Chassis,@Sealno,@Weight, @WeightUnit,@OrderDetailStatus, GETDATE(),@CreateUserKey,@StopDetailKeySF,
				@StopDetailKeyST,GETDATE(),@IsHazardus, @VesselETA, 
				@BookingNo, @Ref, @DropOrLive, @PriorityKey, @OrderType,
				@StopDetailKeySF, @StopDetailKeyST, @StopDetailKeyRT, @StopDetailKeySTA, @StopDetailKeySTB,@CSRKey);
   
			SET @NewOrderDetailKey= ( SELECT SCOPE_IDENTITY() ) 
			UPDATE ContainerNum_AutoGen SET OrderDetailKey=@NewOrderDetailKey WHERE ContainerNo=@Containerno

			IF(ISNULL(@StopDetailKeySF,0) >0)
			BEGIN
				insert into OrderDetailStops 
					(OrderDetailKey, OrderStopKey, StopTypeKey, StopName, StopAddrKey,StopNumber,  LocationType)
				select @NewOrderDetailKey, OS.OrderStopKey, SF.StopTypeKey, A.AddrName, @StopDetailKeySF,OS.StopNumber, @LocTypeSF
				from Address A WITH (NOLOCK) 
				inner join StopsMaster SF WITH (NOLOCK) on 1=1 and SF.StopTypeShortcode = 'SF'
				LEFT join OrderStops OS WITH (NOLOCK) on OS.orderKey = @Orderkey and Os.StopTypeKey = SF.StopTypeKey
				where Addrkey = @StopDetailKeySF
				--added by praveen wrong stopkeys being inserted
				SET @New_Ordetail_StopKey=(SELECT SCOPE_IDENTITY())
				UPDATE OrderDetail SET ShipFromStopKey=@New_Ordetail_StopKey, SourceAddrKey=@StopDetailKeySF  WHERE OrderDetailKey=@NewOrderDetailKey
			End
			ELSE--added for unspecified
			BEGIN
				insert into OrderDetailStops 
					(OrderDetailKey, OrderStopKey, StopTypeKey, StopName, StopAddrKey,StopNumber,  LocationType)
				select @NewOrderDetailKey, OS.OrderStopKey, SF.StopTypeKey, A.AddrName, @UnspecifiedAddrKey,OS.StopNumber, @LocTypeSF
				from Address A WITH (NOLOCK) 
				inner join StopsMaster SF WITH (NOLOCK) on 1=1 and SF.StopTypeShortcode = 'SF'
				LEFT join OrderStops OS WITH (NOLOCK) on OS.orderKey = @Orderkey and Os.StopTypeKey = SF.StopTypeKey
				where Addrkey = @UnspecifiedAddrKey
				SET @New_Ordetail_StopKey=(SELECT SCOPE_IDENTITY())
				UPDATE OrderDetail SET ShipFromStopKey=@New_Ordetail_StopKey, SourceAddrKey=@UnspecifiedAddrKey  WHERE OrderDetailKey=@NewOrderDetailKey
			END

			if(isnull(@StopDetailKeyST,0) >0)
			Begin
				insert into OrderDetailStops 
					(OrderDetailKey, OrderStopKey, StopTypeKey, StopName, StopAddrKey,StopNumber,  LocationType, DropOrLive)
				select @NewOrderDetailKey, OS.OrderStopKey, ST.StopTypeKey, A.AddrName, @StopDetailKeyST,OS.StopNumber, @LocTypeST, @DropLive
				from Address A WITH (NOLOCK) 
				inner join StopsMaster ST WITH (NOLOCK) on 1=1 and ST.StopTypeShortcode = 'ST'
				LEFT join OrderStops OS WITH (NOLOCK) on OS.orderKey = @Orderkey and Os.StopTypeKey = ST.StopTypeKey
				where Addrkey = @StopDetailKeyST
				--added by praveen wrong stopkeys being inserted
				SET @New_Ordetail_StopKey=(SELECT SCOPE_IDENTITY())
				UPDATE OrderDetail SET ShipToStopKey=@New_Ordetail_StopKey, DestinationAddrKey=@StopDetailKeyST  WHERE OrderDetailKey=@NewOrderDetailKey
			End
			ELSE--added for unspecified
			BEGIN
				insert into OrderDetailStops 
					(OrderDetailKey, OrderStopKey, StopTypeKey, StopName, StopAddrKey,StopNumber,  LocationType, DropOrLive)
				select @NewOrderDetailKey, OS.OrderStopKey, ST.StopTypeKey, A.AddrName, @UnspecifiedAddrKey,OS.StopNumber, @LocTypeST, @DropLive
				from Address A WITH (NOLOCK) 
				inner join StopsMaster ST WITH (NOLOCK) on 1=1 and ST.StopTypeShortcode = 'ST'
				LEFT join OrderStops OS WITH (NOLOCK) on OS.orderKey = @Orderkey and Os.StopTypeKey = ST.StopTypeKey
				where Addrkey = @UnspecifiedAddrKey
				--added by praveen wrong stopkeys being inserted
				SET @New_Ordetail_StopKey=(SELECT SCOPE_IDENTITY())
				UPDATE OrderDetail SET ShipToStopKey=@New_Ordetail_StopKey, DestinationAddrKey=@UnspecifiedAddrKey  WHERE OrderDetailKey=@NewOrderDetailKey
			END
			
			if(isnull(@StopDetailKeyRT,0) >0)
			Begin
				insert into OrderDetailStops 
					(OrderDetailKey, OrderStopKey, StopTypeKey, StopName, StopAddrKey,StopNumber,  LocationType)
				select @NewOrderDetailKey, OS.OrderStopKey, RT.StopTypeKey, A.AddrName, @StopDetailKeyRT,OS.StopNumber, @LocTypeRT
				from Address A WITH (NOLOCK) 
				inner join StopsMaster RT WITH (NOLOCK) on 1=1 and RT.StopTypeShortcode = 'RT'
				LEFT join OrderStops OS WITH (NOLOCK) on OS.orderKey = @Orderkey and Os.StopTypeKey = RT.StopTypeKey
				where Addrkey = @StopDetailKeyRT
				--added by praveen wrong stopkeys being inserted
				SET @New_Ordetail_StopKey=(SELECT SCOPE_IDENTITY())
				UPDATE OrderDetail SET ReturnToStopKey=@New_Ordetail_StopKey  WHERE OrderDetailKey=@NewOrderDetailKey
				UPDATE OrderHeader SET ReturnAddrKey=@StopDetailKeyRT  WHERE OrderKey=@Orderkey
			End

			if(isnull(@StopDetailKeySTA,0) >0)
			Begin
				insert into OrderDetailStops 
					(OrderDetailKey, OrderStopKey, StopTypeKey, StopName, StopAddrKey,  LocationType)
				select @NewOrderDetailKey, OS.OrderStopKey, STA.StopTypeKey, A.AddrName, @StopDetailKeySTA, @LocTypeSTA
				from Address A WITH (NOLOCK) 
				inner join StopsMaster STA WITH (NOLOCK) on 1=1 and STA.StopTypeShortcode = 'AF'
				LEFT join OrderStops OS WITH (NOLOCK) on OS.orderKey = @Orderkey and Os.StopTypeKey = STA.StopTypeKey
				where Addrkey = @StopDetailKeySTA
				--added by praveen wrong stopkeys being inserted
				SET @New_Ordetail_StopKey=(SELECT SCOPE_IDENTITY())
				UPDATE OrderDetail SET StopOffA_StopKey=@New_Ordetail_StopKey  WHERE OrderDetailKey=@NewOrderDetailKey
			End

			if(isnull(@StopDetailKeySTB,0) >0)
			Begin
				insert into OrderDetailStops 
					(OrderDetailKey, OrderStopKey, StopTypeKey, StopName, StopAddrKey,  LocationType)
				select @NewOrderDetailKey, OS.OrderStopKey, STB.StopTypeKey, A.AddrName, @StopDetailKeySTB, @LocTypeSTB
				from Address A WITH (NOLOCK) 
				inner join StopsMaster STB WITH (NOLOCK) on 1=1 and STB.StopTypeShortcode = 'AT'
				LEFT join OrderStops OS WITH (NOLOCK) on OS.orderKey = @Orderkey and Os.StopTypeKey = STB.StopTypeKey
				where Addrkey = @StopDetailKeySTB
				--added by praveen wrong stopkeys being inserted
				SET @New_Ordetail_StopKey=(SELECT SCOPE_IDENTITY())
				UPDATE OrderDetail SET StopOffB_StopKey=@New_Ordetail_StopKey  WHERE OrderDetailKey=@NewOrderDetailKey
			End

			IF(@OrderType=4)
			BEGIN
				UPDATE OrderDetail SET IsEmpty=1 WHERE OrderDetailKey=@NewOrderDetailKey
			END
		End 
		ELSE
		BEGIN
		SET @NewOrderDetailKey=@OrderDetailKey
		print 'update'
		print '@OrderDetailKey'
		print @OrderDetailKey
			UPDATE ORderDetail SET
				ContainerNo			= @ContainerNo ,
				ContainerSizeKey	= @ContainerSize,
				Chassis				= @Chassis ,
				SealNo				= @SealNo,
				[Weight]			= @Weight,
				WeightUnit			= @WeightUnit,
				LastUpdateDate		=GETDATE(),
				VesselETA			= @VesselETA,
				DropOrLive			= @DropOrLive,
				BookingNo			= @BookingNo,
				CustRefNo			= @Ref,
				PriorityKey			= @PriorityKey,
				OrderTypeKey		= @OrderType,
				--ShipFromStopKey		= @StopDetailKeySF,
				--ShipToStopKey		= @StopDetailKeyST,
				--ReturnToStopKey		= @StopDetailKeyRT,
				--StopOffA_StopKey	= @StopDetailKeySTA,
				--StopOffB_StopKey	= @StopDetailKeySTB,
				CSRKey				= @CSRKey
			Where OrderDetailKey	= @OrderDetailKey

			print '@StopDetailKeySF'
		print @StopDetailKeySF
	
			if(isnull(@StopDetailKeySF,0) >0)
			Begin
				if(isnull(@ODStopKeySF,0) = 0  )
				Begin
				print '@ODStopKeySF'
		print @ODStopKeySF
					insert into OrderDetailStops 
						(OrderDetailKey, OrderStopKey, StopTypeKey, StopName, StopAddrKey,  LocationType)
					select @NewOrderDetailKey, OS.OrderStopKey, SF.StopTypeKey, A.AddrName, @StopDetailKeySF, @LocTypeSF
					from Address A WITH (NOLOCK) 
					inner join StopsMaster SF WITH (NOLOCK) on 1=1 and SF.StopTypeShortcode = 'SF'
					LEFT join OrderStops OS WITH (NOLOCK) on OS.orderKey = @Orderkey and OS.StopTypeKey = SF.StopTypeKey
					where Addrkey = @StopDetailKeySF
					--added by praveen wrong stopkeys being inserted
					SET @New_Ordetail_StopKey=(SELECT SCOPE_IDENTITY())
					UPDATE OrderDetail SET ShipFromStopKey=@New_Ordetail_StopKey, SourceAddrKey=@StopDetailKeySF  WHERE OrderDetailKey=@NewOrderDetailKey
				End
				ELSE
				BEGIN
					Update ODS SET
						StopName = A.addrname,
						StopAddrKey = @StopDetailKeySF
					from OrderDetailStops ODS
					inner join Address A on A.AddrKey = @StopDetailKeySF
					Where OrderDetailStopKey = @ODStopKeySF

					UPDATE OD SET OD.SourceAddrKey=@StopDetailKeySF
						FROM OrderDetail OD WHERE Od.OrderDetailKey=@OrderDetailKey
				END
			End

			if(isnull(@StopDetailKeyST,0) >0)
			Begin
				if(isnull(@ODStopKeyST,0) = 0  )
				Begin
				print '@@ODStopKeyST'
		print @ODStopKeyST
					insert into OrderDetailStops 
						(OrderDetailKey, OrderStopKey, StopTypeKey, StopName, StopAddrKey,  LocationType)
					select @NewOrderDetailKey, OS.OrderStopKey, ST.StopTypeKey, A.AddrName, @StopDetailKeyST, @LocTypeST
					from Address A WITH (NOLOCK) 
					inner join StopsMaster ST WITH (NOLOCK) on 1=1 and ST.StopTypeShortcode = 'ST'
					LEFT join OrderStops OS WITH (NOLOCK) on OS.orderKey = @Orderkey and Os.StopTypeKey = ST.StopTypeKey
					where Addrkey = @StopDetailKeyST
					--added by praveen wrong stopkeys being inserted
					SET @New_Ordetail_StopKey=(SELECT SCOPE_IDENTITY())
					UPDATE OrderDetail SET ShipToStopKey=@New_Ordetail_StopKey, DestinationAddrKey=@StopDetailKeyST  WHERE OrderDetailKey=@NewOrderDetailKey
				End
				ELSE
				BEGIN
					Update ODS SET
						StopName = A.addrname,
						StopAddrKey = @StopDetailKeyST
					from OrderDetailStops ODS
					inner join Address A on A.AddrKey = @StopDetailKeyST
					Where OrderDetailStopKey = @ODStopKeyST

					UPDATE OD SET OD.DestinationAddrKey=@StopDetailKeyST
						FROM OrderDetail OD WHERE Od.OrderDetailKey=@OrderDetailKey
				END
			End

			if(isnull(@StopDetailKeyRT,0) >0)
			Begin
				if(isnull(@ODStopKeyRT,0) = 0  )
				Begin
				print '@@ODStopKeyRT'
		print @ODStopKeyRT
					insert into OrderDetailStops 
						(OrderDetailKey, OrderStopKey, StopTypeKey, StopName, StopAddrKey,  LocationType)
					select @NewOrderDetailKey, OS.OrderStopKey, RT.StopTypeKey, A.AddrName, @StopDetailKeyRT, @LocTypeRT
					from Address A WITH (NOLOCK) 
					inner join StopsMaster RT WITH (NOLOCK) on 1=1 and RT.StopTypeShortcode = 'RT'
					LEFT join OrderStops OS WITH (NOLOCK) on OS.orderKey = @Orderkey and Os.StopTypeKey = RT.StopTypeKey
					where Addrkey = @StopDetailKeyRT
					--added by praveen wrong stopkeys being inserted
					SET @New_Ordetail_StopKey=(SELECT SCOPE_IDENTITY())
					UPDATE OrderDetail SET ReturnToStopKey=@New_Ordetail_StopKey  WHERE OrderDetailKey=@NewOrderDetailKey
					UPDATE OrderHeader SET ReturnAddrKey=@StopDetailKeyRT  WHERE OrderKey=@Orderkey
				End
				ELSE
				BEGIN
					Update ODS SET
						StopName = A.addrname,
						StopAddrKey = @StopDetailKeyRT
					from OrderDetailStops ODS
					inner join Address A on A.AddrKey = @StopDetailKeyRT
					Where OrderDetailStopKey = @ODStopKeyRT
					UPDATE OrderHeader SET ReturnAddrKey=@StopDetailKeyRT  WHERE OrderKey=@Orderkey
				END
			End

			if(isnull(@StopDetailKeySTA ,0) >0)
			Begin
				if(isnull(@ODStopKeySTA,0) = 0  )
				Begin
				print '@@ODStopKeySTA'
		print @ODStopKeySTA
					insert into OrderDetailStops 
						(OrderDetailKey, OrderStopKey, StopTypeKey, StopName, StopAddrKey,  LocationType)
					select @NewOrderDetailKey, OS.OrderStopKey, STA.StopTypeKey, A.AddrName, @StopDetailKeySTA, @LocTypeSTA
					from Address A WITH (NOLOCK) 
					inner join StopsMaster STA WITH (NOLOCK) on 1=1 and STA.StopTypeShortcode = 'AF'
					LEFT join OrderStops OS WITH (NOLOCK) on OS.orderKey = @Orderkey and Os.StopTypeKey = STA.StopTypeKey
					where Addrkey = @StopDetailKeySTA

					--added by praveen wrong stopkeys being inserted
					SET @New_Ordetail_StopKey=(SELECT SCOPE_IDENTITY())
					UPDATE OrderDetail SET StopOffA_StopKey=@New_Ordetail_StopKey  WHERE OrderDetailKey=@NewOrderDetailKey
				End
				ELSE
				BEGIN
					Update ODS SET
						StopName = A.addrname,
						StopAddrKey = @StopDetailKeySTA
					from OrderDetailStops ODS
					inner join Address A on A.AddrKey = @StopDetailKeySTA
					Where OrderDetailStopKey = @ODStopKeySTA

					--added by praveen wrong stopkeys being inserted
					UPDATE OrderDetail SET StopOffA_StopKey=@StopDetailKeySTA  WHERE OrderDetailKey=@NewOrderDetailKey
				END
			End

			if(isnull(@StopDetailKeySTB ,0) >0)
			Begin
				if(isnull(@ODStopKeySTB,0) = 0  )
				Begin
				print '@@ODStopKeySTB'
		print @ODStopKeySTB
					insert into OrderDetailStops 
						(OrderDetailKey, OrderStopKey, StopTypeKey, StopName, StopAddrKey,  LocationType)
					select @NewOrderDetailKey, OS.OrderStopKey, STB.StopTypeKey, A.AddrName, @StopDetailKeySTB, @LocTypeSTB
					from Address A WITH (NOLOCK) 
					inner join StopsMaster STB WITH (NOLOCK) on 1=1 and STB.StopTypeShortcode = 'AT'
					LEFT join OrderStops OS WITH (NOLOCK) on OS.orderKey = @Orderkey and Os.StopTypeKey = STB.StopTypeKey
					where Addrkey = @StopDetailKeySTB

					--added by praveen wrong stopkeys being inserted
					SET @New_Ordetail_StopKey=(SELECT SCOPE_IDENTITY())
					UPDATE OrderDetail SET StopOffB_StopKey=@New_Ordetail_StopKey  WHERE OrderDetailKey=@NewOrderDetailKey
				End
				ELSE
				BEGIN
					Update ODS SET
						StopName = A.addrname,
						StopAddrKey = @StopDetailKeySTB
					from OrderDetailStops ODS
					inner join Address A on A.AddrKey = @StopDetailKeySTB
					Where OrderDetailStopKey = @ODStopKeySTB

					--added by praveen wrong stopkeys being inserted
					UPDATE OrderDetail SET StopOffB_StopKey=@StopDetailKeySTB  WHERE OrderDetailKey=@NewOrderDetailKey
				END
			End
		END

	    IF ISNULL(LTRIM(RTRIM(@Comment)),'')<>''
		BEGIN
			--***********************Update Container Type items****************
				EXECUTE Update_ContainerTypeItem @OrderDetailKey= @NewOrderDetailKey,@ContType=@Comment,@CreateUserKey=@CreateUserKey

				SELECT ContainerTypeKey,OrderDetailKey
				INTO #ContainerProps
				FROM OPENJSON(@Containerprops,'$')
				WITH (
					ContainerTypeKey		int		'$.ContainerTypeKey',
					OrderDetailKey			INT		'$.OrderDetailKey'
					)

				--selecT '@Containerprops',@Containerprops
				--SELECT '#ContainerProps',* FROM #ContainerProps
				INSERT INTO ContainerTypesLink
				(OrderDetailKey,CommentKey,ContainerTypeKey,IsSelected)
				SELECT @NewOrderDetailKey,0,ContainerTypeKey,1 FROM #ContainerProps
				drop table #ContainerProps
			--*****************************************************************			
		END	
		SEt @JsonOutput = (select @NewOrderDetailKey as OrderDetailKey for JSON PATH)
		-- exec CreateDefaultRoutes @Orderkey, @NewOrderDetailKey, @CreateUserKey
		
		SET @Ouput= 1

		--SELECT @Ouput AS Result
END;
