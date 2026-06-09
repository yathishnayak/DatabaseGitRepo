CREATE TABLE [dbo].[Routes] (
    [RouteKey]                     INT             IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [OrderDetailKey]               INT             NOT NULL,
    [OrderKey]                     INT             NULL,
    [LegKey]                       SMALLINT        NOT NULL,
    [LegNo]                        SMALLINT        NULL,
    [SourceAddrKey]                INT             NULL,
    [PickupDateFrom]               SMALLDATETIME   NULL,
    [PickupDateTo]                 SMALLDATETIME   NULL,
    [CutOffDate]                   DATETIME        NULL,
    [DeliveryDateFrom]             SMALLDATETIME   NULL,
    [DeliveryDateTo]               SMALLDATETIME   NULL,
    [AppointmentNo]                VARCHAR (500)   NULL,
    [ConfirmationNo]               VARCHAR (50)    NULL,
    [LastFreeDay]                  DATETIME        NULL,
    [SwitchTo]                     VARCHAR (50)    NULL,
    [PortWaitingTimeFrom]          DATETIME        NULL,
    [PortWaitingTimeTo]            DATETIME        NULL,
    [CustomerWaitingTimeFrom]      DATETIME        NULL,
    [CustomerWaitingTimeTo]        DATETIME        NULL,
    [ChassisNo]                    VARCHAR (50)    NULL,
    [ChassisType]                  VARCHAR (30)    NULL,
    [TruckNo]                      VARCHAR (50)    NULL,
    [FromLocation]                 VARCHAR (255)   NULL,
    [ToLocation]                   VARCHAR (255)   NULL,
    [DestinationAddrKey]           INT             NULL,
    [EstimatedDistanceInMiles]     DECIMAL (18, 2) NULL,
    [EstimatedTravelTime]          DECIMAL (5, 2)  NULL,
    [Status]                       SMALLINT        NULL,
    [DriverKey]                    INT             NULL,
    [ScheduledPickupDate]          DATETIME        NULL,
    [ScheduledArrival]             DATETIME        NULL,
    [ScheduledDeparture]           DATETIME        NULL,
    [ActualDeparture]              DATETIME        NULL,
    [ActualArrival]                DATETIME        NULL,
    [OdometerAtSource]             SMALLINT        NULL,
    [OdometerAtDestination]        SMALLINT        NULL,
    [DriverCommentKey]             INT             NULL,
    [SchedulerCommentKey]          INT             NULL,
    [ChassisKey]                   INT             NULL,
    [CompanyKey]                   SMALLINT        CONSTRAINT [DF_Routes_CompanyKey] DEFAULT ((1)) NULL,
    [CreateUserKey]                INT             NULL,
    [UpdateUserKey]                INT             NULL,
    [CreateDate]                   DATETIME        CONSTRAINT [DF_Routes_CreateDate] DEFAULT (getdate()) NULL,
    [LastUpdateDate]               DATETIME        CONSTRAINT [DF_Routes_LastUpdateDate] DEFAULT (getdate()) NULL,
    [LocationKey]                  INT             NULL,
    [IsEmpty]                      BIT             CONSTRAINT [DF_Routes_IsEmpty] DEFAULT ((0)) NULL,
    [IsAbandoned]                  BIT             CONSTRAINT [DF_Routes_IsAbandoned] DEFAULT ((0)) NULL,
    [IsDryRun]                     BIT             NULL,
    [IsBobtail]                    BIT             NULL,
    [IsDocumentVerified]           BIT             NULL,
    [IsRateVerified]               BIT             NULL,
    [DocumentVerifiedDate]         DATETIME        NULL,
    [RateVerifiedDate]             DATETIME        NULL,
    [DocumentVerifiedUserKey]      INT             NULL,
    [RateVerifiedUserKey]          INT             NULL,
    [DelConfirmationNo]            VARCHAR (50)    NULL,
    [isStreetTurn]                 BIT             NULL,
    [StreetTurnSetUser]            INT             NULL,
    [StreetTurnSetDate]            DATETIME        NULL,
    [IsChargesApproved]            BIT             NULL,
    [ChargesApprovedDate]          DATETIME        NULL,
    [ChargesApprovedBy]            INT             NULL,
    [DryRunType]                   INT             NULL,
    [YardCheckIn]                  DATETIME        NULL,
    [YardCheckOut]                 DATETIME        NULL,
    [ChassisCategoryKey]           INT             NULL,
    [ActualDepartureUpdateMethod]  VARCHAR (20)    NULL,
    [ActualArrivalUpdateMethod]    VARCHAR (20)    NULL,
    [CarrierRate]                  DECIMAL (18)    NULL,
    [StreeTurnPrevStatusKey]       INT             NULL,
    [EmptySetUser]                 INT             NULL,
    [EmptySetDate]                 DATETIME        NULL,
    [BobtailSetUser]               INT             NULL,
    [BobtailSetDate]               DATETIME        NULL,
    [DryRunSetUser]                INT             NULL,
    [DryRunSetDate]                DATETIME        NULL,
    [SFGYardDiffLogKeyPickup]      INT             NULL,
    [SFGYardChangePickup]          VARCHAR (20)    NULL,
    [SFGYardChangePickupMessage]   VARCHAR (500)   NULL,
    [SFGYardDiffLogKeyDelivery]    INT             NULL,
    [SFGYardChangeDelivery]        VARCHAR (20)    NULL,
    [SFGYardChangeDeliveryMessage] VARCHAR (500)   NULL,
    [YardIDPickupBeforeUpdate]     INT             NULL,
    [YardIDDeliveryBeforeUpdate]   INT             NULL,
    [PrevStatusKey]                INT             NULL,
    [ChassisSource]                VARCHAR (100)   NULL,
    [ChassisChangedDate]           DATETIME        NULL,
    [EmptySource]                  VARCHAR (100)   NULL,
    [DryRunSource]                 VARCHAR (100)   NULL,
    [BobTailSource]                VARCHAR (100)   NULL,
    [StreetTurnSource]             VARCHAR (100)   NULL,
    [ChassisChangedUser]           INT             NULL,
    [ActualDepartureUpdateDate]    DATETIME        NULL,
    [ActualDepartureUpdateUser]    INT             NULL,
    [ActualArrivalUpdateDate]      DATETIME        NULL,
    [ActualArrivalUpdateUser]      INT             NULL,
    [ChargeNotes]                  NVARCHAR (MAX)  NULL,
    [CompletionNotes]              NVARCHAR (MAX)  NULL,
    [DriverInstructions]           VARCHAR (1000)  NULL,
    [FromLocationWaitTimeFrom]     DATETIME        NULL,
    [FromLocationWaitTimeTo]       DATETIME        NULL,
    [ToLocationWaitTimeFrom]       DATETIME        NULL,
    [ToLocationWaitTimeTo]         DATETIME        NULL,
    [CarrierAssignedBy]            INT             NULL,
    [LinkedContainer]              VARCHAR (20)    NULL,
    [LinkedBy]                     INT             NULL,
    [LinkedDate]                   DATE            NULL,
    [ContainerNoSource]            VARCHAR (100)   NULL,
    [NoEmptyAvailableMarked]       BIT             NULL,
    [NoEmptyAvailableMarkedBY]     INT             NULL,
    [NoEmptyAvailableMarkedDate]   DATETIME        NULL,
    [LegType]                      VARCHAR (50)    NULL,
    [IsChassisSplit]               BIT             NULL,
    [LinkedContainerSource]        NVARCHAR (20)   NULL,
    [NoEmptyMarkedSource]          NVARCHAR (20)   NULL,
    [ChassisSplitDate]             DATETIME        NULL,
    [NoWaitTIme]                   BIT             NULL,
    [ChassisSplitBy]               INT             NULL,
    [PickupNoWaitTIme]             BIT             NULL,
    [DeliveryNoWaitTime]           BIT             NULL,
    [ToODStopKey]                  BIGINT          NULL,
    [LegID]                        VARCHAR (50)    NULL,
    [FromODStopKey]                BIGINT          NULL,
    [CWTFromTime]                  NVARCHAR (20)   NULL,
    [CWTToTime]                    NVARCHAR (20)   NULL,
    [CWTToTimeSetBy]               INT             NULL,
    [CWTToTimeSetDate]             DATETIME        NULL,
    [PWTFromTime]                  NVARCHAR (20)   NULL,
    [PWTToTime]                    NVARCHAR (20)   NULL,
    [PWTToTimeSetBy]               INT             NULL,
    [PWTToTimeSetDate]             DATETIME        NULL,
    [DriverSetBy]                  INT             NULL,
    [DriverSetDate]                DATETIME        NULL,
    [SFGYardDiffLogKey]            INT             NULL,
    [SFGYardChangeType]            VARCHAR (100)   NULL,
    [IsManual]                     BIT             NULL,
    [ManualRouteUser]              INT             NULL,
    [ManualRouteAddedDate]         DATETIME        NULL,
    [MiscReason]                   NVARCHAR (300)  NULL,
    [MiscSetBy]                    INT             NULL,
    [MiscSetDate]                  DATETIME        NULL,
    [LinkedContainerType]          NVARCHAR (10)   NULL,
    CONSTRAINT [TMS_routes_pkey] PRIMARY KEY CLUSTERED ([RouteKey] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_Routes_OrderDetailKey_8A7B5]
    ON [dbo].[Routes]([OrderDetailKey] ASC)
    INCLUDE([LegKey]) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_Routes_OrderDetailKey_Status_6C264]
    ON [dbo].[Routes]([OrderDetailKey] ASC, [Status] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_Routes_OrderDetailKey_E8A66]
    ON [dbo].[Routes]([OrderDetailKey] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_Routes_OrderDetailKey_C35FC]
    ON [dbo].[Routes]([OrderDetailKey] ASC)
    INCLUDE([Status]) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_Routes_UpdateCovering]
    ON [dbo].[Routes]([RouteKey] ASC)
    INCLUDE([FromODStopKey], [ToODStopKey], [LegNo]);


