/**

DECLARE 
	@UserKey INT=714,
	@JSONString NVARCHAR(MAX)='{"WeekNum": 2}',
	@Status BIT = 0,  
	@IsDebug BIT = 0,
	@Reason VARCHAR(100) = ''
EXEC [VoucherExportToQB_TransactionPro_V3] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
SELECT @Status AS Status, @Reason AS Reason

**/
CREATE PROCEDURE [dbo].[VoucherExportToQB_TransactionPro_V3]
(
	@UserKey        INT = 714,
    @JSONString     NVARCHAR(MAX) = '{"WeekNum": 2}',
    @Status         BIT = 0 OUTPUT,
    @Reason         VARCHAR(1000) = '' OUTPUT,
    @IsDebug        BIT = 0	
)
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;
	
	-- Initialize output parameters
	SET @Status = 0;
	SET @Reason = '';
	
	BEGIN TRY
		DECLARE @WeekNum INT = 0,
				@Year INT = YEAR(GETDATE());
		
		-- Parse and validate JSON input
		SELECT 
			@WeekNum = ISNULL(WeekNum, 0),
			@Year = ISNULL([Year], YEAR(GETDATE()))
		FROM OPENJSON(@JSONString)
		WITH (
			WeekNum INT '$.WeekNum',
			[Year] INT '$.Year'
		);

		-- Input validation
		IF @WeekNum IS NULL OR @WeekNum < 1 OR @WeekNum > 53
		BEGIN
			SET @Status = 0;
			SET @Reason = 'Invalid WeekNum parameter. Must be between 1 and 53.';
			RETURN;
		END;

		-- Create temp table for voucher expenses with proper data types
		SELECT  
			A.VoucherKey,   
			DATEPART(ISO_WEEK, C.ActualArrival) as WeekNum,
			ISNULL(D.OrgName, CONCAT(D.FirstName, ' ', D.LastName)) as Vendor,  
			DATEADD(wk, 1, DATEADD(DAY, -1-DATEPART(WEEKDAY, C.ActualArrival), DATEDIFF(dd, 0, C.ActualArrival))) as TransactionDate, 
			CONCAT(D.DriverId, '-', YEAR(C.ActualArrival), '-', DATEPART(ISO_WEEK, C.ActualArrival)) as RefNumber,
			'' as BillDue, 
			'' as Terms, 
			CONCAT('Driver Pay for Week - ', DATEPART(ISO_WEEK, C.ActualArrival)) as Memo,
			'' as AddressLine1, 
			'' as AddressLine2, 
			'' as AddressLine3,  
			'' as AddressLine4, 
			'' as AddressCity, 
			'' as AddressState, 
			'' as AddressPostalCode, 
			'' as AddressCountry, 
			'' as VendorAcctNo,  
			ISNULL(G.ERPGLAccount, F.ItemID) as ExpensesAccount, 
			B.ExtCost as ExpensesAmount,
			'CONTRACTOR SERVICE - TMS' as ExpensesMemo, 
			'' as ExpensesClass, 
			'' as ExpensesCustomer, 
			'' as ExpensesBillable,
			'' as ItemsItem,
			'' as ItemsQty,  
			'' as ItemsDescription, 
			'' as ItemsCost,  
			'' as ItemsClass,  
			'' as ItemsCustomer,  
			'' as ItemsBillable, 
			'' as UnitOfMeasure, 
			'' as APAccount, 
			'' as Currency,	
			'' as ExchangeRate   
		INTO #tmpExp
		FROM VoucherHeader A WITH (NOLOCK)
		INNER JOIN VoucherDetail B WITH (NOLOCK) ON A.VoucherKey = B.Voucherkey
		INNER JOIN Routes C WITH (NOLOCK) ON B.RouteKey = C.RouteKey
		INNER JOIN Driver D WITH (NOLOCK) ON C.DriverKey = D.DriverKey
		LEFT OUTER JOIN [Address] E WITH (NOLOCK) ON D.AddrKey = E.AddrKey
		LEFT OUTER JOIN Item F WITH (NOLOCK) ON B.ItemKey = F.ItemKey
		LEFT OUTER JOIN ItemExt G WITH (NOLOCK) ON F.ItemKey = G.ItemKey
		WHERE 
			DATEPART(ISO_WEEK, C.ActualArrival) = @WeekNum
			AND YEAR(C.ActualArrival) = @Year;

		-- Generate final result set with aggregated data
		SELECT 
			Vendor,	
			TransactionDate,	
			RefNumber,	
			BillDue,	
			Terms,	
			Memo,	
			AddressLine1,	
			AddressLine2,	
			AddressLine3,	
			AddressLine4,	
			AddressCity,	
			AddressState,	
			AddressPostalCode,	
			AddressCountry,	
			VendorAcctNo,	
			ExpensesAccount,	
			SUM(ExpensesAmount) as ExpensesAmount,	
			ExpensesMemo,	
			ExpensesClass,	
			ExpensesCustomer,	
			ExpensesBillable,	
			ItemsItem,	
			ItemsQty,	
			ItemsDescription,	
			ItemsCost,	
			ItemsClass,	
			ItemsCustomer,	
			ItemsBillable,	
			UnitOfMeasure,	
			APAccount,	
			Currency,	
			ExchangeRate 
		FROM 
		(
			-- Main voucher expenses
			SELECT * FROM #tmpExp
			
			UNION ALL
			
			-- Additional voucher details with RouteKey = 0
			SELECT DISTINCT 
				A.VoucherKey, 
				C.WeekNum,  
				C.Vendor, 
				A.VoucherDate as TransactionDate, 
				A.VoucherNo as RefNumber,
				'' as BillDue, 
				'' as Terms, 
				'Driver Pay for Week - ' as Memo,
				C.AddressLine1, 
				C.AddressLine2, 
				'' as AddressLine3,  
				'' as AddressLine4, 
				C.AddressCity, 
				C.AddressState, 
				C.AddressPostalCode, 
				'' as AddressCountry, 
				'' as VendorAcctNo, 
				ISNULL(G.ERPGLAccount, D.ItemId) as ExpensesAccount, 
				B.ExtCost as ExpensesAmount,
				'CONTRACTOR SERVICE - TMS' as ExpensesMemo, 
				'' as ExpensesClass, 
				'' as ExpensesCustomer, 
				'' as ExpensesBillable,
				'' as ItemsItem,
				'' as ItemsQty,  
				'' as ItemsDescription, 
				'' as ItemsCost,  
				'' as ItemsClass,  
				'' as ItemsCustomer,  
				'' as ItemsBillable, 
				'' as UnitOfMeasure, 
				'' as APAccount, 
				'' as Currency,	
				'' as ExchangeRate       
			FROM VoucherHeader A WITH (NOLOCK) 
			INNER JOIN VoucherDetail B WITH (NOLOCK) ON A.Voucherkey = B.Voucherkey AND B.RouteKey = 0
			INNER JOIN #tmpExp C ON A.VoucherKey = C.Voucherkey
			INNER JOIN Item D WITH (NOLOCK) ON B.ItemKey = D.ItemKey
			LEFT OUTER JOIN ItemExt G WITH (NOLOCK) ON B.ItemKey = G.ItemKey
			
			UNION ALL
			
			-- Driver voucher deductions (negative amounts)
			SELECT DISTINCT 
				VH.DriverVoucherKey as VoucherKey, 
				VH.WeekNumber as WeekNum, 
				ISNULL(D.OrgName, CONCAT(D.FirstName, ' ', D.LastName)) as Vendor, 
				VH.DriverVoucherdate as TransactionDate, 
				CONCAT(D.DriverId, '-', YEAR(VH.DriverVoucherdate), '-', DATEPART(ISO_WEEK, VH.DriverVoucherdate)) as RefNumber,
				'' as BillDue, 
				'' as Terms, 
				CONCAT('Driver Pay for Week - ', VH.WeekNumber) as Memo,
				'' as AddressLine1, 
				'' as AddressLine2, 
				'' as AddressLine3,  
				'' as AddressLine4, 
				'' as AddressCity, 
				'' as AddressState, 
				'' as AddressPostalCode, 
				'' as AddressCountry, 
				'' as VendorAcctNo, 
				ISNULL(G.ERPGLAccount, I.ItemId) as ExpensesAccount, 
				-1 * VD.ExtCost as ExpensesAmount,
				'CONTRACTOR SERVICE - TMS' as ExpensesMemo, 
				'' as ExpensesClass, 
				'' as ExpensesCustomer, 
				'' as ExpensesBillable,
				'' as ItemsItem,
				'' as ItemsQty,  
				'' as ItemsDescription, 
				'' as ItemsCost,  
				'' as ItemsClass,  
				'' as ItemsCustomer,  
				'' as ItemsBillable, 
				'' as UnitOfMeasure, 
				'' as APAccount, 
				'' as Currency,	
				'' as ExchangeRate         
			FROM DriverVoucherDeduction VH WITH (NOLOCK) 
			INNER JOIN DriverVoucherDeductionDetail VD WITH (NOLOCK) ON VH.DriverVoucherKey = VD.DriverVoucherKey
			INNER JOIN Item I WITH (NOLOCK) ON VD.ItemKey = I.ItemKey		
			INNER JOIN Driver D WITH (NOLOCK) ON VH.DriverKey = D.DriverKey
			LEFT OUTER JOIN [Address] E WITH (NOLOCK) ON D.AddrKey = E.AddrKey
			LEFT OUTER JOIN ItemExt G WITH (NOLOCK) ON I.ItemKey = G.ItemKey
			WHERE VH.WeekNumber = @WeekNum 
		) X
		GROUP BY 
			Vendor, TransactionDate, RefNumber, BillDue, Terms, Memo,
			AddressLine1, AddressLine2, AddressLine3, AddressLine4,
			AddressCity, AddressState, AddressPostalCode, AddressCountry,
			VendorAcctNo, ExpensesAccount, ExpensesMemo, ExpensesClass,
			ExpensesCustomer, ExpensesBillable, ItemsItem, ItemsQty,
			ItemsDescription, ItemsCost, ItemsClass, ItemsCustomer,
			ItemsBillable, UnitOfMeasure, APAccount, Currency, ExchangeRate
		ORDER BY Vendor
		FOR JSON PATH;

		-- Clean up temp table
		DROP TABLE #tmpExp;

		-- Set success status
		SET @Status = 1;
		SET @Reason = 'Success';

	END TRY
	BEGIN CATCH
		-- Clean up resources on error
		IF OBJECT_ID('tempdb..#tmpExp') IS NOT NULL
			DROP TABLE #tmpExp;
		
		-- Handle transaction rollback if needed
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;
		
		-- Set error information
		SET @Status = 0;
		SET @Reason = CONCAT('Error: ', ERROR_MESSAGE(), ' (Line: ', ERROR_LINE(), ')');
		
		-- Log error details if debugging is enabled
		IF @IsDebug = 1
		BEGIN
			SELECT 
				ERROR_NUMBER() AS ErrorNumber,
				ERROR_SEVERITY() AS ErrorSeverity,
				ERROR_STATE() AS ErrorState,
				ERROR_PROCEDURE() AS ErrorProcedure,
				ERROR_LINE() AS ErrorLine,
				ERROR_MESSAGE() AS ErrorMessage;
		END;
	END CATCH;
END;