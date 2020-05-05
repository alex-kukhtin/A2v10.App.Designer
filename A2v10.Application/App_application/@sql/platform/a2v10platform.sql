﻿/*
version: 10.0.7650
generated: 09.04.2020 16:04:25
*/

set nocount on;
if not exists(select * from INFORMATION_SCHEMA.SCHEMATA where SCHEMA_NAME=N'a2sys')
	exec sp_executesql N'create schema a2sys';
go
-----------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA=N'a2sys' and TABLE_NAME=N'Versions')
	create table a2sys.Versions
	(
		Module sysname not null constraint PK_Versions primary key,
		[Version] int null,
		[Title] nvarchar(255),
		[File] nvarchar(255)
	);
go
----------------------------------------------
if exists(select * from a2sys.Versions where [Module]=N'script:segment')
	update a2sys.Versions set [Version]=7650, [File]=N'a2v10platform.sql', Title=null where [Module]=N'script:segment';
else
	insert into a2sys.Versions([Module], [Version], [File], Title) values (N'script:segment', 7650, N'a2v10platform.sql', null);
go



/* a2v10platform.sql */

/*
Copyright © 2008-2019 Alex Kukhtin

Last updated : 21 dec 2019
module version : 7052
*/
------------------------------------------------
set nocount on;
if not exists(select * from INFORMATION_SCHEMA.SCHEMATA where SCHEMA_NAME=N'a2sys')
begin
	exec sp_executesql N'create schema a2sys';
end
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA=N'a2sys' and TABLE_NAME=N'Versions')
begin
	create table a2sys.Versions
	(
		Module sysname not null constraint PK_Versions primary key,
		[Version] int null,
		[Title] nvarchar(255),
		[File] nvarchar(255)
	);
end
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA=N'a2sys' and TABLE_NAME=N'Versions' and COLUMN_NAME=N'Title')
begin
	alter table a2sys.Versions add [Title] nvarchar(255) null;
	alter table a2sys.Versions add [File] nvarchar(255) null;
end
go
------------------------------------------------
if not exists(select * from a2sys.Versions where Module = N'std:system')
	insert into a2sys.Versions (Module, [Version]) values (N'std:system', 7052);
else
	update a2sys.Versions set [Version] = 7052 where Module = N'std:system';
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA=N'a2sys' and TABLE_NAME=N'SysParams')
begin
	create table a2sys.SysParams
	(
		Name sysname not null constraint PK_SysParams primary key,
		StringValue nvarchar(255) null,
		IntValue int null,
		DateValue datetime null
	);
end
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA=N'a2sys' and TABLE_NAME=N'SysParams' and COLUMN_NAME=N'DateValue')
begin
	alter table a2sys.SysParams add DateValue datetime null;
end
go
------------------------------------------------
if exists (select * from sys.objects where object_id = object_id(N'a2sys.fn_trimtime') and type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	drop function a2sys.fn_trimtime;
go
------------------------------------------------
create function a2sys.fn_trimtime(@dt datetime)
returns datetime
as
begin
	declare @ret datetime;
	declare @f float;
	set @f = cast(@dt as float)
	declare @i int;
	set @i = cast(@f as int);
	set @ret = cast(@i as datetime);
	return @ret;
end
go
------------------------------------------------
if not exists (select * from sys.objects where object_id = object_id(N'a2sys.fn_getCurrentDate') and type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
exec sp_executesql N'
create function a2sys.fn_getCurrentDate() 
returns datetime 
as begin return getdate(); end';
go
------------------------------------------------
if exists (select * from sys.objects where object_id = object_id(N'a2sys.fn_trim') and type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	drop function a2sys.fn_trim;
go
------------------------------------------------
create function a2sys.fn_trim(@value nvarchar(max))
returns nvarchar(max)
as
begin
	return ltrim(rtrim(@value));
end
go
------------------------------------------------
if exists (select * from sys.objects where object_id = object_id(N'a2sys.fn_string2table') and type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	drop function a2sys.fn_string2table;
go
------------------------------------------------
create function a2sys.fn_string2table(@var nvarchar(max), @delim nchar(1))
	returns @ret table(VAL nvarchar(max))
as
begin
	select @var = @var + @delim; -- sure delim

	declare @pos int, @start int;
	declare @sub nvarchar(255);

	set @start = 1;
	set @pos   = charindex(@delim, @var, @start);

	while @pos <> 0
		begin
			set @sub = ltrim(rtrim(substring(@var, @start, @pos-@start)));

			if @sub <> N''
				insert into @ret(VAL) values (@sub);

			set @start = @pos + 1;
			set @pos   = charindex(@delim, @var, @start);
		end
	return;
end
go
------------------------------------------------
if exists (select * from sys.objects where object_id = object_id(N'a2sys.fn_string2table_count') and type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	drop function a2sys.fn_string2table_count;
go
------------------------------------------------
create function a2sys.fn_string2table_count(@var nvarchar(max), @count int)
	returns @ret table(RowNo int, VAL nvarchar(max))
as
begin

	declare @start int;
	declare @RowNo int;
	declare @sub nvarchar(255);

	set @start = 1;
	set @RowNo = 1;

	while @start <= len(@var)
		begin
			set @sub = substring(@var, @start, @count);

			if @sub <> N''
				insert into @ret(RowNo, VAL) values (@RowNo, @sub);

			set @start = @start + @count;
			set @RowNo = @RowNo + 1;
		end
	return;
end
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.DOMAINS where DOMAIN_SCHEMA=N'a2sys' and DOMAIN_NAME=N'Id.TableType' and DATA_TYPE=N'table type')
begin
	create type a2sys.[Id.TableType]
	as table(
		Id bigint null
	);
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2sys' and ROUTINE_NAME=N'GetVersions')
	drop procedure a2sys.[GetVersions]
go
------------------------------------------------
create procedure a2sys.[GetVersions]
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;
	select [Module], [Version], [File], [Title] from a2sys.Versions;
end
go
------------------------------------------------
begin
	set nocount on;
	grant execute on schema ::a2sys to public;
end
go
------------------------------------------------
go


/*
------------------------------------------------
Copyright © 2008-2019 Alex Kukhtin

Last updated : 23 dec 2019
module version : 7598
*/
------------------------------------------------
begin
	set nocount on;
	if not exists(select * from a2sys.Versions where Module = N'std:security')
		insert into a2sys.Versions (Module, [Version]) values (N'std:security', 7598);
	else
		update a2sys.Versions set [Version] = 7598 where Module = N'std:security';
end
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.SCHEMATA where SCHEMA_NAME=N'a2security')
begin
	exec sp_executesql N'create schema a2security';
end
go
------------------------------------------------
-- a2security schema
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.SEQUENCES where SEQUENCE_SCHEMA=N'a2security' and SEQUENCE_NAME=N'SQ_Tenants')
	create sequence a2security.SQ_Tenants as bigint start with 100 increment by 1;
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA=N'a2security' and TABLE_NAME=N'Tenants')
begin
	create table a2security.Tenants
	(
		Id	int not null constraint PK_Tenants primary key
			constraint DF_Tenants_PK default(next value for a2security.SQ_Tenants),
		[Admin] bigint null, -- admin user ID
		[Source] nvarchar(255) null,
		[TransactionCount] bigint not null constraint DF_Tenants_TransactionCount default(0),
		LastTransactionDate datetime null,
		DateCreated datetime not null constraint DF_Tenants_UtcDateCreated2 default(a2sys.fn_getCurrentDate()),
		TrialPeriodExpired datetime null,
		DataSize float null,
		[State] nvarchar(128) null,
		UserSince datetime null,
		LastPaymentDate datetime null,
		Balance money null
	);
end
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA=N'a2security' and TABLE_NAME=N'Config')
begin
	create table a2security.Config
	(
		[Key] sysname not null constraint PK_Config primary key,
		[Value] nvarchar(255) not null,
	);
end
go
------------------------------------------------
if not exists (select * from sys.indexes where object_id = object_id(N'a2security.Tenants') and name = N'IX_Tenants_Admin')
	create index IX_Tenants_Admin on a2security.Tenants ([Admin]) include (Id);
go
------------------------------------------------
if exists(select * from sys.default_constraints where name=N'DF_Tenants_UtcDateCreated' and parent_object_id = object_id(N'a2security.Tenants'))
begin
	alter table a2security.Tenants drop constraint DF_Tenants_UtcDateCreated;
	alter table a2security.Tenants add constraint DF_Tenants_UtcDateCreated2 default(a2sys.fn_getCurrentDate()) for DateCreated with values;
end
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA=N'a2security' and TABLE_NAME=N'Tenants' and COLUMN_NAME=N'TransactionCount')
begin
	alter table a2security.Tenants add [TransactionCount] bigint not null constraint DF_Tenants_TransactionCount default(0);
end
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA=N'a2security' and TABLE_NAME=N'Tenants' and COLUMN_NAME=N'TrialPeriodExpired')
begin
	alter table a2security.Tenants add TrialPeriodExpired datetime null;
end
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA=N'a2security' and TABLE_NAME=N'Tenants' and COLUMN_NAME=N'LastTransactionDate')
begin
	alter table a2security.Tenants add [LastTransactionDate] datetime null;
end
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA=N'a2security' and TABLE_NAME=N'Tenants' and COLUMN_NAME=N'LastPaymentDate')
begin
	alter table a2security.Tenants add LastPaymentDate datetime null;
end
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA=N'a2security' and TABLE_NAME=N'Tenants' and COLUMN_NAME=N'Balance')
begin
	alter table a2security.Tenants add Balance money null;
end
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA=N'a2security' and TABLE_NAME=N'Tenants' and COLUMN_NAME=N'DataSize')
	alter table a2security.Tenants add DataSize float null;
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA=N'a2security' and TABLE_NAME=N'Tenants' and COLUMN_NAME=N'State')
	alter table a2security.Tenants add [State] nvarchar(128) null;
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA=N'a2security' and TABLE_NAME=N'Tenants' and COLUMN_NAME=N'UserSince')
	alter table a2security.Tenants add UserSince datetime null;
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.SEQUENCES where SEQUENCE_SCHEMA=N'a2security' and SEQUENCE_NAME=N'SQ_Users')
	create sequence a2security.SQ_Users as bigint start with 100 increment by 1;
go
------------------------------------------------
if exists (select * from sys.objects where object_id = object_id(N'a2security.fn_GetCurrentSegment') and type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	drop function a2security.fn_GetCurrentSegment;
go
------------------------------------------------
create function a2security.fn_GetCurrentSegment()
returns nvarchar(32)
as
begin
	declare @ret nvarchar(32);
	select @ret = [Value] from a2security.Config where [Key] = N'CurrentSegment';
	return @ret;
end
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA=N'a2security' and TABLE_NAME=N'Users')
begin
	create table a2security.Users
	(
		Id	bigint not null constraint PK_Users primary key
			constraint DF_Users_PK default(next value for a2security.SQ_Users),
		Tenant int null 
			constraint FK_Users_Tenant_Tenants foreign key references a2security.Tenants(Id),
		UserName nvarchar(255)	not null constraint UNQ_Users_UserName unique,
		DomainUser nvarchar(255) null,
		Void bit not null constraint DF_Users_Void default(0),
		SecurityStamp nvarchar(max)	not null,
		PasswordHash nvarchar(max)	null,
		TwoFactorEnabled bit not null constraint DF_Users_TwoFactorEnabled default(0),
		Email nvarchar(255)	null,
		EmailConfirmed bit not null constraint DF_Users_EmailConfirmed default(0),
		PhoneNumber nvarchar(255) null,
		PhoneNumberConfirmed bit not null constraint DF_Users_PhoneNumberConfirmed default(0),
		LockoutEnabled	bit	not null constraint DF_Users_LockoutEnabled default(1),
		LockoutEndDateUtc datetimeoffset null,
		AccessFailedCount int not null constraint DF_Users_AccessFailedCount default(0),
		[Locale] nvarchar(32) not null constraint DF_Users_Locale default('uk_UA'),
		PersonName nvarchar(255) null,
		LastLoginDate datetime null, /*UTC*/
		LastLoginHost nvarchar(255) null,
		Memo nvarchar(255) null,
		ChangePasswordEnabled	bit	not null constraint DF_Users_ChangePasswordEnabled default(1),
		RegisterHost nvarchar(255) null,
		TariffPlan nvarchar(255) null,
		[Guid] uniqueidentifier null,
		Referral bigint null,
		Segment nvarchar(32) null,
		DateCreated datetime null
			constraint DF_Users_DateCreated default(a2sys.fn_getCurrentDate()),
	);
