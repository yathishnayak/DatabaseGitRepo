
CREATE PROCEDURE [dbo].[Get_ContainerStatusToDelete]  --130,178,0
@OrderKey				INT=0,
@OrderDetailkey			INT=0,
@OutPut				BIT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SET @OutPut=0;   


	IF EXISTS( SELECT 1 FROM  dbo.OrderDetail OD WITH(NOLOCK) WHERE  OD.[Status] in (6,7,8,9,10,12,13) and OD.OrderDetailKey=  @OrderDetailkey and OD.OrderKey = @OrderKey)
	BEGIN
		PRINT 'Record Exists';
		SET @OutPut=1;   
	END
	ELSE
	BEGIN
		PRINT 'Record doesn''t Exists';
		SET @OutPut=0;   
	END	
END
