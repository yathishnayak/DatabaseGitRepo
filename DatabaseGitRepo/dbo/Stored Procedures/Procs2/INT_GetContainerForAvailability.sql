
CREATE PROC [dbo].[INT_GetContainerForAvailability]
as
BEGIN
	SELECT DISTINCT  CONTAINERNO FROM OrderDetail
	WHERE Status = 1 and SourceAddrKey =  1198
END
