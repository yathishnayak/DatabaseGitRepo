CREATE TABLE [dbo].[OrderDetail] (
    [OrderDetailKey]           INT             IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [OrderKey]                 INT             NOT NULL,
    [ContainerNo]              VARCHAR (20)    NOT NULL,
    [ConfirmationNo]           VARCHAR (30)    NULL,
    [ContainerSizeKey]         SMALLINT        NOT NULL,
    [Chassis]                  VARCHAR (20)    NULL,
    [SealNo]                   VARCHAR (100)   NULL,
    [Weight]                   DECIMAL (18, 2) NULL,
    [ApptDateFrom]             DATE            NULL,
    [ApptDateTo]               DATE            NULL,
    [Status]                   SMALLINT        NULL,
    [StatusDate]               DATETIME        NULL,
    [HoldReasonKey]            SMALLINT        NULL,
    [LastFreeDay]              DATETIME        NULL,
    [HoldDate]                 DATETIME        NULL,
    [ReturnDate]               DATE            NULL,
    [ReturnTime]               TIME (7)        NULL,
    [PickupTime]               VARCHAR (8)     NULL,
    [DropOffTime]              VARCHAR (8)     NULL,
    [PickupDate]               DATETIME        NULL,
    [DropOffDate]              DATETIME        NULL,
    [CutOffDate]               DATETIME        NULL,
    [RouteKey]                 INT             NULL,
    [ActualPickupTime]         VARCHAR (8)     NULL,
    [ActualDropOffTime]        VARCHAR (8)     NULL,
    [ActualPickupDate]         DATETIME        NULL,
    [ActualDropOffDate]        DATETIME        NULL,
    [ContainerID]              VARCHAR (50)    NULL,
    [IsHazardus]               BIT             NULL,
    [IsOverWeight]             BIT             NULL,
    [IsTriaxle]                BIT             NULL,
    [NeedtobeScaled]           BIT             NULL,
    [CommentKey]               INT             NULL,
    [CreateUserKey]            INT             NULL,
    [UpdateUserKey]            INT             NULL,
    [SourceAddrKey]            INT             NULL,
    [DestinationAddrKey]       INT             NULL,
    [CreateDate]               DATETIME        NULL,
    [LastUpdateDate]           DATETIME        NULL,
    [LegTypeKey]               SMALLINT        NULL,
    [WeightUnit]               SMALLINT        NULL,
    [IsEmpty]                  BIT             NULL,
    [DriverNotes]              VARCHAR (1000)  NULL,
    [SchedulerNotes]           VARCHAR (1000)  NULL,
    [IsTMF]                    BIT             NULL,
    [CompleteDate]             DATETIME        NULL,
    [VesselETA]                DATETIME        NULL,
    [isStreetTurn]             BIT             NULL,
    [StreetTurnSetUser]        INT             NULL,
    [StreetTurnSetDate]        DATETIME        NULL,
    [IsLinked]                 BIT             NULL,
    [LinkedContainerNo]        VARCHAR (20)    NULL,
    [LinkedOrderDetailKey]     INT             NULL,
    [ContainerStatusKey]       SMALLINT        NULL,
    [CurrentRouteKey]          INT             NULL,
    [TotalLegs]                SMALLINT        NULL,
    [CurrentLegNo]             SMALLINT        NULL,
    [OpenLegs]                 SMALLINT        NULL,
    [TMFCheckOff]              BIT             NULL,
    [CTFCheckOff]              BIT             NULL,
    [SizeCheckOff]             BIT             NULL,
    [MarkedNoEmptyAvailable]   BIT             NULL,
    [MarkedNoEmptyAvailableBY] INT             NULL,
    [PUDelayedCodeKEy]         INT             NULL,
    [PrepullDelayedCodeKEy]    INT             NULL,
    [isWhseChargesConfirmed]   BIT             DEFAULT ((0)) NULL,
    [WhseChargeApprovedby]     INT             NULL,
    [WhseChargeApprovedDate]   DATETIME        NULL,
    [isCSChargeConfirmed]      BIT             DEFAULT ((0)) NULL,
    [CSChargeConfirmedBy]      INT             NULL,
    [CSChargeConfirmedDate]    DATETIME        NULL,
    [isChargesSharedWithCust]  BIT             DEFAULT ((0)) NULL,
    [ChargeSharedWithCustBy]   INT             NULL,
    [ChargeSharedWithCustDate] DATETIME        NULL,
    [isCustApprovedCharges]    BIT             DEFAULT ((0)) NULL,
    [IsTMFJCTPaid]             BIT             DEFAULT ((0)) NULL,
    [IsTMFCustomerPaid]        BIT             DEFAULT ((0)) NULL,
    [IsCTFJCTPaid]             BIT             DEFAULT ((0)) NULL,
    [IsCTFCustomerPaid]        BIT             DEFAULT ((0)) NULL,
    [TMFMarkDate]              DATETIME        NULL,
    [CTFMarkDate]              DATETIME        NULL,
    [ContainerNoSource]        VARCHAR (100)   NULL,
    [ContainerNoDate]          DATETIME        NULL,
    [ContainerNoUser]          INT             NULL,
    [Consignee]                NVARCHAR (200)  NULL,
    [AvailableT]               BIT             NULL,
    [AvailableTSetUserKey]     INT             NULL,
    [AvailableTSetDateTime]    DATETIME        NULL,
    [ScheduleT]                BIT             NULL,
    [ScheduleTSetUserKey]      INT             NULL,
    [ScheduleTSetDateTime]     DATETIME        NULL,
    [DemCheck]                 BIT             NULL,
    [DemCheckSetUserKey]       INT             NULL,
    [DemCheckSetDateTime]      DATETIME        NULL,
    [ReturnToStopKey]          INT             NULL,
    [StopOffA_StopKey]         INT             NULL,
    [OrderTypeKey]             SMALLINT        NULL,
    [StopOffB_StopKey]         INT             NULL,
    [CustRefNo]                VARCHAR (50)    NULL,
    [PriorityKey]              INT             NULL,
    [BookingNo]                VARCHAR (50)    NULL,
    [ShipFromStopKey]          INT             NULL,
    [CSRKey]                   INT             NULL,
    [ShipToStopKey]            INT             NULL,
    [JCTPaidDemurrage]         BIT             NULL,
    [DropOrLive]               VARCHAR (5)     NULL,
    [StopOffD_StopKey]         INT             NULL,
    [StopOffC_StopKey]         INT             NULL,
    [BillOfLadding]            VARCHAR (50)    NULL,
    [Issues]                   BIT             NULL,
    [IssuesSetUserKey]         INT             NULL,
    [IssuesSetDateTime]        DATETIME        NULL,
    [SenderInfo]               VARCHAR (300)   NULL,
    [ConsigneeKey]             INT             NULL,
    [PTTChecked]               BIT             NULL,
    [PTTCheckedBy]             INT             NULL,
    [PTTCheckedDate]           DATETIME        NULL,
    [Quantity]                 INT             NULL,
    [OnSiteSent]               BIT             NULL,
    [OnSiteSentSetUserKey]     INT             NULL,
    [OnSiteSentSetDateTime]    DATETIME        NULL,
    [PODSent]                  BIT             NULL,
    [PODSentSetUserKey]        INT             NULL,
    [PODSentSetDateTime]       DATETIME        NULL,
    CONSTRAINT [TMS_OrderDetail_pkey] PRIMARY KEY CLUSTERED ([OrderDetailKey] ASC) WITH (FILLFACTOR = 90)
);


