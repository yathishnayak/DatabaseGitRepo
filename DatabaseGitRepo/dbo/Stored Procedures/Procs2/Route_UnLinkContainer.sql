/*
 declare @UserKey		INT=0,
	@JsonString		VARCHAR(MAX)='{"RouteKey":777199,"LinkedContainerNo":"TCNU5626693 DS","OrderDetailKey":243272}',
	@Status			BIT	= 0 ,
	@Reason			VARCHAR(1000) = '' 

	EXEC Route_UnLinkContainer @UserKey,@JsonString,@Status output, @Reason output
	select @Status,@Reason
	*/
CREATE Proc [dbo].[Route_UnLinkContainer]  
(
	@UserKey		INT=0,
	@JsonString		VARCHAR(MAX)='',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT
)
As
Begin
	set nocount on
	set fmtonly off
	SET ARITHABORT ON;
	set @Reason = 0
	set @Reason = ''

	declare @cnt int = 0, @ContainerNo varchar(20) = '', @LinkedOrderDetailKey	int = 0, @UserName VARCHAR(100)='',@OrderDetailKey			int,
	@RouteKey				INT,
	@LinkedContainerNo		varchar(20)
	SELECT @OrderDetailKey=OrderDetailKey,@RouteKey=RouteKey,@LinkedContainerNo=LinkedContainerNo
	FROM OPENJSON(@JsonString, '$')
	WITH (
			OrderDetailKey		INT			'$.OrderDetailKey',
			RouteKey			INT			'$.RouteKey',
			LinkedContainerNo	VARCHAR(20)	'$.LinkedContainerNo'
		)
	
	
	Begin Try
	
		SET @LinkedContainerNo=REPLACE(@LinkedContainerNo,' DS','')
		SET @LinkedContainerNo=REPLACE(@LinkedContainerNo,' OSY','')
		IF(@LinkedContainerNo IS NULL OR ISNULL(@LinkedContainerNo,'')='' OR @LinkedContainerNo=null OR @LinkedContainerNo='null')
		BEGIN
			SELECT @LinkedContainerNo = LinkedContainerNo FROM OrderDetail WHERE OrderDetailKey = @OrderDetailKey
		END
		Select @ContainerNo = ContainerNo from ORderDetail where OrderDetailKey = @OrderDetailKey
		Select @cnt = count(1) from OrderDetail where OrderDetailKey = @OrderDetailKey and LinkedContainerNo = @LinkedContainerNo
		select @LinkedOrderDetailKey = LinkedOrderDetailKey from orderdetail where OrderDetailKey = @OrderDetailKey
		SELECT @UserName= UserName FROM [USER] WHERE UserKey=@UserKey

		IF(@cnt > 0)
		begin
		Begin Transaction
			update OrderDetail set
				IsLinked = 0,
				LinkedContainerNo = null,
				LinkedOrderDetailKey = null
			where  OrderDetailKey = @OrderDetailKey

			update OrderDetail set
				IsLinked = 0,
				LinkedContainerNo = null,
				LinkedOrderDetailKey = null
			where  OrderDetailKey = @LinkedOrderDetailKey

			update Routes set
				LinkedBy = null,
				LinkedContainer = null,
				LinkedDate = null,
				ContainerNoSource=null
			where  RouteKey = @RouteKey

			IF((SELECT COUNT(1) FROM Routes WHERE OrderDetailKey=@OrderDetailKey and LinkedContainer<>'' AND
				LegKey IN (2,8,14,21,23,25,27,30,32,34,35,36,37,38,39,46,47,50,51,52,53,54,55,56,1,9,17,18,24,26,29,31,45,59))>0)
			BEGIN
				--change to update previous leg linked container
				SET @LinkedContainerNo=(SELECT Top 1 ISNULL(LinkedContainer,'') FROM Routes WHERE OrderDetailKey=@OrderDetailKey and LinkedContainer<>'' AND
				LegKey IN (2,8,14,21,23,25,27,30,32,34,35,36,37,38,39,46,47,50,51,52,53,54,55,56,1,9,17,18,24,26,29,31,45,59) ORDER BY RouteKey DESC)

				update OrderDetail set
				IsLinked = 1,
				LinkedContainerNo = (SELECT Top 1 LinkedContainer FROM Routes WHERE OrderDetailKey=@OrderDetailKey and LinkedContainer<>'' AND
				LegKey IN (2,8,14,21,23,25,27,30,32,34,35,36,37,38,39,46,47,50,51,52,53,54,55,56,1,9,17,18,24,26,29,31,45,59) ORDER BY RouteKey DESC),
				LinkedOrderDetailKey = (SELECT ISNULL(OrderDetailKey,0) FROM OrderDetail WHERE ContainerNo=@LinkedContainerNo)
				where  OrderDetailKey = @OrderDetailKey 
			END
			Insert into AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
			select getDate(), @UserName, 'Container', @ContainerNo, @OrderDetailKey, null, 'Text', 'Container ' + @Containerno + ' UnLinked from ' + @LinkedContainerNo 

			Commit Transaction
			Set @Status = 1
			Set @Reason = 'UnLinked Successfully.'
			Return
		end
		
		Set @Status = 0
		Set @Reason = 'Error. Container nos. not found'
		return
	End Try
	Begin Catch
		Set @Status = 0
		Set @Reason = 'Technical Error'
		Rollback Transaction
		return
	End Catch
End