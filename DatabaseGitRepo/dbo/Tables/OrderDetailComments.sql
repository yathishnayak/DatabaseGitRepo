CREATE TABLE [dbo].[OrderDetailComments] (
    [OrderDetailKey] INT NOT NULL,
    [CommentKey]     INT NOT NULL,
    CONSTRAINT [PK_OrderDetailComments] PRIMARY KEY CLUSTERED ([OrderDetailKey] ASC, [CommentKey] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_OrderDetailComments_comment] FOREIGN KEY ([CommentKey]) REFERENCES [dbo].[Comment] ([CommentKey]),
    CONSTRAINT [FK_OrderDetailComments_OrderDetail] FOREIGN KEY ([OrderDetailKey]) REFERENCES [dbo].[OrderDetail] ([OrderDetailKey])
);


GO
CREATE NONCLUSTERED INDEX [IX_OrderDetailComments_CommentKey]
    ON [dbo].[OrderDetailComments]([CommentKey] ASC);


GO
CREATE TRIGGER [dbo].[TR_OrderDetailComments_AfterInsertDelete]
ON [dbo].[OrderDetailComments] AFTER INSERT, DELETE
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
				INNER JOIN DELETED D ON D.OrderDetailKey=A.OrderDetailKey
		   )>0
		   BEGIN
				INSERT INTO [dbo].OrderDetailComments_Log( OrderDetailKey,CommentKey,ActionType,ActionUser,ActionDate)
							
				SELECT	OrderDetailKey, CommentKey, 'UPDATE', @User, GETDATE()
				FROM INSERTED
			END
			--***************Insert Only******************
			IF (
			SELECT COUNT(1) 
			FROM INSERTED A 
				LEFT JOIN DELETED D ON D.OrderDetailKey=A.OrderDetailKey
			WHERE D.OrderDetailKey IS NULL
		   )>0
		   BEGIN
				INSERT INTO [dbo].OrderDetailComments_Log( OrderDetailKey,CommentKey,ActionType,ActionUser,ActionDate)
							
				SELECT	OrderDetailKey, CommentKey, 'INSERT', @User, GETDATE()
				FROM INSERTED
			END
			--**************Delete Only********************
			IF (
			SELECT COUNT(1) 
			FROM DELETED A 
				LEFT JOIN INSERTED D ON D.OrderDetailKey=A.OrderDetailKey
			WHERE D.OrderDetailKey IS NULL
		   )>0
		   BEGIN
				INSERT INTO [dbo].OrderDetailComments_Log( OrderDetailKey,CommentKey,ActionType,ActionUser,ActionDate)
							
				SELECT	OrderDetailKey, CommentKey, 'INSERT', @User, GETDATE()
				FROM DELETED
			END
	END
END