GO
CREATE NONCLUSTERED INDEX [IX_OrderDetail_OrderKey_EC0B7]
    ON [dbo].[OrderDetail]([OrderKey] ASC)
    INCLUDE([Status]);


GO
CREATE NONCLUSTERED INDEX [IX_OrderDetail_OrderKey_DA1F3]
    ON [dbo].[OrderDetail]([OrderKey] ASC)
    INCLUDE([OrderDetailKey], [ContainerNo], [ContainerSizeKey], [SealNo], [Weight], [LastFreeDay], [CutOffDate], [ContainerID], [CreateUserKey], [IsEmpty], [DriverNotes], [SchedulerNotes], [IsTMF], [CompleteDate], [isStreetTurn], [StreetTurnSetUser], [StreetTurnSetDate], [IsLinked], [LinkedContainerNo], [CurrentRouteKey], [TotalLegs], [CurrentLegNo], [PUDelayedCodeKEy], [PrepullDelayedCodeKEy]) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_OrderDetail_OrderKey_Status_C3513]
    ON [dbo].[OrderDetail]([OrderKey] ASC, [Status] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_OrderDetail_Status_1EC47]
    ON [dbo].[OrderDetail]([Status] ASC)
    INCLUDE([OrderKey], [ContainerNo], [VesselETA]) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_OrderDetail_ContainerNo]
    ON [dbo].[OrderDetail]([ContainerNo] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-SourceDestAddrKey]
    ON [dbo].[OrderDetail]([SourceAddrKey] ASC, [DestinationAddrKey] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_OrderDetail_Status]
    ON [dbo].[OrderDetail]([Status] ASC)
    INCLUDE([OrderKey], [ContainerNo], [CompleteDate]);


