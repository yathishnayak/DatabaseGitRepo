CREATE PROCEDURE [dbo].[Get_DryRunTypeList]
As
BEGIN
SELECT DryRunTypeKey,DryRunType FROM DryRunType
WHERE IsActive=1 AND IsDeleted=0 
FOR JSON PATH
END
