CREATE Procedure [dbo].[GetLegNoForMultiContainer]
(
	@OrderDetailKey	INT=0
)
AS

BEGIN
	SELECT ISNULL(Max(ISNULL(LegNo,0)),0) As CurrentLegNo, ISNULL(Max(ISNULL(LegNo,0)),0)+1 As NewLegNo FROM [Routes] WHERE ORderDetailKey=@OrderDetailKey
	FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
END