GO
CREATE NONCLUSTERED INDEX [IDX_191_190_OrderDetail]
    ON [dbo].[OrderDetail]([Status] ASC)
    INCLUDE([OrderKey], [ContainerNo], [ContainerSizeKey], [DropOffDate], [SourceAddrKey], [DestinationAddrKey], [IsEmpty], [VesselETA], [isStreetTurn], [StreetTurnSetUser], [StreetTurnSetDate], [IsLinked], [LinkedContainerNo], [LinkedOrderDetailKey], [CurrentRouteKey], [TotalLegs], [CurrentLegNo], [TMFCheckOff], [CTFCheckOff], [MarkedNoEmptyAvailable], [IsTMFJCTPaid], [IsTMFCustomerPaid], [IsCTFJCTPaid], [IsCTFCustomerPaid]);


GO
CREATE NONCLUSTERED INDEX [IDX_14351_14350_OrderDetail]
    ON [dbo].[OrderDetail]([Status] ASC)
    INCLUDE([OrderKey], [ContainerNo], [ContainerSizeKey], [DropOffDate], [SourceAddrKey], [DestinationAddrKey], [IsEmpty], [ContainerStatusKey], [CurrentRouteKey], [TotalLegs], [CurrentLegNo], [OpenLegs]);


GO
CREATE NONCLUSTERED INDEX [IX_OrderDetail_CreateDate]
    ON [dbo].[OrderDetail]([CreateDate] ASC)
    INCLUDE([SourceAddrKey]);


GO
CREATE NONCLUSTERED INDEX [IX_OrderDetail_CreateDate_2]
    ON [dbo].[OrderDetail]([CreateDate] ASC)
    INCLUDE([DestinationAddrKey]);


GO

CREATE TRIGGER [dbo].[TR_OrderDetail_AfterDelete]
ON [dbo].[OrderDetail] AFTER DELETE
/*
Only Delete Existing Containers
*/
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
				INSERT INTO [dbo].[OrderDetail_Log]
							(
								[OrderDetailKey],[OrderKey],[ContainerNo],[ConfirmationNo],[ContainerSizeKey]
								,[Chassis],[SealNo],[Weight],[ApptDateFrom],[ApptDateTo],[Status],[StatusDate],[HoldReasonKey],[LastFreeDay]
								,[HoldDate],[ReturnDate],[ReturnTime],[PickupTime],[DropOffTime],[PickupDate],[DropOffDate],[CutOffDate]
								,[RouteKey],[ActualPickupTime],[ActualDropOffTime],[ActualPickupDate],[ActualDropOffDate],[ContainerID]
								,[IsHazardus],[IsOverWeight],[IsTriaxle],[NeedtobeScaled],[CommentKey],[CreateUserKey],[UpdateUserKey]
								,[SourceAddrKey],[DestinationAddrKey],[CreateDate],[LastUpdateDate],[LegTypeKey],[ActionType],[ActionUser]
							)
				SELECT   [OrderDetailKey],[OrderKey],[ContainerNo],[ConfirmationNo],[ContainerSizeKey],[Chassis],[SealNo],[Weight],[ApptDateFrom]
						,[ApptDateTo],[Status],[StatusDate],[HoldReasonKey],[LastFreeDay],[HoldDate],[ReturnDate],[ReturnTime],[PickupTime],[DropOffTime]
						,[PickupDate],[DropOffDate],[CutOffDate],[RouteKey],[ActualPickupTime],[ActualDropOffTime],[ActualPickupDate],[ActualDropOffDate],[ContainerID]
						,[IsHazardus],[IsOverWeight],[IsTriaxle],[NeedtobeScaled],[CommentKey],[CreateUserKey],[UpdateUserKey],[SourceAddrKey],[DestinationAddrKey]
						,[CreateDate],[LastUpdateDate],[LegTypeKey] ,'DELETE', isnull(UpdateUserKey,CreateUserKey)
				FROM DELETED 

			END	
	END
END

GO

CREATE TRIGGER [dbo].[TR_OrderDetail_AfterInsert]
ON [dbo].[OrderDetail] AFTER INSERT
/*
Only New Container Addition
*/
AS
BEGIN
	IF @@ROWCOUNT>0 		
	BEGIN
		DECLARE @User VARCHAR(50)
		DECLARE @LastInsert DATETIME
		DECLARE @NewInsert DATETIME

		SET @User=( SELECT SYSTEM_USER )	