GO
CREATE NONCLUSTERED INDEX [IX_Routes_LegKey_8ECA5]
    ON [dbo].[Routes]([LegKey] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_Routes_Status_34235]
    ON [dbo].[Routes]([Status] ASC)
    INCLUDE([OrderKey], [LegKey], [PickupDateFrom], [PickupDateTo], [DeliveryDateFrom], [DeliveryDateTo], [ActualDeparture], [ActualArrival]) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_Routes_OrderDetailKey_80BDC]
    ON [dbo].[Routes]([OrderDetailKey] ASC)
    INCLUDE([CreateDate]) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_Routes_OrderDetailKey_Status_D7093]
    ON [dbo].[Routes]([OrderDetailKey] ASC, [Status] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_Routes_Status_ActualArrival]
    ON [dbo].[Routes]([Status] ASC, [ActualArrival] ASC)
    INCLUDE([OrderDetailKey], [LegKey], [DeliveryDateFrom], [DeliveryDateTo], [DestinationAddrKey], [DriverKey], [IsDocumentVerified], [IsRateVerified]) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_Routes_missing_20220903_1]
    ON [dbo].[Routes]([ActualDeparture] ASC, [ActualArrival] ASC, [ChassisKey] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Routes_ToODStopKey_FromODStopKey]
    ON [dbo].[Routes]([ToODStopKey] ASC, [FromODStopKey] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Routes_DriverKey_Status]
    ON [dbo].[Routes]([DriverKey] ASC, [Status] ASC)
    INCLUDE([ActualDeparture], [ActualArrival]) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_Routes_DriverKey]
    ON [dbo].[Routes]([DriverKey] ASC)
    INCLUDE([PickupDateFrom], [DeliveryDateFrom], [DeliveryDateTo]) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_Routes_ActualArrival]
    ON [dbo].[Routes]([ActualArrival] ASC)
    INCLUDE([CreateUserKey], [UpdateUserKey], [CreateDate]) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_Routes_ActualDeparture]
    ON [dbo].[Routes]([ActualDeparture] ASC)
    INCLUDE([CreateUserKey], [UpdateUserKey], [CreateDate]) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_Routes_PickupDateFrom]
    ON [dbo].[Routes]([PickupDateFrom] ASC)
    INCLUDE([PickupDateTo], [CreateUserKey], [UpdateUserKey], [CreateDate]);