end
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA=N'a2security' and TABLE_NAME=N'Users' and COLUMN_NAME=N'DateCreated')
	alter table a2security.Users add DateCreated datetime null
			constraint DF_Users_DateCreated default(a2sys.fn_getCurrentDate());
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA=N'a2security' and TABLE_NAME=N'UserLogins')
begin
	create table a2security.UserLogins
	(
		[User] bigint not null 
			constraint FK_UserLogins_User_Users foreign key references a2security.Users(Id),
		[LoginProvider] nvarchar(255) not null,
		[ProviderKey] nvarchar(max) not null,
		constraint PK_UserLogins primary key([User], LoginProvider)
	);
end
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA=N'a2security' and TABLE_NAME=N'Users' and COLUMN_NAME=N'Void')
begin
	alter table a2security.Users add Void bit not null constraint DF_Users_Void default(0) with values;
end
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA=N'a2security' and TABLE_NAME=N'Users' and COLUMN_NAME=N'DomainUser')
begin
	alter table a2security.Users add DomainUser nvarchar(255) null;
end
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA=N'a2security' and TABLE_NAME=N'Users' and COLUMN_NAME=N'ChangePasswordEnabled')
begin
	alter table a2security.Users add ChangePasswordEnabled bit not null constraint DF_Users_ChangePasswordEnabled default(1) with values;
end
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA=N'a2security' and TABLE_NAME=N'Users' and COLUMN_NAME=N'LastLoginDate')
begin
	alter table a2security.Users add LastLoginDate datetime null;
	alter table a2security.Users add LastLoginHost nvarchar(255) null;
end
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA=N'a2security' and TABLE_NAME=N'Users' and COLUMN_NAME=N'RegisterHost')
begin
	alter table a2security.Users add RegisterHost nvarchar(255) null;
end
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA=N'a2security' and TABLE_NAME=N'Users' and COLUMN_NAME=N'TariffPlan')
begin
	alter table a2security.Users add TariffPlan nvarchar(255) null;
end
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA=N'a2security' and TABLE_NAME=N'Users' and COLUMN_NAME=N'Guid')
begin
	alter table a2security.Users add [Guid] uniqueidentifier null
end
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA=N'a2security' and TABLE_NAME=N'Users' and COLUMN_NAME=N'Referral')
begin
	alter table a2security.Users add Referral bigint null;
end
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA=N'a2security' and TABLE_NAME=N'Users' and COLUMN_NAME=N'Segment')
begin
	alter table a2security.Users add Segment nvarchar(32) null;
end
go
------------------------------------------------
if not exists (select * from sys.indexes where object_id = object_id(N'a2security.Users') and name = N'UNQ_Users_DomainUser')
	create unique index UNQ_Users_DomainUser on a2security.Users(DomainUser) where DomainUser is not null;
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA=N'a2security' and TABLE_NAME=N'Users' and COLUMN_NAME=N'Tenant')
begin
	alter table a2security.Users add Tenant int null 
			constraint FK_Users_Tenant_Tenants foreign key references a2security.Tenants(Id);
end
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.SEQUENCES where SEQUENCE_SCHEMA=N'a2security' and SEQUENCE_NAME=N'SQ_Groups')
	create sequence a2security.SQ_Groups as bigint start with 100 increment by 1;
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA=N'a2security' and TABLE_NAME=N'Groups')
begin
	create table a2security.Groups
	(
		Id	bigint not null constraint PK_Groups primary key
			constraint DF_Groups_PK default(next value for a2security.SQ_Groups),
		Void bit not null constraint DF_Groups_Void default(0),				
		[Name] nvarchar(255) not null constraint UNQ_Groups_Name unique,
		[Key] nvarchar(255) null,
		Memo nvarchar(255) null
	)
end
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA=N'a2security' and TABLE_NAME=N'Groups' and COLUMN_NAME=N'Void')
begin
	alter table a2security.Groups add Void bit not null constraint DF_Groups_Void default(0) with values;
end
go
------------------------------------------------
if not exists (select * from sys.indexes where object_id = object_id(N'a2security.Groups') and name = N'UNQ_Group_Key')
	create unique index UNQ_Group_Key on a2security.Groups([Key]) where [Key] is not null;
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA=N'a2security' and TABLE_NAME=N'UserGroups')
begin
	-- user groups
	create table a2security.UserGroups
	(
		UserId	bigint	not null
			constraint FK_UserGroups_UsersId_Users foreign key references a2security.Users(Id),
		GroupId bigint	not null
			constraint FK_UserGroups_GroupId_Groups foreign key references a2security.Groups(Id),
		constraint PK_UserGroups primary key(UserId, GroupId)
	)
end
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.SEQUENCES where SEQUENCE_SCHEMA=N'a2security' and SEQUENCE_NAME=N'SQ_Roles')
	create sequence a2security.SQ_Roles as bigint start with 100 increment by 1;
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA=N'a2security' and TABLE_NAME=N'Roles')
begin
	create table a2security.Roles
	(
		Id	bigint not null constraint PK_Roles primary key
			constraint DF_Roles_PK default(next value for a2security.SQ_Roles),
		Void bit not null constraint DF_Roles_Void default(0),				
		[Name] nvarchar(255) not null constraint UNQ_Roles_Name unique,
		[Key] nvarchar(255) null,
		Memo nvarchar(255) null
	)
end
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA=N'a2security' and TABLE_NAME=N'Roles' and COLUMN_NAME=N'Void')
begin
	alter table a2security.Roles add Void bit not null constraint DF_Roles_Void default(0) with values;
end
go
------------------------------------------------
if not exists (select * from sys.indexes where object_id = object_id(N'a2security.Roles') and name = N'UNQ_Role_Key')
	create unique index UNQ_Role_Key on a2security.Roles([Key]) where [Key] is not null;
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.SEQUENCES where SEQUENCE_SCHEMA=N'a2security' and SEQUENCE_NAME=N'SQ_UserRoles')
	create sequence a2security.SQ_UserRoles as bigint start with 100 increment by 1;
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA=N'a2security' and TABLE_NAME=N'UserRoles')
begin
	create table a2security.UserRoles
	(
		Id	bigint	not null constraint PK_UserRoles primary key
			constraint DF_UserRoles_PK default(next value for a2security.SQ_UserRoles),
		RoleId bigint null
			constraint FK_UserRoles_RoleId_Roles foreign key references a2security.Roles(Id),
		UserId	bigint	null
			constraint FK_UserRoles_UserId_Users foreign key references a2security.Users(Id),
		GroupId bigint null 
			constraint FK_UserRoles_GroupId_Groups foreign key references a2security.Groups(Id)
	)
end
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.SEQUENCES where SEQUENCE_SCHEMA=N'a2security' and SEQUENCE_NAME=N'SQ_Acl')
	create sequence a2security.SQ_Acl as bigint start with 100 increment by 1;
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA=N'a2security' and TABLE_NAME=N'Acl')
begin
	-- access control list
	create table a2security.[Acl]
	(
		Id	bigint not null constraint PK_Acl primary key
			constraint DF_Acl_PK default(next value for a2security.SQ_Acl),
		[Object] sysname not null,
		[ObjectId] bigint not null,
		UserId bigint null 
			constraint FK_Acl_UserId_Users foreign key references a2security.Users(Id),
		GroupId bigint null 
			constraint FK_Acl_GroupId_Groups foreign key references a2security.Groups(Id),
		CanView smallint not null	-- 0
			constraint CK_Acl_CanView check(CanView in (0, 1, -1))
			constraint DF_Acl_CanView default(0),
		CanEdit smallint not null	-- 1
			constraint CK_Acl_CanEdit check(CanEdit in (0, 1, -1))
			constraint DF_Acl_CanEdit default(0),
		CanDelete smallint not null	-- 2
			constraint CK_Acl_CanDelete check(CanDelete in (0, 1, -1))
			constraint DF_Acl_CanDelete default(0),
		CanApply smallint not null	-- 3
			constraint CK_Acl_CanApply check(CanApply in (0, 1, -1))
			constraint DF_Acl_CanApply default(0)
	);
end
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA=N'a2security' and TABLE_NAME=N'LogCodes')
begin
	create table a2security.[LogCodes]
	(
		Code int not null constraint PK_LogCodes primary key,
		[Name] nvarchar(32) not null
	);
end
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA=N'a2security' and TABLE_NAME=N'Log')
begin
	create table a2security.[Log]
	(
		Id	bigint not null identity(100, 1) constraint PK_Log primary key,
		UserId bigint not null
			constraint FK_Log_UserId_Users foreign key references a2security.Users(Id),
		Code int not null
			constraint FK_Log_Code_Codes foreign key references a2security.LogCodes(Code),
		EventTime	datetime not null
			constraint DF_Log_EventTime2 default(a2sys.fn_getCurrentDate()),
		Severity nchar(1) not null,
		[Message] nvarchar(max) sparse null
	);
end
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA=N'a2security' and TABLE_NAME=N'Log' and COLUMN_NAME=N'Code')
begin
	alter table a2security.[Log] add Code int not null
		constraint FK_Log_Code_Codes foreign key references a2security.LogCodes(Code);
end
go
------------------------------------------------
if exists(select * from sys.default_constraints where name=N'DF_Log_UtcEventTime' and parent_object_id = object_id(N'a2security.Log'))
begin
	alter table a2security.[Log] drop constraint DF_Log_UtcEventTime;
	alter table a2security.[Log] add constraint DF_Log_EventTime2 default(a2sys.fn_getCurrentDate()) for EventTime with values;
end
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.SEQUENCES where SEQUENCE_SCHEMA=N'a2security' and SEQUENCE_NAME=N'SQ_Referrals')
	create sequence a2security.SQ_Referrals as bigint start with 1000 increment by 1;
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA=N'a2security' and TABLE_NAME=N'Referrals')
begin
	create table a2security.Referrals
	(
		Id	bigint not null constraint PK_Referrals primary key
			constraint DF_Referrals_PK default(next value for a2security.SQ_Referrals),
		Void bit not null constraint DF_Referrals_Void default(0),				
		[Type] nchar(1) not null, /* (S)ystem, (C)ustomer */
		[Link] nvarchar(255) not null constraint UNQ_Referrals_Link unique,
		UserCreated bigint not null
			constraint FK_Referrals_UserCreated_Users foreign key references a2security.Users(Id),
		DateCreated	datetime not null
			constraint DF_Referrals_DateCreated2 default(a2sys.fn_getCurrentDate()),
		Memo nvarchar(255) null
	)
end
go
------------------------------------------------
if exists(select * from sys.default_constraints where name=N'DF_License_UtcDateCreated' and parent_object_id = object_id(N'a2security.Referrals'))
begin
	alter table a2security.Referrals drop constraint DF_Referrals_DateCreated;
	alter table a2security.Referrals add constraint DF_Referrals_DateCreated2 default(a2sys.fn_getCurrentDate()) for DateCreated with values;
end
go

------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS where CONSTRAINT_SCHEMA = N'a2security' and CONSTRAINT_NAME = N'FK_Users_Referral_Referrals')
begin
	alter table a2security.Users add constraint FK_Users_Referral_Referrals foreign key (Referral) references a2security.Referrals(Id);
end
go
------------------------------------------------
if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_SCHEMA=N'a2security' and TABLE_NAME=N'ViewUsers')
begin
	drop view a2security.ViewUsers;
end
go
------------------------------------------------
create view a2security.ViewUsers
as
	select Id, UserName, DomainUser, PasswordHash, SecurityStamp, Email, PhoneNumber,
		LockoutEnabled, AccessFailedCount, LockoutEndDateUtc, TwoFactorEnabled, [Locale],
		PersonName, Memo, Void, LastLoginDate, LastLoginHost, Tenant, EmailConfirmed,
		PhoneNumberConfirmed, RegisterHost, ChangePasswordEnabled, TariffPlan, Segment,
		IsAdmin = cast(case when ug.GroupId = 77 /*predefined*/ then 1 else 0 end as bit),
		IsTenantAdmin = cast(case when exists(select * from a2security.Tenants where [Admin] = u.Id) then 1 else 0 end as bit)
	from a2security.Users u
		left join a2security.UserGroups ug on u.Id = ug.UserId and ug.GroupId=77
	where Void=0 and Id <> 0;
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2security' and ROUTINE_NAME=N'WriteLog')
	drop procedure a2security.[WriteLog]
