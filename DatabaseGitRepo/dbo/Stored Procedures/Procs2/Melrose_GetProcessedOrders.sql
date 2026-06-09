

CREATE PROCEDURE [dbo].[Melrose_GetProcessedOrders]

AS

BEGIN
	SELECT ID FROM Melrose_DataRemarks WHERE Remarks = 'Already Processed'
END
