CREATE PROCEDURE [dbo].[Get_ChassisType]
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SELECT  DISTINCT [ChassisType]      
	FROM [dbo].[Chassis]
	WHERE ChassisType<>'Ext';
END
