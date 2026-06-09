/** 
Declare 
	@UserKey		INT,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING		NVARCHAR(Max) = '{"RefType":"Container", "RefKey":107927}'
	EXEC [Get_CommentLogDetail_V2] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
	SELECT @Status Status, @Reason Reason
**/

CREATE Procedure [dbo].[Get_CommentLogDetail_V2]-- [Get_CommentLogDetail] 'Container',107927
-- [Get_CommentLogDetail] 'Container Note',47697
(
	@UserKey		INT = 1144,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0 
)
as
Begin
	SET NOCOUNT ON
	SET FMTONLY OFF

	IF ISNULL(@JSONString, '') = ''
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'Parameters not found'
			RETURN
		END	
		
	IF (@IsDebug = 1)
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'In Debug Mode'
		END	

	DECLARE 
		@RefType as Varchar(20) = 'Container',
		@RefKey as Int = 172

	SELECT 
		@RefType		=		RefType,
		@RefKey			=		RefKey
	FROM OPENJSON(@JSONString)
	WITH
	(
		RefType			VARCHAR(20)			'$.RefType',
		RefKey			INT					'$.RefKey'
	)


	CREATE TABLE #COMMENTS
	(
		CommentKey				int, 
		DateCreated				DateTime, 
		CreateUser				varchar(50), 
		RefType					varchar(50), 
		RefId					varchar(50), 
		RefKey					int,
		Stage					varchar(50), 
		CommentType				varchar(10),  -- Text / Email
		Comments				nvarchar(max),
		IsDeleted				bit default 0,
		IsUserComment			BIT default 0,
		IsPermanentlyDeleted	BIT DEFAULT 0,
		CommentedUserKey		INT,
		Replies					VARCHAR(1000)
	)

	insert into #COMMENTS(CommentKey,DateCreated,CreateUser,RefType, RefId, RefKey, 
			Stage, CommentType, Comments,IsDeleted,IsUserComment,IsPermanentlyDeleted,CommentedUserKey,Replies)
	select ODC.CommentKey, C.CreateDate, U.UserName,'Container Note', OD.ContainerNo, ODC.OrderDetailKey,
			null, 'Text', C.Description,c.IsDeleted,C.IsUsercomment, C.IsPermanentDelete, C.CreateUserKey,
			(SELECT OHD1.OrderDetailKey,C1.Commentkey, ISNULL(U1.UserName,'') as UserName, C1.[Description] AS DetailComment, 
				C1.CreateDate, C1.CreateUserkey   
				FROM dbo.comment C1 WITH (NOLOCK)
					INNER JOIN dbo.OrderDetailComments OHD1 WITH (NOLOCK) ON OHD1.commentkey = C1.commentkey
					LEFT JOIN dbo.[User] U1 WITH (NOLOCK) ON U1.UserKey=C1.CreateUserKey 
				WHERE OHD1.OrderDetailKey = ODC.OrderDetailKey AND ISNULL(C1.ParentCommentKey,0) <>0 and c1.ParentCommentKey=c.CommentKey 
				and  isnull(isDeleted ,0) = 0 	for json path			
			)
	from OrderDetailComments ODC WITH (NOLOCK)
	inner join Comment C WITH (NOLOCK) on ODC.CommentKey = C.CommentKey
	LEft join [User] U WITH (NOLOCK) on C.CreateUserKey = u.UserKey
	inner join OrderDetail OD WITH (NOLOCK) on ODC.OrderDetailKey = OD.OrderDetailKey
	where ODC.OrderDetailKey = @RefKey  AND ISNULL(ParentCommentKey,0)=0-- and ISNULL(isDeleted,0) = 0

	insert into #COMMENTS(CommentKey,DateCreated,CreateUser,RefType, RefId, RefKey, 
			Stage, CommentType, Comments,IsDeleted,IsUserComment,IsPermanentlyDeleted,CommentedUserKey,Replies)
	select ODC.CommentKey, C.CreateDate, U.UserName,'Order Note', OD.ContainerNo, OD.OrderDetailKey,
			null, 'Text', C.Description, c.IsDeleted,C.IsUsercomment,C.IsPermanentDelete, C.CreateUserKey,
			(SELECT OHD1.OrderKey,C1.Commentkey, ISNULL(U1.UserName,'') as UserName, C1.[Description] AS DetailComment, 
				C1.CreateDate, C1.CreateUserkey   
				FROM dbo.comment C1 WITH (NOLOCK)
					INNER JOIN dbo.OrderHeaderComments OHD1 WITH (NOLOCK) ON OHD1.commentkey = C1.commentkey
					LEFT JOIN dbo.[User] U1 WITH (NOLOCK) ON U1.UserKey=C1.CreateUserKey 
				WHERE OHD1.OrderKey = ODC.OrderKey AND ISNULL(C1.ParentCommentKey,0) <>0 and c1.ParentCommentKey=c.CommentKey 
				and  isnull(isDeleted ,0) = 0 
				for json path
			)
	from OrderHeaderComments ODC WITH (NOLOCK)
	inner join Comment C WITH (NOLOCK) on ODC.CommentKey = C.CommentKey
	LEft join [User] U WITH (NOLOCK) on C.CreateUserKey = u.UserKey
	inner join OrderDetail OD WITH (NOLOCK) on ODC.OrderKey = OD.OrderKey
	where OD.OrderDetailKey = @RefKey AND ISNULL(ParentCommentKey,0)=0 -- and ISNULL(isDeleted,0) = 0

	insert into #COMMENTS(CommentKey,DateCreated,CreateUser,RefType, RefId, RefKey, 
			Stage, CommentType, Comments,IsDeleted,IsUserComment,IsPermanentlyDeleted,CommentedUserKey,Replies)
	select 1, Getdate(), U.UserName,'Warehouse Notes', OD.ContainerNo, OD.OrderDetailKey,
			null, 'Text', OD.SchedulerNotes,0,0,0,OD.CreateUserKey,
			''
	from OrderDetail OD WITH (NOLOCK)
	LEft join [User] U WITH (NOLOCK) on OD.CreateUserKey = U.UserKey
	where OD.OrderDetailKey = @RefKey and isnull(OD.SchedulerNotes,'') <> '' 

	insert into #COMMENTS(CommentKey,DateCreated,CreateUser,RefType, RefId, RefKey, 
			Stage, CommentType, Comments,IsDeleted,IsUserComment,IsPermanentlyDeleted,CommentedUserKey,Replies)
	select ODC.CommentKey, C.CreateDate, U.UserName,'Scheduler Note', OD.ContainerNo, ODC.OrderDetailKey,
			null, 'Text', C.Description,c.IsDeleted, C.IsUserComment,C.IsPermanentDelete, C.CreateUserKey,
			(SELECT OHD1.OrderDetailKey,C1.Commentkey, ISNULL(U1.UserName,'') as UserName, C1.[Description] AS DetailComment, 
				C1.CreateDate, C1.CreateUserkey   
				FROM dbo.comment C1 WITH (NOLOCK)
					INNER JOIN dbo.OrderDetailComments OHD1 WITH (NOLOCK) ON OHD1.commentkey = C1.commentkey
					LEFT JOIN dbo.[User] U1 WITH (NOLOCK) ON U1.UserKey=C1.CreateUserKey 
				WHERE OHD1.OrderDetailKey = ODC.OrderDetailKey AND ISNULL(C1.ParentCommentKey,0) <>0 and c1.ParentCommentKey=c.CommentKey 
				and  isnull(isDeleted ,0) = 0 
				for json path
			)
	from SchedulerComment ODC WITH (NOLOCK)
	inner join Comment C WITH (NOLOCK) on ODC.CommentKey = C.CommentKey
	LEft join [User] U WITH (NOLOCK) on C.CreateUserKey = u.UserKey
	inner join OrderDetail OD WITH (NOLOCK) on ODC.OrderDetailKey = OD.OrderDetailKey
	where ODC.OrderDetailKey = @RefKey and ISNULL(isDeleted,0) = 0 AND ISNULL(ParentCommentKey,0)=0

	insert into #COMMENTS(CommentKey,DateCreated,CreateUser,RefType, RefId, RefKey, 
			Stage, CommentType, Comments,IsDeleted,IsUserComment,IsPermanentlyDeleted,CommentedUserKey,Replies)
	select ODC.CommentKey, C.CreateDate, U.UserName,'Driver Note', L.LegID, ODC.OrderDetailKey,
			null, 'Text', C.Description,c.IsDeleted, C.IsUserComment,C.IsPermanentDelete, C.CreateUserKey,
			(SELECT OHD1.OrderDetailKey,C1.Commentkey, ISNULL(U1.UserName,'') as UserName, C1.[Description] AS DetailComment, 
				C1.CreateDate, C1.CreateUserkey   
				FROM dbo.comment C1 WITH (NOLOCK)
					INNER JOIN dbo.OrderDetailComments OHD1 WITH (NOLOCK) ON OHD1.commentkey = C1.commentkey
					LEFT JOIN dbo.[User] U1 WITH (NOLOCK) ON U1.UserKey=C1.CreateUserKey 
				WHERE OHD1.OrderDetailKey = ODC.OrderDetailKey AND ISNULL(C1.ParentCommentKey,0) <>0 and c1.ParentCommentKey=c.CommentKey 
				and  isnull(isDeleted ,0) = 0 
				for json path
			)
	from SchedulerDriverComment ODC WITH (NOLOCK)
	Left Join Routes RT WITH (NOLOCK) on ODC.RouteKey = RT.RouteKey
	Left Join Leg L WITH (NOLOCK) on RT.LegKey = L.LegKey
	inner join Comment C WITH (NOLOCK) on ODC.CommentKey = C.CommentKey
	LEft join [User] U WITH (NOLOCK) on C.CreateUserKey = u.UserKey
	inner join OrderDetail OD WITH (NOLOCK) on ODC.OrderDetailKey = OD.OrderDetailKey
	where ODC.OrderDetailKey = @RefKey and ISNULL(isDeleted,0) = 0 AND ISNULL(ParentCommentKey,0)=0

	select 
		c.CommentKey, 
		DateCreated, 
		CreateUser, 
		RefType, 
		RefId, 
		RefKey,
		Stage, 
		CommentType, 
		Comments,
		IsDeleted,
		ISNULL(IsPermanentlyDeleted,0) IsPermanentlyDeleted,
		--case when upper(left(Comments,3)) = '<P>' then 1 else 0 end as AllowEdit
		case when ISNULL(IsUserComment,0) = 1 then 1 else 0 end as AllowEdit,
		CommentedUserKey,
		Replies
	from #COMMENTS c 	
	where RefKey = @RefKey 
	order by DateCreated desc
	FOR JSON PATH;

	SET @Status = 1
	SET @Reason = 'Success'

	drop table #COMMENTS
End