go
------------------------------------------------
create procedure [a2security].[WriteLog]
	@UserId bigint = null,
	@SeverityChar nchar(1),
	@Code int = null,
	@Message nvarchar(max) = null
as
begin
	set nocount on;
	set transaction isolation level read committed;
	set xact_abort on;
	insert into a2security.[Log] (UserId, Severity, [Code] , [Message]) 
		values (isnull(@UserId, 0 /*system user*/), @SeverityChar, @Code, @Message);
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2security' and ROUTINE_NAME=N'FindUserById')
	drop procedure a2security.FindUserById
go
------------------------------------------------
create procedure a2security.FindUserById
@Id bigint
as
begin
	set nocount on;
	select * from a2security.ViewUsers where Id=@Id;
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2security' and ROUTINE_NAME=N'FindUserByName')
	drop procedure a2security.FindUserByName
go
------------------------------------------------
create procedure a2security.FindUserByName
@UserName nvarchar(255)
as
begin
	set nocount on;
	select * from a2security.ViewUsers with(nolock)
	where UserName=@UserName;
end
go

------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2security' and ROUTINE_NAME=N'FindUserByEmail')
	drop procedure a2security.FindUserByEmail
go
------------------------------------------------
create procedure a2security.FindUserByEmail
@Email nvarchar(255)
as
begin
	set nocount on;
	select * from a2security.ViewUsers with(nolock)
	where Email=@Email;
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2security' and ROUTINE_NAME=N'FindUserByPhoneNumber')
	drop procedure a2security.FindUserByPhoneNumber
go
------------------------------------------------
create procedure a2security.FindUserByPhoneNumber
@PhoneNumber nvarchar(255)
as
begin
	set nocount on;
	select * from a2security.ViewUsers with(nolock)
	where PhoneNumber=@PhoneNumber;
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2security' and ROUTINE_NAME=N'FindUserByLogin')
	drop procedure a2security.FindUserByLogin
go
------------------------------------------------
create procedure a2security.[FindUserByLogin]
@LoginProvider nvarchar(255),
@ProviderKey nvarchar(max)
as
begin
	set nocount on;
	declare @UserId bigint;
	select @UserId = [User] from a2security.UserLogins where LoginProvider = @LoginProvider and ProviderKey = @ProviderKey;
	select * from a2security.ViewUsers with(nolock)
	where Id=@UserId;
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2security' and ROUTINE_NAME=N'AddUserLogin')
	drop procedure a2security.[AddUserLogin]
go
------------------------------------------------
create procedure a2security.AddUserLogin
@UserId bigint,
@LoginProvider nvarchar(255),
@ProviderKey nvarchar(max)
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;
	if not exists(select * from a2security.UserLogins where [User]=@UserId and LoginProvider=@LoginProvider)
	begin
		insert into a2security.UserLogins([User], [LoginProvider], [ProviderKey]) 
			values (@UserId, @LoginProvider, @ProviderKey);
	end
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2security' and ROUTINE_NAME=N'UpdateUserPassword')
	drop procedure a2security.UpdateUserPassword
go
------------------------------------------------
create procedure a2security.UpdateUserPassword
@Id bigint,
@PasswordHash nvarchar(max),
@SecurityStamp nvarchar(max)
as
begin
	set nocount on;
	set transaction isolation level read committed;
	set xact_abort on;
	update a2security.ViewUsers set PasswordHash = @PasswordHash, SecurityStamp = @SecurityStamp where Id=@Id;
	exec a2security.[WriteLog] @Id, N'I', 15; /*PasswordUpdated*/
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2security' and ROUTINE_NAME=N'UpdateUserLockout')
	drop procedure a2security.UpdateUserLockout
go
------------------------------------------------
create procedure a2security.UpdateUserLockout
@Id bigint,
@AccessFailedCount int,
@LockoutEndDateUtc datetimeoffset
as
begin
	set nocount on;
	set transaction isolation level read committed;
	set xact_abort on;
	update a2security.ViewUsers set 
		AccessFailedCount = @AccessFailedCount, LockoutEndDateUtc = @LockoutEndDateUtc
	where Id=@Id;
	declare @msg nvarchar(255);
	set @msg = N'AccessFailedCount: ' + cast(@AccessFailedCount as nvarchar(255));
	exec a2security.[WriteLog] @Id, N'E', 18, /*AccessFailedCount*/ @msg;
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2security' and ROUTINE_NAME=N'UpdateUserLogin')
	drop procedure a2security.UpdateUserLogin
go
------------------------------------------------
create procedure a2security.UpdateUserLogin
@Id bigint,
@LastLoginDate datetime,
@LastLoginHost nvarchar(255)
as
begin
	set nocount on;
	set transaction isolation level read committed;
	set xact_abort on;
	update a2security.ViewUsers set LastLoginDate = @LastLoginDate, LastLoginHost = @LastLoginHost where Id=@Id;
	exec a2security.[WriteLog] @Id, N'I', 1; /*Login*/
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2security' and ROUTINE_NAME=N'ConfirmEmail')
	drop procedure a2security.ConfirmEmail
go
------------------------------------------------
create procedure a2security.ConfirmEmail
@Id bigint
as
begin
	set nocount on;
	set transaction isolation level read committed;
	set xact_abort on;

	update a2security.ViewUsers set EmailConfirmed = 1 where Id=@Id;

	declare @msg nvarchar(255);
	select @msg = N'Email: ' + Email from a2security.ViewUsers where Id=@Id;
	exec a2security.[WriteLog] @Id, N'I', 26, /*EmailConfirmed*/ @msg;
end
go

------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2security' and ROUTINE_NAME=N'ConfirmPhoneNumber')
	drop procedure a2security.ConfirmPhoneNumber
go
------------------------------------------------
create procedure a2security.ConfirmPhoneNumber
@Id bigint,
@PhoneNumber nvarchar(255),
@PhoneNumberConfirmed bit,
@SecurityStamp nvarchar(max)
as
begin
	set nocount on;
	set transaction isolation level read committed;
	set xact_abort on;
	update a2security.ViewUsers set PhoneNumber = @PhoneNumber,
		PhoneNumberConfirmed = @PhoneNumberConfirmed, SecurityStamp=@SecurityStamp
	where Id=@Id;

	declare @msg nvarchar(255);
	set @msg = N'PhoneNumber: ' + @PhoneNumber;
	exec a2security.[WriteLog] @Id, N'I', 27, /*PhoneNumberConfirmed*/ @msg;
end
go

------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2security' and ROUTINE_NAME=N'GetUserGroups')
	drop procedure a2security.GetUserGroups
go
------------------------------------------------
create procedure a2security.GetUserGroups
@UserId bigint
as
begin
	set nocount on;
	select g.Id, g.[Name], g.[Key]
	from a2security.UserGroups ug
		inner join a2security.Groups g on ug.GroupId = g.Id
	where ug.UserId = @UserId and g.Void=0;
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2security' and ROUTINE_NAME=N'Permission.UpdateUserInfo')
	drop procedure [a2security].[Permission.UpdateUserInfo]
go
------------------------------------------------
create procedure [a2security].[Permission.UpdateUserInfo]
as
begin
	set nocount on;
	declare @procName sysname;
	declare @sqlProc sysname;
	declare #tmpcrs cursor local fast_forward read_only for
		select ROUTINE_NAME from INFORMATION_SCHEMA.ROUTINES 
			where ROUTINE_SCHEMA = N'a2security' and ROUTINE_NAME like N'Permission.UpdateAcl.%';
	open #tmpcrs;
	fetch next from #tmpcrs into @procName;
	while @@fetch_status = 0
	begin
		set @sqlProc = N'a2security.[' + @procName + N']';
		exec sp_executesql @sqlProc;
		fetch next from #tmpcrs into @procName;
	end
	close #tmpcrs;
	deallocate #tmpcrs;
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2security' and ROUTINE_NAME=N'CreateUser')
	drop procedure a2security.CreateUser
go
------------------------------------------------
create procedure a2security.CreateUser
@UserName nvarchar(255),
@PasswordHash nvarchar(max) = null,
@SecurityStamp nvarchar(max),
@Email nvarchar(255) = null,
@PhoneNumber nvarchar(255) = null,
@Tenant int = null,
@PersonName nvarchar(255) = null,
@RegisterHost nvarchar(255) = null,
@Memo nvarchar(255) = null,
@TariffPlan nvarchar(255) = null,
@RetId bigint output
as
begin
-- from account/register only
	set nocount on;
	set transaction isolation level read committed;
	set xact_abort on;
	
	declare @userId bigint; 

	if @Tenant = -1
	begin
		declare @tenants table(id int);
		declare @users table(id bigint);
		declare @tenantId int;

		begin tran;
		insert into a2security.Tenants([Admin])
			output inserted.Id into @tenants(id)
			values (null);

		select top(1) @tenantId = id from @tenants;

		insert into a2security.ViewUsers(UserName, PasswordHash, SecurityStamp, Email, PhoneNumber, Tenant, PersonName, 
			RegisterHost, Memo, TariffPlan, Segment)
			output inserted.Id into @users(id)
			values (@UserName, @PasswordHash, @SecurityStamp, @Email, @PhoneNumber, @tenantId, @PersonName, 
				@RegisterHost, @Memo, @TariffPlan, a2security.fn_GetCurrentSegment());
		select top(1) @userId = id from @users;

		update a2security.Tenants set [Admin]=@userId where Id=@tenantId;

		insert into a2security.UserGroups(UserId, GroupId) values (@userId, 1 /*all users*/);

		if exists(select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA = N'a2security' and ROUTINE_NAME=N'OnCreateNewUser')
		begin
			declare @sql nvarchar(255);
			declare @prms nvarchar(255);
			set @sql = N'a2security.OnCreateNewUser @TenantId, @CompanyId, @UserId';
			set @prms = N'@TenantId int, @CompanyId bigint, @UserId bigint';
			exec sp_executesql @sql, @prms, @tenantId, 1, @userId;
		end

		commit tran;
	end
	else
	begin
		begin tran;

		insert into a2security.ViewUsers(UserName, PasswordHash, SecurityStamp, Email, PhoneNumber, PersonName, RegisterHost, Memo, TariffPlan)
			output inserted.Id into @users(id)
			values (@UserName, @PasswordHash, @SecurityStamp, @Email, @PhoneNumber, @PersonName, @RegisterHost, @Memo, @TariffPlan);
		select top(1) @userId = id from @users;

		insert into a2security.UserGroups(UserId, GroupId) values (@userId, 1 /*all users*/);
		commit tran;

		exec a2security.[Permission.UpdateUserInfo];

	end
	set @RetId = @userId;

	declare @msg nvarchar(255);
	set @msg = N'User: ' + @UserName;
	exec a2security.[WriteLog] @RetId, N'I', 2, /*UserCreated*/ @msg;
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2security' and ROUTINE_NAME=N'User.ChangePassword.Load')
	drop procedure a2security.[User.ChangePassword.Load]
go
------------------------------------------------
create procedure a2security.[User.ChangePassword.Load]
	@TenantId int = 0,
	@UserId bigint
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	if 1 <> (select ChangePasswordEnabled from a2security.Users where Id=@UserId)
	begin
		raiserror (N'UI:@[ChangePasswordDisabled]', 16, -1) with nowait;
	end
	select [User!TUser!Object] = null, [Id!!Id] = Id, [Name!!Name] = UserName, 
		[OldPassword] = cast(null as nvarchar(255)),
		[NewPassword] = cast(null as nvarchar(255)),
		[ConfirmPassword] = cast(null as nvarchar(255)) 
	from a2security.Users where Id=@UserId;
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2security' and ROUTINE_NAME=N'Login.CheckDuplicate')
	drop procedure a2security.[Login.CheckDuplicate]
go
------------------------------------------------
create procedure a2security.[Login.CheckDuplicate]
	@TenantId int = null,
	@UserId bigint,
	@Id bigint,
	@CompanyId bigint = 1,
	@Login nvarchar(255) = null
