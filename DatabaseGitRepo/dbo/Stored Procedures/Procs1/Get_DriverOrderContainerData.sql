CREATE PROCEDURE [dbo].[Get_DriverOrderContainerData]
@OrderDetailKey INT= 9
AS
BEGIN
	SELECT	DISTINCT 	
			D.DriverID,
			left(upper(OD.ContainerNo),4) + '-' + substring(upper(OD.ContainerNo),4,6) + '-' + right(upper(OD.ContainerNo),1) as ContainerNo,
			OH.OrderNo,CS.[Description] AS ContainerSize,OD.[Weight],
			RT.ChassisNo,OD.IsHazardus,C.[Description] AS Notes,OD.OrderDetailKey
	FROM dbo.Routes RT 
		INNER JOIN dbo.OrderDetail OD	ON RT.OrderDetailKey=OD.OrderDetailKey
		INNER JOIN Dbo.OrderHeader OH	ON OD.OrderKey=OH.OrderKey
		INNER JOIN dbo.RouteStatus RTS	ON RTS.Status=RT.Status
		INNER JOIN dbo.ContainerSize CS ON CS.ContainerSizeKey=OD.ContainerSizeKey
		INNER JOIN dbo.Driver D			ON D.DriverKey=RT.DriverKey	
		LEFT JOIN dbo.OrderDetailComments ODC ON ODC.OrderDetailKey=OD.OrderDetailKey
		LEFT JOIN dbo.Comment C ON C.CommentKey=ODC.CommentKey
	WHERE OD.OrderDetailKey=@OrderDetailKey AND RT.DriverKey IS NOT NULL AND RTS.Description<>'Completed'
END
