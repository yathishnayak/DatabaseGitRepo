
/*
 Get_InvoiceReport_PDF @STATUSKEY = 0, @DATEFROM = '2020-01-01T00:00:00.000Z',  @DateTo = '2050-12-31T00:00:00.000', 
		@CustKey=0, @City='',@CSRKey=0, @CreateUserKey=0,@CustomerType=0
*/
CREATE proc [dbo].[Get_InvoiceReport_PDF] 
(
	@DateFrom	dateTime = '2020-01-01',
	@DateTo		dateTime = '2050-12-31',
	@StatusKey	int = NULL,
	@CustKey	int = NULL,
	@City		varchar(100)='',
	@CSRKey		int = 0,
	@CreateUserKey int = 0,
	@CustomerType	bit = 0 -- IsFactored= 1, Non-Factored = 0
)
as
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	SET @DateFrom = ISNULL(@DateFrom,GETDATE()-7)
	SET @DateTo = DATEADD(D,1, ISNULL(@DateTo, GETDATE()) )
	SET @StatusKey = ISNULL(@StatusKey,2)
	SET @CustKey = ISNULL(@CustKey,0)
	Set @CSRKey = 0

	select  InvoiceKey,
			InvoiceNo,
			InvoiceDate,
			isnull(STATUS,'') as STATUS,
			isnull(StatusKey,0) as StatusKey,
			isnull(CustKey,0) as CustKey,
			isnull(CustID,'') as CustID,
			isnull(CustName,'') as CustName,
			isnull(OrderNo,'') as OrderNo,
			isnull(ContainerCount,0) as ContainerCount,
			isnull(DestinationCity,'') as DestinationCity,
			isnull(BrokerRefNo,'') as BrokerRefNo,
			isnull(InvoiceAmount,0) as InvoiceAmount,
			isnull(OverDueDays,0) as OverDueDays,
			isnull(Balance,0) as NetDue,
			isnull(Payments,0) as  Payments,
			isnull(Credit,0) as Credit, 
			isnull(Balance,0) as Balance,
			isnull(InvoiceType ,'') as InvoiceType,
			isnull(Containers,'') as Containers,
			0 as CsrKey, 
			'' as CsrName, 
		   isnull(InvoicerName,'') as InvoicerName,
			convert(date,'01-01-1970') as CompleteDate -- ISNULL(CompleteDate,'01-01-1970') AS CompleteDate
		into #temp
--	From vAllInvoiceStatement VIS WITH (NOLOCK)
--		inner join [User] U with(nolock) on u.UserKey = VIS.CreateUserKey
	From data_invoiceReport
	
	WHERE
		(InvoiceDate BETWEEN @DateFrom AND @DateTo) AND
		(isnull(@StatusKey,0) = 0 OR StatusKey = @StatusKey) AND 
		(CustKey = @CustKey or @CustKey = 0) AND
		(isnull(@city,'')= '' OR DestinationCity like '%' + @City + '%') --AND
		--(ISNULL(@CSRKey,0) = 0 OR isnull(CsrKey,0) = @CSRKey) AND
		--(iSNULL(@CreateUserKey,0)= 0 OR CreateUserKey = @CreateUserKey)
		order by CustName,InvoiceDate

		--select * from #temp
		
		declare @SQLQuery nvarchar(max)
		set @SQLQuery = 'select InvoiceKey,InvoiceNo,InvoiceDate,STATUS,StatusKey,CustKey,CustID,CustName,OrderNo,ContainerCount,DestinationCity,
						BrokerRefNo,InvoiceAmount,OverDueDays,Balance as NetDue,Payments, Credit, Balance,InvoiceType, Containers,
						CsrKey, CsrName, InvoicerName, CompleteDate from #temp'

		--/******************** process to create HTML Output *******************
		DECLARE @columnslist NVARCHAR (max) = ''
		DECLARE @restOfQuery NVARCHAR (2000) = ''
		DECLARE @DynTSQL NVARCHAR (max)
		DECLARE @FROMPOS INT

		SET NOCOUNT ON

		SELECT @columnslist += 'ISNULL(convert(varchar,' + NAME + ',' + '''' + ' ' + '''' + ')' + ', '
		FROM sys.dm_exec_describe_first_result_set(@SQLQuery, NULL, 0)

		
		SET @columnslist = left (@columnslist, Len (@columnslist) - 1)
		SET @FROMPOS = CHARINDEX ('FROM', @SQLQuery, 1)
		SET @restOfQuery = SUBSTRING(@SQLQuery, @FROMPOS, LEN(@SQLQuery) - @FROMPOS + 1)
		SET @columnslist = Replace (@columnslist, ','' '')', '),'' '') as TD')
		--SET @columnslist = @columnslist + ','' '') as TD'
		--select @columnslist
		SET @DynTSQL = CONCAT (
				'SELECT (SELECT '
				, @columnslist
				,' '
				, @restOfQuery
				,' FOR XML RAW (''TR''), ELEMENTS, TYPE) AS ''TBODY'''
				,' FOR XML PATH (''''), ROOT (''TABLE'')'
				)
		
		EXEC (@DynTSQL)
		SET NOCOUNT OFF
		
END
