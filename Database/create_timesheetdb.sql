-- Drop TimesheetDB if it exists
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'TimesheetDB')
BEGIN
    ALTER DATABASE TimesheetDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE TimesheetDB;
    PRINT 'TimesheetDB database dropped.';
END

-- Create TimesheetDB
CREATE DATABASE TimesheetDB;
PRINT 'TimesheetDB database created.';
GO

-- Use TimesheetDB
USE TimesheetDB;
GO

-- Create stored procedure to create tables
CREATE OR ALTER PROCEDURE CreateTimesheetDB
AS
BEGIN
    SET NOCOUNT ON;

    -- Create AuditLog1 table
    IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AuditLog1]') AND type in (N'U'))
    BEGIN
        CREATE TABLE [dbo].[AuditLog1](
            [AuditID] [int] IDENTITY(1,1) NOT NULL,
            [PackageName] [nvarchar](255) NULL,
            [TaskName] [nvarchar](255) NULL,
            [TableName] [nvarchar](255) NULL,
            [RowsLoaded] [int] NULL,
            [RunDate] [datetime] NULL,
            [ExecutedBy] [nvarchar](255) NULL,
            [EmployeeName] [nvarchar](255) NULL,
            [SheetName] [nvarchar](255) NULL,
            [ChangeType] [VARCHAR](20) NULL,
            PRIMARY KEY CLUSTERED ([AuditID] ASC)
        );
        PRINT 'AuditLog1 table created.';
    END

    -- Create Client table
    IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Client]') AND type in (N'U'))
    BEGIN
        CREATE TABLE [dbo].[Client](
            [ClientID] [int] IDENTITY(1,1) NOT NULL,
            [ClientName] [varchar](200) NOT NULL,
            PRIMARY KEY CLUSTERED ([ClientID] ASC)
        );
        PRINT 'Client table created.';
    END

    -- Create Employee table
    IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Employee]') AND type in (N'U'))
    BEGIN
        CREATE TABLE [dbo].[Employee](
            [EmployeeID] [int] IDENTITY(1,1) NOT NULL,
            [EmployeeName] [varchar](50) NOT NULL,
            PRIMARY KEY CLUSTERED ([EmployeeID] ASC)
        );
        PRINT 'Employee table created.';
    END

    -- Create ErrorLog1 table
    IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ErrorLog1]') AND type in (N'U'))
    BEGIN
        CREATE TABLE [dbo].[ErrorLog1](
            [ErrorLogID] [int] IDENTITY(1,1) NOT NULL,
            [ErrorTimeUTC] [datetime] NULL,
            [PackageName] [nvarchar](255) NULL,
            [TaskName] [nvarchar](255) NULL,
            [ErrorMessage] [nvarchar](max) NULL,
            [TableName] [nvarchar](255) NULL,
            [ComponentName] [varchar](100) NULL,
            PRIMARY KEY CLUSTERED ([ErrorLogID] ASC)
        );
        PRINT 'ErrorLog1 table created.';
    END

    -- Create Leave table
    IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Leave]') AND type in (N'U'))
    BEGIN
        CREATE TABLE [dbo].[Leave](
            [LeaveID] [int] IDENTITY(1,1) NOT NULL,
            [EmployeeID] [int] NOT NULL,
            [LeaveTypeID] [int] NOT NULL,
            [StartDate] [date] NOT NULL,
            [EndDate] [date] NOT NULL,
            [NumberOfDays] [decimal](5, 2) NOT NULL,
            [ApprovalObtained] [bit] NOT NULL,
            [SickNoteFilePath] [varchar](260) NULL,
            PRIMARY KEY CLUSTERED ([LeaveID] ASC)
        );
        PRINT 'Leave table created.';
    END

    -- Create LeaveType table
    IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LeaveType]') AND type in (N'U'))
    BEGIN
        CREATE TABLE [dbo].[LeaveType](
            [LeaveTypeID] [int] IDENTITY(1,1) NOT NULL,
            [TypeName] [varchar](50) NOT NULL,
            PRIMARY KEY CLUSTERED ([LeaveTypeID] ASC)
        );
        PRINT 'LeaveType table created.';
    END

    -- Create Stg_Leave1 table
    IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Stg_Leave1]') AND type in (N'U'))
    BEGIN
        CREATE TABLE [dbo].[Stg_Leave1](
            [EmployeeName] [nvarchar](50) NULL,
            [pathName] [nvarchar](50) NULL,
            [TypeOfLeave] [nvarchar](100) NULL,
            [StartDate] [nvarchar](50) NULL,
            [EndDate] [nvarchar](50) NULL,
            [NumberOfDays] [nvarchar](50) NULL,
            [ApprovalObtained] [nvarchar](50) NULL,
            [SickNote] [nvarchar](500) NULL
        ) ON [PRIMARY];
        PRINT 'Stg_Leave1 table created.';
    END

    -- Create Stg_Monthly table
    IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Stg_Monthly]') AND type in (N'U'))
    BEGIN
        CREATE TABLE [dbo].[Stg_Monthly](
            [EmployeeName] [varchar](50) NULL,
            [SheetName] [varchar](50) NULL,
            [Date] [nvarchar](50) NULL,
            [DOfWeek] [nvarchar](50) NULL,
            [Client] [nvarchar](200) NULL,
            [ClientProjectName] [nvarchar](200) NULL,
            [Description] [nvarchar](500) NULL,
            [BillableOrNonBillable] [nvarchar](50) NULL,
            [Comments] [nvarchar](max) NULL,
            [TotalHours] [nvarchar](50) NULL,
            [StartTime] [nvarchar](50) NULL,
            [EndTime] [nvarchar](50) NULL
        ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];
        PRINT 'Stg_Monthly table created.';
    END

    -- Create Timesheet table
    IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Timesheet]') AND type in (N'U'))
    BEGIN
        CREATE TABLE [dbo].[Timesheet](
            [TimesheetID] [int] IDENTITY(1,1) NOT NULL,
            [EmployeeID] [int] NOT NULL,
            [WorkDate] [date] NOT NULL,
            [DayOfWeek] [varchar](255) NOT NULL,
            [ClientProjectName] [varchar](255) NULL,
            [Description] [varchar](255) NULL,
            [Billable] [varchar](255) NULL,
            [Comments] [varchar](max) NULL,
            [StartTime] [time](7) NULL,
            [EndTime] [time](7) NULL,
            [HoursDecimal] [time](7) NULL,
            PRIMARY KEY CLUSTERED ([TimesheetID] ASC)
        );
        PRINT 'Timesheet table created.';
    END
END
GO

-- Execute the stored procedure to create tables
EXEC CreateTimesheetDB;
GO
