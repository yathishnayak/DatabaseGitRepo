CREATE TABLE [dbo].[Invoicedetail] (
    [InvoicelineKey]  INT             IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [InvoiceKey]      INT             NOT NULL,
    [ItemKey]         INT             NOT NULL,
    [Description]     VARCHAR (255)   NULL,
    [UnitPrice]       DECIMAL (18, 5) NULL,
    [Qty]             DECIMAL (18, 5) NULL,
    [ExtAmt]          DECIMAL (18, 2) NULL,
    [Container]       VARCHAR (20)    NULL,
    [OrderDetailKey]  INT             NULL,
    [CreateUserKey]   INT             NOT NULL,
    [CreateDate]      DATETIME        NOT NULL,
    [UpdateUserKey]   INT             NULL,
    [UpdateDate]      DATETIME        NULL,
    [Charges]         DECIMAL (18, 5) NULL,
    [SellPrice]       DECIMAL (18, 5) NULL,
    [BvsNB]           BIT             NULL,
    [FreeTime]        SMALLINT        NULL,
    [Minval]          INT             NULL,
    [MaxVal]          INT             NULL,
    [TimeDuration]    VARCHAR (10)    NULL,
    [ItemNotes]       NVARCHAR (MAX)  NULL,
    [ReportedCost]    DECIMAL (18, 5) NULL,
    [IsPercentage]    BIT             DEFAULT ((0)) NULL,
    [Percentage]      DECIMAL (18, 6) NULL,
    [BaseSellPrice]   DECIMAL (18, 6) NULL,
    [DatePercentCalc] DATETIME        NULL,
    CONSTRAINT [InvoiceDetail_pkey] PRIMARY KEY CLUSTERED ([InvoicelineKey] ASC) WITH (FILLFACTOR = 90)
);


GO
CREATE NONCLUSTERED INDEX [IX_Invoicedetail_InvoiceKey]
    ON [dbo].[Invoicedetail]([InvoiceKey] ASC)
    INCLUDE([ItemKey], [UnitPrice], [Qty], [ExtAmt], [Container], [OrderDetailKey], [Charges]) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_Invoicedetail_OrderDetailKey]
    ON [dbo].[Invoicedetail]([OrderDetailKey] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_Invoicedetail_ItemKey]
    ON [dbo].[Invoicedetail]([ItemKey] ASC)
    INCLUDE([OrderDetailKey]);


GO
CREATE NONCLUSTERED INDEX [IX_Invoicedetail_Container]
    ON [dbo].[Invoicedetail]([Container] ASC);


GO
CREATE TRIGGER [dbo].[TR_Invoicedetail_AfterUpdate]
ON dbo.Invoicedetail AFTER UPDATE
AS
BEGIN
	IF @@ROWCOUNT>0 		
	BEGIN
		DECLARE @User VARCHAR(50)
		SET @User=( SELECT SYSTEM_USER )
		IF UPDATE(UnitPrice) OR UPDATE (Qty) OR UPDATE (Container)
		BEGIN
			IF UPDATE(UnitPrice)
			BEGIN
				INSERT INTO [dbo].[AuditLog]
			   ( [CompanyKey],[FieldName],[IDValue],[NewValue],[OldValue],[Operation]
				,[ProgramName],[SysDate],[TableName],[UserID]  )
				SELECT	IH.CompanyKey, 'UnitPrice',IH.InvoiceNo,A.UnitPrice,
						B.UnitPrice,'Update',NULL,GETDATE(),'Invoicedetail',isnull(A.UpdateUserKey,A.CreateUserKey)					
				FROM INSERTED A 
					INNER JOIN DELETED B ON A.InvoicelineKey=B.InvoicelineKey
					INNER JOIN dbo.InvoiceHeader IH ON IH.InvoiceKey=A.InvoiceKey				
				WHERE ISNULL(A.UnitPrice,0)<>ISNULL(B.UnitPrice,0)
			END

				IF UPDATE(Qty)
				BEGIN
					INSERT INTO [dbo].[AuditLog]
				   ( [CompanyKey],[FieldName],[IDValue],[NewValue],[OldValue],[Operation]
					,[ProgramName],[SysDate],[TableName],[UserID]  )
					SELECT	IH.CompanyKey, 'Qty',IH.InvoiceNo,A.Qty,
							B.Qty,'Update',NULL,GETDATE(),'Invoicedetail',isnull(A.UpdateUserKey,A.CreateUserKey)					
					FROM INSERTED A 
						INNER JOIN DELETED B ON A.InvoicelineKey=B.InvoicelineKey
						INNER JOIN dbo.InvoiceHeader IH ON IH.InvoiceKey=A.InvoiceKey				
					WHERE ISNULL(A.Qty,0)<>ISNULL(B.Qty,0)
				END

				IF UPDATE(Container)
				BEGIN
					INSERT INTO [dbo].[AuditLog]
				   ( [CompanyKey],[FieldName],[IDValue],[NewValue],[OldValue],[Operation]
					,[ProgramName],[SysDate],[TableName],[UserID]  )
					SELECT	IH.CompanyKey, 'Container',IH.InvoiceNo,A.Container,
							B.Container,'Update',NULL,GETDATE(),'Invoicedetail',isnull(A.UpdateUserKey,A.CreateUserKey)					
					FROM INSERTED A 
						INNER JOIN DELETED B ON A.InvoicelineKey=B.InvoicelineKey
						INNER JOIN dbo.InvoiceHeader IH ON IH.InvoiceKey=A.InvoiceKey				
					WHERE ISNULL(A.Container,'')<>ISNULL(B.Container,'')
				END
		END
	END
