/*
Create a proc to save the OrderDetailWise Stops. Proc Name: OrderDetail_SaveStopList
Standard json input and output 
Check whether orderDetailstopkey exists. IF exists, update, otherwise create.
*/
/*

DECLARE @UserKey INT=29,
	@JSONString NVARCHAR(MAX)='', @Status BIT=0, @IsDebug		BIT = 1, 
	@JsonOutput nvarchar(max) ='', @Reason VARCHAR(100)=''
set @JSONString = '[{"OrderDetailStopKey":493302,"OrderDetailKey":121775,"OrderStopKey":null,"StopTypeKey":5,"StopName":"WBCT-ONLY USE","StopAddrKey":30638,"StopNumber":1,"LocationType":"Port","ScheduleDate":null,"ActualDate":null,"ScheduledUserKey":null,"ActualEntryUserKey":null,"ScheduleSetDateTime":null,"ActualSetDateTime":null,"IsDryRun":true,"DryRunSetDateTime":"2025-01-08T00:32:23.207","DryRunSetUserKey":420,"RefNo":null,"IsTMFChecked":null,"IsCTFChecked":null,"TMFCheckUserKey":null,"CTFCheckUserKey":null,"TMFCheckDate":null,"CTFCheckDate":null,"ReasonCode":null,"DropOrLive":null,"DropOrLiveSetUserKey":null,"DropOrLiveSetDatetime":null,"ExceptionReasonCode":null,"ExceptionRCSetUserKey":null,"ExceptionRCSetDateTime":null,"ToRouteKey":411630,"FromRouteKey":null,"StatusKey":1,"CreateDate":"2025-01-08T00:32:23.207","CreateUserKey":4,"UpdateDate":null,"UpdateUserKey":null,"IsDeleted":false,"DeleteUserKey":null,"DeleteDate":null}]'
Exec OrderDetail_SaveStopList @UserKey,@JSONString,@JsonOutput OUTPUT,@Status OUTPUT,@Reason OUTPUT, @IsDebug
Select @JsonOutput, @Status, @Reason

select top 1000 * from orderdetailstops order by OrderDetailStopKey desc

*/

