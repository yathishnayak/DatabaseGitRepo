CREATE  PROCEDURE [dbo].[GET_ChassisDetail_V2]
(
	@UserKey		INT = 953,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS
BEGIN
	
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SELECT ChassisKey,ChassisNo,ChassisType, IsEditable 
	FROM chassis CH WITH (NOLOCK)
		INNER JOIN dbo.[Status] ST WITH (NOLOCK) ON ST.StatusKey=CH.StatusKey
		LEFT JOIN MarketLocation ML WITH (NOLOCK) ON ML.MarketLocationKey=CH.MarketLocationKey
	WHERE ST.StatusName='Active' and chassisKey<>591
	--AND	(ISNULL(@MarketLocationKey,0)=0 OR CASE WHEN @marketLocationKey=0 THEN 0 ELSE ISNULL(CH.MarketLocationKey,0) END = @marketLocationKey)
		order by ChassisNo

		FOR JSON PATH

		SET @Status=1
		SET @Reason='Success'
   
END