END

GO
CREATE TRIGGER [dbo].[TR_Invoicedetail_AfterDelete]
ON dbo.Invoicedetail AFTER DELETE
AS
BEGIN
	IF @@ROWCOUNT>0 		
	BEGIN
		DECLARE @User VARCHAR(50)
		SET @User=( SELECT SYSTEM_USER )				
			--**************Delete Only********************
			IF (
			SELECT COUNT(1) 
			FROM DELETED A 
				LEFT JOIN INSERTED D ON D.InvoicelineKey=A.InvoicelineKey
			WHERE D.InvoicelineKey IS NULL
		   )>0
		   BEGIN
				INSERT INTO [dbo].[Invoicedetail_Log]
				(
					 [InvoicelineKey],[InvoiceKey],[ItemKey],[Description],[UnitPrice],[Qty],[ExtAmt]
					,[Container],[OrderDetailKey],[CreateUserKey],[CreateDate],[UpdateUserKey],[UpdateDate],[ActionType]
					,[ActionUser],ActionDate
				)
				SELECT 
					[InvoicelineKey],[InvoiceKey],[ItemKey],[Description],[UnitPrice]
					,[Qty],[ExtAmt],[Container],[OrderDetailKey],[CreateUserKey],[CreateDate]
					,[UpdateUserKey],[UpdateDate],'DELETE',isnull(UpdateUserKey,CreateUserKey),GETDATE()
				FROM DELETED
			END
	END
END

GO
CREATE TRIGGER [dbo].[TR_Invoicedetail_AfterInsert]
ON dbo.Invoicedetail AFTER INSERT
AS
BEGIN
	IF @@ROWCOUNT>0 		
	BEGIN
		DECLARE @User VARCHAR(50)
		DECLARE @LastInsert DATETIME
		DECLARE @NewInsert DATETIME

		SET @User=( SELECT SYSTEM_USER )
		SET @LastInsert = ( 
							SELECT MAX(N.CreateDate) 
							FROM dbo.Invoicedetail N 
								INNER JOIN INSERTED I ON I.InvoiceKey=N.InvoiceKey
							WHERE N.InvoicelineKey NOT IN ( SELECT InvoicelineKey FROM INSERTED )
						  )
		
		SET @LastInsert= (  CASE WHEN @LastInsert IS NULL THEN GETDATE() ELSE @LastInsert END )

		SET @NewInsert = ( SELECT MAX(CreateDate) FROM INSERTED )

		IF 	( SELECT ISNULL(DATEDIFF(SECOND,@LastInsert,@NewInsert),0))>20 AND 
			(
				SELECT COUNT(1) 
				FROM INSERTED A 
					LEFT JOIN DELETED D ON D.InvoiceKey=A.InvoiceKey
				WHERE D.InvoiceKey IS NULL
			)>0
		BEGIN
--***************Insert Only******************				
			INSERT INTO [dbo].[Invoicedetail_Log]([InvoicelineKey],[InvoiceKey],[ItemKey],[Description],[UnitPrice]
						,[Qty],[ExtAmt],[Container],[OrderDetailKey],[CreateUserKey],[CreateDate],[UpdateUserKey],[UpdateDate]
						,[ActionType]  ,[ActionUser],ActionDate)   
			SELECT [InvoicelineKey],[InvoiceKey],[ItemKey],[Description],[UnitPrice],[Qty],[ExtAmt],[Container]
					,[OrderDetailKey],[CreateUserKey],[CreateDate],[UpdateUserKey],[UpdateDate],'INSERT',
					isnull(UpdateUserKey,CreateUserKey),GETDATE()
			FROM INSERTED
		END
	END
END
