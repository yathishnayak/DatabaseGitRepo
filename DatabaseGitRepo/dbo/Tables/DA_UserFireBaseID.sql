CREATE TABLE [dbo].[DA_UserFireBaseID] (
    [UserKey]      INT           NOT NULL,
    [FireBaseID]   VARCHAR (500) NOT NULL,
    [DeviceKey]    INT           NULL,
    [DateModified] DATETIME      NULL,
    CONSTRAINT [PK__DA_UserF__296ADCF1933D97E5] PRIMARY KEY CLUSTERED ([UserKey] ASC)
);

