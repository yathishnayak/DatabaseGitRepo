
CREATE PROCEDURE [dbo].[Get_ContainerListByOrder]
/*
dbo.fn_getcontainerlistbyorderkey
*/
@OrderKey INT=0
AS
BEGIN	
	SET NOCOUNT ON
	SET FMTONLY OFF

	SELECT 
		od.ContainerNo,		
		od.Chassis,
		od.SealNo,
		od.Weight,
		cs.Description AS ContainerSize,
		OD.VesselETA
	FROM  dbo.OrderDetail od 
		LEFT JOIN dbo.ContainerSize cs on cs.ContainerSizeKey = od.ContainerSizeKey
	WHERE  od.OrderKey = @OrderKey
END
