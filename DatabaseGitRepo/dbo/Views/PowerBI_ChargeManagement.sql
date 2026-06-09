CREATE VIEW [dbo].[PowerBI_ChargeManagement]
AS
SELECT 
	OE.OrderExpenseKey, OE.OrderDetailKey, OE.RouteKey, OE.Itemkey
	, I.ItemID, I.Description AS ItemDesc, IT.ItemType AS ItemType, IT.Description AS ItemTypeDesc, IC.Name AS ItemCategory
	, OE.Qty, OE.FreeTime AS [Free Qty], OE.MinCnt AS [Min Qty], OE.MaxCnt AS [Max Qty], OE.UnitCost AS Rate
	, CASE WHEN OE.BvsNB = 1 THEN 'B' ELSE 'NB' END AS [B Vs. NB]
	, CASE 
			WHEN OE.BvsNB = 1	THEN
				CASE	WHEN ( OE.Qty - ISNULL(OE.FreeTime,0) ) > ISNULL(OE.MaxCnt,0) AND ISNULL(OE.MaxCnt,0) <> 0 THEN ISNULL(OE.MaxCnt,0)
						WHEN ( OE.Qty - ISNULL(OE.FreeTime,0) ) < ISNULL(OE.MinCnt,0) AND ISNULL(OE.MinCnt,0) <> 0 THEN ISNULL(OE.MinCnt,0)
						ELSE ( OE.Qty - ISNULL(OE.FreeTime,0) ) END
			ELSE 0 END AS [Billable Qty]

	, CASE 
			WHEN OE.BvsNB = 1	THEN
				CASE	WHEN ( OE.Qty - ISNULL(OE.FreeTime,0) ) > ISNULL(OE.MaxCnt,0) AND ISNULL(OE.MaxCnt,0) <> 0 THEN ISNULL(OE.MaxCnt,0)
						WHEN ( OE.Qty - ISNULL(OE.FreeTime,0) ) < ISNULL(OE.MinCnt,0) AND ISNULL(OE.MinCnt,0) <> 0 THEN ISNULL(OE.MinCnt,0)
						ELSE ( OE.Qty - ISNULL(OE.FreeTime,0) ) END
			ELSE 0 END * OE.UnitCost AS [Billable Total]

	, OE.InternalNotes
	, OE.ChargeSource,OE.DateFrom, OE.DateTo, OE.CreateDate, USR_Crt.UserName AS CreateUser --, OE.CreateUserKey
	, OE.LastUpdateDate, USR_Upd.UserName AS UpdateUser --, OE.UpdateUserKey
	, CASE WHEN OE.PvsNP = 'true' THEN 'P' ELSE 'NP' END AS [Driver Pay - P Vs. NP]  ---- This field is of VARCHAR Type
	, CASE WHEN OE.IsCSRApproved = 1 THEN 'Yes' ELSE 'No' END AS IsCSRApproved
	, CASE WHEN OE.IsCustomerApproved = 1 THEN 'Yes' ELSE 'No' END AS IsCustomerApproved
	, CASE WHEN OE.isCSApproved = 1 THEN 'Yes' ELSE 'No' END AS isCSApproved
	, OE.CSApprovedDate, OE.CSUserKey
	, CASE WHEN OE.IsInvoiced = 1 THEN 'Yes' ELSE 'No' END AS IsInvoiced
	, CASE WHEN OE.IsChargeSharedWithCustomer = 1 THEN 'Yes' ELSE 'No' END AS IsChargeSharedWithCustomer
	, OE.ChargeSharedWithCustBy, OE.ChargeSharedWithCustDate
	, CASE WHEN OE.IsCustomerApprovedCharge = 1 THEN 'Yes' ELSE 'No' END AS IsCustomerApprovedCharge
	, OE.CustomerApprovedChargeBy, OE.CustomerApprovedChargeDate

FROM OrderExpense AS OE WITH (NOLOCK)
LEFT JOIN Item AS I WITH (NOLOCK) ON OE.ItemKey = I.ItemKey 
LEFT JOIN ItemType AS IT WITH (NOLOCK) ON I.ItemTypeKey = IT.ItemTypeKey 
LEFT JOIN ItemCategory AS IC WITH (NOLOCK) ON I.CategoryKey = IC.CategoryKey
LEFT JOIN [User] USR_Crt WITH (NOLOCK) ON OE.CreateUserKey = USR_Crt.UserKey
LEFT JOIN [User] USR_Upd WITH (NOLOCK) ON OE.UpdateUserKey = USR_Upd.UserKey