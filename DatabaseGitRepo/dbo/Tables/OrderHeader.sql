CREATE TABLE [dbo].[OrderHeader] (
    [OrderKey]             INT             IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [OrderNo]              VARCHAR (20)    NOT NULL,
    [OrderDate]            DATE            NOT NULL,
    [CustKey]              INT             NOT NULL,
    [BillToAddrKey]        INT             NULL,
    [BillToCopyAddrKey]    INT             NULL,
    [SourceAddrKey]        INT             NULL,
    [DestinationAddrKey]   INT             NULL,
    [ReturnAddrKey]        INT             NULL,
    [SourceKey]            INT             NULL,
    [OrderTypeKey]         SMALLINT        NOT NULL,
    [Status]               SMALLINT        NULL,
    [StatusDate]           DATETIME2 (7)   NULL,
    [HoldReasonKey]        SMALLINT        NULL,
    [HoldDate]             DATETIME2 (7)   NULL,
    [BrokerKey]            INT             NULL,
    [BrokerRefNo]          VARCHAR (50)    NULL,
    [PortoForiginKey]      INT             NULL,
    [CarrierKey]           INT             NULL,
    [VesselName]           VARCHAR (50)    NULL,
    [BillOfLading]         VARCHAR (50)    NULL,
    [BookingNo]            VARCHAR (50)    NULL,
    [IsHazardous]          BIT             NULL,
    [IsOverWeight]         BIT             NULL,
    [IsTriaxle]            BIT             NULL,
    [NeedsTobeScaled]      BIT             NULL,
    [PriorityKey]          SMALLINT        NULL,
    [CreateDate]           DATETIME2 (7)   NULL,
    [Ach_Enabled]          BIT             CONSTRAINT [DF_OrderHeader_Ach_Enabled] DEFAULT ((0)) NOT NULL,
    [Ach_Amount]           DECIMAL (18, 2) NULL,
    [CreateUserKey]        INT             NULL,
    [LastUpdateDate]       DATETIME2 (7)   NULL,
    [LastUpdateUserKey]    INT             NULL,
    [PortofDestinationKey] INT             NULL,
    [ConsigneeAddrKey]     INT             NULL,
    [CompanyKey]           SMALLINT        CONSTRAINT [DF_OrderHeader_CompanyKey] DEFAULT ((1)) NOT NULL,
    [CsrKey]               INT             NULL,
    [CommentKey]           INT             NULL,
    [ETADate]              DATETIME2 (7)   NULL,
    [BaseRateAmount]       DECIMAL (18, 2) NULL,
    [SalesPersonKey]       INT             NULL,
    [ReleaseNo]            VARCHAR (10)    NULL,
    [IntegrationWONo]      VARCHAR (100)   NULL,
    [CSRManagerKey]        INT             NULL,
    [OrderSource]          VARCHAR (20)    DEFAULT ('Entry') NULL,
    [MarketLocationKey]    INT             NULL,
    [Consignee]            VARCHAR (100)   DEFAULT ('') NULL,
    [SteamShipLinekey]     INT             NULL,
    [SenderInfo]           VARCHAR (100)   NULL,
    [DropLive]             NVARCHAR (10)   NULL,
    [ConsigneeKey]         INT             NULL,
    [PurchaseOrder]        VARCHAR (50)    NULL,
    CONSTRAINT [TMS_orderheader_pkey] PRIMARY KEY CLUSTERED ([OrderKey] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_OrderHeader_CustKey]
    ON [dbo].[OrderHeader]([CustKey] ASC)
    INCLUDE([BrokerRefNo], [BillOfLading]) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_OrderHeader_missing_20220903_1]
    ON [dbo].[OrderHeader]([OrderNo] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_OrderHeader_CustKey_OrderTypeKey]
    ON [dbo].[OrderHeader]([CustKey] ASC, [OrderTypeKey] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_OrderHeader_CustKey_Status]
    ON [dbo].[OrderHeader]([CustKey] ASC, [Status] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_OrderHeader_CustKey_OrderTypeKey_CreateDate]
    ON [dbo].[OrderHeader]([CustKey] ASC, [OrderTypeKey] ASC, [CreateDate] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_OrderHeader_Status]
    ON [dbo].[OrderHeader]([Status] ASC)
    INCLUDE([StatusDate]) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IDX_12229_12228_OrderHeader]
    ON [dbo].[OrderHeader]([OrderTypeKey] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_OrderHeader_BrokerRefNo]
    ON [dbo].[OrderHeader]([BrokerRefNo] ASC)
    INCLUDE([CustKey]);


