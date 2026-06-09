

CREATE VIEW [dbo].[vContainerType]
as
select OrderDetailKey, CommentKey, A.ContainerTypeKey, B.TypeID
from ContainerTypesLink A WITH (NOLOCK)
inner join ContainerTypes B  WITH (NOLOCK) on A.ContainerTypeKey = B.ContainerTypeKey