CREATE PROCEDURE [dbo].[OrderDetail_SaveStopList]
(
    @UserKey INT,
    @JSONString NVARCHAR(MAX) = '',
    @JsonOutput NVARCHAR(MAX) = '' OUTPUT,
    @Status BIT = 0 OUTPUT,
    @Reason VARCHAR(500) = '' OUTPUT,
    @IsDebug BIT = 0
)
AS
BEGIN
    BEGIN TRY
        -- Validate input
        IF ISNULL(@JSONString, '') = ''
        BEGIN
            SET @Status = 0;
            SET @Reason = 'Invalid JSON input';
            RETURN;
        END;

        DECLARE 
		@OrderDetailStopKey			bigint			,
		@OrderDetailKey				int				,
		@OrderStopKey				bigint			,
		@StopTypeKey				smallint		,
		@StopName					varchar(100)	,
		@StopAddrKey				int				,
		@StopNumber					smallint		,
		@LocationType				varchar(20)		,
		@ScheduleDate				datetime		,
		@ActualDate					datetime		,
		@ScheduledUserKey			int				,
		@ActualEntryUserKey			int				,
		@ScheduleSetDateTime		datetime		,
		@ActualSetDateTime			datetime		,
		@RefNo						varchar(50)	    ,
		@IsTMFChecked				bit				,
		@IsCTFChecked				bit				,
		@TMFCheckUserKey			int				,
		@CTFCheckUserKey			int				,
		@TMFCheckDate				datetime		,
		@CTFCheckDate				datetime		,
		@ReasonCode					int				,
		@DropOrLive					char(1)			,
		@DropOrLiveSetUserKey		int				,
		@DropOrLiveSetDatetime		datetime		,
		@ExceptionReasonCode		int				,
		@ExceptionRCSetUserKey		int				,
		@ExceptionRCSetDateTime		datetime		,
		@StatusKey					smallint		,
		@CreateDate					datetime		,
		@CreateUserKey				int				,
		@UpdateDate					datetime		,
		@UpdateUserKey				int				,
		@IsDeleted					bit				,
		@DeleteUserKey				int				,
		@DeleteDate					datetime		,
		@IsDryRun					bit				,
		@DryRunSetDateTime			datetime		,
		@DryRunSetUserKey			int				

        -- Parse JSON into a temporary table
        SELECT OrderDetailStopKey, OrderDetailKey, OrderStopKey, StopTypeKey, StopName, StopAddrKey, StopNumber, LocationType, ScheduleDate, ActualDate, 
				ScheduledUserKey, ActualEntryUserKey, ScheduleSetDateTime, ActualSetDateTime, RefNo, 
				IsTMFChecked, IsCTFChecked, TMFCheckUserKey, CTFCheckUserKey, TMFCheckDate, CTFCheckDate, 
				ReasonCode, DropOrLive, DropOrLiveSetUserKey, DropOrLiveSetDatetime, 
				ExceptionReasonCode, ExceptionRCSetUserKey, ExceptionRCSetDateTime, StatusKey, CreateDate, CreateUserKey, 
				UpdateDate, UpdateUserKey, IsDeleted, DeleteUserKey, DeleteDate, IsDryRun, DryRunSetDateTime, DryRunSetUserKey
        INTO #Temp
        FROM OPENJSON(@JSONString)
        WITH (
            OrderDetailStopKey			bigint	   		'$.OrderDetailStopKey'		,
			OrderDetailKey				int		   		'$.OrderDetailKey'			,
			OrderStopKey				bigint	   		'$.OrderStopKey'			,
			StopTypeKey					smallint   		'$.StopTypeKey'				,
			StopName					varchar(100)	'$.StopName'				,
			StopAddrKey					int		   		'$.StopAddrKey'				,
			StopNumber					smallint   		'$.StopNumber'				,
			LocationType				varchar(20)	    '$.LocationType'			,
			ScheduleDate				datetime   		'$.ScheduleDate'			,
			ActualDate					datetime   		'$.ActualDate'				,
			ScheduledUserKey			int		   		'$.ScheduledUserKey'		,
			ActualEntryUserKey			int		   		'$.ActualEntryUserKey'		,
			ScheduleSetDateTime			datetime   		'$.ScheduleSetDateTime'		,
			ActualSetDateTime			datetime   		'$.ActualSetDateTime'		,
			RefNo						varchar(50)	    '$.RefNo'					,
			IsTMFChecked				bit		   		'$.IsTMFChecked'			,
			IsCTFChecked				bit		   		'$.IsCTFChecked'			,
			TMFCheckUserKey				int		   		'$.TMFCheckUserKey'			,
			CTFCheckUserKey				int		   		'$.CTFCheckUserKey'			,
			TMFCheckDate				datetime   		'$.TMFCheckDate'			,
			CTFCheckDate				datetime   		'$.CTFCheckDate'			,
			ReasonCode					int		   		'$.ReasonCode'				,
			DropOrLive					char(1)	   		'$.DropOrLive'				,
			DropOrLiveSetUserKey		int		   		'$.DropOrLiveSetUserKey'	,
			DropOrLiveSetDatetime		datetime   		'$.DropOrLiveSetDatetime'	,
			ExceptionReasonCode			int		   		'$.ExceptionReasonCode'		,
			ExceptionRCSetUserKey		int		   		'$.ExceptionRCSetUserKey'	,
			ExceptionRCSetDateTime		datetime   		'$.ExceptionRCSetDateTime'	,
			StatusKey					smallint   		'$.StatusKey'				,
			CreateDate					datetime   		'$.CreateDate'				,
			CreateUserKey				int		   		'$.CreateUserKey'			,
			UpdateDate					datetime   		'$.UpdateDate'				,
			UpdateUserKey				int		   		'$.UpdateUserKey'			,
			IsDeleted					bit		   		'$.IsDeleted'				,
			DeleteUserKey				int		   		'$.DeleteUserKey'			,
			DeleteDate					datetime   		'$.DeleteDate'				,
			IsDryRun					bit				'$.IsDryRun'				,
			DryRunSetDateTime			datetime		'$.DryRunSetDateTime'		,
			DryRunSetUserKey			int				'$.DryRunSetUserKey'		
        );

		if (@IsDebug = 1)
		BEGIN
		SELECT * from #Temp
		END

        -- Cursor to iterate over parsed data
        DECLARE cur CURSOR FOR
        SELECT OrderDetailStopKey, OrderDetailKey, OrderStopKey, StopTypeKey, StopName, StopAddrKey, StopNumber, LocationType, ScheduleDate, ActualDate, 
				ScheduledUserKey, ActualEntryUserKey, ScheduleSetDateTime, ActualSetDateTime, RefNo, 
				IsTMFChecked, IsCTFChecked, TMFCheckUserKey, CTFCheckUserKey, TMFCheckDate, CTFCheckDate, 
				ReasonCode, DropOrLive, DropOrLiveSetUserKey, DropOrLiveSetDatetime, 
				ExceptionReasonCode, ExceptionRCSetUserKey, ExceptionRCSetDateTime, StatusKey, CreateDate, CreateUserKey, 
				UpdateDate, UpdateUserKey, IsDeleted, DeleteUserKey, DeleteDate, IsDryRun, DryRunSetDateTime, DryRunSetUserKey
        FROM #Temp;

        OPEN cur;

        FETCH NEXT FROM cur 
		INTO @OrderDetailStopKey, @OrderDetailKey, @OrderStopKey, @StopTypeKey, @StopName, @StopAddrKey, @StopNumber, 
			 @LocationType, @ScheduleDate, @ActualDate, @ScheduledUserKey, @ActualEntryUserKey, @ScheduleSetDateTime, @ActualSetDateTime, 
			 @RefNo, @IsTMFChecked, @IsCTFChecked, @TMFCheckUserKey, @CTFCheckUserKey, @TMFCheckDate, @CTFCheckDate, 
			 @ReasonCode, @DropOrLive, @DropOrLiveSetUserKey, @DropOrLiveSetDatetime, 
			 @ExceptionReasonCode, @ExceptionRCSetUserKey, @ExceptionRCSetDateTime, @StatusKey, @CreateDate, @CreateUserKey, 
			 @UpdateDate, @UpdateUserKey, @IsDeleted, @DeleteUserKey, @DeleteDate, @IsDryRun, @DryRunSetDateTime, @DryRunSetUserKey

        WHILE @@FETCH_STATUS = 0
        BEGIN
			if (@IsDebug = 1)
			BEGIN
				SELECT @OrderDetailStopKey as OrderDetailStopKey
			END
            IF EXISTS (SELECT 1 FROM OrderDetailStops WHERE OrderDetailStopKey = @OrderDetailStopKey)
            BEGIN
                -- Update existing record
                UPDATE OrderDetailStops
                SET OrderDetailKey = @OrderDetailKey, OrderStopKey = @OrderStopKey, StopTypeKey = @StopTypeKey, StopName = @StopName, 
				StopAddrKey = @StopAddrKey, StopNumber = @StopNumber, LocationType = @LocationType, 
				SchedulePickupDate = @ScheduleDate, ActualPickupDate = @ActualDate, 
				SchedulePickupUserKey = Case when SchedulePickupDate is not null then  @ScheduledUserKey end, 
				ActualPickupUserKey = case when ActualPickupDate is not null then  @ActualEntryUserKey end, 
				SchedulePickupSetDateTime = Case when SchedulePickupDate is not null then @ScheduleSetDateTime end, 
				ActualPickupSetDateTime = case when ActualPickupDate is not null then @ActualSetDateTime end, 
				RefNo = @RefNo, IsTMFChecked = @IsTMFChecked, IsCTFChecked = @IsCTFChecked, 
				TMFCheckUserKey = @TMFCheckUserKey, CTFCheckUserKey = @CTFCheckUserKey, TMFCheckDate = @TMFCheckDate, CTFCheckDate = @CTFCheckDate, 
				ReasonCode = @ReasonCode, DropOrLive = @DropOrLive, DropOrLiveSetUserKey = @DropOrLiveSetUserKey, DropOrLiveSetDatetime = @DropOrLiveSetDatetime, 
				ExceptionReasonCode = @ExceptionReasonCode, ExceptionRCSetUserKey = @ExceptionRCSetUserKey, ExceptionRCSetDateTime = @ExceptionRCSetDateTime, 
				StatusKey = @StatusKey, CreateDate = @CreateDate, CreateUserKey = @CreateUserKey, 
				UpdateDate = GETDATE(), UpdateUserKey = @UpdateUserKey, IsDeleted = @IsDeleted, DeleteUserKey = @DeleteUserKey, DeleteDate = @DeleteDate,
				IsDryRunPort = @IsDryRun, DryRunPortSetDateTime = @DryRunSetDateTime, DryRunPortSetUserKey = @DryRunSetUserKey
                WHERE OrderDetailStopKey = @OrderDetailStopKey;

				SET @JsonOutput = (
			    SELECT OrderDetailStopKey, OrderDetailKey, OrderStopKey, StopTypeKey, StopName, StopAddrKey, StopNumber, LocationType, SchedulePickupDate, 
						ActualPickupDate, SchedulePickupUserKey, ActualPickupUserKey, SchedulePickupSetDateTime, ActualPickupSetDateTime, RefNo, 
						IsTMFChecked, IsCTFChecked, TMFCheckUserKey, CTFCheckUserKey, TMFCheckDate, CTFCheckDate, 
						ReasonCode, DropOrLive, DropOrLiveSetUserKey, DropOrLiveSetDatetime, 
						ExceptionReasonCode, ExceptionRCSetUserKey, ExceptionRCSetDateTime, StatusKey, CreateDate, CreateUserKey, 
						UpdateDate, UpdateUserKey, IsDeleted, DeleteUserKey, DeleteDate, IsDryRunPort, DryRunPortSetDateTime, DryRunPortSetUserKey
			    FROM	OrderDetailStops
			    WHERE	OrderDetailStopKey = @OrderDetailStopKey
			    FOR JSON PATH
			);
			Print '--------------Updated'
            END
            ELSE
            BEGIN
                -- Insert new record
                INSERT INTO OrderDetailStops (OrderDetailKey, OrderStopKey, StopTypeKey, StopName, StopAddrKey, StopNumber, LocationType, 
						SchedulePickupDate, 
						ActualPickupDate, SchedulePickupUserKey, ActualPickupUserKey, SchedulePickupSetDateTime, ActualPickupSetDateTime, RefNo, 
						IsTMFChecked, IsCTFChecked, TMFCheckUserKey, CTFCheckUserKey, TMFCheckDate, CTFCheckDate, 
						ReasonCode, DropOrLive, DropOrLiveSetUserKey, DropOrLiveSetDatetime, 
						ExceptionReasonCode, ExceptionRCSetUserKey, ExceptionRCSetDateTime, StatusKey, CreateDate, CreateUserKey, 
						UpdateDate, UpdateUserKey, IsDeleted, DeleteUserKey, DeleteDate, IsDryRunPort, DryRunPortSetDateTime, DryRunPortSetUserKey)
                VALUES (@OrderDetailKey, @OrderStopKey, @StopTypeKey, @StopName, @StopAddrKey, @StopNumber, @LocationType, 
						@ScheduleDate, @ActualDate, 
						case when @ScheduleDate is null then null else @ScheduledUserKey end, 
						case when @ActualDate is null then null else @ActualEntryUserKey end, 
						case when @ScheduleDate is null then null else @ScheduleSetDateTime end, 
						case when @ActualDate is null then null else @ActualSetDateTime end, @RefNo, 
						@IsTMFChecked, @IsCTFChecked, @TMFCheckUserKey, @CTFCheckUserKey, @TMFCheckDate, @CTFCheckDate, 
						@ReasonCode, @DropOrLive, @DropOrLiveSetUserKey, @DropOrLiveSetDatetime, 
						@ExceptionReasonCode, @ExceptionRCSetUserKey, @ExceptionRCSetDateTime, @StatusKey, GETDATE(), @CreateUserKey, 
						GETDATE(), @UpdateUserKey, @IsDeleted, @DeleteUserKey, @DeleteDate, @IsDryRun, @DryRunSetDateTime, @DryRunSetUserKey);

				SET @JsonOutput = (
			    SELECT OrderDetailStopKey, OrderDetailKey, OrderStopKey, StopTypeKey, StopName, StopAddrKey, StopNumber, LocationType, SchedulePickupDate, 
						ActualPickupDate, SchedulePickupUserKey, ActualPickupUserKey, SchedulePickupSetDateTime, ActualPickupSetDateTime, RefNo, 
						IsTMFChecked, IsCTFChecked, TMFCheckUserKey, CTFCheckUserKey, TMFCheckDate, CTFCheckDate, 
						ReasonCode, DropOrLive, DropOrLiveSetUserKey, DropOrLiveSetDatetime, 
						ExceptionReasonCode, ExceptionRCSetUserKey, ExceptionRCSetDateTime, StatusKey, CreateDate, CreateUserKey, 
						UpdateDate, UpdateUserKey, IsDeleted, DeleteUserKey, DeleteDate, IsDryRunPort, DryRunPortSetDateTime, DryRunPortSetUserKey
			    FROM	OrderDetailStops
			    WHERE	OrderDetailStopKey = SCOPE_IDENTITY()
			    FOR JSON PATH
				);
				Print '--------------Inserted'
            END;

            FETCH NEXT FROM cur 
			INTO @OrderDetailStopKey, @OrderDetailKey, @OrderStopKey, @StopTypeKey, @StopName, @StopAddrKey, @StopNumber, @LocationType, @ScheduleDate, @ActualDate, 
				 @ScheduledUserKey, @ActualEntryUserKey, @ScheduleSetDateTime, @ActualSetDateTime, @RefNo, 
				 @IsTMFChecked, @IsCTFChecked, @TMFCheckUserKey, @CTFCheckUserKey, @TMFCheckDate, @CTFCheckDate, 
				 @ReasonCode, @DropOrLive, @DropOrLiveSetUserKey, @DropOrLiveSetDatetime, 
				 @ExceptionReasonCode, @ExceptionRCSetUserKey, @ExceptionRCSetDateTime, @StatusKey, @CreateDate, @CreateUserKey, 
				 @UpdateDate, @UpdateUserKey, @IsDeleted, @DeleteUserKey, @DeleteDate, @IsDryRun, @DryRunSetDateTime, @DryRunSetUserKey;
        END;

        CLOSE cur;
        DEALLOCATE cur;

        DROP TABLE #Temp;

        -- Success status
        SET @Status = 1;
        SET @Reason = 'Success';

    END TRY
    BEGIN CATCH
			print @@ERROR
			print ERROR_NUMBER()  
			print ERROR_SEVERITY() 
			print ERROR_STATE() 
			print ERROR_PROCEDURE()  
			print ERROR_LINE() 
			print ERROR_MESSAGE() 
        -- Error handling
        SET @Status = 0;
        SET @Reason = ERROR_MESSAGE();

        IF OBJECT_ID('tempdb..#Temp') IS NOT NULL
            DROP TABLE #Temp;

        IF CURSOR_STATUS('GLOBAL', 'cur') >= 0
        BEGIN
            CLOSE cur;
            DEALLOCATE cur;
        END;
    END CATCH;
END;