GO
CREATE NONCLUSTERED INDEX [IX_Routes_DeliveryDateFrom]
    ON [dbo].[Routes]([DeliveryDateFrom] ASC)
    INCLUDE([DeliveryDateTo], [CreateUserKey], [UpdateUserKey], [CreateDate]);


GO
CREATE NONCLUSTERED INDEX [IX_Routes_Orderdetailkey]
    ON [dbo].[Routes]([OrderKey] ASC)
    INCLUDE([OrderDetailKey], [LegNo]) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IDX_11316_11315_Routes]
    ON [dbo].[Routes]([LegKey] ASC)
    INCLUDE([OrderDetailKey], [LegNo], [IsEmpty], [IsDryRun]);


GO
CREATE NONCLUSTERED INDEX [IDX_11319_11318_Routes]
    ON [dbo].[Routes]([LegKey] ASC, [IsEmpty] ASC)
    INCLUDE([OrderDetailKey], [LegNo], [IsDryRun]) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IDX_11471_11470_Routes]
    ON [dbo].[Routes]([LegKey] ASC)
    INCLUDE([OrderDetailKey], [SourceAddrKey], [DestinationAddrKey], [DriverKey]);


GO
CREATE NONCLUSTERED INDEX [IDX_14421_14420_Routes]
    ON [dbo].[Routes]([LegKey] ASC, [isStreetTurn] ASC)
    INCLUDE([OrderDetailKey], [LegNo], [IsEmpty], [IsDryRun]);


GO
CREATE NONCLUSTERED INDEX [IDX_14423_14422_Routes]
    ON [dbo].[Routes]([isStreetTurn] ASC)
    INCLUDE([OrderDetailKey], [LegKey], [LegNo], [IsEmpty], [IsDryRun]);


GO
CREATE NONCLUSTERED INDEX [IX_Routes_LastUpdateDate]
    ON [dbo].[Routes]([LastUpdateDate] ASC)
    INCLUDE([OrderDetailKey], [PickupDateFrom], [DeliveryDateFrom], [ActualDeparture], [ActualArrival]);


GO
CREATE NONCLUSTERED INDEX [IX_Routes_Status]
    ON [dbo].[Routes]([Status] ASC)
    INCLUDE([OrderDetailKey], [LegKey], [SourceAddrKey], [PickupDateFrom], [PickupDateTo], [DeliveryDateFrom], [DeliveryDateTo], [DestinationAddrKey]);


GO
CREATE NONCLUSTERED INDEX [IX_Routes_Status_DriverKey_Covering]
    ON [dbo].[Routes]([Status] ASC, [DriverKey] ASC)
    INCLUDE([RouteKey], [OrderDetailKey], [LegKey], [DestinationAddrKey], [ActualArrival], [DeliveryDateFrom], [IsDocumentVerified], [IsRateVerified]);


GO
CREATE TRIGGER [dbo].[TR_Routes_AfterDelete]
ON dbo.Routes AFTER DELETE
AS
BEGIN
	IF @@ROWCOUNT>0 
	BEGIN		
		DECLARE @User VARCHAR(50)
		SET @User=( SELECT SYSTEM_USER )

		IF  (
				SELECT COUNT(1) FROM DELETED A 
					LEFT JOIN INSERTED I ON I.OrderdetailKey=A.OrderdetailKey
				WHERE I.orderdetailKey IS NULL
			)>0
			BEGIN
				INSERT INTO [dbo].[Routes_Log]
				(
					[RouteKey],[OrderDetailKey],[OrderKey],[LegKey],[LegNo],[SourceAddrKey],[PickupDateFrom],[PickupDateTo]
				,[CutOffDate],[DeliveryDateFrom],[DeliveryDateTo],[AppointmentNo],[ConfirmationNo],[LastFreeDay],[SwitchTo],[PortWaitingTimeFrom]
				,[PortWaitingTimeTo],[CustomerWaitingTimeFrom],[CustomerWaitingTimeTo],[ChassisNo],[ChassisType]
				,[TruckNo],[FromLocation],[ToLocation],[DestinationAddrKey],[EstimatedDistanceInMiles],[EstimatedTravelTime]
				,[Status],[DriverKey],[ScheduledPickupDate],[ScheduledArrival],[ScheduledDeparture],[ActualDeparture]
				,[ActualArrival],[OdometerAtSource],[OdometerAtDestination],[DriverCommentKey],[SchedulerCommentKey]
				,[ChassisKey],[CompanyKey],[CreateUserKey],[UpdateUserKey],[CreateDate],[LastUpdateDate],ActionDate
				,[ActionType],[ActionUser]
				)
				SELECT  	
					 [RouteKey],[OrderDetailKey],[OrderKey],[LegKey],[LegNo],[SourceAddrKey],[PickupDateFrom],[PickupDateTo]
					,[CutOffDate],[DeliveryDateFrom],[DeliveryDateTo],[AppointmentNo],[ConfirmationNo],[LastFreeDay],[SwitchTo],[PortWaitingTimeFrom]
					,[PortWaitingTimeTo],[CustomerWaitingTimeFrom],[CustomerWaitingTimeTo],[ChassisNo],[ChassisType]
					,[TruckNo],[FromLocation],[ToLocation],[DestinationAddrKey],[EstimatedDistanceInMiles],[EstimatedTravelTime]
					,[Status],[DriverKey],[ScheduledPickupDate],[ScheduledArrival],[ScheduledDeparture],[ActualDeparture]
					,[ActualArrival],[OdometerAtSource],[OdometerAtDestination],[DriverCommentKey],[SchedulerCommentKey]
					,[ChassisKey],[CompanyKey],[CreateUserKey],[UpdateUserKey],[CreateDate],[LastUpdateDate],GETDATE()
					,'DELETE',isnull(CreateUserKey,UpdateUserKey)
				FROM DELETED 

			END	
	END