GO
CREATE NONCLUSTERED INDEX [IX_OrderHeader_OrderDate]
    ON [dbo].[OrderHeader]([OrderDate] ASC)
    INCLUDE([OrderNo], [CustKey], [BillToAddrKey], [SourceAddrKey], [DestinationAddrKey], [ReturnAddrKey], [OrderTypeKey], [Status], [BrokerKey], [BrokerRefNo], [VesselName], [BillOfLading], [BookingNo], [PriorityKey], [CsrKey], [SalesPersonKey], [CSRManagerKey], [MarketLocationKey], [Consignee], [SteamShipLinekey], [SenderInfo]);


GO
CREATE NONCLUSTERED INDEX [IX_OrderHeader_CreateDate_BToA]
    ON [dbo].[OrderHeader]([CreateDate] ASC)
    INCLUDE([BillToAddrKey]);


GO
CREATE NONCLUSTERED INDEX [IX_OrderHeader_OrderTypeKey_OrderSource_CreateDate]
    ON [dbo].[OrderHeader]([OrderTypeKey] ASC, [OrderSource] ASC, [CreateDate] ASC)
    INCLUDE([BookingNo]);


GO
CREATE NONCLUSTERED INDEX [IX_OrderHeader_OrderDate_Covering]
    ON [dbo].[OrderHeader]([OrderDate] ASC)
    INCLUDE([OrderKey], [OrderNo], [BrokerRefNo], [MarketLocationKey]);


GO

