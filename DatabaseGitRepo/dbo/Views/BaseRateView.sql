
CREATE view [dbo].[BaseRateView]
as
select BR.BaseRateKey, BR.ClientOrBrokerKey, BR.IsClient, BR.IsBroker, BR.CityKey, case when BR.IsClient = 1 then C.ClientName else R.BrokerName end as BrokerOrClientName,
	BR.CustomerKey, CU.CustID, CU.CustName, L.City, L.Country, L.State, L.ZipCode, BR.EmailContact, BR.CreateDate, BR.EffectiveDate,  BR.LastUpdateDate, 
	BR.UnitPrice, BR.CreateUserKey,BR.Itemkey
from CustomerItemRate BR  WITH (NOLOCK) 
Left join Client C  WITH (NOLOCK) on BR.ClientOrBrokerKey = C.ClientKey and BR.IsClient = 1
Left join Broker R  WITH (NOLOCK) on BR.ClientOrBrokerKey = R.BrokerKey and BR.IsBroker = 1
LEft join Customer CU  WITH (NOLOCK) on BR.CustomerKey = CU.CustKey
Left join LocationData L  WITH (NOLOCK) on BR.CityKey = L.CityKey