END

GO
CREATE TRIGGER [dbo].[TR_Routes_AfterInsert]
ON [dbo].[Routes] AFTER INSERT
/*
Only New Leg Addition
*/
AS
BEGIN
	IF @@ROWCOUNT>0 		
	BEGIN
		DECLARE @User VARCHAR(50)
		DECLARE @LastInsert DATETIME
		DECLARE @NewInsert DATETIME

		SET @User=( SELECT SYSTEM_USER )
		SET @LastInsert = ( SELECT MAX(RT.CreateDate) 
							FROM dbo.[Routes] RT  
								INNER JOIN INSERTED I ON I.OrderDetailKey=RT.OrderDetailKey
							WHERE RT.RouteKey NOT IN ( SELECT RouteKey FROM  INSERTED I)
						  )
						  
		SET @LastInsert=(  CASE WHEN @LastInsert IS NULL THEN GETDATE() ELSE @LastInsert END )

		SET @NewInsert = ( SELECT MAX(CreateDate) FROM INSERTED )	


		--IF 	( SELECT ISNULL(DATEDIFF(SECOND,@LastInsert,@NewInsert),0))>10 AND 
		--	(
		--		SELECT COUNT(1) 
		--		FROM INSERTED A 
		--			LEFT JOIN DELETED D ON D.RouteKey=A.RouteKey
		--		WHERE D.RouteKey IS NULL
		--	)>0
		--BEGIN
--***************Insert Only******************			
			INSERT INTO [dbo].[Routes_Log]
				(
					[RouteKey],[OrderDetailKey],[OrderKey],[LegKey],[LegNo],[SourceAddrKey],[PickupDateFrom],[PickupDateTo]
				,[CutOffDate],[DeliveryDateFrom],[DeliveryDateTo],[AppointmentNo],[ConfirmationNo],[LastFreeDay],[SwitchTo],[PortWaitingTimeFrom]
				,[PortWaitingTimeTo],[CustomerWaitingTimeFrom],[CustomerWaitingTimeTo],[ChassisNo],[ChassisType]
				,[TruckNo],[FromLocation],[ToLocation],[DestinationAddrKey],[EstimatedDistanceInMiles],[EstimatedTravelTime]
				,[Status],[DriverKey],[ScheduledPickupDate],[ScheduledArrival],[ScheduledDeparture],[ActualDeparture]
				,[ActualArrival],[OdometerAtSource],[OdometerAtDestination],[DriverCommentKey],[SchedulerCommentKey]
				,[ChassisKey],[CompanyKey],[CreateUserKey],[UpdateUserKey],[CreateDate],[LastUpdateDate],ActionDate
				,[ActionType],[ActionUser]
				)
			SELECT  	
					 [RouteKey],[OrderDetailKey],[OrderKey],[LegKey],[LegNo],[SourceAddrKey],[PickupDateFrom],[PickupDateTo]
					,[CutOffDate],[DeliveryDateFrom],[DeliveryDateTo],[AppointmentNo],[ConfirmationNo],[LastFreeDay],[SwitchTo],[PortWaitingTimeFrom]
					,[PortWaitingTimeTo],[CustomerWaitingTimeFrom],[CustomerWaitingTimeTo],[ChassisNo],[ChassisType]
					,[TruckNo],[FromLocation],[ToLocation],[DestinationAddrKey],[EstimatedDistanceInMiles],[EstimatedTravelTime]
					,[Status],[DriverKey],[ScheduledPickupDate],[ScheduledArrival],[ScheduledDeparture],[ActualDeparture]
					,[ActualArrival],[OdometerAtSource],[OdometerAtDestination],[DriverCommentKey],[SchedulerCommentKey]
					,[ChassisKey],[CompanyKey],[CreateUserKey],[UpdateUserKey],[CreateDate],[LastUpdateDate],GETDATE()
					,'INSERT',isnull(CreateUserKey, UpdateUserKey)
			FROM INSERTED 

			insert into Routes_DateTracker (RouteKey, DateType, DateTime, CreateDate, CreateUserKey)
			select Routekey, 'SP', isnull(PickupDateTo, PickupDateFrom), GetDate(), isnull(CreateUserKey, UpdateUserKey)
			from inserted where isnull(PickupDateTo, PickupDateFrom) is not null

			insert into Routes_DateTracker (RouteKey, DateType, DateTime, CreateDate, CreateUserKey)
			select Routekey, 'SD', isnull(DeliveryDateTo, DeliveryDateFrom), GetDate(), isnull(CreateUserKey, UpdateUserKey)
			from inserted where isnull(DeliveryDateTo, DeliveryDateFrom) is not null

			insert into Routes_DateTracker (RouteKey, DateType, DateTime, CreateDate, CreateUserKey)
			select Routekey, 'AP', ActualDeparture, GetDate(), isnull(CreateUserKey, UpdateUserKey)
			from inserted where ActualDeparture is not null

			insert into Routes_DateTracker (RouteKey, DateType, DateTime, CreateDate, CreateUserKey)
			select Routekey, 'AD', ActualArrival, GetDate(), isnull(CreateUserKey, UpdateUserKey)
			from inserted where ActualArrival is not null

		--END
	END
