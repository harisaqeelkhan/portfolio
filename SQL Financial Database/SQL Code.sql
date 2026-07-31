create database analysiswizard;


create table SystemUser (
    ID int primary key,
    Username varchar(255) not null check(
	len(Username)>=4
	),
    User_Password varchar(255) not null check (
        len(User_Password) >= 8 and
        User_Password like '%[A-Z]%' and  
        User_Password like '%[a-z]%' and  
        User_Password like '%[0-9]%' and  
        User_Password like '%[!@#$%^&*]%' 
		),
    FullName varchar(255),
    Email varchar(255) null check (
	 Email like '%_@__%.__%'),
    user_role varchar(255) check (user_role in ('Admin', 'User'))
);

create table Calculations (
    Calculation_ID int primary key,
    CalculationType int check (
	  CalculationType between 1 and 4),
    Cal_Description varchar(255),
    CalculationDate date check (
	   CalculationDate <= getdate()),
    SystemUser_ID int,
    foreign key (SystemUser_ID) references SystemUser(ID)
);
create table NPV (
    NPV_ID numeric(19,0) primary key,
    InitialInvestment decimal(15,2) check(
	 InitialInvestment > 0),
    DiscountRate decimal(5,2) check (
	DiscountRate between 0 and 1),
    Cashflowperiods int check (
	  Cashflowperiods between 1 and 30),
    NPVresults decimal(15,2),
    CashflowValues varchar(1000), 
    CalculationsCalculation_ID int,
    foreign key (CalculationsCalculation_ID) references Calculations(Calculation_ID)
);

create table Financial_Ratios (
    Company_ID int primary key,
    Current_Assets decimal(15,2)check (
	Current_Assets > 0),
    Current_Liabilities decimal(15,2) check (
	Current_Liabilities > 0),
    Inventory decimal(15,2) check (
	Inventory >= 0),
    Cost_of_goods_sold decimal(15,2) check(
	Cost_of_goods_sold >= 0),
    Revenue decimal(15,2) check (
	Revenue > 0),
    Net_fixed_Assets decimal(15,2)check (
	Net_fixed_Assets >= 0),
	 Total_Assets as (Current_Assets + Net_fixed_Assets),
    Net_Income decimal(15,2) not null,
    Total_Shares decimal(15,2) not null check (
	Total_Shares >=0),
     Current_Ratio AS (Current_Assets / Current_Liabilities),
    Quick_Ratio AS ((Current_Assets - Inventory) / Current_Liabilities),
    Inventory_Turnover AS (Cost_of_goods_sold / NULLIF(Inventory, 0)),
    Fixed_Assets_Turnover AS (Revenue / NULLIF(Net_Fixed_Assets, 0)),
     Total_assets_turnover AS (Revenue / (Current_Assets + Net_Fixed_Assets)),
     Profit_Margin AS (Net_Income / NULLIF(Revenue, 0)),
    EPS AS (Net_Income / Total_Shares),
    CalculationsCalculation_ID int,
    foreign key (CalculationsCalculation_ID) references Calculations(Calculation_ID)
);

create table Value_of_the_firm (
    PFID int primary key,
    FCF_Value decimal(15,2) not null check (
	FCF_Value>0),
    WACC decimal(5,2) not null check(
	WACC between 0.01 and 1),
    Growth_Rate decimal(5,2) not null check(
	Growth_Rate between 0 and 0.5),
    CalculationsCalculation_ID int,
    foreign key (CalculationsCalculation_ID) references Calculations(Calculation_ID)
);

create table PV (
    PV_ID int primary key,
    FutureValue decimal(15,2) not null check(
	FutureValue>0),
    InterestRate decimal(5,2) not null check(
	InterestRate between 0 and 1),
    investment_period int check ( 
	investment_period between 1 and 100),
    PVResults decimal(15,2) not null,
    CalculationsCalculation_ID int,
    foreign key (CalculationsCalculation_ID) references Calculations(Calculation_ID)
);

drop table PV;
insert into SystemUser values
    (1, 'AdminUser1', 'Secure@1234', 'Admin User', 'admin@finance.com', 'Admin'),
    (2, 'FinancialAnalyst1', 'Analyst#2024', 'John Smith', 'john.smith@company.com', 'User'),
    (3, 'FinanceManager1', 'Mgr$5678Xy', 'Sarah Lee', 'sarah.lee@finance.com', 'Admin'),
    (4, 'FinanceUser1', 'Passw0rd!Xy', 'Mike Brown', 'mike.brown@finance.com', 'User'),
    (5, 'SeniorAuditor1', 'Audit@2025Z', 'Lisa Wong', 'lisa.wong@auditfirm.com', 'User');


