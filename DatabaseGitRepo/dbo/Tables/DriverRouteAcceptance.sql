CREATE TABLE [dbo].[DriverRouteAcceptance] (
    [AcceptanceKey]     INT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [RouteKey]          INT          NOT NULL,
    [Description]       VARCHAR (50) NULL,
    [CreateDate]        DATETIME     CONSTRAINT [DF_DriverRouteAcceptance_CreateDate] DEFAULT (getdate()) NOT NULL,
    [RejectReasonKey]   SMALLINT     NULL,
    [RejectReasonDescr] VARCHAR (50) NULL,
    [CreateUserKey]     INT          NULL,
    [DriverKey]         INT          NULL,
    [ActionDate]        DATETIME     NULL,
    CONSTRAINT [PK_DriverRouteAcceptance] PRIMARY KEY CLUSTERED ([AcceptanceKey] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_DriverRouteAcceptance_RouteKey_Description]
    ON [dbo].[DriverRouteAcceptance]([RouteKey] ASC, [Description] ASC);


GO

CREATE TRIGGER [dbo].[TR_DriverRouteAcceptance_AfterDeleteUpdate]
ON [dbo].[DriverRouteAcceptance] AFTER UPDATE,DELETE
AS
BEGIN
	IF @@ROWCOUNT>0 
	BEGIN		
		DECLARE @User VARCHAR(50)
		SET @User=( SELECT SYSTEM_USER )

		IF  (
				SELECT COUNT(1) FROM DELETED A 
					LEFT JOIN INSERTED I ON I.RouteKey=A.RouteKey
				WHERE I.RouteKey IS NULL
			)>0
			BEGIN
				INSERT INTO [dbo].[DriverRouteAcceptance_Log]
				   (
					[AcceptanceKey]
				   ,[RouteKey]
				   ,[Description]
				   ,[CreateDate]
				   ,[RejectReasonKey]
				   ,[RejectReasonDescr]
				   ,[CreateUserKey]
				   ,[ActionDate]
				   ,[ActionUser]
				   ,[ActionType]
				 )		
				SELECT [AcceptanceKey]
				  ,[RouteKey]
				  ,[Description]
				  ,[CreateDate]
				  ,[RejectReasonKey]
				  ,[RejectReasonDescr]
				  ,[CreateUserKey]
				  ,GETDATE()
				  ,@User
				  ,'DELETE'
				FROM DELETED 
			END	

			IF  (
					SELECT COUNT(1) 
					FROM DELETED A 
						JOIN INSERTED I ON I.RouteKey=A.RouteKey				
			)>0
			BEGIN
				INSERT INTO [dbo].[DriverRouteAcceptance_Log]
				   (
					[AcceptanceKey]
				   ,[RouteKey]
				   ,[Description]
				   ,[CreateDate]
				   ,[RejectReasonKey]
				   ,[RejectReasonDescr]
				   ,[CreateUserKey]
				   ,[ActionDate]
				   ,[ActionUser]
				   ,[ActionType]
				 )		
				SELECT [AcceptanceKey]
				  ,[RouteKey]
				  ,[Description]
				  ,[CreateDate]
				  ,[RejectReasonKey]
				  ,[RejectReasonDescr]
				  ,[CreateUserKey]
				  ,GETDATE()
				  ,@User
				  ,'DELETE'
				FROM DELETED 

				INSERT INTO [dbo].[DriverRouteAcceptance_Log]
				   (
					[AcceptanceKey]
				   ,[RouteKey]
				   ,[Description]
				   ,[CreateDate]
				   ,[RejectReasonKey]
				   ,[RejectReasonDescr]
				   ,[CreateUserKey]
				   ,[ActionDate]
				   ,[ActionUser]
				   ,[ActionType]
				 )		
				SELECT [AcceptanceKey]
				  ,[RouteKey]
				  ,[Description]
				  ,[CreateDate]
				  ,[RejectReasonKey]
				  ,[RejectReasonDescr]
				  ,[CreateUserKey]
				  ,GETDATE()
				  ,@User
				  ,'INSERT'
				FROM INSERTED 
			END	
	END
END
