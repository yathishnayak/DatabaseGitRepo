




CREATE view [dbo].[vNotifications]
as
select NotificationKey, N.UserKey, HeadText, DetailText, CreateDate, IsRead,
ReadDateTime, isActive, SentUserKey, RelatedTranType, RelatedTranKey, 
R.UserName as RecepientName, S.UserName as SenderName
from Notifications N  WITH (NOLOCK) 
inner join [User] R WITH (NOLOCK)  on N.UserKey = R.UserKey -- recepient
left join [User] S WITH (NOLOCK)  on N.SentUserKey = S.UserKey -- Sender