insert into Calculations values
(101, 1, 'Q2 Project NPV', '2023-05-01', 1),
(102, 3, 'Annual Ratios', '2023-06-15', 2),
(103, 4, 'Startup Valuation', '2023-07-20', 3),
(104, 2, 'Bond PV', '2023-08-10', 4),
(105, 1, 'Equipment Investment', '2023-09-05', 5);

insert into NPV values
(1001, 50000.00, 0.12, 5, 18950.25, '10000,12000,15000,18000,20000', 101),
(1002, 100000.00, 0.08, 3, -2450.00, '30000,35000,40000', 102);

insert into Financial_Ratios (
    Company_ID, Current_Assets, Current_Liabilities, Inventory, 
    Cost_of_goods_sold, Revenue, Net_fixed_Assets, Net_Income, Total_Shares, CalculationsCalculation_ID
) values
(501, 150000.00, 75000.00, 50000.00, 200000.00, 500000.00, 300000.00, 100000.00, 1000000.00, 101),
(502, 80000.00, 100000.00, 30000.00, 150000.00, 250000.00, 150000.00, 25000.00, 500000.00, 102);

insert into Value_of_the_firm values
(201, 250000.00, 0.10, 0.03, 101),
(202, 500000.00, 0.12, 0.05, 102);

insert into PV values
(301, 10000.00, 0.05, 5, 7835.26, 101),
(302, 500000.00, 0.10, 10, 192771.64, 102);

-- Procedure for entering a new user--
create procedure RegisterUser 
    @Username varchar(255),
    @Password varchar(255),
    @FullName varchar(255) = NULL,
    @Email varchar(255) = NULL,
    @Role varchar(255) = 'User'

as
begin
    set nocount on;
    
    if len(@Password) < 8 
        or @Password not like '%[A-Z]%'
        or @Password not like '%[a-z]%'
        or @Password not like '%[0-9]%'
        or @Password not like '%[!@#$%^&*]%'
    begin
        RAISERROR('Password must contain: 8+ chars, 1 uppercase, 1 lowercase, 1 number, 1 special char (!@#$%^&*)', 16, 1);
        return -1;
    end
    
    if len(@Username) < 4
    begin
        RAISERROR('Username must be at least 4 characters', 16, 1);
        return -1;
    end
    
    if @Role not in ('Admin', 'User')
    begin
        RAISERROR('Role must be either Admin or User', 16, 1);
        return -1;
    end
    
    if @Email is not null and @Email not like '%_@__%.__%'
    begin
        RAISERROR('Invalid email format', 16, 1);
        return -1;
    end
    
    if exists (select 1 from SystemUser where Username = @Username)
    begin
        RAISERROR('Username already exists', 16, 1);
        return -1;
    end
    
    declare @NewID int;
    select @NewID = isnull(max(ID), 0) + 1 from SystemUser;
    
    insert into SystemUser (
        ID,
        Username,
        User_Password,
        FullName,
        Email,
        user_role
    )
    values (
        @NewID,
        @Username,
        @Password,
        @FullName,
        @Email,
        @Role
    );
    
    select @NewID as NewUserID;
    return 0;
end;


EXEC RegisterUser 
    @Username = 'Financeintern',
    @Password = 'P@ssw0rd123',
    @FullName = 'Shaheer Uddin Sheikh',
    @Email = 'shaheer.sheikh@finance.com',
    @Role = 'User';

	select*from SystemUser;

-- Procedure for Updating Password--
CREATE PROCEDURE UpdateUserPassword (
    @Username varchar(255),
    @OldPassword varchar(255),
    @NewPassword varchar(255)
)
as
begin
    set nocount on;
    
    
    IF not exists (
        select 1 
        from SystemUser 
        where Username = @Username 
          and User_Password = @OldPassword
    )
    begin
        RAISERROR('Invalid username or current password', 16, 1);
        return -1;
    end
    
    
    if len(@NewPassword) < 8 
        or @NewPassword not like '%[A-Z]%'
        or @NewPassword not like '%[a-z]%'
        or @NewPassword not like '%[0-9]%'
        or @NewPassword not like '%[!@#$%^&*]%'
    begin
        RAISERROR('New password must contain: 8+ chars, 1 uppercase, 1 lowercase, 1 number, 1 special char (!@#$%^&*)', 16, 1);
        return -1;
    end
    

    if @NewPassword = @OldPassword
    begin
        RAISERROR('New password cannot be the same as old password', 16, 1);
        return -1;
    end


    update SystemUser
    set User_Password = @NewPassword
    where Username = @Username;


    return 0;
end;


