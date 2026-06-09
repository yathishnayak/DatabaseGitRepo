CREATE TABLE [dbo].[OrderExpense] (
    [OrderExpenseKey]            INT             IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [Itemkey]                    INT             NOT NULL,
    [RouteKey]                   INT             NOT NULL,
    [UnitCost]                   DECIMAL (18, 5) NULL,
    [Qty]                        DECIMAL (18, 5) NULL,
    [NewUnitCost]                DECIMAL (18, 5) NULL,
    [DateFrom]                   DATETIME        NULL,
    [DateTo]                     DATETIME        NULL,
    [CreateDate]                 DATETIME        NOT NULL,
    [CreateUserKey]              INT             NOT NULL,
    [LastUpdateDate]             DATETIME        NULL,
    [UpdateUserKey]              INT             NULL,
    [ExpenseItemKey]             INT             NULL,
    [TimeDuration]               VARCHAR (10)    NULL,
    [InternalNotes]              NVARCHAR (MAX)  NULL,
    [PvsNP]                      VARCHAR (5)     NULL,
    [IsCSRApproved]              BIT             DEFAULT ((0)) NULL,
    [IsCustomerApproved]         BIT             DEFAULT ((0)) NULL,
    [FreeTime]                   INT             NULL,
    [BvsNB]                      BIT             NULL,
    [MinCnt]                     INT             NULL,
    [MaxCnt]                     INT             NULL,
    [CustomerRate]               DECIMAL (18, 4) NULL,
    [ChargeSource]               VARCHAR (20)    DEFAULT ('GEN') NULL,
    [isCSApproved]               BIT             DEFAULT ((0)) NULL,
    [CSApprovedDate]             DATETIME        NULL,
    [CSUserKey]                  INT             NULL,
    [WarehouseItemKey]           INT             NULL,
    [IsInvoiced]                 BIT             DEFAULT ((0)) NULL,
    [OrderDetailKey]             INT             NULL,
    [IsChargeSharedWithCustomer] BIT             DEFAULT ((0)) NULL,
    [ChargeSharedWithCustBy]     INT             NULL,
    [ChargeSharedWithCustDate]   DATETIME        NULL,
    [IsCustomerApprovedCharge]   BIT             DEFAULT ((0)) NULL,
    [CustomerApprovedChargeBy]   INT             NULL,
    [CustomerApprovedChargeDate] DATETIME        NULL,
    [ReportedCost]               DECIMAL (18, 5) NULL,
    [IsWaitTimeDateTmp]          BIT             NULL,
    CONSTRAINT [PK_OrderExpene] PRIMARY KEY CLUSTERED ([OrderExpenseKey] ASC),
    CONSTRAINT [FK_OrderExpene_Itemkey] FOREIGN KEY ([Itemkey]) REFERENCES [dbo].[Item] ([ItemKey]),
    CONSTRAINT [FK_OrderExpene_Route] FOREIGN KEY ([RouteKey]) REFERENCES [dbo].[Routes] ([RouteKey])
);


GO
CREATE NONCLUSTERED INDEX [IX_OrderExpense_Itemkey_RouteKey_EE293]
    ON [dbo].[OrderExpense]([Itemkey] ASC, [RouteKey] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_OrderExpense_RouteKey]
    ON [dbo].[OrderExpense]([RouteKey] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_OrderExpense_Itemkey]
    ON [dbo].[OrderExpense]([Itemkey] ASC)
    INCLUDE([RouteKey], [UnitCost], [Qty], [NewUnitCost]) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_OrderExpense_OrderDetailKey]
    ON [dbo].[OrderExpense]([OrderDetailKey] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IDX_2334_2333_OrderExpense]
    ON [dbo].[OrderExpense]([Itemkey] ASC)
    INCLUDE([OrderDetailKey]) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_OrderExpense_WarehouseItemKey]
    ON [dbo].[OrderExpense]([WarehouseItemKey] ASC);


GO


CREATE TRIGGER [dbo].[TR_OrderExpense_AfterInsertDelete]
ON [dbo].[OrderExpense] AFTER INSERT, DELETE
AS
BEGIN
	IF @@ROWCOUNT>0 		
	BEGIN
		DECLARE @User VARCHAR(50)
		SET @User=( SELECT SYSTEM_USER )
		--*******************Update Only***************
		IF (
			SELECT COUNT(1) 
			FROM INSERTED A 
				INNER JOIN DELETED D ON D.RouteKey=A.RouteKey
		   )>0
		   BEGIN
				INSERT INTO [dbo].[OrderExpense_log]
							(
								[OrderExpenseKey],[Itemkey],[RouteKey],[UnitCost],[Qty],[NewUnitCost],[CreateDate],
								[CreateUserKey],[LastUpdateDate],[UpdateUserKey],[ActionType],[ActionUser],ActionDate
							)
				SELECT	[OrderExpenseKey], [Itemkey], [RouteKey], [UnitCost], [Qty], 
						[NewUnitCost], [CreateDate], [CreateUserKey], [LastUpdateDate], [UpdateUserKey],'UPDATE', 
						isnull(UpdateUserKey,CreateUserKey), GETDATE()
				FROM INSERTED
			END
			--***************Insert Only******************
			IF (
			SELECT COUNT(1) 
			FROM INSERTED A 
				LEFT JOIN DELETED D ON D.RouteKey=A.RouteKey
			WHERE D.RouteKey IS NULL
		   )>0
		   BEGIN
				INSERT INTO [dbo].[OrderExpense_log]
							(
								[OrderExpenseKey],[Itemkey],[RouteKey],[UnitCost],[Qty],[NewUnitCost],[CreateDate],
								[CreateUserKey],[LastUpdateDate],[UpdateUserKey],[ActionType],[ActionUser],ActionDate
							)
				SELECT	[OrderExpenseKey], [Itemkey], [RouteKey], [UnitCost], [Qty], 
						[NewUnitCost], [CreateDate], [CreateUserKey], [LastUpdateDate], [UpdateUserKey],'INSERT', 
						isnull(UpdateUserKey,CreateUserKey),GETDATE()
				FROM INSERTED
			END
			--**************Delete Only********************
			IF (
			SELECT COUNT(1) 
			FROM DELETED A 
				LEFT JOIN INSERTED D ON D.RouteKey=A.RouteKey
			WHERE D.RouteKey IS NULL
		   )>0
		   BEGIN
				INSERT INTO [dbo].[OrderExpense_log]
							(
								[OrderExpenseKey],[Itemkey],[RouteKey],[UnitCost],[Qty],[NewUnitCost],[CreateDate],
								[CreateUserKey],[LastUpdateDate],[UpdateUserKey],[ActionType],[ActionUser],ActionDate
							)
				SELECT	[OrderExpenseKey], [Itemkey], [RouteKey], [UnitCost], [Qty], 
						[NewUnitCost], [CreateDate], [CreateUserKey], [LastUpdateDate], [UpdateUserKey],'DELETE', 
						isnull(UpdateUserKey,CreateUserKey), GETDATE()
				FROM DELETED
			END
	END
END
