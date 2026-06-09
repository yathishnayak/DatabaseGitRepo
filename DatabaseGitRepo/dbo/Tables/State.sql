CREATE TABLE [dbo].[State] (
    [StateKey]   INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [StateID]    VARCHAR (20)  NOT NULL,
    [StateName]  VARCHAR (255) NOT NULL,
    [CreateDate] DATETIME2 (7) NOT NULL,
    [Status]     SMALLINT      NOT NULL,
    [StatusDate] DATETIME2 (7) NOT NULL,
    CONSTRAINT [State_pkey] PRIMARY KEY CLUSTERED ([StateKey] ASC)
);

