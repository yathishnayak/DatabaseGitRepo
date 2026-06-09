CREATE PROCEDURE [dbo].[ContainerLeg_Update] --ContainerLeg_Update 352978,1
(
  --  @OrderDetailKey  INT = 0,
	@RouteKey  INT = 0,
	@LegKey INT = 0
)
AS 
BEGIN
	UPDATE Routes
	SET LegKey = @LegKey
	WHERE RouteKey = @RouteKey

END 