as
begin
	set nocount on;
	declare @valid bit = 1;
	if exists(select * from a2security.Users where UserName = @Login and Id <> @Id)
		set @valid = 0;
	select [Result!TResult!Object] = null, [Value] = @valid;
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2security' and ROUTINE_NAME=N'PhoneNumber.CheckDuplicate')
	drop procedure a2security.[PhoneNumber.CheckDuplicate]
go
------------------------------------------------
create procedure a2security.[PhoneNumber.CheckDuplicate]
	@TenantId int = null,
	@UserId bigint,
	@Id bigint,
	@CompanyId bigint = 1,
	@PhoneNumber nvarchar(255) = null
as
begin
	set nocount on;
	declare @valid bit = 1;
	if exists(select * from a2security.Users where PhoneNumber = @PhoneNumber and Id <> @Id)
		set @valid = 0;
	select [Result!TResult!Object] = null, [Value] = @valid;
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2security' and ROUTINE_NAME=N'UserStateInfo.Load')
	drop procedure a2security.[UserStateInfo.Load]
go
------------------------------------------------
create procedure a2security.[UserStateInfo.Load]
@TenantId int = null,
@UserId bigint
as
begin
	select [UserState!TUserState!Object] = null;
end
go
------------------------------------------------
begin
	set nocount on;
	declare @codes table (Code int, [Name] nvarchar(32))

	insert into @codes(Code, [Name])
	values
		(1,  N'Login'		        ), 
		(2,  N'UserCreated'         ), 
		(3,  N'TeantUserCreated'    ), 
		(15, N'PasswordUpdated'     ), 
		(18, N'AccessFailedCount'   ), 
		(26, N'EmailConfirmed'      ), 
		(27, N'PhoneNumberConfirmed');

	merge into a2security.[LogCodes] t
	using @codes s on s.Code = t.Code
	when matched then update set
		[Name]=s.[Name]
	when not matched by target then insert 
		(Code, [Name]) values (s.Code, s.[Name])
	when not matched by source then delete;
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2security' and ROUTINE_NAME=N'SaveReferral')
	drop procedure a2security.SaveReferral
go
------------------------------------------------
create procedure a2security.SaveReferral
@UserId bigint,
@Referral nvarchar(255)
as
begin
	set nocount on;
	set transaction isolation level read committed;
	set xact_abort on;
	declare @refid bigint;
	select @refid = Id from a2security.Referrals where lower(Link) = lower(@Referral);
	if @refid is not null
		update a2security.Users set Referral = @refid where Id=@UserId;
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2security' and ROUTINE_NAME=N'DeleteUser')
	drop procedure a2security.DeleteUser
go
------------------------------------------------
create procedure a2security.DeleteUser
@CurrentUser bigint,
@Tenant bigint,
@Id bigint
as
begin
	set nocount on;
	set transaction isolation level serializable;
	set xact_abort on;
	declare @TenantAdmin bigint;
	select @TenantAdmin = [Admin] from a2security.Tenants where Id = @Tenant;
	if @TenantAdmin <> @CurrentUser
	begin
		raiserror(N'Invalid teanant administrator', 16, 1);
		return;
	end
	if @TenantAdmin = @Id
	begin
		raiserror(N'Unable to delete tenant administrator', 16, 1);
		return;
	end
	begin try
		begin tran
		delete from a2security.UserRoles where UserId = @Id;
		delete from a2security.UserGroups where UserId = @Id;
		delete from a2security.[Menu.Acl] where UserId = @Id;
		delete from a2security.[Log] where UserId = @Id;
		delete from a2security.Users where Tenant = @Tenant and Id = @Id;
		commit tran
	end try
	begin catch
		if @@trancount > 0
		begin
			rollback tran;
		end
		declare @msg nvarchar(255);
		set @msg = error_message();
		raiserror(@msg, 16, 1);
	end catch
end
go
------------------------------------------------
set nocount on;
begin
	-- predefined users and groups
	if not exists(select * from a2security.Users where Id = 0)
		insert into a2security.Users (Id, UserName, SecurityStamp) values (0, N'System', N'System');
	if not exists(select * from a2security.Groups where Id = 1)
		insert into a2security.Groups(Id, [Key], [Name]) values (1, N'Users', N'@[AllUsers]');
	if not exists(select * from a2security.Groups where Id = 77)
		insert into a2security.Groups(Id, [Key], [Name]) values (77, N'Admins', N'@[AdminUsers]');
end
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA=N'a2security' and TABLE_NAME=N'License')
begin
	create table a2security.License
	(
		[Text] nvarchar(max) not null,
		DateCreated datetime not null constraint DF_License_DateCreated2 default(a2sys.fn_getCurrentDate()),
		DateModified datetime not null constraint DF_License_DateModified2 default (a2sys.fn_getCurrentDate())
	);
end
go
------------------------------------------------
if exists(select * from sys.default_constraints where name=N'DF_License_UtcDateCreated' and parent_object_id = object_id(N'a2security.License'))
begin
	alter table a2security.License drop constraint DF_License_UtcDateCreated;
	alter table a2security.License add constraint DF_License_DateCreated2 default(a2sys.fn_getCurrentDate()) for DateCreated with values;
end
go
------------------------------------------------
if exists(select * from sys.default_constraints where name=N'DF_License_UtcDateModified' and parent_object_id = object_id(N'a2security.License'))
begin
	alter table a2security.License drop constraint DF_License_UtcDateModified;
	alter table a2security.License add constraint DF_License_DateModified2 default(a2sys.fn_getCurrentDate()) for DateModified with values;
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2security' and ROUTINE_NAME=N'License.Load')
	drop procedure a2security.[License.Load]
go
------------------------------------------------
create procedure a2security.[License.Load]
as
begin
	set nocount on;
	select [Text] from a2security.License;
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2security' and ROUTINE_NAME=N'License.Update')
	drop procedure a2security.[License.Update]
go
------------------------------------------------
create procedure a2security.[License.Update]
@License nvarchar(max)
as
begin
	set nocount on;
	if exists(select * from a2security.License)
		update a2security.License set [Text]=@License, DateModified = a2sys.fn_getCurrentDate();
	else
		insert into a2security.License ([Text]) values (@License);
end
go
------------------------------------------------
begin
	set nocount on;
	grant execute on schema ::a2security to public;
end
go


/*
Copyright © 2008-2019 Alex Kukhtin

Last updated : 21 dec 2019
module version : 7053
*/
------------------------------------------------
begin
	set nocount on;
	if not exists(select * from a2sys.Versions where Module = N'std:messaging')
		insert into a2sys.Versions (Module, [Version]) values (N'std:messaging', 7053);
	else
		update a2sys.Versions set [Version] = 7053 where Module = N'std:messaging';
end
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.SCHEMATA where SCHEMA_NAME=N'a2messaging')
begin
	exec sp_executesql N'create schema a2messaging';
end
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.SEQUENCES where SEQUENCE_SCHEMA=N'a2messaging' and SEQUENCE_NAME=N'SQ_Messages')
	create sequence a2messaging.SQ_Messages as bigint start with 100 increment by 1;
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA=N'a2messaging' and TABLE_NAME=N'Messages')
begin
	create table a2messaging.[Messages]
	(
		Id	bigint	not null constraint PK_Messages primary key
			constraint DF_Messages_PK default(next value for a2messaging.SQ_Messages),
		Template nvarchar(255) not null,
		[Key] nvarchar(255) not null,
		TargetId bigint null,
		[Source] nvarchar(255) null,
		DateCreated datetime not null constraint DF_Messages_DateCreated2 default(a2sys.fn_getCurrentDate())
	);
end
go
------------------------------------------------
if exists(select * from sys.default_constraints where name=N'DF_Processes_UtcDateCreated' and parent_object_id = object_id(N'a2messaging.Messages'))
begin
	alter table a2messaging.[Messages] drop constraint DF_Processes_UtcDateCreated;
	alter table a2messaging.[Messages] add constraint DF_Messages_DateCreated2 default(a2sys.fn_getCurrentDate()) for DateCreated with values;
end
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.SEQUENCES where SEQUENCE_SCHEMA=N'a2messaging' and SEQUENCE_NAME=N'SQ_Parameters')
	create sequence a2messaging.SQ_Parameters as bigint start with 100 increment by 1;
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA=N'a2messaging' and TABLE_NAME=N'Parameters')
begin
	create table a2messaging.[Parameters]
	(
		Id	bigint	not null constraint PK_Parameters primary key
			constraint Parameters_PK default(next value for a2messaging.SQ_Parameters),
		[Message] bigint not null
			constraint FK_Parameters_Messages_Id references a2messaging.[Messages](Id),
		[Name] nvarchar(255) not null,
		[Value] nvarchar(255) not null
	);
end
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.SEQUENCES where SEQUENCE_SCHEMA=N'a2messaging' and SEQUENCE_NAME=N'SQ_Environment')
	create sequence a2messaging.SQ_Environment as bigint start with 100 increment by 1;
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA=N'a2messaging' and TABLE_NAME=N'Environment')
begin
	create table a2messaging.[Environment]
	(
		Id	bigint	not null constraint PK_Environment primary key
			constraint Environment_PK default(next value for a2messaging.SQ_Environment),
		[Message] bigint not null
			constraint FK_Environment_Messages_Id references a2messaging.[Messages](Id),
		[Name] nvarchar(255) not null,
		[Value] nvarchar(255) not null
	);
end
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA=N'a2messaging' and TABLE_NAME=N'Log')
begin
	create table a2messaging.[Log]
	(
		Id	bigint not null identity(100, 1) constraint PK_Log primary key,
		UserId bigint not null
			constraint FK_Log_UserId_Users foreign key references a2security.Users(Id),
		EventTime	datetime not null
			constraint DF_Log_EventTime2 default(a2sys.fn_getCurrentDate()),
		Severity nchar(1) not null,
		[Message] nvarchar(max) null,
	);
end
go
------------------------------------------------
if exists(select * from sys.default_constraints where name=N'DF_Log_EventTime' and parent_object_id = object_id(N'a2messaging.Log'))
begin
	alter table a2messaging.[Log] drop constraint DF_Log_EventTime;
	alter table a2messaging.[Log] add constraint DF_Log_EventTime2 default(a2sys.fn_getCurrentDate()) for EventTime with values;
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2messaging' and ROUTINE_NAME=N'WriteLog')
	drop procedure [a2messaging].[WriteLog]
go
------------------------------------------------
create procedure [a2messaging].[WriteLog]
	@UserId bigint = null,
	@Severity int,
	@Message nvarchar(max)
as
begin
	set nocount on;
	set transaction isolation level read committed;
	set xact_abort on;
	insert into a2messaging.[Log] (UserId, Severity, [Message]) 
		values (isnull(@UserId, 0 /*system user*/), char(@Severity), @Message);
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2messaging' and ROUTINE_NAME=N'Message.Queue.Metadata')
	drop procedure a2messaging.[Message.Queue.Metadata]
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2messaging' and ROUTINE_NAME=N'Message.Queue.Update')
	drop procedure a2messaging.[Message.Queue.Update]
go
------------------------------------------------
if exists (select * from sys.types st join sys.schemas ss ON st.schema_id = ss.schema_id where st.name = N'Message.TableType' AND ss.name = N'a2messaging')
	drop type a2messaging.[Message.TableType];
go
------------------------------------------------
if exists (select * from sys.types st join sys.schemas ss ON st.schema_id = ss.schema_id where st.name = N'NameValue.TableType' AND ss.name = N'a2messaging')
	drop type a2messaging.[NameValue.TableType];
go
------------------------------------------------
create type a2messaging.[Message.TableType] as
table (
	[Id] bigint null,
	[Template] nvarchar(255),
	[Key] nvarchar(255),
	[TargetId] bigint,
	[Source] nvarchar(255)
)
go
------------------------------------------------
create type a2messaging.[NameValue.TableType] as
table (
	[Name] nvarchar(255),
	[Value] nvarchar(255)
)
go
------------------------------------------------
create procedure a2messaging.[Message.Queue.Metadata]
as
begin
	set nocount on;
	declare @message a2messaging.[Message.TableType];
	declare @nv a2messaging.[NameValue.TableType];
	select [Message!Message!Metadata] = null, * from @message;
	select [Parameters!Message.Parameters!Metadata] = null, * from @nv;
	select [Environment!Message.Environment!Metadata] = null, * from @nv;
