
/**
DECLARE @UserKey INT=29,
	@JSONString NVARCHAR(MAX)='[{"OrderKey":144871,"ContainerId":"FL.012502XXX_ABCD1234577","Containerno":"ABCD1234577","ContainerSize":3,"Chassis":"","Sealno":"1234","Weight":1200.00,"WeightUnit":0,"Comment":"Hazard, Transload, ","CreateUserKey":29,"OrderType":1,"BookingNo":"Booking-1234","Ref":"CUSTREF-1234"}]',
	@Status BIT=0,@IsDebug		BIT = 0, 
	@JsonOutput nvarchar(max) ='', 	@Reason VARCHAR(100)=''
Exec [InsertUpdate_OrderDetail_V2] @UserKey,@JSONString,@JsonOutput OUTPUT,@Status OUTPUT,@Reason OUTPUT, @IsDebug
Select @JsonOutput, @Status, @Reason
**/
CREATE PROC [dbo].[InsertUpdate_OrderDetail_V2]
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
	@StopAddrKeySF	int,
	@StopAddrKeyST	int,
	@StopAddrKeyRT	int,
	@StopAddrKeySTA	int,
	@StopAddrKeySTB	int,
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
	@DropLive			VARCHAR(10),
	@HazardClasses		VARCHAR(200)


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
		@StopAddrKeySF	= StopAddrKeySF,	
		@StopAddrKeyST	= StopAddrKeyST,	
		@StopAddrKeyRT	= StopAddrKeyRT,	
		@StopAddrKeySTA	= StopAddrKeySTA,	
		@StopAddrKeySTB	= StopAddrKeySTB,
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
		@DropLive			= DropLive,
		@HazardClasses		= HazardClasses
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
		StopAddrKeySF		int				'$.StopAddrKeySF',
		StopAddrKeyST		int				'$.StopAddrKeyST',
		StopAddrKeyRT		int				'$.StopAddrKeyRT',
		StopAddrKeySTA	int					'$.StopAddrKeySTA',
		StopAddrKeySTB	int					'$.StopAddrKeySTB',
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
		DropLive			VARCHAR(10)		'$.DropLive',
		HazardClasses		VARCHAR(200)	'$.HazardClasses'
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

		SELECT CAST([Value] as INT) AS ClassKey
		INTO #HazardClassKeys
		FROM Fn_SplitParamCol(@HazardClasses)

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
				@Chassis,@Sealno,@Weight, @WeightUnit,@OrderDetailStatus, GETDATE(),@CreateUserKey,@StopAddrKeySF,
				@StopAddrKeyST,GETDATE(),@IsHazardus, @VesselETA, 
				@BookingNo, @Ref, @DropOrLive, @PriorityKey, @OrderType,
				@StopAddrKeySF, @StopAddrKeyST, @StopAddrKeyRT, @StopAddrKeySTA, @StopAddrKeySTB,@CSRKey);
   
			SET @NewOrderDetailKey= ( SELECT SCOPE_IDENTITY() ) 
			UPDATE ContainerNum_AutoGen SET OrderDetailKey=@NewOrderDetailKey WHERE ContainerNo=@Containerno

			IF(ISNULL(@StopAddrKeySF,0) >0)
			BEGIN
				insert into OrderDetailStops 
					(OrderDetailKey, OrderStopKey, StopTypeKey, StopName, StopAddrKey,StopNumber,  LocationType)
				select @NewOrderDetailKey, OS.OrderStopKey, SF.StopTypeKey, A.AddrName, @StopAddrKeySF,isnull(OS.StopNumber,1), @LocTypeSF
				from Address A WITH (NOLOCK) 
				inner join StopsMaster SF WITH (NOLOCK) on 1=1 and SF.StopTypeShortcode = 'SF'
				LEFT join OrderStops OS WITH (NOLOCK) on OS.orderKey = @Orderkey and Os.StopTypeKey = SF.StopTypeKey
				where Addrkey = @StopAddrKeySF
				--added by praveen wrong stopkeys being inserted
				SET @New_Ordetail_StopKey=(SELECT SCOPE_IDENTITY())
				UPDATE OrderDetail SET ShipFromStopKey=@New_Ordetail_StopKey, SourceAddrKey=@StopAddrKeySF  WHERE OrderDetailKey=@NewOrderDetailKey
			End
			ELSE--added for unspecified
			BEGIN
				insert into OrderDetailStops 
					(OrderDetailKey, OrderStopKey, StopTypeKey, StopName, StopAddrKey,StopNumber,  LocationType)
				select @NewOrderDetailKey, OS.OrderStopKey, SF.StopTypeKey, A.AddrName, @UnspecifiedAddrKey,isnull(OS.StopNumber,1), @LocTypeSF
				from Address A WITH (NOLOCK) 
				inner join StopsMaster SF WITH (NOLOCK) on 1=1 and SF.StopTypeShortcode = 'SF'
				LEFT join OrderStops OS WITH (NOLOCK) on OS.orderKey = @Orderkey and Os.StopTypeKey = SF.StopTypeKey
				where Addrkey = @UnspecifiedAddrKey
				SET @New_Ordetail_StopKey=(SELECT SCOPE_IDENTITY())
				UPDATE OrderDetail SET ShipFromStopKey=@New_Ordetail_StopKey, SourceAddrKey=@UnspecifiedAddrKey  WHERE OrderDetailKey=@NewOrderDetailKey
			END

			if(isnull(@StopAddrKeyST,0) >0)
			Begin
				insert into OrderDetailStops 
					(OrderDetailKey, OrderStopKey, StopTypeKey, StopName, StopAddrKey,StopNumber,  LocationType, DropOrLive)
				select @NewOrderDetailKey, OS.OrderStopKey, ST.StopTypeKey, A.AddrName, @StopAddrKeyST,isnull(OS.StopNumber,2), @LocTypeST, @DropLive
				from Address A WITH (NOLOCK) 
				inner join StopsMaster ST WITH (NOLOCK) on 1=1 and ST.StopTypeShortcode = 'ST'
				LEFT join OrderStops OS WITH (NOLOCK) on OS.orderKey = @Orderkey and Os.StopTypeKey = ST.StopTypeKey
				where Addrkey = @StopAddrKeyST
				--added by praveen wrong stopkeys being inserted
				SET @New_Ordetail_StopKey=(SELECT SCOPE_IDENTITY())
				UPDATE OrderDetail SET ShipToStopKey=@New_Ordetail_StopKey, DestinationAddrKey=@StopAddrKeyST  WHERE OrderDetailKey=@NewOrderDetailKey
			End
			ELSE--added for unspecified
			BEGIN
				insert into OrderDetailStops 
					(OrderDetailKey, OrderStopKey, StopTypeKey, StopName, StopAddrKey,StopNumber,  LocationType, DropOrLive)
				select @NewOrderDetailKey, OS.OrderStopKey, ST.StopTypeKey, A.AddrName, @UnspecifiedAddrKey,isnull(OS.StopNumber,2), @LocTypeST, @DropLive
				from Address A WITH (NOLOCK) 
				inner join StopsMaster ST WITH (NOLOCK) on 1=1 and ST.StopTypeShortcode = 'ST'
				LEFT join OrderStops OS WITH (NOLOCK) on OS.orderKey = @Orderkey and Os.StopTypeKey = ST.StopTypeKey
				where Addrkey = @UnspecifiedAddrKey
				--added by praveen wrong stopkeys being inserted
				SET @New_Ordetail_StopKey=(SELECT SCOPE_IDENTITY())
				UPDATE OrderDetail SET ShipToStopKey=@New_Ordetail_StopKey, DestinationAddrKey=@UnspecifiedAddrKey  WHERE OrderDetailKey=@NewOrderDetailKey
			END
			
			if(isnull(@StopAddrKeyRT,0) >0)
			Begin
				insert into OrderDetailStops 
					(OrderDetailKey, OrderStopKey, StopTypeKey, StopName, StopAddrKey,StopNumber,  LocationType)
				select @NewOrderDetailKey, OS.OrderStopKey, RT.StopTypeKey, A.AddrName, @StopAddrKeyRT,isnull(OS.StopNumber,3), @LocTypeRT
				from Address A WITH (NOLOCK) 
				inner join StopsMaster RT WITH (NOLOCK) on 1=1 and RT.StopTypeShortcode = 'RT'
				LEFT join OrderStops OS WITH (NOLOCK) on OS.orderKey = @Orderkey and Os.StopTypeKey = RT.StopTypeKey
				where Addrkey = @StopAddrKeyRT
				--added by praveen wrong stopkeys being inserted
				SET @New_Ordetail_StopKey=(SELECT SCOPE_IDENTITY())
				UPDATE OrderDetail SET ReturnToStopKey=@New_Ordetail_StopKey  WHERE OrderDetailKey=@NewOrderDetailKey
				UPDATE OrderHeader SET ReturnAddrKey=@StopAddrKeyRT  WHERE OrderKey=@Orderkey
			End

			if(isnull(@StopAddrKeySTA,0) >0)
			Begin
				insert into OrderDetailStops 
					(OrderDetailKey, OrderStopKey, StopTypeKey, StopName, StopAddrKey,  LocationType)
				select @NewOrderDetailKey, OS.OrderStopKey, STA.StopTypeKey, A.AddrName, @StopAddrKeySTA, @LocTypeSTA
				from Address A WITH (NOLOCK) 
				inner join StopsMaster STA WITH (NOLOCK) on 1=1 and STA.StopTypeShortcode = 'AF'
				LEFT join OrderStops OS WITH (NOLOCK) on OS.orderKey = @Orderkey and Os.StopTypeKey = STA.StopTypeKey
				where Addrkey = @StopAddrKeySTA
				--added by praveen wrong stopkeys being inserted
				SET @New_Ordetail_StopKey=(SELECT SCOPE_IDENTITY())
				UPDATE OrderDetail SET StopOffA_StopKey=@New_Ordetail_StopKey  WHERE OrderDetailKey=@NewOrderDetailKey
			End

			if(isnull(@StopAddrKeySTB,0) >0)
			Begin
				insert into OrderDetailStops 
					(OrderDetailKey, OrderStopKey, StopTypeKey, StopName, StopAddrKey,  LocationType)
				select @NewOrderDetailKey, OS.OrderStopKey, STB.StopTypeKey, A.AddrName, @StopAddrKeySTB, @LocTypeSTB
				from Address A WITH (NOLOCK) 
				inner join StopsMaster STB WITH (NOLOCK) on 1=1 and STB.StopTypeShortcode = 'AT'
				LEFT join OrderStops OS WITH (NOLOCK) on OS.orderKey = @Orderkey and Os.StopTypeKey = STB.StopTypeKey
				where Addrkey = @StopAddrKeySTB
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
				--ShipFromStopKey		= @StopAddrKeySF,
				--ShipToStopKey		= @StopAddrKeyST,
				--ReturnToStopKey		= @StopAddrKeyRT,
				--StopOffA_StopKey	= @StopAddrKeySTA,
				--StopOffB_StopKey	= @StopAddrKeySTB,
				CSRKey				= @CSRKey
			Where OrderDetailKey	= @OrderDetailKey

			print '@StopAddrKeySF'
		print @StopAddrKeySF
	
			if(isnull(@StopAddrKeySF,0) >0)
			Begin
				if(isnull(@ODStopKeySF,0) = 0  )
				Begin
				print '@ODStopKeySF'
		print @ODStopKeySF
					insert into OrderDetailStops 
						(OrderDetailKey, OrderStopKey, StopTypeKey, StopName, StopAddrKey,  LocationType, StopNumber)
					select @NewOrderDetailKey, OS.OrderStopKey, SF.StopTypeKey, A.AddrName, @StopAddrKeySF, @LocTypeSF, isnull(OS.StopNumber,1)
					from Address A WITH (NOLOCK) 
					inner join StopsMaster SF WITH (NOLOCK) on 1=1 and SF.StopTypeShortcode = 'SF'
					LEFT join OrderStops OS WITH (NOLOCK) on OS.orderKey = @Orderkey and OS.StopTypeKey = SF.StopTypeKey
					where Addrkey = @StopAddrKeySF
					--added by praveen wrong stopkeys being inserted
					SET @New_Ordetail_StopKey=(SELECT SCOPE_IDENTITY())
					UPDATE OrderDetail SET ShipFromStopKey=@New_Ordetail_StopKey, SourceAddrKey=@StopAddrKeySF  WHERE OrderDetailKey=@NewOrderDetailKey
				End
				ELSE
				BEGIN
					Update ODS SET
						StopName = A.addrname,
						StopAddrKey = @StopAddrKeySF
					from OrderDetailStops ODS
					inner join Address A on A.AddrKey = @StopAddrKeySF
					Where OrderDetailStopKey = @ODStopKeySF

					UPDATE OD SET OD.SourceAddrKey=@StopAddrKeySF
						FROM OrderDetail OD WHERE Od.OrderDetailKey=@OrderDetailKey
				END
			End

			if(isnull(@StopAddrKeyST,0) >0)
			Begin
				if(isnull(@ODStopKeyST,0) = 0  )
				Begin
				print '@@ODStopKeyST'
		print @ODStopKeyST
					insert into OrderDetailStops 
						(OrderDetailKey, OrderStopKey, StopTypeKey, StopName, StopAddrKey,  LocationType, StopNumber)
					select @NewOrderDetailKey, OS.OrderStopKey, ST.StopTypeKey, A.AddrName, @StopAddrKeyST, @LocTypeST,isnull(OS.StopNumber,1)
					from Address A WITH (NOLOCK) 
					inner join StopsMaster ST WITH (NOLOCK) on 1=1 and ST.StopTypeShortcode = 'ST'
					LEFT join OrderStops OS WITH (NOLOCK) on OS.orderKey = @Orderkey and Os.StopTypeKey = ST.StopTypeKey
					where Addrkey = @StopAddrKeyST
					--added by praveen wrong stopkeys being inserted
					SET @New_Ordetail_StopKey=(SELECT SCOPE_IDENTITY())
					UPDATE OrderDetail SET ShipToStopKey=@New_Ordetail_StopKey, DestinationAddrKey=@StopAddrKeyST  WHERE OrderDetailKey=@NewOrderDetailKey
				End
				ELSE
				BEGIN
					Update ODS SET
						StopName = A.addrname,
						StopAddrKey = @StopAddrKeyST
					from OrderDetailStops ODS
					inner join Address A on A.AddrKey = @StopAddrKeyST
					Where OrderDetailStopKey = @ODStopKeyST

					UPDATE OD SET OD.DestinationAddrKey=@StopAddrKeyST
						FROM OrderDetail OD WHERE Od.OrderDetailKey=@OrderDetailKey
				END
			End

			if(isnull(@StopAddrKeyRT,0) >0)
			Begin
				if(isnull(@ODStopKeyRT,0) = 0  )
				Begin
				print '@@ODStopKeyRT'
		print @ODStopKeyRT
					insert into OrderDetailStops 
						(OrderDetailKey, OrderStopKey, StopTypeKey, StopName, StopAddrKey,  LocationType, StopNumber)
					select @NewOrderDetailKey, OS.OrderStopKey, RT.StopTypeKey, A.AddrName, @StopAddrKeyRT, @LocTypeRT, isnull(OS.StopNumber,1)
					from Address A WITH (NOLOCK) 
					inner join StopsMaster RT WITH (NOLOCK) on 1=1 and RT.StopTypeShortcode = 'RT'
					LEFT join OrderStops OS WITH (NOLOCK) on OS.orderKey = @Orderkey and Os.StopTypeKey = RT.StopTypeKey
					where Addrkey = @StopAddrKeyRT
					--added by praveen wrong stopkeys being inserted
					SET @New_Ordetail_StopKey=(SELECT SCOPE_IDENTITY())
					UPDATE OrderDetail SET ReturnToStopKey=@New_Ordetail_StopKey  WHERE OrderDetailKey=@NewOrderDetailKey
					UPDATE OrderHeader SET ReturnAddrKey=@StopAddrKeyRT  WHERE OrderKey=@Orderkey
				End
				ELSE
				BEGIN
					Update ODS SET
						StopName = A.addrname,
						StopAddrKey = @StopAddrKeyRT
					from OrderDetailStops ODS
					inner join Address A on A.AddrKey = @StopAddrKeyRT
					Where OrderDetailStopKey = @ODStopKeyRT
					UPDATE OrderHeader SET ReturnAddrKey=@StopAddrKeyRT  WHERE OrderKey=@Orderkey
				END
			End

			if(isnull(@StopAddrKeySTA ,0) >0)
			Begin
				if(isnull(@ODStopKeySTA,0) = 0  )
				Begin
				print '@@ODStopKeySTA'
		print @ODStopKeySTA
					insert into OrderDetailStops 
						(OrderDetailKey, OrderStopKey, StopTypeKey, StopName, StopAddrKey,  LocationType)
					select @NewOrderDetailKey, OS.OrderStopKey, STA.StopTypeKey, A.AddrName, @StopAddrKeySTA, @LocTypeSTA
					from Address A WITH (NOLOCK) 
					inner join StopsMaster STA WITH (NOLOCK) on 1=1 and STA.StopTypeShortcode = 'AF'
					LEFT join OrderStops OS WITH (NOLOCK) on OS.orderKey = @Orderkey and Os.StopTypeKey = STA.StopTypeKey
					where Addrkey = @StopAddrKeySTA

					--added by praveen wrong stopkeys being inserted
					SET @New_Ordetail_StopKey=(SELECT SCOPE_IDENTITY())
					UPDATE OrderDetail SET StopOffA_StopKey=@New_Ordetail_StopKey  WHERE OrderDetailKey=@NewOrderDetailKey
				End
				ELSE
				BEGIN
					Update ODS SET
						StopName = A.addrname,
						StopAddrKey = @StopAddrKeySTA
					from OrderDetailStops ODS
					inner join Address A on A.AddrKey = @StopAddrKeySTA
					Where OrderDetailStopKey = @ODStopKeySTA

					--added by praveen wrong stopkeys being inserted
					UPDATE OrderDetail SET StopOffA_StopKey=@StopAddrKeySTA  WHERE OrderDetailKey=@NewOrderDetailKey
				END
			End

			if(isnull(@StopAddrKeySTB ,0) >0)
			Begin
				if(isnull(@ODStopKeySTB,0) = 0  )
				Begin
				print '@@ODStopKeySTB'
		print @ODStopKeySTB
					insert into OrderDetailStops 
						(OrderDetailKey, OrderStopKey, StopTypeKey, StopName, StopAddrKey,  LocationType)
					select @NewOrderDetailKey, OS.OrderStopKey, STB.StopTypeKey, A.AddrName, @StopAddrKeySTB, @LocTypeSTB
					from Address A WITH (NOLOCK) 
					inner join StopsMaster STB WITH (NOLOCK) on 1=1 and STB.StopTypeShortcode = 'AT'
					LEFT join OrderStops OS WITH (NOLOCK) on OS.orderKey = @Orderkey and Os.StopTypeKey = STB.StopTypeKey
					where Addrkey = @StopAddrKeySTB

					--added by praveen wrong stopkeys being inserted
					SET @New_Ordetail_StopKey=(SELECT SCOPE_IDENTITY())
					UPDATE OrderDetail SET StopOffB_StopKey=@New_Ordetail_StopKey  WHERE OrderDetailKey=@NewOrderDetailKey
				End
				ELSE
				BEGIN
					Update ODS SET
						StopName = A.addrname,
						StopAddrKey = @StopAddrKeySTB
					from OrderDetailStops ODS
					inner join Address A on A.AddrKey = @StopAddrKeySTB
					Where OrderDetailStopKey = @ODStopKeySTB

					--added by praveen wrong stopkeys being inserted
					UPDATE OrderDetail SET StopOffB_StopKey=@StopAddrKeySTB  WHERE OrderDetailKey=@NewOrderDetailKey
				END
			End
		END

	    IF ISNULL(LTRIM(RTRIM(@Comment)),'')<>''
		BEGIN
			--***********************Update Container Type items****************
			print '@NewOrderDetailKey'
			print @NewOrderDetailKey
			print '@Containerprops'
			print @Containerprops
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
				IF(LEN(ISNULL(@Comment,'')) > 0 AND ISNULL(@OrderDetailKey,0)=0 )
				BEGIN
					CREATE TABLE #ContainerTypes
					(
						PropertyKey	INT,
						PropertyCode		varchar(50)
					)

					DECLARE @TemComment NVARCHAR(500)=''
					SET @TemComment=@Comment
					SET @TemComment=REPLACE(@TemComment,';',':');
					SET @TemComment=REPLACE(@TemComment,',',':');
					insert into #ContainerTypes(PropertyCode)
					select value from dbo.Fn_SplitParamCol(@TemComment)
					UPDATE A SET PropertyKey=CT.ContainerTypeKey
						FROM #ContainerTypes A
						INNER JOIN ContainerTypes CT ON A.PropertyCode=CT.ShortCode

					print '@Comment'
					print @Comment
					--select '#ContainerTypes',* from #ContainerTypes
					DELETE FROM ContainerTypesLink WHERE OrderDetailKey=@NewOrderDetailKey
					INSERT INTO ContainerTypesLink
					(OrderDetailKey,CommentKey,ContainerTypeKey,IsSelected)
					SELECT @NewOrderDetailKey,0,PropertyKey,1 FROM #ContainerTypes

					INSERT INTO HazardClassesLink (OrderDetailKey, ClassKey, IsSelected)
					SELECT @NewOrderDetailKey, ClassKey, 1
					FROM #HazardClassKeys;

					drop table #ContainerTypes

					DECLARE @UserName NVARCHAR(100)='',@Comments NVARCHAR(100)=''
					SELECT @UserName=UserName FROM [User] WITH (NOLOCK) WHERE UserKey=@UserKey;
					SET @Comments='by '+@UserName +' on '+ CAST(GETDATE() AS VARCHAR);
					SET @ContainerNo =(SELECT TOP 1 ContainerNo FROM OrderDetail WHERE OrderDetailKey=@NewOrderDetailKey)
					print 'before log properties'
					INSERT INTO AuditLogDetail
					(DateCreated,CreateUser,RefType,RefId,RefKey,Stage,CommentType,Comments)
					SELECT GETDATE(),@UserName,'Container',@ContainerNo,@NewOrderDetailKey,null,'Text','Properties Added ' + ISNULL(@TemComment,'')+' '+ISNULL(@Comments,'')
					 
				END
				
			--*****************************************************************			
		END	
		SEt @JsonOutput = (select @NewOrderDetailKey as OrderDetailKey for JSON PATH)
		-- exec CreateDefaultRoutes @Orderkey, @NewOrderDetailKey, @CreateUserKey
		
		SET @Ouput= 1

		--SELECT @Ouput AS Result
END;
