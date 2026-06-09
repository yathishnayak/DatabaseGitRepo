
CREATE proc [dbo].[TMS_Integration_ContainerSizeList]
AS
SELECT		ContainerSizeKey, Description
FROM		ContainerSize with (nolock)
WHERE		StatusKey = 1
ORDER		by Description
For JSON PATH