end
go
------------------------------------------------
create procedure a2messaging.[Message.Queue.Update]
@Message a2messaging.[Message.TableType] readonly,
@Parameters a2messaging.[NameValue.TableType] readonly,
@Environment a2messaging.[NameValue.TableType] readonly
as
begin
	set nocount on;
	set transaction isolation level serializable;
	set xact_abort on;
	declare @rt table(Id bigint);
	declare @msgid bigint;
	insert into a2messaging.[Messages] (Template, [Key], TargetId, [Source])
		output inserted.Id into @rt(Id)
		select Template, [Key], TargetId, [Source] from @Message;
	select top(1) @msgid = Id from @rt;
	insert into a2messaging.[Parameters] ([Message], [Name], [Value]) 
		select @msgid, [Name], [Value] from @Parameters;
	insert into a2messaging.Environment([Message], [Name], [Value]) 
		select @msgid, [Name], [Value] from @Environment;
	select [Result!TResult!Object] = null, Id=@msgid;
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2messaging' and ROUTINE_NAME=N'Message.Queue.Load')
	drop procedure a2messaging.[Message.Queue.Load]
go
------------------------------------------------
create procedure a2messaging.[Message.Queue.Load]
@Id bigint
as
begin
	set nocount on;
	set transaction isolation level read committed;
	select [Message!TMessage!Object] = null, [Id!!Id] = Id, [Template], [Key], TargetId,
		[Parameters!TNameValue!Array] = null, [Environment!TNameValue!Array] = null
	from a2messaging.[Messages] where Id=@Id;
	select [!TNameValue!Array] = null, [Name], [Value], [!TMessage.Parameters!ParentId] = [Message]
		from a2messaging.[Parameters] where [Message]=@Id;
	select [!TNameValue!Array] = null, [Name], [Value], [!TMessage.Environment!ParentId] = [Message]
		from a2messaging.[Environment] where [Message]=@Id;
end
go
------------------------------------------------
begin
	set nocount on;
	grant execute on schema ::a2messaging to public;
end
go


/*
Copyright © 2008-2019 Alex Kukhtin

Last updated : 21 dec 2019
module version : 7550
*/
------------------------------------------------
begin
	set nocount on;
	if not exists(select * from a2sys.Versions where Module = N'std:ui')
		insert into a2sys.Versions (Module, [Version]) values (N'std:ui', 7550);
	else
		update a2sys.Versions set [Version] = 7550 where Module = N'std:ui';
	end
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.SCHEMATA where SCHEMA_NAME=N'a2ui')
begin
	exec sp_executesql N'create schema a2ui';
end
go
if not exists(select * from INFORMATION_SCHEMA.SEQUENCES where SEQUENCE_SCHEMA=N'a2ui' and SEQUENCE_NAME=N'SQ_Menu')
	create sequence a2ui.SQ_Menu as bigint start with 100 increment by 1;
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA=N'a2ui' and TABLE_NAME=N'Menu')
begin
	create table a2ui.Menu
	(
		Id	bigint not null constraint PK_Menu primary key
			constraint DF_Menu_PK default(next value for a2ui.SQ_Menu),
		Parent bigint null
			constraint FK_Menu_Parent_Menu foreign key references a2ui.Menu(Id),
		[Key] nchar(4) null,
		[Name] nvarchar(255) null,
		[Url] nvarchar(255) null,
		Icon nvarchar(255) null,
		Model nvarchar(255) null,
		Help nvarchar(255) null,
		[Order] int not null constraint DF_Menu_Order default(0),
		[Description] nvarchar(255) null,
		[Params] nvarchar(255) null,
		[Feature] nchar(4) null
	);
end
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA=N'a2ui' and TABLE_NAME=N'Menu' and COLUMN_NAME=N'Help')
begin
	alter table a2ui.Menu add Help nvarchar(255) null;
end
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA=N'a2ui' and TABLE_NAME=N'Menu' and COLUMN_NAME=N'Key')
begin
	alter table a2ui.Menu add [Key] nchar(4) null;
end
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA=N'a2ui' and TABLE_NAME=N'Menu' and COLUMN_NAME=N'Params')
begin
	alter table a2ui.Menu add Params nvarchar(255) null;
end
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA=N'a2ui' and TABLE_NAME=N'Menu' and COLUMN_NAME=N'Feature')
begin
	alter table a2ui.Menu add [Feature] nchar(4) null;
end
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA=N'a2security' and TABLE_NAME=N'Menu.Acl')
begin
	-- ACL for menu
	create table a2security.[Menu.Acl]
	(
		Menu bigint not null 
			constraint FK_MenuAcl_Menu foreign key references a2ui.Menu(Id),
		UserId bigint not null 
			constraint FK_MenuAcl_UserId_Users foreign key references a2security.Users(Id),
		CanView bit null,
		[Permissions] as cast(CanView as int)
		constraint PK_MenuAcl primary key(Menu, UserId)
	);
end
go
------------------------------------------------
if not exists (select * from sys.indexes where [name] = N'IX_MenuAcl_UserId')
	create nonclustered index IX_MenuAcl_UserId on a2security.[Menu.Acl] (UserId);
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA=N'a2ui' and TABLE_NAME=N'Feedback')
begin
	create table a2ui.Feedback
	(
		Id	bigint identity(1, 1) not null constraint PK_Feedback primary key,
		[Date] datetime not null
			constraint DF_Feedback_CurrentDate default(a2sys.fn_getCurrentDate()),
		UserId bigint not null
			constraint FK_Feedback_UserId_Users foreign key references a2security.Users(Id),
		[Text] nvarchar(max) null
	);
end
go
------------------------------------------------
if exists(select * from sys.default_constraints where name=N'DF_Feedback_UtcDate' and parent_object_id = object_id(N'a2ui.Feedback'))
begin
	alter table a2ui.Feedback drop constraint DF_Feedback_UtcDate;
	alter table a2ui.Feedback add constraint DF_Feedback_CurrentDate default(a2sys.fn_getCurrentDate()) for [Date];
end
go
------------------------------------------------
if (255 = (select CHARACTER_MAXIMUM_LENGTH from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA=N'a2ui' and TABLE_NAME=N'Feedback' and COLUMN_NAME=N'Text'))
begin
	alter table a2ui.Feedback alter column [Text] nvarchar(max) null;
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2ui' and ROUTINE_NAME=N'Menu.User.Load')
	drop procedure a2ui.[Menu.User.Load]
go
------------------------------------------------
create procedure a2ui.[Menu.User.Load]
@TenantId int = null,
@UserId bigint,
@Mobile bit = 0,
@Groups nvarchar(255) = null -- for use claims
as
begin
	set nocount on;
	declare @RootId bigint;
	set @RootId = 1;
	if @Mobile = 1
		set @RootId = 2;
	with RT as (
		select Id=m0.Id, ParentId = m0.Parent, [Level]=0
			from a2ui.Menu m0
			where m0.Id = @RootId
		union all
		select m1.Id, m1.Parent, RT.[Level]+1
			from RT inner join a2ui.Menu m1 on m1.Parent = RT.Id
	)
	select [Menu!TMenu!Tree] = null, [Id!!Id]=RT.Id, [!TMenu.Menu!ParentId]=RT.ParentId,
		[Menu!TMenu!Array] = null,
		m.Name, m.Url, m.Icon, m.[Description], m.Help, m.Params
	from RT 
		inner join a2security.[Menu.Acl] a on a.Menu = RT.Id
		inner join a2ui.Menu m on RT.Id=m.Id
	where a.UserId = @UserId and a.CanView = 1
	order by RT.[Level], m.[Order], RT.[Id];

	-- system parameters
	select [SysParams!TParam!Object]= null, [AppTitle], [AppSubTitle], [SideBarMode], [Pages]
	from (select Name, Value=StringValue from a2sys.SysParams) as s
		pivot (min(Value) for Name in ([AppTitle], [AppSubTitle], [SideBarMode], [Pages])) as p;
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2ui' and ROUTINE_NAME=N'AppTitle.Load')
	drop procedure a2ui.[AppTitle.Load]
go
------------------------------------------------
create procedure a2ui.[AppTitle.Load]
as
begin
	set nocount on;
	select [AppTitle], [AppSubTitle]
	from (select Name, Value=StringValue from a2sys.SysParams) as s
		pivot (min(Value) for Name in ([AppTitle], [AppSubTitle])) as p;
