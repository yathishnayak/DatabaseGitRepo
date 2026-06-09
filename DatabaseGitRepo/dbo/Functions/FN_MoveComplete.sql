

create FUNCTION [dbo].[FN_MoveComplete]
(
    @OrderDetailKey INT
)
RETURNS int
AS
BEGIN
	DECLARE @IsRouteComplete BIT = 0
	DECLARE @legCount INT

    SELECT @legCount = COUNT(rt.Status)
    FROM dbo.Routes RT WITH (NOLOCK)
    WHERE RT.OrderDetailKey = @OrderDetailKey and rt.[Status] <> 5



	SET @IsRouteComplete = CASE WHEN @legCount = 0 THEN 1 ELSE 0 END

	IF(@IsRouteComplete = 1)
	BEGIN
		DECLARE @cnt	INT = 0,
				@CntST	INT = 0,
				@CntNotComplete		INT = 0,
				@CompleteStatusKey	int = 0

		select @CompleteStatusKey = Status from RouteStatus where Description = 'Leg Completed'

		select @CntST = count(1) 
		from Routes R WITH (NOLOCK)
		inner join OrderDetail OD WITH (NOLOCK) on r.OrderDetailKey = OD.OrderDetailKey
		where OD.OrderDetailKey = @OrderDetailKey and OD.isStreetTurn = 1

		if(isnull(@CntST ,0)>0)
		begin
			select @CntNotComplete = Count(1) 
			from Routes R WITH (NOLOCK)
			where R.OrderDetailKey = @OrderDetailKey and Status <> @CompleteStatusKey
		end

		IF(ISNULL(@CntST,0) > 0 AND ISNULL(@CntNotComplete ,0) = 0)
		BEGIN
			SET @cnt = 1
		END
		ELSE
		BEGIN
			SELECT @cnt = count(1)
			FROM Routes R WITH (NOLOCK)
				LEFT JOIN Leg L WITH (NOLOCK) ON R.LegKey = L.LegKey
			WHERE   orderdetailkey = @OrderDetailKey
			AND (select count(1) from Routes R WITH (NOLOCK) 
					where orderdetailkey = @OrderDetailKey and R.Status <> @CompleteStatusKey) = 0
			--AND R.RouteKey = 
			--(
			--	SELECT MAX(RouteKey)
			--	FROM dbo.[Routes] T WITH (NOLOCK)
			--	WHERE OrderDetailKey = @OrderDetailKey
			--)
		END

		IF(@cnt = 0)
		BEGIN
			SET @IsRouteComplete = 0
		END
		ELSE
		BEGIN
			SET @IsRouteComplete = 1
		END
	END
   
    -- Return the result of the function
    RETURN @IsRouteComplete;
END