EXEC UpdateUserPassword
    @Username = 'Financeintern',
    @OldPassword = 'P@ssw0rd123',
    @NewPassword = 'Apple@2017';

	select*from SystemUser;
-- Update User rule--

create procedure UpdateUserRole (
    @TargetUserID int,
    @NewRole varchar(255),
    @AdminUserID int  
)
as
begin
    set  nocount  on;
    
   
    IF not exists (
        select 1 from SystemUser 
        where ID = @AdminUserID AND user_role = 'Admin'
    )
    begin
        RAISERROR('Error: Only Admin users can modify roles', 16, 1);
        return -1;
    end
    
    
    if @NewRole not in ('Admin', 'User')
    begin
        RAISERROR('Error: Role must be either "Admin" or "User"', 16, 1);
        return -1;
    end
    
    
    if not exists (select 1 from SystemUser where ID = @TargetUserID)
    begin
        RAISERROR('Error: Target user does not exist', 16, 1);
        return -1;
    end
    
    
    if @NewRole = 'User' 
       and @TargetUserID = @AdminUserID
       and (SELECT count(*) from SystemUser where user_role = 'Admin') = 1
    begin
        RAISERROR('Error: system requires at least one admin', 16, 1);
        return -1;
    end
    
    
    update SystemUser
    set user_role = @NewRole
    where ID = @TargetUserID;
    
   
    return 0;
end;

EXEC UpdateUserRole 
    @TargetUserID = 5,
    @NewRole = 'Admin',
    @AdminUserID = 1;

SELECT ID, Username, user_role 
FROM SystemUser 
WHERE ID IN (1, 5);

select*from SystemUser;

-- Validation of PV--

create procedure ValidatePVCalculation (
    @FutureValue decimal(15,2),
    @InterestRate decimal(5,4),
    @Periods int,
    @PVResult decimal(15,2) output,
    @IsValid bit output,
    @Message varchar(255) output
)
as
begin
    set nocount on;
    
   
    set @IsValid = 1;
    set @Message = 'Validation passed';
    set @PVResult = NULL;
    
    
    if @FutureValue <= 0
    begin
        set @IsValid = 0;
        set @Message = 'Future value must be positive';
        return;
    end
    
    
    if @InterestRate < 0 OR @InterestRate > 1
    begin
        set @IsValid = 0;
        set @Message = 'Interest rate must be between 0 and 1 (0%-100%)';
        return;
    end
    
    
    if @Periods <= 0 OR @Periods > 1000
    begin
        set @IsValid = 0;
        set @Message = 'Periods must be between 1 and 1000';
        return;
    end
    
    
    declare @CalculatedPV decimal(15,2);
    
    if @InterestRate = 0
        set @CalculatedPV = @FutureValue; 
    else
        set @CalculatedPV = @FutureValue / POWER(1 + @InterestRate, @Periods);
    
    
    set @CalculatedPV = round(@CalculatedPV, 2);
    set @PVResult = @CalculatedPV;
    
    
    if abs(@PVResult - @CalculatedPV) > 0.01
    begin
        set @Message = 'Warning: Provided PV differs from calculated value by more than $0.01';
        
    end
end;


DECLARE @PV DECIMAL(15,2), @Valid BIT, @Msg VARCHAR(255);

EXEC ValidatePVCalculation 
    @FutureValue = 10000,
    @InterestRate = 0.05,
    @Periods = 5,
    @PVResult = @PV OUTPUT,
    @IsValid = @Valid OUTPUT,
    @Message = @Msg OUTPUT;

SELECT @Valid AS IsValid, @Msg AS Message_final, @PV AS CalculatedPV;

-- NPV Analysis Report--
SELECT 
    n.NPV_ID,
    u.Username,
    c.CalculationDate,
    n.InitialInvestment,
    n.DiscountRate * 100 AS DiscountRatePercentage,
    n.Cashflowperiods,
    n.NPVresults,
    CASE 
        WHEN n.NPVresults > 0 THEN 'Profitable'
        WHEN n.NPVresults = 0 THEN 'Break-even'
        ELSE 'Loss-making'
    END AS InvestmentStatus,
    n.NPVresults / NULLIF(n.InitialInvestment, 0) * 100 AS ROI_Percentage
FROM 
    NPV n
JOIN 
    Calculations c ON n.CalculationsCalculation_ID = c.Calculation_ID
JOIN 
    SystemUser u ON c.SystemUser_ID = u.ID
ORDER BY 
    c.CalculationDate DESC;

exec RegisterUser
	@username = "HarisKhan",
	@password = "HarisKhan@1",
	@fullname = "Muhammad Haris Khan",
	@Email = 'haris.khan@finance.com',
    @Role = 'User';

select * from SystemUser
group by user_role;
