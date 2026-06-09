CREATE TABLE [dbo].[VoucherDetail] (
    [VoucherLineKey] INT             IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [Voucherkey]     INT             NOT NULL,
    [ItemKey]        INT             NOT NULL,
    [Description]    VARCHAR (255)   NULL,
    [UnitCost]       DECIMAL (18, 5) NULL,
    [Qty]            DECIMAL (18, 5) NULL,
    [ExtCost]        DECIMAL (18, 5) NULL,
    [RouteKey]       INT             NULL,
    [Remarks]        VARCHAR (2000)  NULL,
    [CreateUserKey]  INT             NOT NULL,
    [CreateDate]     DATETIME        NOT NULL,
    [UpdateUserKey]  INT             NULL,
    [UpdateDate]     DATETIME        NULL,
    [IsDeleted]      BIT             CONSTRAINT [DF_VoucherDetail_IsDeleted] DEFAULT ((0)) NULL,
    [DriverPay]      VARCHAR (2)     NULL,
    CONSTRAINT [VoucherDetail_pkey] PRIMARY KEY CLUSTERED ([VoucherLineKey] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_VoucherDetail_Item] FOREIGN KEY ([ItemKey]) REFERENCES [dbo].[Item] ([ItemKey])
);


GO
CREATE NONCLUSTERED INDEX [IX_VoucherDetail_Voucherkey_97840]
    ON [dbo].[VoucherDetail]([Voucherkey] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_VoucherDetail_RouteKey_C64D5]
    ON [dbo].[VoucherDetail]([RouteKey] ASC) WITH (FILLFACTOR = 90);


GO


CREATE TRIGGER [dbo].[TR_VoucherDetail_AfterDelete]
ON [dbo].[VoucherDetail] AFTER DELETE
AS
BEGIN
	IF @@ROWCOUNT>0 		
	BEGIN
		DECLARE @User VARCHAR(50)
		SET @User=( SELECT SYSTEM_USER )
		IF UPDATE(UnitCost) OR UPDATE (Qty)				
			--**************Delete Only********************
			IF	(
					SELECT COUNT(1) 
					FROM DELETED A 
						LEFT JOIN INSERTED D ON D.VoucherLineKey=A.VoucherLineKey
					WHERE D.VoucherLineKey IS NULL
				)>0
		   BEGIN
				INSERT INTO [dbo].[VoucherDetail_Log]
					([VoucherLineKey],[Voucherkey],[ItemKey],[Description],[UnitCost],[Qty],[ExtCost],[RouteKey]
					,[CreateUserKey],[CreateDate],[UpdateUserKey],[UpdateDate],[ActionType],[ActionUser],ActionDate)
				SELECT	[VoucherLineKey],[Voucherkey],[ItemKey],[Description],[UnitCost],[Qty],[ExtCost],[RouteKey],
						[CreateUserKey],[CreateDate],[UpdateUserKey],[UpdateDate], 'DELETE',
						isnull(UpdateUserKey,CreateUserKey),GETDATE()
				FROM DELETED 
			END
	END
END

GO


CREATE TRIGGER [dbo].[TR_VoucherDetail_AfterInsert]
ON [dbo].[VoucherDetail] AFTER INSERT
AS
BEGIN
--****************Insert new Item***************
	IF @@ROWCOUNT>0 		
	BEGIN
		DECLARE @User VARCHAR(50)
		DECLARE @LastInsert DATETIME
		DECLARE @NewInsert DATETIME

		SET @User=( SELECT SYSTEM_USER )
		SET @LastInsert = ( SELECT MAX(V.CreateDate) FROM [VoucherDetail] V 
								INNER JOIN INSERTED I ON I.Voucherkey=V.Voucherkey
							WHERE V.VoucherLineKey NOT IN ( SELECT VoucherLineKey FROM INSERTED  ) )

		SET @LastInsert= (  CASE WHEN @LastInsert IS NULL THEN dateadd(S,-20,GETDATE()) ELSE @LastInsert END )

		SET @NewInsert = ( SELECT MAX(CreateDate) FROM INSERTED )


		IF 	( @LastInsert < @NewInsert ) AND 
			(
				SELECT COUNT(1) 
				FROM INSERTED A 
					LEFT JOIN DELETED D ON D.VoucherLineKey=A.VoucherLineKey
				WHERE D.VoucherLineKey IS NULL
			)>0
		BEGIN
--***************Insert Only******************			
			INSERT INTO [dbo].[VoucherDetail_Log]
			(
				[VoucherLineKey],[Voucherkey],[ItemKey],[Description],[UnitCost],[Qty],[ExtCost],[RouteKey]
				,[CreateUserKey],[CreateDate],[UpdateUserKey],[UpdateDate],[ActionType],[ActionUser],ActionDate
			)
			SELECT	[VoucherLineKey],[Voucherkey],[ItemKey],[Description],[UnitCost],[Qty],[ExtCost]
					,[RouteKey],[CreateUserKey],[CreateDate],[UpdateUserKey],[UpdateDate],'INSERT',
					isnull(UpdateUserKey,CreateUserKey),GETDATE()
			FROM INSERTED
		END
	END
END

GO


CREATE TRIGGER [dbo].[TR_VoucherDetail_AfterUpdate]
ON [dbo].[VoucherDetail] AFTER UPDATE
AS
BEGIN
--- Update for  Qty an UnitCost
	IF @@ROWCOUNT>0 		
	BEGIN
		DECLARE @User VARCHAR(50)
		SET @User=( SELECT SYSTEM_USER )
		IF UPDATE(UnitCost) OR UPDATE (Qty)
		BEGIN
			IF UPDATE(UnitCost)
			BEGIN
				INSERT INTO [dbo].[AuditLog]
			    ( 
				  [CompanyKey],[FieldName],[IDValue],[NewValue],[OldValue],[Operation],
				  [ProgramName],[SysDate],[TableName],[UserID] , VoucherKey , VoucherLineKey
				)
				SELECT	VH.CompanyKey, 'UnitCost',VH.VoucherNo,A.UnitCost,
						B.UnitCost,'Update',NULL,GETDATE(),'VoucherDetail',isnull(A.UpdateUserKey,A.CreateUserKey),
						A.Voucherkey, A.VoucherLineKey
				FROM INSERTED A 
					INNER JOIN DELETED B ON A.VoucherLineKey=B.VoucherLineKey
					INNER JOIN dbo.VoucherHeader VH ON VH.VoucherKey=A.VoucherKey				
				WHERE ISNULL(A.UnitCost,0)<>ISNULL(B.UnitCost,0)
			END
				IF UPDATE(Qty)
				BEGIN
					INSERT INTO [dbo].[AuditLog]
				   ( [CompanyKey],[FieldName],[IDValue],[NewValue],[OldValue],[Operation]
					,[ProgramName],[SysDate],[TableName],[UserID] , VoucherKey , VoucherLineKey )
					SELECT	VH.CompanyKey, 'Qty',VH.VoucherNo,A.Qty,
							B.Qty,'Update',NULL,GETDATE(),'VoucherDetail',isnull(A.UpdateUserKey,A.CreateUserKey),
							 A.VoucherKey , A.VoucherLineKey
					FROM INSERTED A 
						INNER JOIN DELETED B ON A.VoucherLineKey=B.VoucherLineKey
						INNER JOIN dbo.VoucherHeader VH ON VH.VoucherKey=A.VoucherKey				
					WHERE ISNULL(A.Qty,0)<>ISNULL(B.Qty,0)
				END
		END				
	END
END
