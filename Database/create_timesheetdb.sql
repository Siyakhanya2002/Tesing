-- STEP 1: Create TimesheetDB if not exists
USE master;
GO
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'TimesheetDB')
BEGIN
    CREATE DATABASE TimesheetDB;
    PRINT '✅ TimesheetDB created.';
END
ELSE
    PRINT 'ℹ️ TimesheetDB already exists.';
GO

-- STEP 2: Switch to TimesheetDB
USE TimesheetDB;
GO

-- STEP 3: Drop old procedure if exists
IF OBJECT_ID('dbo.usp_RecreateTimesheetSchema', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_RecreateTimesheetSchema;
GO

-- STEP 4: Create the procedure
CREATE PROCEDURE dbo.usp_RecreateTimesheetSchema
AS
BEGIN
    SET NOCOUNT ON;

    PRINT '⚙️ Recreating schema in TimesheetDB...';

    -- Drop all tables if they exist
    IF OBJECT_ID('dbo.LeaveEntry', 'U') IS NOT NULL DROP TABLE dbo.LeaveEntry;
    IF OBJECT_ID('dbo.ExpenseEntry', 'U') IS NOT NULL DROP TABLE dbo.ExpenseEntry;
    IF OBJECT_ID('dbo.TimesheetEntry', 'U') IS NOT NULL DROP TABLE dbo.TimesheetEntry;
    IF OBJECT_ID('dbo.Project', 'U') IS NOT NULL DROP TABLE dbo.Project;
    IF OBJECT_ID('dbo.Client', 'U') IS NOT NULL DROP TABLE dbo.Client;
    IF OBJECT_ID('dbo.Employee', 'U') IS NOT NULL DROP TABLE dbo.Employee;
    IF OBJECT_ID('dbo.ExpenseCategory', 'U') IS NOT NULL DROP TABLE dbo.ExpenseCategory;
    IF OBJECT_ID('dbo.LeaveType', 'U') IS NOT NULL DROP TABLE dbo.LeaveType;
    IF OBJECT_ID('dbo.AuditLog1', 'U') IS NOT NULL DROP TABLE dbo.AuditLog1;
    IF OBJECT_ID('dbo.ErrorLog1', 'U') IS NOT NULL DROP TABLE dbo.ErrorLog1;

    -- Create Employee
    CREATE TABLE dbo.Employee (
        EmployeeID   INT IDENTITY(1,1) PRIMARY KEY,
        EmployeeName VARCHAR(150) NOT NULL,
        CONSTRAINT UQ_Employee_EmployeeName UNIQUE (EmployeeName)
    );

    -- Create Client
    CREATE TABLE dbo.Client (
        ClientID   INT IDENTITY(1,1) PRIMARY KEY,
        ClientName VARCHAR(200) NOT NULL,
        CONSTRAINT UQ_Client_ClientName UNIQUE (ClientName)
    );

    -- Create Project
    CREATE TABLE dbo.Project (
        ProjectID   INT IDENTITY(1,1) PRIMARY KEY,
        ClientID    INT NOT NULL
            CONSTRAINT FK_Project_Client REFERENCES dbo.Client(ClientID)
            ON UPDATE CASCADE ON DELETE NO ACTION,
        ProjectName VARCHAR(200) NOT NULL,
        CONSTRAINT UQ_Project_ClientID_ProjectName UNIQUE (ClientID, ProjectName)
    );

    -- ExpenseCategory
    CREATE TABLE dbo.ExpenseCategory (
        ExpenseCategoryID INT IDENTITY(1,1) PRIMARY KEY,
        CategoryName VARCHAR(100) NOT NULL,
        CONSTRAINT UQ_ExpenseCategory_CategoryName UNIQUE (CategoryName)
    );

    -- LeaveType
    CREATE TABLE dbo.LeaveType (
        LeaveTypeID INT IDENTITY(1,1) PRIMARY KEY,
        TypeName VARCHAR(100) NOT NULL,
        CONSTRAINT UQ_LeaveType_TypeName UNIQUE (TypeName)
    );

    -- TimesheetEntry
    CREATE TABLE dbo.TimesheetEntry (
        TimesheetID  BIGINT IDENTITY(1,1) PRIMARY KEY,
        EmployeeID   INT NOT NULL
            CONSTRAINT FK_TimesheetEntry_Employee REFERENCES dbo.Employee(EmployeeID)
            ON UPDATE CASCADE ON DELETE NO ACTION,
        ProjectID    INT NOT NULL
            CONSTRAINT FK_TimesheetEntry_Project REFERENCES dbo.Project(ProjectID)
            ON UPDATE CASCADE ON DELETE NO ACTION,
        WorkDate     DATE NOT NULL,
        Billable     BIT NOT NULL DEFAULT (0),
        Description  VARCHAR(500) NULL,
        Comments     VARCHAR(MAX) NULL,
        HoursDecimal DECIMAL(5,2) NOT NULL,
        StartTime    TIME(0) NULL,
        EndTime      TIME(0) NULL,
        CONSTRAINT UQ_Timesheet_Employee_Project_Date UNIQUE (EmployeeID, ProjectID, WorkDate)
    );

    -- ExpenseEntry
    CREATE TABLE dbo.ExpenseEntry (
        ExpenseID         BIGINT IDENTITY(1,1) PRIMARY KEY,
        EmployeeID        INT NOT NULL
            CONSTRAINT FK_Expense_Employee REFERENCES dbo.Employee(EmployeeID)
            ON UPDATE CASCADE ON DELETE NO ACTION,
        ExpenseDate       DATE NOT NULL,
        ExpenseCategoryID INT NOT NULL
            CONSTRAINT FK_Expense_ExpenseCategory REFERENCES dbo.ExpenseCategory(ExpenseCategoryID)
            ON UPDATE CASCADE ON DELETE NO ACTION,
        ExpenseDesc       VARCHAR(500) NULL,
        AmountDEC         DECIMAL(12,2) NOT NULL,
        CONSTRAINT UQ_Expense_Employee_Date_Category UNIQUE (EmployeeID, ExpenseDate, ExpenseCategoryID)
    );

    -- LeaveEntry
    CREATE TABLE dbo.LeaveEntry (
        LeaveID            BIGINT IDENTITY(1,1) PRIMARY KEY,
        EmployeeID         INT NOT NULL
            CONSTRAINT FK_Leave_Employee REFERENCES dbo.Employee(EmployeeID)
            ON UPDATE CASCADE ON DELETE NO ACTION,
        LeaveTypeID        INT NOT NULL
            CONSTRAINT FK_Leave_LeaveType REFERENCES dbo.LeaveType(LeaveTypeID)
            ON UPDATE CASCADE ON DELETE NO ACTION,
        StartDate          DATE NOT NULL,
        EndDate            DATE NOT NULL,
        NumberOfDays       DECIMAL(5,2) NOT NULL,
        ApprovalObtained   BIT NOT NULL DEFAULT (0),
        SickNoteFilePath   VARCHAR(260) NULL,
        AddressDuringLeave VARCHAR(500) NULL,
        CONSTRAINT UQ_Leave_Employee_Start_End UNIQUE (EmployeeID, StartDate, EndDate)
    );

    -- AuditLog1
    CREATE TABLE dbo.AuditLog1 (
        AuditID      INT IDENTITY(1,1) PRIMARY KEY,
        PackageName  VARCHAR(200),
        TaskName     VARCHAR(200),
        TableName    VARCHAR(200),
        RowsLoaded   INT,
        RunDate      DATETIME,
        ExecutedBy   VARCHAR(100),
        EmployeeName VARCHAR(150),
        SheetName    VARCHAR(100)
    );

    -- ErrorLog1
    CREATE TABLE dbo.ErrorLog1 (
        ErrorLogID   INT IDENTITY(1,1) PRIMARY KEY,
        ErrorTimeUTC DATETIME,
        PackageName  VARCHAR(200),
        TaskName     VARCHAR(200),
        ErrorMessage VARCHAR(MAX),
        TableName    VARCHAR(200)
    );

    -- Indexes
    CREATE NONCLUSTERED INDEX IX_TS_Employee_WorkDate
        ON dbo.TimesheetEntry (EmployeeID, WorkDate);
    CREATE NONCLUSTERED INDEX IX_TS_Project_WorkDate
        ON dbo.TimesheetEntry (ProjectID, WorkDate);
    CREATE NONCLUSTERED INDEX IX_EXP_Employee_ExpenseDate
        ON dbo.ExpenseEntry (EmployeeID, ExpenseDate);
    CREATE NONCLUSTERED INDEX IX_LEAVE_Employee_StartDate
        ON dbo.LeaveEntry (EmployeeID, StartDate);
    CREATE NONCLUSTERED INDEX IX_ExpenseCategory_CategoryName
        ON dbo.ExpenseCategory (CategoryName);
    CREATE NONCLUSTERED INDEX IX_LeaveType_TypeName
        ON dbo.LeaveType (TypeName);

    PRINT '✅ All tables and indexes created.';
END;
GO

-- STEP 5: Run the procedure
EXEC dbo.usp_RecreateTimesheetSchema;
GO
