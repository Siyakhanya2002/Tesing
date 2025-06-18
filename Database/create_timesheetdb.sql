USE master;
GO

-- Create the database if it doesn't exist
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'TimesheetDB')
BEGIN
    CREATE DATABASE TimesheetDB;
    PRINT '✅ TimesheetDB database created.';
END
ELSE
BEGIN
    PRINT 'ℹ️ TimesheetDB database already exists.';
END
GO

-- Switch to TimesheetDB
USE TimesheetDB;
GO

-- Create the stored procedure to recreate tables if not exists
IF OBJECT_ID('dbo.usp_EnsureTimesheetSchema', 'P') IS NOT NULL 
    DROP PROCEDURE dbo.usp_EnsureTimesheetSchema;
GO

CREATE PROCEDURE dbo.usp_EnsureTimesheetSchema
AS
BEGIN
    SET NOCOUNT ON;

    PRINT '⚙️ Checking and creating missing tables in TimesheetDB...';

    -- Employee
    IF OBJECT_ID('dbo.Employee', 'U') IS NULL
    BEGIN
        CREATE TABLE dbo.Employee (
            EmployeeID   INT IDENTITY(1,1) PRIMARY KEY,
            EmployeeName VARCHAR(150) NOT NULL UNIQUE
        );
        PRINT '✅ Employee table created.';
    END

    -- Client
    IF OBJECT_ID('dbo.Client', 'U') IS NULL
    BEGIN
        CREATE TABLE dbo.Client (
            ClientID   INT IDENTITY(1,1) PRIMARY KEY,
            ClientName VARCHAR(200) NOT NULL UNIQUE
        );
        PRINT '✅ Client table created.';
    END

    -- Project
    IF OBJECT_ID('dbo.Project', 'U') IS NULL
    BEGIN
        CREATE TABLE dbo.Project (
            ProjectID   INT IDENTITY(1,1) PRIMARY KEY,
            ClientID    INT NOT NULL,
            ProjectName VARCHAR(200) NOT NULL,
            CONSTRAINT FK_Project_Client FOREIGN KEY (ClientID) REFERENCES dbo.Client(ClientID),
            CONSTRAINT UQ_Project_Client_Project UNIQUE (ClientID, ProjectName)
        );
        PRINT '✅ Project table created.';
    END

    -- ExpenseCategory
    IF OBJECT_ID('dbo.ExpenseCategory', 'U') IS NULL
    BEGIN
        CREATE TABLE dbo.ExpenseCategory (
            ExpenseCategoryID INT IDENTITY(1,1) PRIMARY KEY,
            CategoryName VARCHAR(100) NOT NULL UNIQUE
        );
        PRINT '✅ ExpenseCategory table created.';
    END

    -- LeaveType
    IF OBJECT_ID('dbo.LeaveType', 'U') IS NULL
    BEGIN
        CREATE TABLE dbo.LeaveType (
            LeaveTypeID INT IDENTITY(1,1) PRIMARY KEY,
            TypeName VARCHAR(100) NOT NULL UNIQUE
        );
        PRINT '✅ LeaveType table created.';
    END

    -- TimesheetEntry
    IF OBJECT_ID('dbo.TimesheetEntry', 'U') IS NULL
    BEGIN
        CREATE TABLE dbo.TimesheetEntry (
            TimesheetID BIGINT IDENTITY(1,1) PRIMARY KEY,
            EmployeeID INT NOT NULL,
            ProjectID INT NOT NULL,
            WorkDate DATE NOT NULL,
            Billable BIT NOT NULL DEFAULT (0),
            Description VARCHAR(500),
            Comments VARCHAR(MAX),
            HoursDecimal DECIMAL(5,2) NOT NULL,
            StartTime TIME(0),
            EndTime TIME(0),
            CONSTRAINT FK_TS_Employee FOREIGN KEY (EmployeeID) REFERENCES dbo.Employee(EmployeeID),
            CONSTRAINT FK_TS_Project FOREIGN KEY (ProjectID) REFERENCES dbo.Project(ProjectID),
            CONSTRAINT UQ_Timesheet UNIQUE (EmployeeID, ProjectID, WorkDate)
        );
        PRINT '✅ TimesheetEntry table created.';
    END

    -- ExpenseEntry
    IF OBJECT_ID('dbo.ExpenseEntry', 'U') IS NULL
    BEGIN
        CREATE TABLE dbo.ExpenseEntry (
            ExpenseID BIGINT IDENTITY(1,1) PRIMARY KEY,
            EmployeeID INT NOT NULL,
            ExpenseDate DATE NOT NULL,
            ExpenseCategoryID INT NOT NULL,
            ExpenseDesc VARCHAR(500),
            AmountDEC DECIMAL(12,2) NOT NULL,
            CONSTRAINT FK_Expense_Employee FOREIGN KEY (EmployeeID) REFERENCES dbo.Employee(EmployeeID),
            CONSTRAINT FK_Expense_Category FOREIGN KEY (ExpenseCategoryID) REFERENCES dbo.ExpenseCategory(ExpenseCategoryID),
            CONSTRAINT UQ_ExpenseEntry UNIQUE (EmployeeID, ExpenseDate, ExpenseCategoryID)
        );
        PRINT '✅ ExpenseEntry table created.';
    END

    -- LeaveEntry
    IF OBJECT_ID('dbo.LeaveEntry', 'U') IS NULL
    BEGIN
        CREATE TABLE dbo.LeaveEntry (
            LeaveID BIGINT IDENTITY(1,1) PRIMARY KEY,
            EmployeeID INT NOT NULL,
            LeaveTypeID INT NOT NULL,
            StartDate DATE NOT NULL,
            EndDate DATE NOT NULL,
            NumberOfDays DECIMAL(5,2) NOT NULL,
            ApprovalObtained BIT NOT NULL DEFAULT (0),
            SickNoteFilePath VARCHAR(260),
            AddressDuringLeave VARCHAR(500),
            CONSTRAINT FK_Leave_Employee FOREIGN KEY (EmployeeID) REFERENCES dbo.Employee(EmployeeID),
            CONSTRAINT FK_Leave_Type FOREIGN KEY (LeaveTypeID) REFERENCES dbo.LeaveType(LeaveTypeID),
            CONSTRAINT UQ_LeaveEntry UNIQUE (EmployeeID, StartDate, EndDate)
        );
        PRINT '✅ LeaveEntry table created.';
    END

    -- AuditLog1
    IF OBJECT_ID('dbo.AuditLog1', 'U') IS NULL
    BEGIN
        CREATE TABLE dbo.AuditLog1 (
            AuditID INT IDENTITY(1,1) PRIMARY KEY,
            PackageName NVARCHAR(255),
            TaskName NVARCHAR(255),
            TableName NVARCHAR(255),
            RowsLoaded INT,
            RunDate DATETIME,
            ExecutedBy NVARCHAR(255),
            EmployeeName NVARCHAR(255),
            SheetName NVARCHAR(255)
        );
        PRINT '✅ AuditLog1 table created.';
    END

    -- ErrorLog1
    IF OBJECT_ID('dbo.ErrorLog1', 'U') IS NULL
    BEGIN
        CREATE TABLE dbo.ErrorLog1 (
            ErrorLogID INT IDENTITY(1,1) PRIMARY KEY,
            ErrorTimeUTC DATETIME,
            PackageName NVARCHAR(255),
            TaskName NVARCHAR(255),
            ErrorMessage NVARCHAR(MAX),
            TableName NVARCHAR(255)
        );
        PRINT '✅ ErrorLog1 table created.';
    END

    PRINT '🎉 All tables ensured. Schema is ready.';
END;
GO

-- Run the procedure to ensure tables exist
EXEC dbo.usp_EnsureTimesheetSchema;
GO
