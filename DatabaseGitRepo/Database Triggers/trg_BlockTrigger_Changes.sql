CREATE TRIGGER trg_BlockTrigger_Changes
ON DATABASE
FOR CREATE_TRIGGER, ALTER_TRIGGER
AS
BEGIN
    IF IS_ROLEMEMBER('db_CreateAlter') = 1
    BEGIN
        ROLLBACK;
        THROW 51001, 'Creating or altering triggers is not allowed for this role. Contact DB Admin.', 1;
    END
END

