-- 1. Create database if it doesn't exis
BEGIN TRY
    IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'AutoDBSiya1')
    BEGIN
        CREATE DATABASE AutoDBSiya1;
        PRINT 'Database created successfully.';
    END
    ELSE
        PRINT 'Database already exists.';
END TRY
BEGIN CATCH
    PRINT 'Error creating database:';
    PRINT ERROR_MESSAGE();
END CATCH
GO

-- 2. Switch to the new database
USE AutoDBSiya1;
GO

-- 3. Drop stored procedure if it exists
BEGIN TRY
    IF OBJECT_ID('CreateUserTable', 'P') IS NOT NULL
    BEGIN
        DROP PROCEDURE CreateUserTable;
        PRINT 'Existing procedure dropped.';
    END
END TRY
BEGIN CATCH
    PRINT 'Error dropping procedure:';
    PRINT ERROR_MESSAGE();
END CATCH
GO

-- 4. Create stored procedure that creates the table and inserts data
BEGIN TRY
    EXEC('
    CREATE PROCEDURE CreateUserTable
    AS
    BEGIN
        BEGIN TRY
            -- Check if the table exists
            IF OBJECT_ID(''user'', ''U'') IS NULL
            BEGIN
                CREATE TABLE [user] (
                    Name NVARCHAR(50),
                    Surname NVARCHAR(50),
                    Email NVARCHAR(100)
                );

                -- Insert sample rows
                INSERT INTO [user] (Name, Surname, Email)
                VALUES 
                (''John'', ''Doe'', ''john@example.com''),
                (''Jane'', ''Smith'', ''jane@example.com'');
            END
            ELSE
                PRINT ''Table already exists.'';
        END TRY
        BEGIN CATCH
            PRINT ''Error inside procedure CreateUserTable:'';
            PRINT ERROR_MESSAGE();
        END CATCH
    END
    ');
    PRINT 'Procedure created.';
END TRY
BEGIN CATCH
    PRINT 'Error creating procedure:';
    PRINT ERROR_MESSAGE();
END CATCH
GO

-- 5. Execute the stored procedure
BEGIN TRY
    EXEC CreateUserTable;
    PRINT 'Procedure executed.';
END TRY
BEGIN CATCH
    PRINT 'Error executing procedure:';
    PRINT ERROR_MESSAGE();
END CATCH
GO
