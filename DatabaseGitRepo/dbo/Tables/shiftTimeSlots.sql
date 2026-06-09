CREATE TABLE [dbo].[shiftTimeSlots] (
    [slotkey]  SMALLINT     IDENTITY (1, 1) NOT NULL,
    [slotName] VARCHAR (50) NULL,
    [timeFrom] TIME (7)     NULL,
    [timeTo]   TIME (7)     NULL,
    [shiftKey] SMALLINT     NULL,
    [isActive] BIT          DEFAULT ((1)) NULL,
    [OrderBy]  SMALLINT     NULL,
    PRIMARY KEY CLUSTERED ([slotkey] ASC)
);