--***************Insert Only******************					
		IF  (
				SELECT COUNT(1) FROM INSERTED A 
					LEFT JOIN DELETED I ON I.OrderdetailKey=A.OrderdetailKey
				WHERE I.orderdetailKey IS NULL
			)>0
		BEGIN
			INSERT INTO [dbo].[OrderDetail_Log]
						(
							[OrderDetailKey],[OrderKey],[ContainerNo],[ConfirmationNo],[ContainerSizeKey]
							,[Chassis],[SealNo],[Weight],[ApptDateFrom],[ApptDateTo],[Status],[StatusDate],[HoldReasonKey],[LastFreeDay]
							,[HoldDate],[ReturnDate],[ReturnTime],[PickupTime],[DropOffTime],[PickupDate],[DropOffDate],[CutOffDate]
							,[RouteKey],[ActualPickupTime],[ActualDropOffTime],[ActualPickupDate],[ActualDropOffDate],[ContainerID]
							,[IsHazardus],[IsOverWeight],[IsTriaxle],[NeedtobeScaled],[CommentKey],[CreateUserKey],[UpdateUserKey]
							,[SourceAddrKey],[DestinationAddrKey],[CreateDate],[LastUpdateDate],[LegTypeKey],[ActionType],[ActionUser]
						)
			SELECT   [OrderDetailKey],[OrderKey],[ContainerNo],[ConfirmationNo],[ContainerSizeKey],[Chassis],[SealNo],[Weight],[ApptDateFrom]
						,[ApptDateTo],[Status],[StatusDate],[HoldReasonKey],[LastFreeDay],[HoldDate],[ReturnDate],[ReturnTime],[PickupTime],[DropOffTime]
						,[PickupDate],[DropOffDate],[CutOffDate],[RouteKey],[ActualPickupTime],[ActualDropOffTime],[ActualPickupDate],[ActualDropOffDate],[ContainerID]
						,[IsHazardus],[IsOverWeight],[IsTriaxle],[NeedtobeScaled],[CommentKey],[CreateUserKey],[UpdateUserKey],[SourceAddrKey],[DestinationAddrKey]
						,[CreateDate],[LastUpdateDate],[LegTypeKey] ,'INSERT', isnull(UpdateUserKey,CreateUserKey)
			FROM INSERTED 
		END
	END
END

GO

