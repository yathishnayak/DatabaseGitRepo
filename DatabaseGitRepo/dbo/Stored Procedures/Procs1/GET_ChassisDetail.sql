

CREATE PROCEDURE [dbo].[GET_ChassisDetail]
@MarketLocationKey	INT=0
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SELECT chassisKey,ChassisNo,ChassisType, isEditable 
	FROM chassis CH WITH (NOLOCK)
		INNER JOIN dbo.[Status] ST WITH (NOLOCK) ON ST.StatusKey=CH.StatusKey
		LEFT JOIN MarketLocation ML WITH (NOLOCK) ON ML.MarketLocationKey=CH.MarketLocationKey
	WHERE ST.StatusName='Active' and chassisKey<>591
	--AND	(ISNULL(@MarketLocationKey,0)=0 OR CASE WHEN @marketLocationKey=0 THEN 0 ELSE ISNULL(CH.MarketLocationKey,0) END = @marketLocationKey)
		order by ChassisNo
END
