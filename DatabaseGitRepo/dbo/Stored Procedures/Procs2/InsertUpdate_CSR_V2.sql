/*
DECLARE @UserKey INT = 951, @JSONString NVARCHAR(MAX),@Status BIT = 0,@Reason VARCHAR(1000), @IsDebug BIT = 1 
SET @JSONString ='{
	"CsrKey": 0,
	"AddrKey": 0,
	"Address": {
		"AddrName": "Addr 1",
		"Address1": "Line 1",
		"Zip": "50002",
		"City": "Adair",
		"State": "IA",
		"Country": "USA",
		"Email": "testmail",
		"Phone": 123456
	},
	"CsrName": "CSR New7",
	"StatusKey": "2",
	"CSRManagerKey": 74,
	"LinkedUserKey": 752,
	"TerminalLocationKey": 12
}'
 
EXEC [InsertUpdate_CSR_V2] @UserKey, @JSONString, @Status OUTPUT, @Reason OUTPUT, @IsDebug
SELECT @Status Status, @Reason Reason 
*/

CREATE PROCEDURE [dbo].[InsertUpdate_CSR_V2]
(
	@UserKey	INT,
	@JSONString	NVARCHAR(MAX) = '',
	@Status		BIT OUTPUT,
	@Reason		NVARCHAR(MAX) OUTPUT,
	@IsDebug	BIT = 0
)
as
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	IF(ISNULL(@JSONString,'') = '')
	BEGIN
		SET @Status = 0
		SET @Reason = 'JSONString cannot be empty'
		return;
	END

	DECLARE @CSRKey		INT = 0,
			@CName	VARCHAR(100) = '';

	CREATE TABLE #CSR
	(
		CSRKey				INT,
		CsrName				VARCHAR(100),
		FirstName			VARCHAR(50),
		LastName			VARCHAR(50),
		LinkedUserKey		INT,
		IsManager			BIT,
		CSRManagerKey		INT,
		AddrKey				INT,
		StatusKey			INT,
		TerminalLocationKey	INT
	)

	INSERT INTO #CSR (CSRKey, CsrName, Firstname, LastName, LinkedUserKey, IsManager, CSRManagerKey, AddrKey, StatusKey, TerminalLocationKey)
	SELECT CSRKey, CsrName, Firstname, LastName, LinkedUserKey, IsManager, CSRManagerKey, AddrKey, StatusKey, TerminalLocationKey
	FROM OpenJson(@JSONString,'$')
	WITH (
		CSRKey					INT				'$.CsrKey',
		CsrName					VARCHAR(100)	'$.CsrName',
		Firstname				VARCHAR(50)	    '$.FirstName',
		LastName				VARCHAR(50)		'$.LastName',
		LinkedUserKey			INT				'$.LinkedUserKey',
		IsManager				BIT				'$.IsManager',
		CSRManagerKey			INT				'$.CSRManagerKey',
		AddrKey					INT				'$.AddrKey',
		StatusKey				INT				'$.StatusKey',
		TerminalLocationKey		INT				'$.TerminalLocationKey'
	)

	SELECT @CSRKey  = CSRKey FROM #CSR;
	SELECT @CName = CsrName FROM #CSR;

	IF EXISTS (
        SELECT 1
        FROM CSR
        WHERE CsrName = @CName
         AND CsrKey <> ISNULL(@CsrKey,0)
    )
    BEGIN
        SET @Status = 0
        SET @Reason = 'CSR already exist'
        RETURN
    END

	DECLARE @CNT INT = 0
	SELECT @CNT = COUNT(1) FROM #CSR
	IF(ISNULL(@CNT,0) = 0)
	BEGIN
		SET @Status = 0
		SET @Reason = 'CSR data not exists'
		RETURN;
	END

	DECLARE @AddressData NVARCHAR(max)
	SELECT @AddressData = Address
	FROM OpenJson(@JSONString,'$')
	WITH (
		Address		NVARCHAR(max)	'$.Address' AS JSON
	)

	CREATE TABLE #Address
	(
		AddrKey		INT,
		AddrName	VARCHAR(255),
		Address1	VARCHAR(255),
		Address2	VARCHAR(255),
		City		VARCHAR(255),
		State		VARCHAR(255),
		ZipCode		VARCHAR(50),
		Country		CHAR(3),
		Website		VARCHAR(255),
		Phone		VARCHAR(20),
		Email		VARCHAR(255),
		Fax			VARCHAR(20),
		Phone2		VARCHAR(20),
		Email2		VARCHAR(50)
	)

	IF(ISNULL(@AddressData,'') = '')
	BEGIN
		SET @Status = 0
		SET @Reason = 'CSR address is empty'
		RETURN;
	END

	INSERT INTO #Address(AddrKey, AddrName, Address1, Address2, City, State, ZipCode, Country, Website, Phone, Email, Fax, Phone2 ,Email2)
	SELECT AddrKey, AddrName, Address1, Address2, City, State, ZipCode, Country, Website, Phone, Email, Fax, Phone2 ,Email2
	FROM OpenJson(@AddressData,'$')
	WITH(
		AddrKey		INT				'$.AddrKey',
		AddrName	VARCHAR(255)	'$.AddrName',
		Address1	VARCHAR(255)	'$.Address1',
		Address2	VARCHAR(255)	'$.Address2',
		City		VARCHAR(255)	'$.City',
		State		VARCHAR(255)	'$.State',
		ZipCode		VARCHAR(50)		'$.Zip',
		Country		CHAR(3)			'$.Country',
		Website		VARCHAR(255)	'$.Website',
		Phone		VARCHAR(20)		'$.Phone',
		Email		VARCHAR(255)	'$.Email',
		Fax			VARCHAR(20)		'$.Fax',
		Phone2		VARCHAR(20)		'$.Phone2',
		Email2		VARCHAR(50)		'$.Email2'
	)
	
	SET @CNT = 0
	SELECT @CNT = COUNT(1) FROM #Address
	IF(ISNULL(@CNT,0) = 0)
	BEGIN
		SET @Status = 0
		SET @Reason = 'CSR address data not exists'
		RETURN;
	END

	DECLARE @AddrKey	INT = 0
	SELECT @AddrKey = AddrKey from #Address

	BEGIN TRANSACTION
	BEGIN TRY
		IF(ISNULL(@AddrKey,0) = 0)
		BEGIN
			INSERT INTO Address(AddrName, Address1, Address2, City, State, ZipCode, Country, Website, Phone, Email, Fax, Phone2 ,Email2)
			SELECT AddrName, Address1, Address2, City, State, ZipCode, Country, Website, Phone, Email, Fax, Phone2 ,Email2
			FROM #Address
			SET @AddrKey = SCOPE_IDENTITY()
			UPDATE #CSR SET AddrKey = @AddrKey
		END
		ELSE
		BEGIN	
			UPDATE A SET
				AddrName	=B.AddrName,
				Address1	=B.Address1,
				Address2	=B.Address2,
				City		=B.City	,
				State		=B.State,
				ZipCode		=B.ZipCode,	
				Country		=B.Country,	
				Website		=B.Website,	
				Phone		=B.Phone,
				Email		=B.Email,
				Fax			=B.Fax,	
				Phone2		=B.Phone2,
				Email2		=B.Email2	
			FROM Address A
			INNER JOIN #Address B ON A.AddrKey = B.AddrKey
		END
		-- SELECT * FROM #CSR

		IF(ISNULL(@CSRKey,0) = 0)
		BEGIN
			INSERT INTO CSR(CsrName, FirstName, LastName, LinkedUserKey, IsManager, CSRManagerKey, AddrKey, StatusKey, StatusDate, TerminalLocationKey, IsActive, CreateUser, CreateDate)
			SELECT CsrName, FirstName, LastName, LinkedUserKey, IsManager, CSRManagerKey, AddrKey, 1, GETDATE(), TerminalLocationKey, 1, @UserKey, GETDATE()
			FROM #CSR
			SET @CSRKey = SCOPE_IDENTITY()
		END
		else
		BEGIN
			UPDATE C SET
				CsrName				=	B.CsrName,	
				FirstName			=	B.FirstName,	
				LastName			=	B.LastName,		
				IsManager			=	B.IsManager,	
				CSRManagerKey		=	CASE WHEN B.CSRManagerKey > 0 THEN B.CSRManagerKey ELSE NULL END,	
				LinkedUserKey		=	B.LinkedUserKey,	
				TerminalLocationKey	=	B.TerminalLocationKey,
				AddrKey				=	B.AddrKey,
				StatusKey			=   B.StatusKey,
				UpdateDate			=	GETDATE(),
				UpdateUser			=	@UserKey
			FROM CSR C
			INNER JOIN #CSR B ON C.CsrKey = B.CSRKey
		END
		COMMIT TRANSACTION
		SET @Status = 1
		SET @Reason = 'CSR Saved Successfully'
	END TRY
	BEGIN CATCH
		SET @Status = 0
		SET @Reason = ERROR_MESSAGE()
		Rollback Transaction
	END CATCH
END