CREATE TRIGGER [dbo].[TR_OrderHeader_AfterUpdate]
ON [dbo].[OrderHeader] AFTER UPDATE
AS
BEGIN
	IF @@ROWCOUNT>0 AND 
		(	
			UPDATE(SourceAddrKey)OR UPDATE(DestinationAddrKey) OR UPDATE(ReturnAddrKey)
			OR UPDATE(BrokerKey) OR UPDATE(BookingNo) OR UPDATE(CarrierKey) OR UPDATE(BillOfLading) OR UPDATE(CsrKey)
			OR UPDATE(BrokerRefNo) OR UPDATE(Ach_Amount) OR UPDATE(PriorityKey)
		)
	BEGIN
		DECLARE @User VARCHAR(50)
		SET @User=( SELECT SYSTEM_USER )

		IF UPDATE(SourceAddrKey)
		BEGIN
			INSERT INTO [dbo].[AuditLog]
           ( [CompanyKey],[FieldName],[IDValue],[NewValue],[OldValue],[Operation]
			,[ProgramName],[SysDate],[TableName],[UserID],[NewKey],[OldKey],OrderKey  )
			SELECT	A.CompanyKey, 'SourceAddrKey',A.OrderNo,New.AddrName,
					Old.AddrName,'Update',NULL,GETDATE(),'OrderHeader',isnull(B.LastUpdateUserKey,B.CreateUserKey),
					A.SourceAddrKey,B.SourceAddrKey,A.OrderKey
			FROM INSERTED A 
				INNER JOIN DELETED B ON A.OrderKey=B.OrderKey
				LEFT JOIN dbo.[Address] New ON New.AddrKey=A.SourceAddrKey
				LEFT JOIN dbo.[Address] Old ON Old.AddrKey=B.SourceAddrKey
			WHERE ISNULL(A.SourceAddrKey,0)<>ISNULL(B.SourceAddrKey,0)
		END

		IF UPDATE(DestinationAddrKey)
		BEGIN
			INSERT INTO [dbo].[AuditLog]
           ( [CompanyKey],[FieldName],[IDValue],[NewValue],[OldValue],[Operation]
			,[ProgramName],[SysDate],[TableName],[UserID],[NewKey],[OldKey],OrderKey  )
			SELECT	A.CompanyKey, 'DestinationAddrKey',A.OrderNo,New.AddrName,
					Old.AddrName,'Update',NULL,GETDATE(),'OrderHeader',isnull(B.LastUpdateUserKey,B.CreateUserKey),
					A.DestinationAddrKey,B.DestinationAddrKey,A.OrderKey
			FROM INSERTED A 
				INNER JOIN DELETED B ON A.OrderKey=B.OrderKey
				LEFT JOIN dbo.[Address] New ON New.AddrKey=A.DestinationAddrKey
				LEFT JOIN dbo.[Address] Old ON Old.AddrKey=B.DestinationAddrKey
			WHERE ISNULL(A.DestinationAddrKey,0)<>ISNULL(B.DestinationAddrKey,0)
		END

		IF UPDATE(ReturnAddrKey)
		BEGIN
			INSERT INTO [dbo].[AuditLog]
           ( [CompanyKey],[FieldName],[IDValue],[NewValue],[OldValue],[Operation]
			,[ProgramName],[SysDate],[TableName],[UserID],[NewKey],[OldKey],OrderKey  )
			SELECT	A.CompanyKey, 'ReturnAddrKey',A.OrderNo,New.AddrName,
					Old.AddrName,'Update',NULL,GETDATE(),'OrderHeader',isnull(B.LastUpdateUserKey,B.CreateUserKey),
					A.ReturnAddrKey,B.ReturnAddrKey,A.OrderKey	
			FROM  INSERTED A
					INNER JOIN DELETED B ON A.OrderKey=B.OrderKey
					LEFT JOIN dbo.[Address] New ON New.AddrKey=A.ReturnAddrKey
					LEFT JOIN dbo.[Address] Old ON Old.AddrKey=B.ReturnAddrKey
			WHERE ISNULL(A.ReturnAddrKey,0)<>ISNULL(B.ReturnAddrKey,0)
		END

		IF UPDATE(BrokerKey)
		BEGIN
			INSERT INTO [dbo].[AuditLog]
           ( [CompanyKey],[FieldName],[IDValue],[NewValue],[OldValue],[Operation]
			,[ProgramName],[SysDate],[TableName],[UserID],[NewKey],[OldKey],OrderKey  )
			SELECT	A.CompanyKey, 'BrokerKey',A.OrderNo,New.BrokerName,
					Old.BrokerName,'Update',NULL,GETDATE(),'OrderHeader',isnull(B.LastUpdateUserKey,B.CreateUserKey),
					A.BrokerKey,B.BrokerKey,A.OrderKey	
			FROM INSERTED A 
				INNER JOIN DELETED B ON A.OrderKey=B.OrderKey
				LEFT JOIN dbo.[Broker] New ON B.BrokerKey=A.BrokerKey
				LEFT JOIN dbo.[Broker] Old ON B.BrokerKey=A.BrokerKey
			WHERE ISNULL(A.BrokerKey,0)<>ISNULL(B.BrokerKey,0)
		END

		IF UPDATE(BookingNo)
		BEGIN
			INSERT INTO [dbo].[AuditLog]
           ( [CompanyKey],[FieldName],[IDValue],[NewValue],[OldValue],[Operation]
			,[ProgramName],[SysDate],[TableName],[UserID],OrderKey )
			SELECT	A.CompanyKey, 'BookingNo',A.OrderNo,A.BookingNo,
					B.BookingNo,'Update',NULL,GETDATE(),'OrderHeader',isnull(B.LastUpdateUserKey,B.CreateUserKey),
					A.OrderKey			
			FROM INSERTED A 
				INNER JOIN DELETED B ON A.OrderKey=B.OrderKey				
			WHERE ISNULL(A.BookingNo,'')<>ISNULL(B.BookingNo,'')
		END
		
		IF UPDATE(BrokerRefNo)
		BEGIN
			INSERT INTO [dbo].[AuditLog]
           ( [CompanyKey],[FieldName],[IDValue],[NewValue],[OldValue],[Operation]
			,[ProgramName],[SysDate],[TableName],[UserID],OrderKey )
			SELECT	A.CompanyKey, 'BrokerRefNo',A.OrderNo,A.BrokerRefNo,
					B.BrokerRefNo,'Update',NULL,GETDATE(),'OrderHeader',isnull(B.LastUpdateUserKey,B.CreateUserKey),
					A.OrderKey				
			FROM INSERTED A 
				INNER JOIN DELETED B ON A.OrderKey=B.OrderKey				
			WHERE ISNULL(A.BrokerRefNo,'')<>ISNULL(B.BrokerRefNo,'')
		END

		IF UPDATE(PriorityKey)
		BEGIN
			INSERT INTO [dbo].[AuditLog]
           ( [CompanyKey],[FieldName],[IDValue],[NewValue],[OldValue],[Operation]
			,[ProgramName],[SysDate],[TableName],[UserID],[NewKey],[OldKey],OrderKey  )
			SELECT	A.CompanyKey, 'PriorityKey',A.OrderNo,New.[Description],
					Old.[Description],'Update',NULL,GETDATE(),'OrderHeader',isnull(B.LastUpdateUserKey,B.CreateUserKey),
					A.PriorityKey,B.PriorityKey,A.OrderKey	
			FROM INSERTED A 
				INNER JOIN DELETED B ON A.OrderKey=B.OrderKey
				LEFT JOIN dbo.[Priority] New ON New.PriorityKey=A.PriorityKey
				LEFT JOIN dbo.[Priority] Old ON Old.PriorityKey=B.PriorityKey
			WHERE ISNULL(A.PriorityKey,0)<>ISNULL(B.PriorityKey,0)
		END

		IF UPDATE(CarrierKey)
		BEGIN
			INSERT INTO [dbo].[AuditLog]
           ( [CompanyKey],[FieldName],[IDValue],[NewValue],[OldValue],[Operation]
			,[ProgramName],[SysDate],[TableName],[UserID],[NewKey],[OldKey],OrderKey  )
			SELECT	A.CompanyKey, 'CarrierKey',A.OrderNo,New.CarrierName,
					Old.CarrierName,'Update',NULL,GETDATE(),'OrderHeader',isnull(B.LastUpdateUserKey,B.CreateUserKey),
					A.CarrierKey,B.CarrierKey,A.OrderKey	
			FROM INSERTED A 
				INNER JOIN DELETED B ON A.OrderKey=B.OrderKey
				LEFT JOIN dbo.Carrier New ON New.CarrierKey=A.CarrierKey
				LEFT JOIN dbo.Carrier Old ON Old.CarrierKey=B.CarrierKey
			WHERE ISNULL(A.CarrierKey,0)<>ISNULL(B.CarrierKey,0)
		END

		IF UPDATE(BillOfLading)
		BEGIN
			INSERT INTO [dbo].[AuditLog]
           ( [CompanyKey],[FieldName],[IDValue],[NewValue],[OldValue],[Operation]
			,[ProgramName],[SysDate],[TableName],[UserID],OrderKey )
			SELECT	A.CompanyKey, 'BillOfLading',A.OrderNo,A.BillOfLading,
					B.BillOfLading,'Update',NULL,GETDATE(),'OrderHeader',isnull(B.LastUpdateUserKey,B.CreateUserKey),
					A.OrderKey					
			FROM INSERTED A 
				INNER JOIN DELETED B ON A.OrderKey=B.OrderKey				
			WHERE ISNULL(A.BillOfLading,'')<>ISNULL(B.BillOfLading,'')
		END

		IF UPDATE(CsrKey)
		BEGIN
			INSERT INTO [dbo].[AuditLog]
           ( [CompanyKey],[FieldName],[IDValue],[NewValue],[OldValue],[Operation]
			,[ProgramName],[SysDate],[TableName],[UserID],[NewKey],[OldKey],OrderKey  )
			SELECT	A.CompanyKey, 'CsrKey',A.OrderNo,New.CsrName,
					Old.CsrName,'Update',NULL,GETDATE(),'OrderHeader',isnull(B.LastUpdateUserKey,B.CreateUserKey),
					A.CsrKey,B.CsrKey,A.OrderKey	
			FROM INSERTED A 
				INNER JOIN DELETED B ON A.OrderKey=B.OrderKey
				LEFT JOIN dbo.CSR New ON New.CsrKey=A.CsrKey
				LEFT JOIN dbo.CSR Old ON Old.CsrKey=B.CsrKey
			WHERE ISNULL(A.CsrKey,0)<>ISNULL(B.CsrKey,0)
		END
		
		IF UPDATE(Ach_Amount)
		BEGIN
			INSERT INTO [dbo].[AuditLog]
           ( [CompanyKey],[FieldName],[IDValue],[NewValue],[OldValue],[Operation]
			,[ProgramName],[SysDate],[TableName],[UserID],OrderKey )
			SELECT	A.CompanyKey, 'Arh_Amount',A.OrderNo,A.Ach_Amount,
					B.Ach_Amount,'Update',NULL,GETDATE(),'OrderHeader',isnull(B.LastUpdateUserKey,B.CreateUserKey),
					A.OrderKey				
			FROM INSERTED A 
				INNER JOIN DELETED B ON A.OrderKey=B.OrderKey				
			WHERE ISNULL(A.Ach_Amount,0)<>ISNULL(B.Ach_Amount,0)
		END
	END
END
