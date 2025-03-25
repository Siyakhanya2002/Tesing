-- Create the database
CREATE DATABASE AutoTest;
GO

USE AutoTest;
GO

-- Create a stored procedure to create table and insert data
CREATE PROCEDURE CreateUserTable
AS
BEGIN
    CREATE TABLE [user] (
        Name NVARCHAR(50),
        Surname NVARCHAR(50),
        Email NVARCHAR(100)
    );

    INSERT INTO [user] (Name, Surname, Email) VALUES
    ('John', 'Doe', 'john.doe@example.com'),
    ('Jane', 'Smith', 'jane.smith@example.com');
END;
GO

-- Run the stored procedure
EXEC CreateUserTable;
GO
