

CREATE PROCEDURE [dbo].[Safegate_UpdateLocationFromSafegate] -- Safegate_UpdateLocationFromSafegate 504090, 1
(
	@Routekey			INT	,
	@ISDebug			BIT
)

AS

BEGIN
	DECLARE		@OldLocation VARCHAR(50) = '', @NewLocation VARCHAR(50) = '', @LegID VARCHAR(100) = '', @ContainerNo		VARCHAR(20), @OrderDetailKey		INT
				,@SGSourceAddrKey INT,  @SGDestinationAddrKey INT, @Effect INT, @IsUpdate BIT = 0, @AuditKey INT, @SFGYardChangeType VARCHAR(20)
				,@NextLegRouteKey	INT, @PrevLegRouteKey	INT, @NextLegUpdate BIT = 0, @PrevLegUpdate BIT = 0
				,@UpdatePrevLegRoute INT = 0, @UpdateNextLegRoute INT = 0, @PrevOldLocation VARCHAR(100), @PrevLegID VARCHAR(100)
				,@NextOldLocation VARCHAR(100), @NextLegID VARCHAR(100), @AuditKeyNextPrev INT

	SELECT		@OldLocation = TMSYardName, @NewLocation = YardName,@ContainerNo = ContainerNo, @OrderDetailKey = OrderDetailkey 
				, @LegID = LegID, @SGSourceAddrKey = SGSourceAddrKey, @SGDestinationAddrKey = SGDestinationAddrKey, @Effect = Effect
				,@NextLegRouteKey = NextLegRouteKey, @PrevLegRouteKey = PrevLegRouteKey, @UpdatePrevLegRoute = UpdatePrevLegRoute, @UpdateNextLegRoute = UpdateNextLegRoute
				,@PrevOldLocation = TMSPrevYardName, @PrevLegID = TMSPrevLegID
				,@NextOldLocation = TMSNextYardName,@NextLegID = TMSNextLegID
	FROM		SafeGateIntegration_VGetYardDifference
	WHERE		RouteKey = @Routekey

	DECLARE		@Comments VARCHAR(1000) = 'Auto Update : ' +  CASE WHEN @Effect = 1 THEN 'Delivery' ELSE 'Pickup' END + ' Yard Location Changed from ' + @OldLocation + ' to ' + @NewLocation +  ' as per "safegate Data" for the LegID  "' + @LegID + '".'
	DECLARE		@NextPrevLegComments VARCHAR(1000) = ''


	BEGIN TRANSACTION

    BEGIN TRY

		IF(@Effect = 1 AND ISNULL(@SGDestinationAddrKey,0) > 0)
			BEGIN
				--SELECT		DestinationAddrKey, @SGDestinationAddrKey
				UPDATE		R 	SET			DestinationAddrKey = @SGDestinationAddrKey
				FROM		Routes R
				WHERE		RouteKey = @Routekey
				SET			@IsUpdate = 1
				SET			@SFGYardChangeType = 'Delivery'

				IF(@NextLegRouteKey > 0 AND @UpdateNextLegRoute = 1)
					BEGIN
						--SELECT		SourceAddrKey, @SGDestinationAddrKey
						UPDATE		R 	SET			SourceAddrKey = @SGDestinationAddrKey
						FROM		Routes R
						WHERE		RouteKey = @NextLegRouteKey
						SET			@NextLegUpdate = 1
					END

			END

		IF(@Effect = -1 AND ISNULL(@SGSourceAddrKey,0) > 0)
			BEGIN
				--SELECT		SourceAddrKey, @SGSourceAddrKey
				UPDATE		R SET			SourceAddrKey = @SGSourceAddrKey
				FROM		Routes R
				WHERE		RouteKey = @Routekey
				SET			@IsUpdate = 1
				SET			@SFGYardChangeType = 'Pickup'

				IF(@PrevLegRouteKey > 0 AND @UpdatePrevLegRoute = 1)
					BEGIN
						--SELECT		DestinationAddrKey, @SGSourceAddrKey
						UPDATE		R 	SET			DestinationAddrKey = @SGSourceAddrKey
						FROM		Routes R
						WHERE		RouteKey = @PrevLegRouteKey
						SET			@PrevLegUpdate = 1
					END
			END

		SELECT @NextOldLocation, @PrevOldLocation, @NextLegID, @PrevLegID

		IF(@PrevLegUpdate = 1)
			BEGIN
				SET @NextPrevLegComments = 'Auto Update : Delivery Yard Location Changed from ' + @PrevOldLocation + ' to ' + @NewLocation +  ' as per "safegate Data" for the LegID  "' + @PrevLegID + '".'
			END

		IF(@NextLegUpdate = 1)
			BEGIN
				SET @NextPrevLegComments = 'Auto Update : Pickup Yard Location Changed from ' + @NextOldLocation + ' to ' + @NewLocation +  ' as per "safegate Data" for the LegID  "' + @NextLegID + '".'
			END
		
		IF(@IsUpdate = 1)
			BEGIN
				INSERT INTO AuditLogDetail (DateCreated,CreateUser,RefType,RefId,RefKey,Stage,CommentType,Comments)
				SELECT GETDATE(),'Auto','Container',@ContainerNo,@OrderDetailKey,'','Text',@Comments
				SET @AuditKey = @@IDENTITY

				IF(ISNULL(@NextPrevLegComments,'') <> '')
					BEGIN
						INSERT INTO AuditLogDetail (DateCreated,CreateUser,RefType,RefId,RefKey,Stage,CommentType,Comments)
						SELECT GETDATE(),'Auto','Container',@ContainerNo,@OrderDetailKey,'','Text',@NextPrevLegComments
						SET @AuditKeyNextPrev = @@IDENTITY
					END

				IF(@ISDebug = 1)
					BEGIN
						SELECT @AuditKey, @Routekey, @OldLocation, @NewLocation
						UNION ALL
						SELECT @AuditKeyNextPrev, @PrevLegRouteKey, @PrevOldLocation, @NewLocation
						UNION ALL
						SELECT @AuditKeyNextPrev, @NextLegRouteKey, @NextOldLocation, @NewLocation


						SELECT '@Routekey',@Routekey,@SFGYardChangeType
						UNION ALL
						SELECT '@PrevLegRouteKey',@PrevLegRouteKey,'Delivery'
						UNION ALL
						SELECT '@NextLegRouteKey',@NextLegRouteKey, 'Pickup'
					END

				IF((@AuditKey > 0 AND @Routekey > 0))
					BEGIN
						-- SELECT	@AuditKey, @SFGYardChangeType
						UPDATE	A SET		SFGYardDiffLogKey = @AuditKey, SFGYardChangeType = @SFGYardChangeType
						FROM	Routes A
						WHERE	RouteKey = @Routekey
					END

				IF((@AuditKeyNextPrev > 0 AND @PrevLegRouteKey > 0))
					BEGIN
						-- SELECT	@AuditKeyNextPrev, 'Delivery'
						UPDATE	A SET		SFGYardDiffLogKey = @AuditKeyNextPrev, SFGYardChangeType = 'Delivery'
						FROM	Routes A
						WHERE	RouteKey = @PrevLegRouteKey
					END

				IF((@AuditKeyNextPrev > 0 AND @NextLegRouteKey > 0 ))
					BEGIN
						-- SELECT	@AuditKeyNextPrev, 'Pickup'
						UPDATE	A SET		SFGYardDiffLogKey = @AuditKeyNextPrev, SFGYardChangeType = 'Pickup'
						FROM	Routes A
						WHERE	RouteKey = @NextLegRouteKey
					END

			END

		IF(@ISDebug = 0)
			BEGIN
				SELECT @IsUpdate
			END

    COMMIT TRANSACTION;
    END TRY

    BEGIN CATCH
        ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT

        SELECT @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE();
		RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)
    END CATCH	
END