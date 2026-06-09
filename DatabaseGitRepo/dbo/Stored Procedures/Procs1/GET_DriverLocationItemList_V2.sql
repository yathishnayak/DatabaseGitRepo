/*
DECLARE 
	@UserKey INT=1144,
	@JSONString NVARCHAR(MAX)='{"DiverKey":0,"CityKey": 25191,"EffectiveDate":"2026-05-03"}',
	@Status BIT=0,
	@Reason VARCHAR(100)=''
EXec [GET_DriverLocationItemList_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT
Select @Status, @Reason
*/

CREATE PROCEDURE [dbo].[GET_DriverLocationItemList_V2]
(
    @UserKey    INT = 0,
    @JSONString NVARCHAR(MAX) = '',
    @Status     BIT = 0 OUTPUT,
    @Reason     VARCHAR(1000) = '' OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
    SET FMTONLY OFF;
    SET ARITHABORT ON;

	IF(@JSONString='' OR @JSONString IS NULL)
	BEGIN
        SET @Reason='Parameter not Present';
        SET @Status=0
		SET @Reason='Failure';
        RETURN;
    END    

	 DECLARE @DiverKey		INT = 0,
             @CityKey		INT = 0,
             @EffectiveDate	DATE = '7/05/2021',
			 @ItemType      VARCHAR(20)

			
	SET @ItemType='Expense'
	SET @CityKey= CASE WHEN @CityKey=0 THEN NULL ELSE @CityKey	END

    SELECT @DiverKey= DiverKey, @CityKey = CityKey, @EffectiveDate = EffectiveDate
    FROM OPENJSON(@JSONString,'$')
	WITH (		
		DiverKey	  INT		'$.DiverKey',
		CityKey		  INT		'$.CityKey',
		EffectiveDate DATE		'$.EffectiveDate'	
		)

	SET @ItemType='Expense'
	SET @CityKey= CASE WHEN @CityKey=0 THEN NULL ELSE @CityKey	END

	CREATE TABLE #Items
	(
		DriverRateKey INT,
		Itemkey		  INT,
		CityKey		  INT,
		DriverKey	  INT ,
		UnitCost	   DECIMAL(18,2),
		EffectiveDate  DATE
	)

		INSERT INTO #Items ( DriverRateKey,Itemkey,CityKey,DriverKey ,UnitCost,EffectiveDate )
		SELECT A.DriverRateKey,A.Itemkey,A.CityKey,A.Driverkey ,A.UnitCost,EffectiveDate 
		FROM dbo.DriverLocationItem A
			INNER JOIN dbo.Item I		ON I.ItemKey=A.Itemkey
			INNER JOIN dbo.ItemType T	ON I.ItemTypeKey=T.ItemTypeKey
			INNER JOIN dbo.[Status] S	ON S.StatusKey=I.StatusKey
		WHERE isnull(Driverkey,0)=ISNULL(@DiverKey,0) AND (CityKey=@CityKey OR @CityKey=0 OR @CityKey IS NULL) AND S.StatusName='Active' AND EffectiveDate=@EffectiveDate
			AND T.ItemType in ( @ItemType,'Expense + Service')		AND i.CategoryKey <> 8
	
	SELECT @DiverKey as DriverKey, @CityKey as CityKey, @EffectiveDate as EffectiveDate,
		0 as DriverRateKey,ItemKey,ItemID,A.[Description],ItemType ,A.UnitCost AS Rate
	FROM dbo.Item A 
		INNER JOIN dbo.ItemType T	ON A.ItemTypeKey=T.ItemTypeKey
		INNER JOIN dbo.Status S		ON S.StatusKey=A.StatusKey
	WHERE S.StatusName='Active' AND ItemKey NOT IN (SELECT Itemkey FROM #Items)	AND T.ItemType in( @ItemType, 'Expense + Service') AND a.CategoryKey <> 8
	UNION ALL
	SELECT A.DriverKey, A.CityKey, EffectiveDate,
		DriverRateKey,A.Itemkey ,I.itemID,I.[Description],ItemType ,A.UnitCost
	FROM #Items A
		INNER JOIN dbo.Item I		ON I.itemkey=A.itemkey
		INNER JOIN dbo.ItemType T	ON T.ItemTypeKey=I.ItemTypeKey
		--INNER JOIN DBO.ItemCategory IT ON I.CategoryKey = IT.CategoryKey
	WHERE ISNULL(I.CategoryKey,0) <> 8 AND T.ItemType in ( @ItemType, 'Expense + Service')
	ORDER BY ItemType , ItemID	

            FOR JSON PATH
			--Without_Array_Wrapper

	SET @Status = 1;
    SET @Reason = 'Success';
END