CREATE PROCEDURE [dbo].[Get_CustomerSegments]

AS

BEGIN
	SELECT CustomerSegmentKey,CustomerSegment FROM CustomerSegments
	WHERE IsActive=1 AND IsDeleted=0
	FOR JSON PATH
END
