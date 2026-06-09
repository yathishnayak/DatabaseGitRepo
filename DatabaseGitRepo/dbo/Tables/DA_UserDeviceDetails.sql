CREATE TABLE [dbo].[DA_UserDeviceDetails] (
    [UserKey]      INT      NOT NULL,
    [DeviceKey]    INT      NOT NULL,
    [IsApproved]   BIT      CONSTRAINT [DF__DA_UserDe__IsApp__2C55260F] DEFAULT ((0)) NOT NULL,
    [DriverKey]    INT      NOT NULL,
    [ApprovedBy]   INT      NULL,
    [ApprovedDate] DATETIME NULL,
    [CreatedDate]  DATETIME NULL
);

