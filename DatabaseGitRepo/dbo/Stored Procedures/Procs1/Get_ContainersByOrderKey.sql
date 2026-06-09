
CREATE PROCEDURE [dbo].[Get_ContainersByOrderKey]
/*
dbo.fn_get_containersbyorderkey
*/
@OrderKey INT=0
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	 SELECT 
		 od.ContainerNo,
		 CS.[Description] AS ContainerSize,
		 od.Chassis,
		 od.SealNo,
		 od.[Weight],
		 cs.[Description],
		 OD.VesselETA
	 FROM  dbo.OrderDetail od 
		LEFT JOIN dbo.ContainerSize cs on cs.ContainerSizeKey = od.ContainerSizeKey
	 WHERE  od.OrderKey = @Orderkey;
END