CREATE TRIGGER [dbo].[TR_OrderDetail_AfterUpdate]
ON [dbo].[OrderDetail] AFTER UPDATE
AS
BEGIN
	IF @@ROWCOUNT>0
	BEGIN

	SELECT * INTO #INSERTED  FROM INSERTED
	SELECT * INTO #DELETED   FROM DELETED

	IF
		(
			SELECT COUNT(1) 
			FROM #INSERTED A 
				INNER JOIN #DELETED B ON A.OrderDetailKey=B.OrderDetailKey
			WHERE
				A.ContainerNo<>B.ContainerNo OR	A.ConfirmationNo<>B.ConfirmationNo OR
				A.ContainerSizeKey<>B.ContainerSizeKey OR A.Chassis<>B.Chassis OR
				A.SealNo<>B.SealNo OR A.[Weight]<>B.[Weight] OR
				A.ApptDateFrom<>B.ApptDateFrom OR A.ApptDateTo<>B.ApptDateTo OR
				A.[Status]<>B.[Status] OR A.HoldReasonKey<>B.HoldReasonKey OR
				A.LastFreeDay<>B.LastFreeDay OR	A.HoldDate<>B.HoldDate OR
				A.ReturnDate<>B.ReturnDate OR A.ReturnTime<>B.ReturnTime OR
				A.PickupTime<>B.PickupTime OR A.DropOffTime<>B.DropOffTime OR
				A.PickupDate<>B.PickupDate OR A.DropOffDate<>B.DropOffDate OR
				A.CutOffDate<>B.CutOffDate OR A.RouteKey<>B.RouteKey OR
				A.ActualPickupTime<>B.ActualPickupTime OR A.ActualDropOffTime<>B.ActualDropOffTime OR
				A.ActualPickupDate<>B.ActualPickupDate OR A.ActualDropOffDate<>B.ActualDropOffDate OR
				A.ContainerID<>B.ContainerID OR A.IsHazardus<>B.IsHazardus OR
				A.IsOverWeight<>B.IsOverWeight OR A.IsTriaxle<>B.IsTriaxle OR
				A.NeedtobeScaled<>B.NeedtobeScaled OR A.SourceAddrKey<>B.SourceAddrKey OR
				A.DestinationAddrKey<>B.DestinationAddrKey OR A.LegTypeKey<>B.LegTypeKey OR
				A.WeightUnit<>B.WeightUnit
		)>0
		BEGIN
			EXECUTE INSERT_OrderDetailLog
		END
	END
	IF @@ROWCOUNT>0 AND 
		(	
			UPDATE(ContainerNo)OR UPDATE(ContainerSizeKey)
			OR UPDATE(SealNo) OR UPDATE([Weight])
		)
	BEGIN
		DECLARE @User VARCHAR(50)
		SET @User=( SELECT SYSTEM_USER )

		IF UPDATE(ContainerNo)
		BEGIN
			INSERT INTO [dbo].[AuditLog]
           ( [CompanyKey],[FieldName],[IDValue],[NewValue],[OldValue],[Operation]
			,[ProgramName],[SysDate],[TableName],[UserID],OrderDetailKey )
			SELECT	OH.CompanyKey, 'ContainerNo',OH.OrderNo,A.ContainerNo,
					B.ContainerNo,'Update',NULL,GETDATE(),'OrderDetail',isnull(A.UpdateUserKey, A.CreateUserKey),
					A.OrderDetailKey				
			FROM INSERTED A 
				INNER JOIN DELETED B ON A.OrderDetailKey=B.OrderDetailKey
				INNER JOIN dbo.OrderHeader OH ON OH.OrderKey=A.orderKey				
			WHERE ISNULL(A.ContainerNo,'')<>ISNULL(B.ContainerNo,'')
		END

		IF UPDATE(ContainerSizeKey)
		BEGIN
			INSERT INTO [dbo].[AuditLog]
           ( [CompanyKey],[FieldName],[IDValue],[NewValue],[OldValue],[Operation]
			,[ProgramName],[SysDate],[TableName],[UserID],[NewKey],[OldKey],OrderDetailKey )
			SELECT	OH.CompanyKey, 'ContainerSizeKey',OH.OrderNo,New.[Description],
					Old.[Description],'Update',NULL,GETDATE(),'OrderDetail',isnull(A.UpdateUserKey, A.CreateUserKey),
					A.ContainerSizeKey,B.ContainerSizeKey,A.OrderDetailKey
			FROM INSERTED A 
				INNER JOIN DELETED B ON A.OrderDetailKey=B.OrderDetailKey
				LEFT JOIN dbo.ContainerSize New ON New.ContainerSizeKey=A.ContainerSizeKey
				LEFT JOIN dbo.ContainerSize Old ON Old.ContainerSizeKey=B.ContainerSizeKey
				INNER JOIN dbo.OrderHeader OH ON OH.OrderKey=A.orderKey
			WHERE ISNULL(A.ContainerSizeKey,0)<>ISNULL(B.ContainerSizeKey,0)
		END	

		IF UPDATE(SealNo)
		BEGIN
			INSERT INTO [dbo].[AuditLog]
           ( [CompanyKey],[FieldName],[IDValue],[NewValue],[OldValue],[Operation]
			,[ProgramName],[SysDate],[TableName],[UserID],OrderDetailKey  )
			SELECT	OH.CompanyKey, 'SealNo',OH.OrderNo,A.SealNo,
					B.SealNo,'Update',NULL,GETDATE(),'OrderDetail',isnull(A.UpdateUserKey, A.CreateUserKey),
					A.OrderDetailKey				
			FROM INSERTED A 
				INNER JOIN DELETED B ON A.OrderDetailKey=B.OrderDetailKey	
				INNER JOIN dbo.OrderHeader OH ON OH.OrderKey=A.orderKey			
			WHERE ISNULL(A.SealNo,'')<>ISNULL(B.SealNo,'')
		END

		IF UPDATE([Weight])
		BEGIN
			INSERT INTO [dbo].[AuditLog]
           ( [CompanyKey],[FieldName],[IDValue],[NewValue],[OldValue],[Operation]
			,[ProgramName],[SysDate],[TableName],[UserID],OrderDetailKey )
			SELECT	OH.CompanyKey, 'Weight',OH.OrderNo,A.[Weight],
					B.[Weight],'Update',NULL,GETDATE(),'OrderDetail',isnull(A.UpdateUserKey, A.CreateUserKey),
					A.OrderDetailKey				
			FROM INSERTED A 
				INNER JOIN DELETED B ON A.OrderDetailKey=B.OrderDetailKey	
				INNER JOIN dbo.OrderHeader OH ON OH.OrderKey=A.orderKey			
			WHERE ISNULL(A.[Weight],'')<>ISNULL(B.[Weight],'')
		END
	END
END