end
go
-----------------------------------------------
if exists (select * from sys.objects where object_id = object_id(N'a2security.fn_GetMenuFor') and type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	drop function a2security.fn_GetMenuFor;
go
------------------------------------------------
create function a2security.fn_GetMenuFor(@MenuId bigint)
returns @rettable table (Id bigint, Parent bit)
as
begin
	declare @tx table (Id bigint, Parent bit);

	-- all children
	with C(Id, ParentId)
	as
	(
		select @MenuId, cast(null as bigint) 
		union all
		select m.Id, m.Parent
			from a2ui.Menu m inner join C on m.Parent=C.Id
	)
	insert into @tx(Id, Parent)
		select Id, 0 from C
		group by Id;

	-- all parent 
	with P(Id, ParentId)
	as
	(
		select cast(null as bigint), @MenuId 
		union all
		select m.Id, m.Parent
			from a2ui.Menu m inner join P on m.Id=P.ParentId
	)
	insert into @tx(Id, Parent)
		select Id, 1 from P
		group by Id;

	insert into @rettable
		select Id, Parent from @tx
			where Id is not null
		group by Id, Parent;
	return;
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2security' and ROUTINE_NAME=N'Permission.UpdateAcl.Menu')
	drop procedure [a2security].[Permission.UpdateAcl.Menu]
go
------------------------------------------------
create procedure [a2security].[Permission.UpdateAcl.Menu]
as
begin
	set nocount on;
	declare @MenuTable table (Id bigint, UserId bigint, GroupId bigint, CanView smallint);

	insert into @MenuTable (Id, UserId, GroupId, CanView)
		select f.Id, a.UserId, a.GroupId, a.CanView
		from a2security.Acl a 
			cross apply a2security.fn_GetMenuFor(a.ObjectId) f
			/*exclude denied parents */
		where a.[Object] = N'std:menu' and Not (Parent = 1 and CanView = -1)
		group by f.Id, UserId, GroupId, CanView;

	declare @UserTable table (ObjectId bigint, UserId bigint, CanView bit);

	with T(ObjectId, UserId, CanView)
	as
	(
		select a.Id, UserId=isnull(ur.UserId, a.UserId), a.CanView
		from @MenuTable a
		left join a2security.UserGroups ur on a.GroupId = ur.GroupId
		where isnull(ur.UserId, a.UserId) is not null
	)
	insert into @UserTable(ObjectId, UserId, CanView)
	select ObjectId, UserId,
		_CanView = isnull(case 
				when min(T.CanView) = -1 then 0
				when max(T.CanView) = 1 then 1
				end, 0)
	from T
	group by ObjectId, UserId;

	merge a2security.[Menu.Acl] as target
	using
	(
		select ObjectId, UserId, CanView
		from @UserTable T
		where CanView = 1
	) as source(ObjectId, UserId, CanView)
		on target.Menu = source.[ObjectId] and target.UserId=source.UserId
	when matched then
		update set 
			target.CanView = source.CanView
	when not matched by target then
		insert (Menu, UserId, CanView)
			values (source.[ObjectId], source.UserId, source.CanView)
	when not matched by source then
		delete;
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2security' and ROUTINE_NAME=N'Permission.UpdateUserAcl.Menu')
	drop procedure [a2security].[Permission.UpdateUserAcl.Menu]
go
------------------------------------------------
create procedure [a2security].[Permission.UpdateUserAcl.Menu]
@UserId bigint
as
begin
	set nocount on;
	declare @MenuTable table (Id bigint, UserId bigint, GroupId bigint, CanView smallint);

	insert into @MenuTable (Id, UserId, GroupId, CanView)
		select f.Id, a.UserId, a.GroupId, a.CanView
		from a2security.Acl a 
			cross apply a2security.fn_GetMenuFor(a.ObjectId) f
			/*exclude denied parents */
		where a.[Object] = N'std:menu' and Not (Parent = 1 and CanView = -1)
		group by f.Id, UserId, GroupId, CanView;

	declare @UserTable table (ObjectId bigint, UserId bigint, CanView bit);

	with T(ObjectId, UserId, CanView)
	as
	(
		select a.Id, UserId=isnull(ur.UserId, a.UserId), a.CanView
		from @MenuTable a
		left join a2security.UserGroups ur on a.GroupId = ur.GroupId
		where isnull(ur.UserId, a.UserId) = @UserId
	)
	insert into @UserTable(ObjectId, UserId, CanView)
	select ObjectId, UserId,
		_CanView = isnull(case 
				when min(T.CanView) = -1 then 0
				when max(T.CanView) = 1 then 1
				end, 0)
	from T
	group by ObjectId, UserId;

	merge a2security.[Menu.Acl] as target
	using
	(
		select ObjectId, UserId, CanView
		from @UserTable T
		where CanView = 1
	) as source(ObjectId, UserId, CanView)
		on target.Menu = source.[ObjectId] and target.UserId=source.UserId
	when matched then
		update set 
			target.CanView = source.CanView
	when not matched by target then
		insert (Menu, UserId, CanView)
			values (source.[ObjectId], source.UserId, source.CanView)
	when not matched by source and target.UserId = @UserId then
		delete;
end
go
-----------------------------------------------
if exists (select * from sys.objects where object_id = object_id(N'a2security.fn_IsMenuVisible') and type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	drop function a2security.fn_IsMenuVisible;
go
------------------------------------------------
create function a2security.fn_IsMenuVisible(@MenuId bigint, @UserId bigint)
returns bit
as
begin
	declare @result bit;
	select @result = case when CanView = 1 then 1 else 0 end from a2security.Acl where [Object] = N'std:menu' and ObjectId = @MenuId and UserId = @UserId;
	return isnull(@result, 1); -- not found - visible
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2ui' and ROUTINE_NAME=N'Menu.SetVisible')
	drop procedure a2ui.[Menu.SetVisible]
go
------------------------------------------------
create procedure a2ui.[Menu.SetVisible]
@UserId bigint,
@MenuId bigint,
@Visible bit
as
begin
	set nocount on;
	set transaction isolation level read committed;
	if @Visible = 0 and not exists(select * from a2security.Acl where [Object] = N'std:menu' and ObjectId = @MenuId and UserId = @UserId)
		 insert into a2security.Acl ([Object], ObjectId, UserId, CanView) values (N'std:menu', @MenuId, @UserId, -1);
	else if @Visible = 1
		delete from a2security.Acl where [Object] = N'std:menu' and ObjectId = @MenuId and UserId = @UserId;
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2ui' and ROUTINE_NAME=N'SaveFeedback')
	drop procedure a2ui.SaveFeedback
go
------------------------------------------------
create procedure a2ui.SaveFeedback
@UserId bigint,
@Text nvarchar(max)
as
begin
	set nocount on;
	set transaction isolation level read committed;
	set xact_abort on;
	insert into a2ui.Feedback(UserId, [Text]) values (@UserId, @Text);
end
go
------------------------------------------------
begin
	set nocount on;
	grant execute on schema ::a2ui to public;
end
go

/*
------------------------------------------------
Copyright © 2008-2019 Alex Kukhtin

Last updated : 23 dec 2019
module version : 7170
*/
------------------------------------------------
begin
	set nocount on;
	if not exists(select * from a2sys.Versions where Module = N'std:admin')
		insert into a2sys.Versions (Module, [Version]) values (N'std:admin', 7170);
	else
		update a2sys.Versions set [Version] = 7170 where Module = N'std:admin';
end
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.SCHEMATA where SCHEMA_NAME=N'a2admin')
begin
	exec sp_executesql N'create schema a2admin';
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2admin' and ROUTINE_NAME=N'Ensure.Admin')
	drop procedure a2admin.[Ensure.Admin]
go
------------------------------------------------
create procedure a2admin.[Ensure.Admin]
	@TenantId int = null,
	@UserId bigint
as
begin
	set nocount on;
	if not exists(select 1 from a2security.UserGroups where GroupId = 77 /*predefined*/ and UserId = @UserId)
		throw 60000, N'The current user is not an administrator', 0;
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2admin' and ROUTINE_NAME=N'Menu.Admin.Load')
	drop procedure a2admin.[Menu.Admin.Load]
go
------------------------------------------------
create procedure a2admin.[Menu.Admin.Load]
@TenantId int = null,
@UserId bigint
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	exec a2admin.[Ensure.Admin] @TenantId, @UserId;
	declare @RootId bigint;
	select @RootId = Id from a2ui.Menu where Parent is null and [Name] = N'Admin';

	with RT as (
		select Id=m0.Id, ParentId = m0.Parent, [Level]=0
			from a2ui.Menu m0
			where m0.Id = @RootId
		union all
		select m1.Id, m1.Parent, RT.[Level]+1
			from RT inner join a2ui.Menu m1 on m1.Parent = RT.Id
	)
	select [Menu!TMenu!Tree] = null, [Id!!Id]=RT.Id, [!TMenu.Menu!ParentId]=RT.ParentId,
		[Menu!TMenu!Array] = null,
		m.Name, m.Url, m.Icon, m.[Description], m.Help, m.Params
	from RT 
		inner join a2ui.Menu m on RT.Id=m.Id
	order by RT.[Level], m.[Order], RT.[Id];

	-- system parameters
	select [SysParams!TParam!Object]= null, [AppTitle], [AppSubTitle]
	from (select Name, Value=StringValue from a2sys.SysParams) as s
		pivot (min(Value) for Name in ([AppTitle], [AppSubTitle])) as p;
end
go

------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2admin' and ROUTINE_NAME=N'User.Index')
	drop procedure [a2admin].[User.Index]
go
------------------------------------------------
create procedure a2admin.[User.Index]
@TenantId int = null,
@UserId bigint,
@Order nvarchar(255) = N'Id',
@Dir nvarchar(255) = N'desc',
@Offset int = 0,
@PageSize int = 20,
@Fragment nvarchar(255) = null
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	exec a2admin.[Ensure.Admin]  @TenantId, @UserId;

	declare @Asc nvarchar(10), @Desc nvarchar(10), @RowCount int;
	set @Asc = N'asc'; set @Desc = N'desc';
	set @Dir = isnull(@Dir, @Asc);
	if @Fragment is not null
		set @Fragment = N'%' + upper(@Fragment) + N'%';

	-- list of users
	with T([Id!!Id], [Name!!Name], [Phone!!Phone], Email, PersonName, Memo, IsAdmin, [LastLoginDate!!UtcDate], LastLoginHost, [!!RowNumber])
	as(
		select u.Id, u.UserName, u.PhoneNumber, u.Email, u.PersonName, Memo, IsAdmin,
			LastLoginDate, LastLoginHost,
			[!!RowNumber] = row_number() over (
			 order by
				case when @Order=N'Id' and @Dir = @Asc then u.Id end asc,
				case when @Order=N'Id' and @Dir = @Desc  then u.Id end desc,
				case when @Order=N'Name' and @Dir = @Asc then u.UserName end asc,
				case when @Order=N'Name' and @Dir = @Desc  then u.UserName end desc,
				case when @Order=N'PersonName' and @Dir = @Asc then u.PersonName end asc,
				case when @Order=N'PersonName' and @Dir = @Desc then u.PersonName end desc,
				case when @Order=N'Email' and @Dir = @Asc then u.Email end asc,
				case when @Order=N'Email' and @Dir = @Desc then u.Email end desc,
				case when @Order=N'Phone' and @Dir = @Asc then u.PhoneNumber end asc,
				case when @Order=N'Phone' and @Dir = @Desc then u.PhoneNumber end desc,
				case when @Order=N'Memo' and @Dir = @Asc then u.Memo end asc,
				case when @Order=N'Memo' and @Dir = @Desc then u.Memo end desc
			)
		from a2security.ViewUsers u
		where @Fragment is null or upper(u.UserName) like @Fragment or upper(u.PersonName) like @Fragment
			or upper(u.Email) like @Fragment or upper(u.PhoneNumber) like @Fragment 
			or cast(u.Id as nvarchar) like @Fragment or upper(u.Memo) like @Fragment
	)
	select [Users!TUser!Array]=null, *, [!!RowCount] = (select count(1) from T)
	from T
		where [!!RowNumber] > @Offset and [!!RowNumber] <= @Offset + @PageSize
	order by [!!RowNumber];

	select [!$System!] = null, [!Users!PageSize] = @PageSize, 
		[!Users!SortOrder] = @Order, [!Users!SortDir] = @Dir,
		[!Users!Offset] = @Offset, [!Users.Fragment!Filter] = @Fragment;
end
go

------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2admin' and ROUTINE_NAME=N'User.Load')
	drop procedure [a2admin].[User.Load]
go
------------------------------------------------
create procedure a2admin.[User.Load]
	@TenantId int = null,
	@UserId bigint,
	@Id bigint = null
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	exec a2admin.[Ensure.Admin]  @TenantId, @UserId;

	select [User!TUser!Object]=null, 
		[Id!!Id]=u.Id, [Name!!Name]=u.UserName, [Phone!!Phone]=u.PhoneNumber, [Email]=u.Email,
		[PersonName] = u.PersonName, Memo = u.Memo,
		[Groups!TGroup!Array] = null,
		[Roles!TRole!Array] = null
	from a2security.ViewUsers u
	where u.Id = @Id;
	
	select [!TGroup!Array] = null, [Id!!Id] = g.Id, [Key] = g.[Key], [Name!!Name] = g.[Name], [Memo] = g.Memo,
		[!TUser.Groups!ParentId] = ug.UserId
	from a2security.UserGroups ug
		inner join a2security.Groups g on ug.GroupId = g.Id
	where ug.UserId = @Id and g.Void = 0;

	select [!TRole!Array] = null, [Id!!Id] = r.Id, [Name!!Name] = r.[Name], r.[Key], [Memo] = r.Memo, 
		[!TUser.Roles!ParentId] = ur.UserId
	from a2security.UserRoles ur
		inner join a2security.Roles r on ur.RoleId = r.Id
	where ur.UserId = @Id and r.Void = 0;
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2admin' and ROUTINE_NAME=N'User.Metadata')
	drop procedure [a2admin].[User.Metadata]
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2admin' and ROUTINE_NAME=N'User.Update')
	drop procedure [a2admin].[User.Update]
go
------------------------------------------------
if exists(select * from INFORMATION_SCHEMA.DOMAINS where DOMAIN_SCHEMA=N'a2admin' and DOMAIN_NAME=N'User.TableType' and DATA_TYPE=N'table type')
	drop type [a2admin].[User.TableType];
go
------------------------------------------------
create type a2admin.[User.TableType]
as table(
	Id bigint null,
	[Name] nvarchar(255),
	[Email] nvarchar(255),
	[Phone] nvarchar(255),
	[PersonName] nvarchar(255),
	[Memo] nvarchar(255)
)
go
------------------------------------------------
create procedure a2admin.[User.Metadata]
as
begin
	set nocount on;

	declare @User a2admin.[User.TableType];
	declare @Roles a2sys.[Id.TableType];
	declare @Groups a2sys.[Id.TableType];
	select [User!User!Metadata]=null, * from @User;
	select [Roles!User.Roles!Metadata]=null, * from @Roles;
	select [Groups!User.Groups!Metadata]=null, * from @Groups;
end
go
------------------------------------------------
create procedure [a2admin].[User.Update]
	@TenantId int = null,
	@UserId bigint,
	@User a2admin.[User.TableType] readonly,
	@Roles a2sys.[Id.TableType] readonly,
	@Groups a2sys.[Id.TableType] readonly,
	@RetId bigint = null output
as
begin
	set nocount on;
	set transaction isolation level read committed;
	set xact_abort on;

	declare @AllUsersGroupId bigint = 1; -- predefined

	exec a2admin.[Ensure.Admin]  @TenantId, @UserId;

	declare @output table(op sysname, id bigint);
	merge a2security.ViewUsers as target
	using @User as source
	on (target.Id = source.Id)
	when matched then
		update set 
			target.[UserName] = source.[Name],
			target.[Email] = source.Email,
			target.PhoneNumber = source.Phone,
			target.Memo = source.Memo,
			target.PersonName = source.PersonName
	when not matched by target then
		insert ([UserName], Email, PhoneNumber, Memo, PersonName, SecurityStamp)
		values ([Name], Email, Phone, Memo, PersonName, N'')
	output 
		$action op,
		inserted.Id id
	into @output(op, id);

	select top(1) @RetId = id from @output;

	merge a2security.UserRoles as target
	using @Roles as source
	on target.UserId=@RetId and target.RoleId = source.Id and target.GroupId is null
	when not matched by target then
		insert(RoleId, UserId, GroupId) values (source.Id, @RetId, null)
	when not matched by source and target.UserId=@RetId and target.GroupId is null then 
		delete;

	merge a2security.UserGroups as target
	using @Groups as source
	on target.UserId=@RetId and target.GroupId = source.Id
	when not matched by target then
		insert(UserId, GroupId) values (@RetId, source.Id)
	when not matched by source and target.UserId=@RetId then
		delete;

	if exists (select * from @output where op = N'INSERT')
	begin
		if not exists(select * from a2security.UserGroups where UserId=@RetId and GroupId=@AllUsersGroupId)
			insert into a2security.UserGroups(UserId, GroupId) values (@RetId, @AllUsersGroupId);
	end	
	exec a2security.[Permission.UpdateUserInfo];
	exec a2admin.[User.Load] @TenantId, @UserId, @RetId;
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2admin' and ROUTINE_NAME=N'User.Login.CheckDuplicate')
	drop procedure [a2admin].[User.Login.CheckDuplicate]
go
------------------------------------------------
create procedure a2admin.[User.Login.CheckDuplicate]
	@TenantId int = null,
	@UserId bigint,
	@Id bigint,
	@Login nvarchar(255)
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	declare @valid bit = 1;
	if exists(select * from a2security.Users where UserName = @Login and Id <> @Id)
		set @valid = 0;
	select [Result!TResult!Object] = null, [Value] = @valid;
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2admin' and ROUTINE_NAME=N'User.Delete')
	drop procedure [a2admin].[User.Delete]
go
------------------------------------------------
create procedure a2admin.[User.Delete]
	@TenantId int = null,
	@UserId bigint,
	@Id bigint = null
as
begin
	set nocount on;
	set transaction isolation level read committed;
	set xact_abort on;

	exec a2admin.[Ensure.Admin]  @TenantId, @UserId;
	delete from a2security.UserGroups where UserId = @Id;
	delete from a2security.UserRoles where UserId = @Id;
	update a2security.ViewUsers set Void=1 where Id=@Id;
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2admin' and ROUTINE_NAME=N'Group.Index')
	drop procedure [a2admin].[Group.Index]
go
------------------------------------------------
create procedure a2admin.[Group.Index]
	@TenantId int = null,
	@UserId bigint,
	@Order nvarchar(255) = N'Id',
	@Dir nvarchar(255) = N'desc',
	@Offset int = 0,
	@PageSize int = 20,
	@Fragment nvarchar(255) = null
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	exec a2admin.[Ensure.Admin]  @TenantId, @UserId;

	declare @Asc nvarchar(10), @Desc nvarchar(10), @RowCount int;
	set @Asc = N'asc'; set @Desc = N'desc';
	set @Dir = isnull(@Dir, @Asc);

	set @Dir = isnull(@Dir, @Asc);
	if @Fragment is not null
		set @Fragment = N'%' + upper(@Fragment) + N'%';

	-- list of groups
	with T([Id!!Id], [Name!!Name], [Key], [Memo], [UserCount], [!!RowNumber]) 
	as (
		select [Id!!Id]=g.Id, [Name!!Name]=g.[Name], 
			[Key] = g.[Key], [Memo]=g.Memo, 
			[UserCount]=(select count(1) from a2security.UserGroups ug where ug.GroupId = g.Id),
			[!!RowNumber] = row_number() over (
			 order by
				case when @Order=N'Id' and @Dir = @Asc then g.Id end asc,
				case when @Order=N'Id' and @Dir = @Desc  then g.Id end desc,
				case when @Order=N'Name' and @Dir = @Asc then g.[Name] end asc,
				case when @Order=N'Name' and @Dir = @Desc  then g.[Name] end desc,
				case when @Order=N'Key' and @Dir = @Asc then g.[Key] end asc,
				case when @Order=N'Key' and @Dir = @Desc  then g.[Key] end desc,
				case when @Order=N'Memo' and @Dir = @Asc then g.Memo end asc,
				case when @Order=N'Memo' and @Dir = @Desc then g.Memo end desc
			)
		from a2security.Groups g
		where g.Void = 0 and (@Fragment is null or upper(g.[Name]) like @Fragment or upper(g.[Key]) like @Fragment
			or upper(g.Memo) like @Fragment or cast(g.Id as nvarchar) like @Fragment)
	)

	select [Groups!TGroup!Array]=null, *, [!!RowCount] = (select count(1) from T) 
	from T
		where [!!RowNumber] > @Offset and [!!RowNumber] <= @Offset + @PageSize
	order by [!!RowNumber];


	select [!$System!] = null, [!Groups!PageSize] = @PageSize, 
		[!Groups!SortOrder] = @Order, [!Groups!SortDir] = @Dir,
		[!Groups!Offset] = @Offset, [!Groups.Fragment!Filter] = @Fragment;

end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2admin' and ROUTINE_NAME=N'Group.Load')
	drop procedure a2admin.[Group.Load]
go
------------------------------------------------
create procedure a2admin.[Group.Load]
	@TenantId int = null,
	@UserId bigint,
	@Id bigint = null
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;
	
	exec a2admin.[Ensure.Admin]  @TenantId, @UserId;

	select [Group!TGroup!Object]=null, [Id!!Id]=g.Id, [Name!!Name]=g.[Name], 
		[Key] = g.[Key], [Memo]=g.Memo, 
		[UserCount]=(select count(1) from a2security.UserGroups ug where ug.GroupId = @Id),
		[Users!TUser!Array] = null
	from a2security.Groups g
	where g.Id = @Id and g.Void = 0;

	/* users in group */
	select [!TUser!Array] = null, [Id!!Id] = u.Id, [Name!!Name] = u.UserName, u.PersonName,
		u.Memo,
		[!TGroup.Users!ParentId] = ug.GroupId
	from a2security.UserGroups ug
		inner join a2security.ViewUsers u on ug.UserId = u.Id
	where ug.GroupId = @Id;
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2admin' and ROUTINE_NAME=N'Group.Metadata')
	drop procedure a2admin.[Group.Metadata]
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2admin' and ROUTINE_NAME=N'Group.Update')
	drop procedure a2admin.[Group.Update]
go
------------------------------------------------
if exists(select * from INFORMATION_SCHEMA.DOMAINS where DOMAIN_SCHEMA=N'a2admin' and DOMAIN_NAME=N'Group.TableType' and DATA_TYPE=N'table type')
	drop type a2admin.[Group.TableType];
go
------------------------------------------------
create type a2admin.[Group.TableType]
as table(
	Id bigint null,
	[Name] nvarchar(255),
	[Key] nvarchar(255),
	[Memo] nvarchar(255)
)
go
------------------------------------------------
create procedure a2admin.[Group.Metadata]
as
begin
	set nocount on;

	declare @Group a2admin.[Group.TableType];
	declare @Users a2sys.[Id.TableType];

	select [Group!Group!Metadata]=null, * from @Group;
	select [Users!Group.Users!Metadata] = null, * from @Users;
end
go
------------------------------------------------
create procedure a2admin.[Group.Update]
	@TenantId  int = null,
	@UserId bigint,
	@Group a2admin.[Group.TableType] readonly,
	@Users a2sys.[Id.TableType] readonly,
	@RetId bigint = null output
as
begin
	set nocount on;
	set transaction isolation level read committed;
	set xact_abort on;

	exec a2admin.[Ensure.Admin]  @TenantId, @UserId;

	declare @output table(op sysname, id bigint);

	merge a2security.Groups as target
	using @Group as source
	on (target.Id = source.Id)
	when matched then
		update set 
			target.[Name] = source.[Name],
			target.[Key] = source.[Key],
			target.[Memo] = source.Memo
	when not matched by target then 
		insert ([Name], [Key], Memo)
		values ([Name], [Key], Memo)
	output 
		$action op,
		inserted.Id id
	into @output(op, id);
	select top(1) @RetId = id from @output;

	merge a2security.UserGroups as target
	using @Users as source
	on target.UserId=source.Id and target.GroupId=@RetId
	when not matched by target then
		insert(GroupId, UserId) values (@RetId, source.Id)
	when not matched by source and target.GroupId=@RetId then delete;
		
	exec a2security.[Permission.UpdateUserInfo];
	exec a2admin.[Group.Load] @TenantId, @UserId, @RetId;
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2admin' and ROUTINE_NAME=N'Group.Delete')
	drop procedure [a2admin].[Group.Delete]
go
------------------------------------------------
create procedure a2admin.[Group.Delete]
	@TenantId int = null,
	@UserId bigint,
	@Id bigint = null
as
begin
	set nocount on;
	set transaction isolation level read committed;
	set xact_abort on;

	exec a2admin.[Ensure.Admin]  @TenantId, @UserId;
	delete from a2security.UserGroups where GroupId = @Id;
	delete from a2security.UserRoles where GroupId = @Id;
	update a2security.Groups set Void=1, [Key] = null where Id=@Id;
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2admin' and ROUTINE_NAME=N'Group.Key.CheckDuplicate')
	drop procedure [a2admin].[Group.Key.CheckDuplicate]
go
------------------------------------------------
create procedure a2admin.[Group.Key.CheckDuplicate]
	@TenantId int = null,
	@UserId bigint,
	@Id bigint,
	@Key nvarchar(255)
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	declare @valid bit = 1;
	if exists(select * from a2security.Groups where [Key] = @Key and Id <> @Id)
		set @valid = 0;
	select [Result!TResult!Object] = null, [Value] = @valid;
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2admin' and ROUTINE_NAME=N'Group.Name.CheckDuplicate')
	drop procedure [a2admin].[Group.Name.CheckDuplicate]
go
------------------------------------------------
create procedure a2admin.[Group.Name.CheckDuplicate]
	@TenantId int = null,
	@UserId bigint,
	@Id bigint,
	@Name nvarchar(255)
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	declare @valid bit = 1;
	if exists(select * from a2security.Groups where [Name] = @Name and Id <> @Id)
		set @valid = 0;
	select [Result!TResult!Object] = null, [Value] = @valid;
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2admin' and ROUTINE_NAME=N'Role.Index')
	drop procedure [a2admin].[Role.Index]
go
------------------------------------------------
create procedure a2admin.[Role.Index]
@TenantId int = null,
@UserId bigint,
@Order nvarchar(255) = N'Id',
@Dir nvarchar(255) = N'desc',
@Offset int = 0,
@PageSize int = 20,
@Fragment nvarchar(255) = null
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	exec a2admin.[Ensure.Admin]  @TenantId, @UserId;

	declare @Asc nvarchar(10), @Desc nvarchar(10), @RowCount int;
	set @Asc = N'asc'; set @Desc = N'desc';
	set @Dir = isnull(@Dir, @Asc);

	set @Dir = isnull(@Dir, @Asc);
	if @Fragment is not null
		set @Fragment = N'%' + upper(@Fragment) + N'%';

	-- list of roles
	with T([Id!!Id], [Name!!Name], [Key], [Memo], [ElemCount], [!!RowNumber]) 
	as (
		select [Id!!Id]=r.Id, [Name!!Name]=r.[Name], 
			[Key] = r.[Key], [Memo]=r.Memo, 
			[ElemCount]=(select count(1) from a2security.UserRoles ur where ur.RoleId = r.Id),
			[!!RowNumber] = row_number() over (
			 order by
				case when @Order=N'Id' and @Dir = @Asc then r.Id end asc,
				case when @Order=N'Id' and @Dir = @Desc  then r.Id end desc,
				case when @Order=N'Name' and @Dir = @Asc then r.[Name] end asc,
				case when @Order=N'Name' and @Dir = @Desc  then r.[Name] end desc,
				case when @Order=N'Key' and @Dir = @Asc then r.[Key] end asc,
				case when @Order=N'Key' and @Dir = @Desc  then r.[Key] end desc,
				case when @Order=N'Memo' and @Dir = @Asc then r.Memo end asc,
				case when @Order=N'Memo' and @Dir = @Desc then r.Memo end desc
			)
		from a2security.Roles r
		where r.Void = 0 and (@Fragment is null or upper(r.[Name]) like @Fragment or upper(r.[Key]) like @Fragment
			or upper(r.Memo) like @Fragment or cast(r.Id as nvarchar) like @Fragment)
	)

	select [Roles!TRole!Array]=null, *, [!!RowCount] = (select count(1) from T) 
	from T
		where [!!RowNumber] > @Offset and [!!RowNumber] <= @Offset + @PageSize
	order by [!!RowNumber]; 


	select [!$System!] = null, [!Roles!PageSize] = @PageSize, 
		[!Roles!SortOrder] = @Order, [!Roles!SortDir] = @Dir,
		[!Roles!Offset] = @Offset, [!Roles.Fragment!Filter] = @Fragment;
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2admin' and ROUTINE_NAME=N'Role.Load')
	drop procedure a2admin.[Role.Load]
go
------------------------------------------------
create procedure a2admin.[Role.Load]
@TenantId int = null,
@UserId bigint,
@Id bigint = null
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;
	
	exec a2admin.[Ensure.Admin]  @TenantId, @UserId;

	select [Role!TRole!Object]=null, [Id!!Id]=r.Id, [Name!!Name]=r.[Name], 
		[Key] = r.[Key], [Memo]=r.Memo, [UsersGroups!TUserOrGroup!Array] = null,
		[ElemCount]=(select count(1) from a2security.UserRoles ur where ur.RoleId = r.Id)
	from a2security.Roles r
	where r.Id = @Id and r.Void = 0;

	/* users in role */
	select [!TUserOrGroup!Array] = null, [Id!!Id] = ur.Id, [!TRole.UsersGroups!ParentId] = ur.RoleId,
		[UserId] = ur.UserId, [UserName] = u.UserName, u.PersonName,
		GroupId = ur.GroupId, GroupName= g.[Name]		
	from a2security.UserRoles ur
		left join a2security.ViewUsers u on ur.UserId = u.Id
		left join a2security.Groups g on ur.GroupId = g.Id
	where ur.RoleId = @Id;
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2admin' and ROUTINE_NAME=N'Role.Delete')
	drop procedure [a2admin].[Role.Delete]
go
------------------------------------------------
create procedure a2admin.[Role.Delete]
@TenantId int = null,
@UserId bigint,
@Id bigint = null
as
begin
	set nocount on;
	set transaction isolation level read committed;
	set xact_abort on;

	exec a2admin.[Ensure.Admin]  @TenantId, @UserId;
	delete from a2security.UserRoles where RoleId = @Id;
	update a2security.Roles set Void=1, [Key] = null where Id=@Id;
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2admin' and ROUTINE_NAME=N'Role.Key.CheckDuplicate')
	drop procedure [a2admin].[Role.Key.CheckDuplicate]
go
------------------------------------------------
create procedure a2admin.[Role.Key.CheckDuplicate]
@TenantId int = null,
@UserId bigint,
@Id bigint,
@Key nvarchar(255)
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	declare @valid bit = 1;
	if exists(select * from a2security.Roles where [Key] = @Key and Id <> @Id)
		set @valid = 0;
	select [Result!TResult!Object] = null, [Value] = @valid;
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2admin' and ROUTINE_NAME=N'Role.Name.CheckDuplicate')
	drop procedure [a2admin].[Role.Name.CheckDuplicate]
go
------------------------------------------------
create procedure a2admin.[Role.Name.CheckDuplicate]
@TenantId int = null,
@UserId bigint,
@Id bigint,
@Name nvarchar(255)
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	declare @valid bit = 1;
	if exists(select * from a2security.Roles where [Name] = @Name and Id <> @Id)
		set @valid = 0;
	select [Result!TResult!Object] = null, [Value] = @valid;
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2admin' and ROUTINE_NAME=N'Role.Metadata')
	drop procedure a2admin.[Role.Metadata]
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2admin' and ROUTINE_NAME=N'Role.Update')
	drop procedure a2admin.[Role.Update]
go
------------------------------------------------
if exists(select * from INFORMATION_SCHEMA.DOMAINS where DOMAIN_SCHEMA=N'a2admin' and DOMAIN_NAME=N'Role.TableType' and DATA_TYPE=N'table type')
	drop type a2admin.[Role.TableType];
go
------------------------------------------------
if exists(select * from INFORMATION_SCHEMA.DOMAINS where DOMAIN_SCHEMA=N'a2admin' and DOMAIN_NAME=N'UserGroup.TableType' and DATA_TYPE=N'table type')
	drop type a2admin.[UserGroup.TableType];
go
------------------------------------------------
create type a2admin.[Role.TableType]
as table(
	Id bigint null,
	[Name] nvarchar(255),
	[Key] nvarchar(255),
	[Memo] nvarchar(255)
)
go
------------------------------------------------
create type a2admin.[UserGroup.TableType]
as table(
	Id bigint null,
	ParentId bigint,
	[UserId] bigint,
	[GroupId] bigint
)
go
------------------------------------------------
create procedure a2admin.[Role.Metadata]
as
begin
	set nocount on;

	declare @Role a2admin.[Role.TableType];
	declare @UserGroup a2admin.[UserGroup.TableType];

	select [Role!Role!Metadata]=null, * from @Role;
	select [UsersGroups!Role.UsersGroups!Metadata] = null, * from @UserGroup;
end
go
------------------------------------------------
create procedure a2admin.[Role.Update]
	@TenantId int = null,
	@UserId bigint,
	@Role a2admin.[Role.TableType] readonly,
	@UsersGroups a2admin.[UserGroup.TableType] readonly,
	@RetId bigint = null output
as
begin
	set nocount on;
	set transaction isolation level read committed;
	set xact_abort on;

	exec a2admin.[Ensure.Admin]  @TenantId, @UserId;

	declare @output table(op sysname, id bigint);

	merge a2security.Roles as target
	using @Role as source
	on (target.Id = source.Id)
	when matched then
		update set 
			target.[Name] = source.[Name],
			target.[Key] = source.[Key],
			target.[Memo] = source.Memo
	when not matched by target then 
		insert ([Name], [Key], Memo)
		values ([Name], [Key], Memo)
	output 
		$action op,
		inserted.Id id
	into @output(op, id);
	select top(1) @RetId = id from @output;

	merge a2security.UserRoles as target
	using @UsersGroups as source
	on (target.Id = source.Id)
	when not matched by target then
		insert (RoleId, UserId, GroupId) 
		values (@RetId, UserId, GroupId)
	when not matched by source and target.RoleId=@RetId then
		delete;

	exec a2admin.[Role.Load] @TenantId, @UserId, @RetId;
end
go
------------------------------------------------
create or alter procedure a2admin.[Process.Index]
	@TenantId int = null,
	@UserId bigint,
	@Order nvarchar(255) = N'Id',
	@Dir nvarchar(255) = N'desc',
	@Offset int = 0,
	@PageSize int = 20,
	@Fragment nvarchar(255) = null
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	exec a2admin.[Ensure.Admin]  @TenantId, @UserId;

	--declare @Asc nvarchar(10), @Desc nvarchar(10), @RowCount int;
	--set @Asc = N'asc'; set @Desc = N'desc';
	--set @Dir = isnull(@Dir, @Asc);
	--if @Fragment is not null
	--	set @Fragment = N'%' + upper(@Fragment) + N'%';

	-- list of processes
	with T([Id!!Id], [Kind!!Name], Base, [Owner], DateCreated, DateModified, [!!RowNumber])
	as(
		select p.Id, p.Kind, p.ActionBase, u.UserName, p.DateCreated, p.DateModified
			,[!!RowNumber] = row_number() over (order by p.Id desc)
		from a2workflow.Processes p
			left join a2security.Users u on p.[Owner]=u.Id
	)
	select [Processes!TProcess!Array]=null, *, [!!RowCount] = (select count(1) from T)
	from T
	where [!!RowNumber] > @Offset and [!!RowNumber] <= @Offset + @PageSize
	order by [!!RowNumber];

	select [!$System!] = null, [!Processes!PageSize] = @PageSize, 
		[!Processes!SortOrder] = @Order, [!Processes!SortDir] = @Dir,
		[!Processes!Offset] = @Offset, [!Processes.Fragment!Filter] = @Fragment;
end
go
------------------------------------------------
create or alter procedure a2admin.[Inbox.Index]
	@TenantId int = null,
	@UserId bigint,
	@Order nvarchar(255) = N'Id',
	@Dir nvarchar(255) = N'desc',
	@Offset int = 0,
	@PageSize int = 20,
	@Fragment nvarchar(255) = null
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	exec a2admin.[Ensure.Admin]  @TenantId, @UserId;

	--declare @Asc nvarchar(10), @Desc nvarchar(10), @RowCount int;
	--set @Asc = N'asc'; set @Desc = N'desc';
	--set @Dir = isnull(@Dir, @Asc);
	--if @Fragment is not null
	--	set @Fragment = N'%' + upper(@Fragment) + N'%';

	-- list of inboxes
	with T([Id!!Id], [Bookmark!!Name], ProcessId, [Role], [User], [Text], DateCreated, DateRemoved, [!!RowNumber])
	as(
		select i.Id, i.Bookmark, i.ProcessId, i.[For], u.UserName, i.[Text], i.DateCreated, i.DateRemoved
			,[!!RowNumber] = row_number() over (order by i.Id desc)
		from a2workflow.Inbox i
			left join a2security.Users u on i.ForId=u.Id
		where @Fragment is null or i.ProcessId=try_cast(@Fragment as bigint)
	)
	select [Inboxes!TInbox!Array]=null, *, [!!RowCount] = (select count(1) from T)
	from T
	where [!!RowNumber] > @Offset and [!!RowNumber] <= @Offset + @PageSize
	order by [!!RowNumber];

	select [!$System!] = null, [!Inboxes!PageSize] = @PageSize, 
		[!Inboxes!SortOrder] = @Order, [!Inboxes!SortDir] = @Dir,
		[!Inboxes!Offset] = @Offset, [!Inboxes.Fragment!Filter] = @Fragment;
end
go
------------------------------------------------
begin
	-- create admin menu
	declare @menu table(id bigint, p0 bigint, [name] nvarchar(255), [url] nvarchar(255), icon nvarchar(255), [order] int);
	insert into @menu(id, p0, [name], [url], icon, [order])
	values
		(900, null,	N'Admin',           null,			null,		0),
		(901, 900,	N'Пользователи',	N'identity',	null,		10),
		(902, 900,	N'Бизнес процессы', N'workflow',	null,		20),
		(910, 901,	N'Пользователи',	N'user',		N'user',	10),
		(911, 901,	N'Группы',			N'group',		N'users',	20),
		(912, 901,	N'Роли',			N'role',		N'users',	30),
		(921, 902,	N'Процессы',		N'process',		N'process', 10),
		(922, 902,	N'Задачи',			N'inbox',		N'queue',	20);
			
	merge a2ui.Menu as target
	using @menu as source
	on target.Id=source.id and target.Id >= 900 and target.Id < 1000
	when matched then
		update set
			target.Id = source.id,
			target.[Name] = source.[name],
			target.[Url] = source.[url],
			target.[Icon] = source.icon,
			target.[Order] = source.[order]
	when not matched by target then
		insert(Id, Parent, [Name], [Url], Icon, [Order]) values (id, p0, [name], [url], icon, [order])
	when not matched by source and target.Id >= 900 and target.Id < 1000 then 
		delete;
end
go
------------------------------------------------
if not exists(select * from a2security.Users where Id <> 0)
begin
	set nocount on;
	insert into a2security.Users(Id, UserName, SecurityStamp, PasswordHash, PersonName, EmailConfirmed)
	values (99, N'admin@admin.com', N'c9bb451a-9d2b-4b26-9499-2d7d408ce54e', N'AJcfzvC7DCiRrfPmbVoigR7J8fHoK/xdtcWwahHDYJfKSKSWwX5pu9ChtxmE7Rs4Vg==',
		N'System administrator', 1);
	insert into a2security.UserGroups(UserId, GroupId) values (99, 77), (99, 1); /*predefined values*/
end
go
------------------------------------------------
begin
	set nocount on;
	grant execute on schema ::a2admin to public;
end
go

