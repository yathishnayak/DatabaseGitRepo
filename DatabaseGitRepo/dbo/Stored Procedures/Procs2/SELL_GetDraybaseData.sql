/*
exec SELL_GetDraybaseData 
@ContainerNo='BEAU5844634',@city = 'LONG BEACH',@State='CA',@ZipCode='90805',@LocationName='Junction Collaborative Transports',@MarketKey=2, 
@TerminalKey=6,@CustKey=3363,@InvoiceDate='2025-12-11'
*/
CREATE proc [dbo].[SELL_GetDraybaseData]
(
	@ContainerNo		VARCHAR(20),
	@city				VARCHAR(200),
	@State				VARCHAR(10),
	@ZipCode			varchar(10),
	@LocationName		varchar(200),
	@MarketKey			int,
	@TerminalKey		int,
	@CustKey			int,
	@InvoiceDate		Date
)
as
	SET NOCOUNT ON
	SET FMTONLY OFF

	BEGIN
		create table #draybase_Temp (
			ContainerNo			   varchar(50),
			DrayBase_Value		   float,
			Margin_Percent		   float,
			Margin_Value		   float,
			DrayBase_Rate		   float,
			FSF_Percent			   float,
			FSF_Value			   float,
			Draybase_Total		   float,
			NetRevenue			   float,
			EffectiveDate		   datetime,
			EffectiveDateFrom	   varchar(50),
			FileName			   varchar(100),
			DateUploaded		   datetime,
			UploadedBy			   varchar(50),
			OutputDataKey		   int,
			LocationName			VARCHAR(200)
		)
		INSERT INTO #draybase_Temp
			(ContainerNo,DrayBase_Value	,FSF_Percent	,FSF_Value	,
			EffectiveDate,EffectiveDateFrom,FileName,DateUploaded,UploadedBy,OutputDataKey,LocationName)

		select TOP 1 @ContainerNo, DraybaseCost, FSF * 100, 0, 
				EffectiveDate, EffectiveDateFrom, F.FileName, DateUploaded, U.UserName as UploadedBy ,OutputDataKey ,LocationName
			from SELL_NAC_Draybase_FinalDataOutput A WITH (NOLOCK)
			inner join SELL_NAC_Draybase_FileProcessInfo F  WITH (NOLOCK) on A.FileProcessKey = F.FileProcessKey
			inner join [user] U  WITH (NOLOCK) on F.UserKey = U.UserKey
			where (City = @city OR ISNULL(City,'')='') and 
					(State = @State OR ISNULL(State,'')='') and 
					(Zip = @ZipCode OR isnull(Zip,0) =0  ) and
					(ltrim(rtrim(LocationName)) = ltrim(rtrim(@LocationName)) OR isnull(LocationName,'') = '') and  
					MarketKey = @MarketKey and A.Custkey = @CustKey and
					(TerminalKey = @TerminalKey OR ISNULL(TerminalKey,0)=0)  
					and convert(date,(CASE 
        WHEN ISDATE(EffectiveDate) = 1 
            THEN CONVERT(varchar(10), CAST(EffectiveDate AS datetime), 101)
        WHEN TRY_CONVERT(datetime, EffectiveDate, 103) IS NOT NULL 
            THEN CONVERT(varchar(10), TRY_CONVERT(datetime, EffectiveDate, 103), 101) END)) <= convert(date,isnull(@InvoiceDate,GETUTCDATE()))
					and ISNULL(A.IsArchived,0) = 0 and 
					(CASE 
        WHEN ISDATE(ExpiryDate) = 1 
            THEN CONVERT(varchar(10), CAST(ExpiryDate AS datetime), 101)
        WHEN TRY_CONVERT(datetime, ExpiryDate, 103) IS NOT NULL 
            THEN CONVERT(varchar(10), TRY_CONVERT(datetime, ExpiryDate, 103), 101) end) >= Convert(date, isnull(@InvoiceDate,GETUTCDATE()))
				ORDER BY LocationName desc, convert(datetime, (CASE 
        WHEN ISDATE(EffectiveDate) = 1 
            THEN CONVERT(varchar(10), CAST(EffectiveDate AS datetime), 101)
        WHEN TRY_CONVERT(datetime, EffectiveDate, 103) IS NOT NULL 
            THEN CONVERT(varchar(10), TRY_CONVERT(datetime, EffectiveDate, 103), 101) END)) DESC, city DESC, State DESC, Zip Desc
			,OutputDataKey desc--, LocationName DESC

			update #draybase_Temp set Margin_Value = 0; -- AS PER COMMUNICATION ON 18/03/2024 - NO MARGIN FOR NACS 
			--update #DrayBase set Margin_Value = DrayBase_Value * (Margin_Percent/100) where ContainerNo = @_ContainerNo
			update #draybase_Temp set DrayBase_Rate = DrayBase_Value + Margin_Value where ContainerNo = @ContainerNo
			update #draybase_Temp set FSF_Value = DrayBase_Rate * (isnull(FSF_Percent,0) / 100) where ContainerNo = @ContainerNo
			update #draybase_Temp set Draybase_Total = DrayBase_Rate + isnull(FSF_Value,0) where ContainerNo = @ContainerNo
			update #draybase_Temp set NetRevenue = Draybase_Total - DrayBase_Value where ContainerNo = @ContainerNo

		Select * from #draybase_Temp
		drop table #draybase_Temp
				
	END