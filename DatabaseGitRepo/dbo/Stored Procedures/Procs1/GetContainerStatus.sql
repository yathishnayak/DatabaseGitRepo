

CREATE proc [dbo].[GetContainerStatus]
as
Select status as StatusKey,
Description as StatusDescription
from OrderDetailStatus
