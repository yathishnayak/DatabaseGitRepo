CREATE TABLE [dbo].[EmptyLegData] (
    [EmptyLegDataKey]     INT      IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [OrderDetailKey]      INT      NOT NULL,
    [IsEmpty]             BIT      NOT NULL,
    [EmptySetDate]        DATETIME NULL,
    [EmptySetRouteKey]    INT      NULL,
    [EmptyRemoveDate]     DATETIME NULL,
    [EmptyRemoveRouteKey] INT      NULL,
    [UserKey]             INT      NOT NULL,
    [CreateDate]          DATETIME CONSTRAINT [DF_EmptyLegData_CreateDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_EmptyLegData] PRIMARY KEY CLUSTERED ([EmptyLegDataKey] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_EmptyLegData_OrderDetailKey]
    ON [dbo].[EmptyLegData]([OrderDetailKey] ASC)
    INCLUDE([EmptyLegDataKey], [IsEmpty], [EmptySetDate], [EmptySetRouteKey], [EmptyRemoveDate], [EmptyRemoveRouteKey]);