END

GO
CREATE TRIGGER [dbo].[TR_Routes_AfterUpdate]
ON dbo.Routes AFTER UPDATE
AS
BEGIN
	IF @@ROWCOUNT>0
	BEGIN
		SELECT * INTO #inserted FROM inserted
		SELECT * INTO #deleted  FROM deleted
		--Select R.* into #original 
		--from Routes R
		--left join #Inserted I on R.RouteKey = I.RouteKey

		IF (
			SELECT COUNT(1) 
			FROM #inserted A INNER JOIN #deleted B ON B.RouteKey = A.RouteKey
			WHERE 
				A.LegKey<>B.LegKey OR A.LegNo<>B.LegNo OR
				A.SourceAddrKey<>B.SourceAddrKey OR A.PickupDateFrom<>B.PickupDateFrom OR
				A.PickupDateTo<>B.PickupDateTo OR A.CutOffDate<>B.CutOffDate OR
				A.DeliveryDateFrom<>B.DeliveryDateFrom OR A.DeliveryDateTo<>B.DeliveryDateTo OR
				A.AppointmentNo<>B.AppointmentNo OR A.ConfirmationNo<>B.ConfirmationNo OR
				A.LastFreeDay<>B.LastFreeDay OR A.SwitchTo<>B.SwitchTo OR
				A.PortWaitingTimeFrom<>B.PortWaitingTimeFrom OR A.PortWaitingTimeTo<>B.PortWaitingTimeTo OR
				A.CustomerWaitingTimeFrom<>B.CustomerWaitingTimeFrom OR A.CustomerWaitingTimeTo<>B.CustomerWaitingTimeTo OR
				A.ChassisNo<>B.ChassisNo OR A.ChassisType<>B.ChassisType OR
				A.TruckNo<>B.TruckNo OR A.FromLocation<>B.FromLocation OR
				A.ToLocation<>B.ToLocation OR A.DestinationAddrKey<>B.DestinationAddrKey OR
				A.EstimatedDistanceInMiles<>B.EstimatedDistanceInMiles OR A.EstimatedTravelTime<>B.EstimatedTravelTime OR
				A.[Status]<>B.[Status] OR A.DriverKey<>B.DriverKey OR A.ScheduledPickupDate<>B.ScheduledPickupDate OR
				A.ScheduledArrival<>B.ScheduledArrival OR A.ScheduledDeparture<>B.ScheduledDeparture OR
				A.ActualDeparture<>B.ActualDeparture OR A.ActualArrival<>B.ActualArrival OR
				A.OdometerAtSource<>B.OdometerAtSource OR A.OdometerAtDestination<>B.OdometerAtDestination OR				
				A.ChassisKey<>B.ChassisKey OR A.CompanyKey<>B.CompanyKey					
		)>0
		BEGIN
			EXECUTE INSERT_RouteLog 
		END
	END
	IF @@ROWCOUNT>0 AND 
		(	
			UPDATE(PickupDateFrom)OR UPDATE(PickupDateTo)OR UPDATE(DeliveryDateFrom)OR UPDATE(DeliveryDateTo) OR UPDATE(CutOffDate)
			OR UPDATE(ConfirmationNo) OR UPDATE(LastFreeDay) OR UPDATE(SourceAddrKey) 
			OR UPDATE(DestinationAddrKey) OR UPDATE(ChassisNo) OR UPDATE(DriverKey) OR
			UPDATE(ActualArrival) OR UPDATE(ActualDeparture)
		)
	BEGIN
		DECLARE @User VARCHAR(50)
		SET @User=( SELECT SYSTEM_USER )

		IF UPDATE(PickupDateFrom)
		BEGIN
			INSERT INTO [dbo].[AuditLog]
           ( [CompanyKey],[FieldName],[IDValue],[NewValue],[OldValue],[Operation]
			,[ProgramName],[SysDate],[TableName],[UserID],RouteKey )
			SELECT	A.CompanyKey, 'PickupDate',OD.ContainerNo,
				CONVERT(VARCHAR,A.PickupDateFrom,101)+' '+ CONVERT(VARCHAR,A.PickupDateFrom,108),
				CONVERT(VARCHAR,B.PickupDateFrom,101)+' '+ CONVERT(VARCHAR,B.PickupDateFrom,108),
				'Update',NULL,GETDATE(),'Routes',isnull(A.CreateUserKey,A.UpdateUserKey),A.RouteKey					
			FROM INSERTED A 
				INNER JOIN DELETED B ON A.OrderDetailKey=B.OrderDetailKey
				INNER JOIN dbo.Orderdetail OD ON OD.orderdetailkey=	B.OrderDetailKey			
			WHERE ISNULL(A.PickupDateFrom,'01/01/2020')<>ISNULL(B.PickupDateFrom,'01/01/2020')

			insert into Routes_DateTracker (RouteKey, DateType, DateTime, CreateDate, CreateUserKey)
			select I.Routekey, 'SP', isnull(I.PickupDateTo, I.PickupDateFrom), GetDate(), isnull(I.UpdateUserKey, I.CreateUserKey )
			from inserted I
			LEft join Deleted D on I.RouteKey = D.RouteKey
			where isnull(I.PickupDateTo, I.PickupDateFrom) is not null and isnull(I.PickupDateTo, I.PickupDateFrom) <> D.PickupDateFrom

		END
		IF UPDATE(PickupDateTo)
		BEGIN
			INSERT INTO [dbo].[AuditLog]
           ( [CompanyKey],[FieldName],[IDValue],[NewValue],[OldValue],[Operation]
			,[ProgramName],[SysDate],[TableName],[UserID],RouteKey)
			SELECT	A.CompanyKey, 'PickupDate',OD.ContainerNo,
				CONVERT(VARCHAR,A.PickupDateTo,101)+' '+ CONVERT(VARCHAR,A.PickupDateTo,108),
				CONVERT(VARCHAR,B.PickupDateTo,101)+' '+ CONVERT(VARCHAR,B.PickupDateTo,108),
				'Update',NULL,GETDATE(),'Routes',isnull(A.CreateUserKey,A.UpdateUserKey),A.RouteKey					
			FROM INSERTED A 
				INNER JOIN DELETED B ON A.OrderDetailKey=B.OrderDetailKey
				INNER JOIN dbo.Orderdetail OD ON OD.orderdetailkey=	B.OrderDetailKey			
			WHERE ISNULL(A.PickupDateTo,'01/01/2020')<>ISNULL(B.PickupDateTo,'01/01/2020')

			insert into Routes_DateTracker (RouteKey, DateType, DateTime, CreateDate, CreateUserKey)
			select I.Routekey, 'SP', isnull(I.PickupDateTo, I.PickupDateFrom), GetDate(), isnull(I.UpdateUserKey, I.CreateUserKey )
			from inserted I
			LEft join Deleted D on I.RouteKey = D.RouteKey
			where isnull(I.PickupDateTo, I.PickupDateFrom) is not null and isnull(I.PickupDateTo, I.PickupDateFrom) <> D.PickupDateFrom
		END

		IF UPDATE(DeliveryDateFrom)
		BEGIN
			INSERT INTO [dbo].[AuditLog]
           ( [CompanyKey],[FieldName],[IDValue],[NewValue],[OldValue],[Operation]
			,[ProgramName],[SysDate],[TableName],[UserID],RouteKey )
			SELECT	A.CompanyKey, 'DeliveryDateFrom',OD.ContainerNo, 
				CONVERT(VARCHAR,A.DeliveryDateFrom,101)+' '+ CONVERT(VARCHAR,A.DeliveryDateFrom,108),
				CONVERT(VARCHAR,B.DeliveryDateFrom,101)+' '+ CONVERT(VARCHAR,B.DeliveryDateFrom,108),
				'Update',NULL,GETDATE(),'Routes',@User,A.RouteKey					
			FROM INSERTED A 
				INNER JOIN DELETED B ON A.OrderDetailKey=B.OrderDetailKey
				INNER JOIN dbo.Orderdetail OD ON OD.orderdetailkey=	B.OrderDetailKey			
			WHERE ISNULL(A.DeliveryDateFrom,'01/01/2020')<>ISNULL(B.DeliveryDateFrom,'01/01/2020')

			insert into Routes_DateTracker (RouteKey, DateType, DateTime, CreateDate, CreateUserKey)
			select I.Routekey, 'SD', isnull(I.DeliveryDateTo, I.DeliveryDateFrom), GetDate(),  isnull(I.UpdateUserKey, I.CreateUserKey )
			from inserted  I
			LEft join Deleted D on I.RouteKey = D.RouteKey
			where isnull(I.DeliveryDateTo, I.DeliveryDateFrom) is not null and isnull(I.DeliveryDateTo, I.DeliveryDateFrom) <> D.DeliveryDateFrom
		END

		IF UPDATE(DeliveryDateTo)
		BEGIN
			INSERT INTO [dbo].[AuditLog]
           ( [CompanyKey],[FieldName],[IDValue],[NewValue],[OldValue],[Operation]
			,[ProgramName],[SysDate],[TableName],[UserID],RouteKey )
			SELECT	A.CompanyKey, 'DeliveryDateTo',OD.ContainerNo, 
				CONVERT(VARCHAR,A.DeliveryDateTo,101)+' '+ CONVERT(VARCHAR,A.DeliveryDateTo,108),
				CONVERT(VARCHAR,B.DeliveryDateTo,101)+' '+ CONVERT(VARCHAR,B.DeliveryDateTo,108),
				'Update',NULL,GETDATE(),'Routes',@User,A.RouteKey					
			FROM INSERTED A 
				INNER JOIN DELETED B ON A.OrderDetailKey=B.OrderDetailKey
				INNER JOIN dbo.Orderdetail OD ON OD.orderdetailkey=	B.OrderDetailKey			
			WHERE ISNULL(A.DeliveryDateTo,'01/01/2020')<>ISNULL(B.DeliveryDateTo,'01/01/2020')

			insert into Routes_DateTracker (RouteKey, DateType, DateTime, CreateDate, CreateUserKey)
			select I.Routekey, 'SD', isnull(I.DeliveryDateTo, I.DeliveryDateFrom), GetDate(),  isnull(I.UpdateUserKey, I.CreateUserKey )
			from inserted  I
			LEft join Deleted D on I.RouteKey = D.RouteKey
			where isnull(I.DeliveryDateTo, I.DeliveryDateFrom) is not null and isnull(I.DeliveryDateTo, I.DeliveryDateFrom) <> D.DeliveryDateFrom
		END

		IF UPDATE(CutOffDate)
		BEGIN
			INSERT INTO [dbo].[AuditLog]
           ( [CompanyKey],[FieldName],[IDValue],[NewValue],[OldValue],[Operation]
			,[ProgramName],[SysDate],[TableName],[UserID],RouteKey )
			SELECT	A.CompanyKey, 'CutOffDate',OD.ContainerNo, CONVERT(VARCHAR,A.CutOffDate,101),
					 CONVERT(VARCHAR,B.CutOffDate,101),'Update',NULL,GETDATE(),'Routes',@User,A.RouteKey					
			FROM INSERTED A 
				INNER JOIN DELETED B ON A.OrderDetailKey=B.OrderDetailKey
				INNER JOIN dbo.Orderdetail OD ON OD.orderdetailkey=	B.OrderDetailKey			
			WHERE ISNULL(A.CutOffDate,'01/01/2020')<>ISNULL(B.CutOffDate,'01/01/2020')
		END

		IF UPDATE(ConfirmationNo)
		BEGIN
			INSERT INTO [dbo].[AuditLog]
           ( [CompanyKey],[FieldName],[IDValue],[NewValue],[OldValue],[Operation]
			,[ProgramName],[SysDate],[TableName],[UserID],RouteKey )
			SELECT	A.CompanyKey, 'ConfirmationNo',OD.ContainerNo,A.ConfirmationNo,
					B.ConfirmationNo,'Update',NULL,GETDATE(),'Routes',@User,A.RouteKey					
			FROM INSERTED A 
				INNER JOIN DELETED B ON A.OrderDetailKey=B.OrderDetailKey
				INNER JOIN dbo.Orderdetail OD ON OD.orderdetailkey=	B.OrderDetailKey			
			WHERE ISNULL(A.ConfirmationNo,'')<>ISNULL(B.ConfirmationNo,'')
		END

		IF UPDATE(LastFreeDay)
		BEGIN
			INSERT INTO [dbo].[AuditLog]
           ( [CompanyKey],[FieldName],[IDValue],[NewValue],[OldValue],[Operation]
			,[ProgramName],[SysDate],[TableName],[UserID],RouteKey )
			SELECT	A.CompanyKey, 'LastFreeDay',OD.ContainerNo, CONVERT(VARCHAR,A.LastFreeDay,101),
					 CONVERT(VARCHAR,B.LastFreeDay,101),'Update',NULL,GETDATE(),'Routes',@User,A.RouteKey					
			FROM INSERTED A 
				INNER JOIN DELETED B ON A.OrderDetailKey=B.OrderDetailKey
				INNER JOIN dbo.Orderdetail OD ON OD.orderdetailkey=	B.OrderDetailKey			
			WHERE ISNULL(A.LastFreeDay,'01/01/2020')<>ISNULL(B.LastFreeDay,'01/01/2020')
		END

		IF UPDATE(SourceAddrKey)
		BEGIN
			INSERT INTO [dbo].[AuditLog]
           ( [CompanyKey],[FieldName],[IDValue],[NewValue],[OldValue],[Operation]
			,[ProgramName],[SysDate],[TableName],[UserID],[NewKey],[OldKey],RouteKey  )
			SELECT	A.CompanyKey, 'SourceAddrKey',OD.ContainerNo,New.AddrName,
					Old.AddrName,'Update',NULL,GETDATE(),'Routes',@User,
					A.SourceAddrKey,B.SourceAddrKey,A.RouteKey
			FROM INSERTED A 
				INNER JOIN DELETED B ON A.OrderKey=B.OrderKey
				LEFT JOIN dbo.[Address] New ON New.AddrKey=A.SourceAddrKey
				LEFT JOIN dbo.[Address] Old ON Old.AddrKey=B.SourceAddrKey
				INNER JOIN dbo.Orderdetail OD ON OD.orderdetailkey=	B.OrderDetailKey
			WHERE ISNULL(A.SourceAddrKey,0)<>ISNULL(B.SourceAddrKey,0)
		END

		IF UPDATE(DestinationAddrKey)
		BEGIN
			INSERT INTO [dbo].[AuditLog]
           ( [CompanyKey],[FieldName],[IDValue],[NewValue],[OldValue],[Operation]
			,[ProgramName],[SysDate],[TableName],[UserID],[NewKey],[OldKey],RouteKey  )
			SELECT	A.CompanyKey, 'DestinationAddrKey',OD.ContainerNo,New.AddrName,
					Old.AddrName,'Update',NULL,GETDATE(),'Routes',@User,
					A.DestinationAddrKey,B.DestinationAddrKey,A.RouteKey
			FROM INSERTED A 
				INNER JOIN DELETED B ON A.OrderKey=B.OrderKey
				LEFT JOIN dbo.[Address] New ON New.AddrKey=A.DestinationAddrKey
				LEFT JOIN dbo.[Address] Old ON Old.AddrKey=B.DestinationAddrKey
				INNER JOIN dbo.Orderdetail OD ON OD.orderdetailkey=	B.OrderDetailKey
			WHERE ISNULL(A.DestinationAddrKey,0)<>ISNULL(B.DestinationAddrKey,0)
		END	
		--*****************Dispatch**********************
		IF UPDATE(ChassisNo)
		BEGIN
			INSERT INTO [dbo].[AuditLog]
           ( [CompanyKey],[FieldName],[IDValue],[NewValue],[OldValue],[Operation]
			,[ProgramName],[SysDate],[TableName],[UserID],RouteKey )
			SELECT	A.CompanyKey, 'ChassisNo',OD.ContainerNo,A.ChassisNo,
					B.ChassisNo,'Update',NULL,GETDATE(),'Routes',@User,A.RouteKey					
			FROM INSERTED A 
				INNER JOIN DELETED B ON A.OrderDetailKey=B.OrderDetailKey
				INNER JOIN dbo.Orderdetail OD ON OD.orderdetailkey=	B.OrderDetailKey			
			WHERE ISNULL(A.ConfirmationNo,'')<>ISNULL(B.ConfirmationNo,'')
		END	

		IF UPDATE(DriverKey)
		BEGIN
			INSERT INTO [dbo].[AuditLog]
           ( [CompanyKey],[FieldName],[IDValue],[NewValue],[OldValue],[Operation]
			,[ProgramName],[SysDate],[TableName],[UserID],[NewKey],[OldKey],RouteKey  )
			SELECT	A.CompanyKey, 'DriverKey',OD.ContainerNo,New.DriverID,
					Old.DriverID,'Update',NULL,GETDATE(),'Routes',@User,
					A.Driverkey,B.Driverkey,A.RouteKey
			FROM INSERTED A 
				INNER JOIN DELETED B ON A.OrderKey=B.OrderKey
				LEFT JOIN dbo.Driver New ON New.Driverkey=A.Driverkey
				LEFT JOIN dbo.Driver Old ON Old.Driverkey=B.Driverkey
				INNER JOIN dbo.Orderdetail OD ON OD.orderdetailkey=	B.OrderDetailKey
			WHERE ISNULL(A.Driverkey,0)<>ISNULL(B.Driverkey,0)
		END

		IF UPDATE(ActualArrival)
		BEGIN	
			INSERT INTO [dbo].[AuditLog]
				( [CompanyKey],[FieldName],[IDValue],[NewValue],[OldValue],[Operation]
				,[ProgramName],[SysDate],[TableName],[UserID],RouteKey )
			SELECT	A.CompanyKey, 'ActualArrival',OD.ContainerNo,
				CONVERT(VARCHAR,A.ActualArrival,101)+' '+ CONVERT(VARCHAR,A.ActualArrival,108),
				CONVERT(VARCHAR,B.ActualArrival,101)+' '+ CONVERT(VARCHAR,B.ActualArrival,108),
				'Update',NULL,GETDATE(),'Routes',@User,A.RouteKey				
			FROM INSERTED A 
				INNER JOIN DELETED B ON A.OrderDetailKey=B.OrderDetailKey
				INNER JOIN dbo.Orderdetail OD ON OD.orderdetailkey=	B.OrderDetailKey			
			WHERE ISNULL(A.ActualArrival,'01/01/2020')<>ISNULL(B.ActualArrival,'01/01/2020')

			UPDATE DR 
			SET DR.DriverCompleteDate= I.ActualArrival
			FROM dbo.DriverRoute DR 
				INNER JOIN INSERTED I ON I.RouteKey=DR.RouteKey
			WHERE ISNULL(DR.DriverCompleteDate,'01/01/2000')<>ISNULL(I.ActualArrival,'01/01/2000')

			insert into Routes_DateTracker (RouteKey, DateType, DateTime, CreateDate, CreateUserKey)
			select I.Routekey, 'AD', I.ActualArrival, GetDate(),  isnull(I.UpdateUserKey, I.CreateUserKey )
			from inserted  I
			LEft join Deleted D on I.RouteKey = D.RouteKey
			where I.ActualArrival is not null and I.ActualArrival <> D.ActualArrival
		END

		IF UPDATE(ActualDeparture)
		BEGIN	
			INSERT INTO [dbo].[AuditLog]
           ( [CompanyKey],[FieldName],[IDValue],[NewValue],[OldValue],[Operation]
			,[ProgramName],[SysDate],[TableName],[UserID],RouteKey )
			SELECT	A.CompanyKey, 'ActualDeparture',OD.ContainerNo, 
				CONVERT(VARCHAR,A.ActualDeparture,101)+' '+ CONVERT(VARCHAR,A.ActualDeparture,108),
				CONVERT(VARCHAR,B.ActualDeparture,101)+' '+ CONVERT(VARCHAR,B.ActualDeparture,108),
				'Update',NULL,GETDATE(),'Routes',@User,A.RouteKey					
			FROM INSERTED A 
				INNER JOIN DELETED B ON A.OrderDetailKey=B.OrderDetailKey
				INNER JOIN dbo.Orderdetail OD ON OD.orderdetailkey=	B.OrderDetailKey			
			WHERE ISNULL(A.ActualDeparture,'01/01/2020')<>ISNULL(B.ActualDeparture,'01/01/2020')

			UPDATE DR 
			SET DR.DriverStartDate= I.ActualDeparture
			FROM dbo.DriverRoute DR 
				INNER JOIN INSERTED I ON I.RouteKey=DR.RouteKey	
			WHERE ISNULL(DR.DriverStartDate,'01/01/2000')<>ISNULL(I.ActualDeparture,'01/01/2000')

			insert into Routes_DateTracker (RouteKey, DateType, DateTime, CreateDate, CreateUserKey)
			select I.Routekey, 'AP', I.ActualDeparture, GetDate(),  isnull(I.UpdateUserKey, I.CreateUserKey )
			from inserted I
			LEft join Deleted D on I.RouteKey = D.RouteKey
			where I.ActualDeparture is not null and I.ActualDeparture <> D.ActualDeparture
		END
	END
END

GO
CREATE TRIGGER [dbo].[TR_Routes_UpdateStatus]
ON [dbo].[Routes]
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
   -- Update RT SET PrevStatusKey=D.[Status] FROM 
			--[Routes] RT
			--INNER JOIN deleted D ON RT.RouteKey=D.RouteKey
    UPDATE routes
    SET status = CASE
        WHEN inserted.status IS NULL THEN deleted.status
        ELSE inserted.status
    END
    FROM routes
    JOIN inserted ON routes.RouteKey = inserted.RouteKey
    JOIN deleted ON routes.RouteKey = deleted.RouteKey;


END;
GO
DISABLE TRIGGER [dbo].[TR_Routes_UpdateStatus]
    ON [dbo].[Routes];

