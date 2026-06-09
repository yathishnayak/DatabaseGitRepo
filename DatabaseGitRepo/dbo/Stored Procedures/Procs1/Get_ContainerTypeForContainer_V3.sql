/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"OrderDetailKey" : 47902, "Container" : "FCIU9249458"}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [Get_ContainerTypeForContainer_V3] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	Select @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[Get_ContainerTypeForContainer_V3] 
(
	@UserKey		INT = 0,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS
BEGIN

	IF (ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'Parameters not found'
			RETURN
		END	

	DECLARE
		@OrderDetailKey	INT = 0,
		@Container		VARCHAR(20) = ''

	SELECT
		@OrderDetailKey			=  OrderDetailKey	,
		@Container				=  Container
	FROM OPENJSON(@JSONString)
	WITH
	(
		OrderDetailKey		INT				'$.OrderDetailKey',
		Container			VARCHAR(20)		'$.Container'
	)

	SELECT A.*
	FROM (
	SELECT 
		OC.orderdetailkey,OC.commentkey,LTRIM(RTRIM([value])) AS 'Comment', OD.ContainerNo,LEFT([value],3) AS ShortComment
		FROM [dbo].[Comment] C WITH(NOLOCK)
			CROSS APPLY STRING_SPLIT(C.description,',')  
			INNER JOIN 
				[dbo].[OrderDetailComments] OC WITH(NOLOCK)  ON  OC.CommentKey = C.CommentKey
			INNER JOIN Orderdetail OD WITH(NOLOCK) on OD.OrderDetailKey = OC.OrderDetailKey
		WHERE (@OrderDetailKey = 0 OR OD.OrderDetailKey = @OrderDetailKey)
			AND (@Container = 'NA' OR OD.ContainerNo = @Container OR @Container='')
		) A 
		INNER JOIN ContainerTypes CT WITH(NOLOCK) ON A.Comment = CT.TypeID OR A.Comment = CT.ShortCode

		FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
		SET @Status = 1
		SET @Reason = 'Success'
END