
--EXEC Get_InvoiceItemReport 0, 'CHASSIS FARE:BASE DRAY:FUEL COST:DRY RUN', '2023-06-01','2023-07-31',0
--EXEC Get_InvoiceItemReport 3154, '', '2022-01-01','2022-12-31',0
CREATE Proc [dbo].[Get_InvoiceItemReport]
(
	@CustKey		int = 0,
	@ItemID			varchar(500) = '', --// SEMICOLON SEPERATED
	@InvFromDate	DateTime = '2020-01-01',
	@InvToDate		DateTime = '2050-12-31',
	@City			varchar(100)='',
	@AddrKey		INT=0,
	@RecCount		int	=0	OUTPUT
)
as
BEGIN
	--SET NOCOUNT ON
	--SET FMTONLY OFF

	IF(LEN(@ItemID) = 0 and @CustKey = 0)
	BEGIN
		SET @RecCount = 0
		Select '' CustomerID, '' CustomerName, '' InvoiceNo, getdate() [InvoiceDate],  
				''  [OrderNumber],'' Container,'' City, ''BrokerRefNo, 0.00InvoiceAmount,  ''   Status, 
				0.00 as Item_1,  0.00 as Item_2, 0.00 as Item_3, 0.00 as Item_4, 0.00 as Item_5,      
				0.00 as Item_6, 0.00 as Item_7,	0.00 as Item_8, 0.00 as Item_9, 0.00 as Item_10,
				0.00 as Item_11,  0.00 as Item_12, 0.00 as Item_13, 0.00 as Item_14, 0.00 as Item_15,      
				0.00 as Item_16, 0.00 as Item_17,	0.00 as Item_18, 0.00 as Item_19, 0.00 as Item_20,
				'[BR],[CHASSIS FARE],[DRY RUN],[FUEL COST],' AS dataColumns 
		RETURN;
	END

	if(@CustKey > 0 and @ITemid = '')
	Begin
			SELECT DISTINCT @ItemID =
            (
                SELECT  + convert(Varchar(60), ST1.ItemID)  + ':' AS [text()]
                FROM (
					select distinct ITemID
					from InvoiceHeader A
					inner join Invoicedetail B on (A.InvoiceKey = B.InvoiceKey)
					inner join Customer C on (A.CustKey = C.CustKey)
					inner join Item I on B.itemkey = I.ItemKey
					where A.CustKey = @CustKey and ( a.InvoiceDate BETWEEN @InvFromDate AND @InvToDate) 
						
				)ST1
				--inner join Item I on st1.itemkey = I.ItemKey
                ORDER BY ST1.ITEMID
                FOR XML PATH (''), TYPE
            ).value('text()[1]','nvarchar(max)') 
		
		print @Itemid
	end

	

	CREATE TABLE #ITEMKEY
	(
		ITEMKEY		INT
	)

	INSERT INTO #ITEMKEY (ITEMKEY)
	SELECT * FROM Fn_SplitParamCol(@ItemID)

	CREATE TABLE #ITEMS
	(
		ITEMID		VARCHAR(1000)
	)

	INSERT INTO #ITEMS (ITEMID)
	SELECT ItemID FROM Item WHERE ItemKey IN (SELECT ITEMKEY FROM #ITEMKEY)

	--select * from #ITEMS

	select c.CustID as CustomerID,c.CustName as CustomerName, 
			a.InvoiceNo, A.InvoiceDate as [InvoiceDate],
			E.OrderNo [OrderNumber],b.Container, h.city,
			e.BrokerRefNo,a.InvoiceAmount,i.Description as Status, 
			g.ItemID,b.UnitPrice, b.Qty as NoOfDays,b.ExtAmt
	INTO #DATA
		from InvoiceHeader A
		inner join Invoicedetail B on (A.InvoiceKey = B.InvoiceKey)
		inner join Customer C on (A.CustKey = C.CustKey)
		left join OrderDetail D on (B.OrderDetailKey = D.OrderDetailKey)
		left join OrderHeader E on (D.OrderKey = E.OrderKey)
		left join Address F on (A.BillToAddrKey = F.AddrKey)
		inner join Item G on (B.ItemKey = G.ItemKey)
		Left outer join Address H ON ( e.DestinationAddrKey=h.AddrKey)
		LEFT JOIN CustomerAddress CA ON (CA.AddrKey=F.AddrKey) AND (CA.CustKey=C.CustKey)
		left outer Join InvoiceStatus i ON a.StatusKey=i.StatusKey
		INNER JOIN #ITEMS T ON LEFT(G.itemid,20) = LEFT(T.ITEMID,20)
		WHERE	(@CustKey = 0 OR C.CustKey = @CustKey) AND
				( a.InvoiceDate BETWEEN @InvFromDate  AND @InvToDate) AND
				( ISNULL(@City,'') = '' OR h.City LIKE '%' + @City + '%'  ) AND
				(ISNULL(@AddrKey,0)=0 OR CA.AddrKey=@AddrKey)

	select itemId, sum(isnull(extAmt,0)) as Value into #TempTotals from #data group by ItemID
	select Top 19 itemid into #FinalItems from #TempTotals
	order by value desc
	

	--select * from #data

	DECLARE @STRSQL VARCHAR(5000) = '',
		@ColumnString varchar(3000) = ''

	select @ColumnString = ItemIds 
	from (
		 SELECT DISTINCT 
            (
                SELECT '[' + st1.ITEMID + ']' + ',' AS [text()]
                FROM #FinalItems ST1
				--inner join Item I on st1.ITEMID = I.ItemID
                ORDER BY ST1.ITEMID
                FOR XML PATH (''), TYPE
            ).value('text()[1]','nvarchar(max)') ItemIds
	) A

	insert into #FinalItems values ('Others')
	
	--select * from #FinalItems

	update #data set itemid = 'Others'
	from #data A
	where  A.ItemID  not in (Select itemid from #FinalItems)

	--select @ColumnString
	set @ColumnString = @ColumnString + '[OTHERS]'

	CREATE TABLE #ITEMSnew
	(
		rowkey		smallint identity(1,1),
		ITEMID		VARCHAR(500)
	)
	
	insert into #ITEMSnew(ITEMID)
	select * from Fn_SplitParam(@ColumnString)

	--select * from #ITEMSnew

	
	--select * from #DATA

	SET @STRSQL = 
	'Select CustomerID, CustomerName, InvoiceNo, [InvoiceDate],
		[OrderNumber],Container, City,BrokerRefNo,InvoiceAmount,
		 Status,' +
		' sum(Case when ItemID =''' + replace(REPLACE(ISNULL((SELECT isnull(ITEMID,'') FROM #ITEMSnew WHERE rowkey = 1),''),'[',''),']','') +  ''' then ExtAmt else 0 end ) as Item_1,
		 sum(Case when ItemID =''' +  replace(REPLACE(ISNULL((SELECT isnull(ITEMID,'') FROM #ITEMSnew WHERE rowkey = 2),''),'[',''),']','') +  ''' then ExtAmt else 0 end) as Item_2, 
		 sum(Case when ItemID =''' +  replace(REPLACE(ISNULL((SELECT isnull(ITEMID,'') FROM #ITEMSnew WHERE rowkey = 3),''),'[',''),']','') +  ''' then ExtAmt else 0 end) as Item_3,
		 sum(Case when ItemID =''' +  replace(REPLACE(ISNULL((SELECT isnull(ITEMID,'') FROM #ITEMSnew WHERE rowkey = 4),''),'[',''),']','') +  ''' then ExtAmt else 0 end) as Item_4, 
		 sum(Case when ItemID =''' +  replace(REPLACE(ISNULL((SELECT isnull(ITEMID,'') FROM #ITEMSnew WHERE rowkey = 5),''),'[',''),']','') +  ''' then ExtAmt else 0 end) as Item_5,  
		 sum(Case when ItemID =''' +  replace(REPLACE(ISNULL((SELECT isnull(ITEMID,'') FROM #ITEMSnew WHERE rowkey = 6),''),'[',''),']','') +  ''' then ExtAmt else 0 end) as Item_6,
		 sum(Case when ItemID =''' +  replace(REPLACE(ISNULL((SELECT isnull(ITEMID,'') FROM #ITEMSnew WHERE rowkey = 7),''),'[',''),']','') +  ''' then ExtAmt else 0 end) as Item_7,
		 sum(Case when ItemID =''' +  replace(REPLACE(ISNULL((SELECT isnull(ITEMID,'') FROM #ITEMSnew WHERE rowkey = 8),''),'[',''),']','') +  ''' then ExtAmt else 0 end) as Item_8,
		 sum(Case when ItemID =''' +  replace(REPLACE(ISNULL((SELECT isnull(ITEMID,'') FROM #ITEMSnew WHERE rowkey = 9),''),'[',''),']','') +  ''' then ExtAmt else 0 end) as Item_9,
		 sum(Case when ItemID =''' +  replace(REPLACE(ISNULL((SELECT isnull(ITEMID,'') FROM #ITEMSnew WHERE rowkey = 10),''),'[',''),']','') +  ''' then ExtAmt else 0 end) as Item_10, 
		 sum(Case when ItemID =''' +  replace(REPLACE(ISNULL((SELECT isnull(ITEMID,'') FROM #ITEMSnew WHERE rowkey = 11),''),'[',''),']','') +  ''' then ExtAmt else 0 end) as Item_11, 
		 sum(Case when ItemID =''' +  replace(REPLACE(ISNULL((SELECT isnull(ITEMID,'') FROM #ITEMSnew WHERE rowkey = 12),''),'[',''),']','') +  ''' then ExtAmt else 0 end) as Item_12, 
		 sum(Case when ItemID =''' +  replace(REPLACE(ISNULL((SELECT isnull(ITEMID,'') FROM #ITEMSnew WHERE rowkey = 13),''),'[',''),']','') +  ''' then ExtAmt else 0 end) as Item_13, 
		 sum(Case when ItemID =''' +  replace(REPLACE(ISNULL((SELECT isnull(ITEMID,'') FROM #ITEMSnew WHERE rowkey = 14),''),'[',''),']','') +  ''' then ExtAmt else 0 end) as Item_14, 
		 sum(Case when ItemID =''' +  replace(REPLACE(ISNULL((SELECT isnull(ITEMID,'') FROM #ITEMSnew WHERE rowkey = 15),''),'[',''),']','') +  ''' then ExtAmt else 0 end) as Item_15, 
		 sum(Case when ItemID =''' +  replace(REPLACE(ISNULL((SELECT isnull(ITEMID,'') FROM #ITEMSnew WHERE rowkey = 16),''),'[',''),']','') +  ''' then ExtAmt else 0 end) as Item_16, 
		 sum(Case when ItemID =''' +  replace(REPLACE(ISNULL((SELECT isnull(ITEMID,'') FROM #ITEMSnew WHERE rowkey = 17),''),'[',''),']','') +  ''' then ExtAmt else 0 end) as Item_17, 
		 sum(Case when ItemID =''' +  replace(REPLACE(ISNULL((SELECT isnull(ITEMID,'') FROM #ITEMSnew WHERE rowkey = 18),''),'[',''),']','') +  ''' then ExtAmt else 0 end) as Item_18, 
		 sum(Case when ItemID =''' +  replace(REPLACE(ISNULL((SELECT isnull(ITEMID,'') FROM #ITEMSnew WHERE rowkey = 19),''),'[',''),']','') +  ''' then ExtAmt else 0 end) as Item_19, 
		 sum(Case when ItemID =''' +  replace(REPLACE(ISNULL((SELECT isnull(ITEMID,'') FROM #ITEMSnew WHERE rowkey = 20),''),'[',''),']','') +  ''' then ExtAmt else 0 end) as Item_20' 
		 + ',' +
		 '''' + @ColumnString +  ''' AS dataColumns ' +
	'  FROM  #DATA
	group by CustomerID, CustomerName, InvoiceNo, [InvoiceDate], 
	[OrderNumber], Container, city, BrokerRefNo, InvoiceAmount, Status
	order by [InvoiceDate]'

	--SELECT @STRSQL
	PRINT (@STRSQL)
	exec (@STRSQL)
	select @RecCount = @@ROWCOUNT
	print @recCount
	if(@RecCount = 0)
	begin
		Select '' CustomerID, '' CustomerName, '' InvoiceNo, getdate() [InvoiceDate],  
		''  [OrderNumber],'' Container,'' City, ''BrokerRefNo, 0.00InvoiceAmount,  ''   Status, 
		0.00 as Item_1,  0.00 as Item_2, 0.00 as Item_3, 0.00 as Item_4, 0.00 as Item_5,      
		0.00 as Item_6, 0.00 as Item_7,	0.00 as Item_8, 0.00 as Item_9, 0.00 as Item_10,
		0.00 as Item_11,  0.00 as Item_12, 0.00 as Item_13, 0.00 as Item_14, 0.00 as Item_15,      
		0.00 as Item_16, 0.00 as Item_17,	0.00 as Item_18, 0.00 as Item_19, 0.00 as Item_20,
		'[BR],[CHASSIS FARE],[DRY RUN],[FUEL COST],' AS dataColumns 
	End
END
