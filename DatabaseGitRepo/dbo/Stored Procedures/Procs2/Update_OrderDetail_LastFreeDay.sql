CREATE PROCEDURE [dbo].[Update_OrderDetail_LastFreeDay]
/*
Update detail data from Container Screen
*/
@OrderDetailKey		INT,
@LastFreeDay		Date,
@UpdateUserKey INT,
@OutPut		   BIT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SET @OutPut=0;
	DECLARE @UserName				NVARCHAR(100)='',
			@ContainerNo			NVARCHAR(20)

	SELECT  @UserName=ISNULL(UserName,'') FROM [User] WITH (NOLOCK) WHERE UserKey=@UpdateUserKey			
	SELECT TOP 1 @ContainerNo = ContainerNo FROM OrderDetail WITH (NOLOCK) WHERE OrderDetailKey=@OrderDetailKey

	UPDATE OrderDetail 
	SET LastFreeDay= @LastFreeDay, LastUpdateDate = GETDATE(), UpdateUserKey = @UpdateUserKey  
	WHERE OrderDetailKey= @OrderDetailKey 

	UPDATE Container_GnosisData 
	SET LFD= @LastFreeDay, LFDChangedByUser=CASE WHEN ISNULL(@LastFreeDay,'')<>ISNULL(LFD,'') THEN 1 ELSE LFDChangedByUser END
	WHERE OrderDetailKey= @OrderDetailKey

	INSERT INTO AuditLogDetail
			(DateCreated,CreateUser,RefType,RefId,RefKey,
			 Stage,CommentType,Comments)
	SELECT   GETDATE(),@UserName,'Container',@ContainerNo,@OrderDetailKey,
			 null,'Text','LastFreeDay is updated by '+@UserName

	SET @OutPut=1;
END
