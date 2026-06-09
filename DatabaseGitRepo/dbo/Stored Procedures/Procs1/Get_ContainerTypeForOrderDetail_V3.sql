/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"OrderDetailKey" : 48363}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [Get_ContainerTypeForOrderDetail_V3] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[Get_ContainerTypeForOrderDetail_V3]  -- Get_ContainerTypeForLeg 352
(
	@UserKey		INT = 0,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	IF (ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
	BEGIN
		SET		@Status = 0
		SET		@Reason = 'Parameters not found'
		RETURN
	END

	DECLARE
		@OrderDetailKey		INT = 0

	SELECT 
		@OrderDetailKey		= OrderDetailKey
	FROM OPENJSON(@JSONString)
	WITH
	(
		OrderDetailKey		INT			'$.OrderDetailKey'
	)


	SELECT @orderDetailKey as OrderDetailKey, 0 as RouteKey,
		CT.ContainerTypeKey, CT.TypeID, Ct.ItemKey, CT.isActive as IsActive,
		CONVERT(BIT,ISNULL(CASE WHEN ISNULL(CTL.OrderDetailKey,0) = 0 THEN 0 ELSE 1 END,0)) AS IsSelected
	FROM ContainerTypes CT WITH (NOLOCK)
--	LEFT JOIN (
--	SELECT 
--		OC.orderdetailkey,0 as RouteKey,OC.commentkey,LTRIM(RTRIM([value])) AS 'Comment', OD.ContainerNo,LEFT([value],3) AS ShortComment
--		FROM [dbo].[Comment] C  WITH (NOLOCK) 
--			CROSS APPLY STRING_SPLIT(C.description,',')  
--			INNER JOIN 
--				[dbo].[OrderDetailComments] OC   WITH (NOLOCK)  ON  OC.CommentKey = C.CommentKey
--			INNER JOIN Orderdetail OD   WITH (NOLOCK)  on OD.OrderDetailKey = OC.OrderDetailKey
----			INNER JOIN ROUTES RT   WITH (NOLOCK) ON OD.OrderDetailKey = RT.OrderDetailKey
--		WHERE OC.OrderDetailKey = @OrderDetailKey
--		) A ON A.Comment = CT.TypeID
	LEFT JOIN ContainerTypesLink CTL WITH(NOLOCK) ON CT.ContainerTypeKey = CTL.ContainerTypeKey AND CTL.OrderDetailKey = @OrderDetailKey 
	-- WHERE CTL.OrderDetailKey = @OrderDetailKey
	FOR JSON PATH

		SET @Status = 1
		SET @Reason = 'Success'
END