CREATE TABLE [dbo].[RouteSwitch] (
    [FromRouteKey]  INT      NULL,
    [ToRouteKey]    INT      NULL,
    [CreateDate]    DATETIME NULL,
    [CreateUserKey] INT      NULL
);


GO

CREATE TRIGGER [dbo].[TR_RouteSwitch_AfterDeleteUpdate]
ON [dbo].[RouteSwitch] AFTER UPDATE,DELETE
AS
BEGIN
	IF @@ROWCOUNT>0 
	BEGIN		
		DECLARE @User VARCHAR(50)
		SET @User=( SELECT SYSTEM_USER )

		IF  (
				SELECT COUNT(1) FROM DELETED A 
					LEFT JOIN INSERTED I ON I.FromRouteKey=A.FromRouteKey
				WHERE I.FromRouteKey IS NULL
			)>0
			BEGIN
				INSERT INTO [dbo].[RouteSwitch_Log]
				   (
					[FromRouteKey]
				   ,[ToRouteKey]
				   ,[CreateDate]
				   ,CreateUserKey
				   ,[ActionDate]
				   ,[ActionUser]
				   ,[ActionType]
				   )
				SELECT [FromRouteKey]
				  ,[ToRouteKey]
				  ,[CreateDate]
				  ,CreateUserKey  
				  ,GETDATE()
				  ,@User
				  ,'DELETE'
				FROM DELETED 
			END	

			IF  (
					SELECT COUNT(1) 
					FROM DELETED A 
						JOIN INSERTED I ON I.FromRouteKey=A.FromRouteKey				
			)>0
			BEGIN
				INSERT INTO [dbo].[RouteSwitch_Log]
				   (
					[FromRouteKey]
				   ,[ToRouteKey]
				   ,[CreateDate]
				   ,CreateUserKey
				   ,[ActionDate]
				   ,[ActionUser]
				   ,[ActionType]
				   )	
				SELECT [FromRouteKey]
				  ,[ToRouteKey]
				  ,[CreateDate]
				  ,CreateUserKey  
				  ,GETDATE()
				  ,@User
				  ,'DELETE'
				FROM DELETED 

				INSERT INTO [dbo].[RouteSwitch_Log]
				   (
					[FromRouteKey]
				   ,[ToRouteKey]
				   ,[CreateDate]
				   ,CreateUserKey
				   ,[ActionDate]
				   ,[ActionUser]
				   ,[ActionType]
				   )
				SELECT [FromRouteKey]
				  ,[ToRouteKey]				
				  ,[CreateDate]			
				  ,CreateUserKey
				  ,GETDATE()
				  ,@User
				  ,'INSERT'
				FROM INSERTED 
			END	
	END
END
