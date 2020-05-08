-- SCHEMAS
-------------------------------------
if not exists(select * from INFORMATION_SCHEMA.SCHEMATA where SCHEMA_NAME=N'sample')
begin
	exec sp_executesql N'create schema sample';
end
go

-- TABLES
-------------------------------------
if not exists(select * from INFORMATION_SCHEMA.SEQUENCES where SEQUENCE_SCHEMA=N'sample' and SEQUENCE_NAME=N'SQ_Agents')
	create sequence [sample].SQ_Agents as bigint start with 100 increment by 1;
go
-------------------------------------
if not exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA=N'sample' and TABLE_NAME=N'Agents')
begin
create table [sample].[Agents]
(
	Id bigint not null constraint DF_Agents_Id default(next value for [sample].SQ_Agents)
		constraint PK_Agents primary key,
	[Kind] nchar(4) null,
	[Name] nvarchar(50) not null,
	[Code] nvarchar(16) null,
	[FullName] nvarchar(255) null,
	[Memo] nvarchar(255) null,
	DateCreated datetime not null constraint DF_Agents_DateCreated default(a2sys.fn_getCurrentDate()),
	DateModified datetime not null constraint DF_Agents_DateModified default(a2sys.fn_getCurrentDate())
)
end
go
-------------------------------------
if not exists(select * from INFORMATION_SCHEMA.SEQUENCES where SEQUENCE_SCHEMA=N'sample' and SEQUENCE_NAME=N'SQ_Units')
	create sequence [sample].SQ_Units as bigint start with 100 increment by 1;
go
-------------------------------------
if not exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA=N'sample' and TABLE_NAME=N'Units')
begin
create table [sample].[Units]
(
	Id bigint not null constraint DF_Units_Id default(next value for [sample].SQ_Units)
		constraint PK_Units primary key,
	[Short] nvarchar(8) null,
	[Name] nvarchar(50) null,
	[Memo] nvarchar(255) null,
	DateCreated datetime not null constraint DF_Units_DateCreated default(a2sys.fn_getCurrentDate()),
	DateModified datetime not null constraint DF_Units_DateModified default(a2sys.fn_getCurrentDate())
)
end
go
-------------------------------------
if not exists(select * from INFORMATION_SCHEMA.SEQUENCES where SEQUENCE_SCHEMA=N'sample' and SEQUENCE_NAME=N'SQ_Products')
	create sequence [sample].SQ_Products as bigint start with 100 increment by 1;
go
-------------------------------------
if not exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA=N'sample' and TABLE_NAME=N'Products')
begin
create table [sample].[Products]
(
	Id bigint not null constraint DF_Products_Id default(next value for [sample].SQ_Products)
		constraint PK_Products primary key,
	[Name] nvarchar(255) null,
	[Article] nvarchar(20) null,
	[FullName] nvarchar(255) null,
	[Memo] nvarchar(255) null,
	DateCreated datetime not null constraint DF_Products_DateCreated default(a2sys.fn_getCurrentDate()),
	DateModified datetime not null constraint DF_Products_DateModified default(a2sys.fn_getCurrentDate())
)
end
go
-------------------------------------
if not exists(select * from INFORMATION_SCHEMA.SEQUENCES where SEQUENCE_SCHEMA=N'sample' and SEQUENCE_NAME=N'SQ_Warehouses')
	create sequence [sample].SQ_Warehouses as bigint start with 100 increment by 1;
go
-------------------------------------
if not exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA=N'sample' and TABLE_NAME=N'Warehouses')
begin
create table [sample].[Warehouses]
(
	Id bigint not null constraint DF_Warehouses_Id default(next value for [sample].SQ_Warehouses)
		constraint PK_Warehouses primary key,
	DateCreated datetime not null constraint DF_Warehouses_DateCreated default(a2sys.fn_getCurrentDate()),
	DateModified datetime not null constraint DF_Warehouses_DateModified default(a2sys.fn_getCurrentDate())
)
end
go
-------------------------------------
if not exists(select * from INFORMATION_SCHEMA.SEQUENCES where SEQUENCE_SCHEMA=N'sample' and SEQUENCE_NAME=N'SQ_Documents')
	create sequence [sample].SQ_Documents as bigint start with 100 increment by 1;
go
-------------------------------------
if not exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA=N'sample' and TABLE_NAME=N'Documents')
begin
create table [sample].[Documents]
(
	Id bigint not null constraint DF_Documents_Id default(next value for [sample].SQ_Documents)
		constraint PK_Documents primary key,
	[Kind] nchar(4) null,
	[Date] date null,
	[Customer] bigint null
		constraint FK_Documents_Customer_Agents references [sample].[Agents](Id),
	[Sum] money null,
	[Memo] nvarchar(255) null,
	DateCreated datetime not null constraint DF_Documents_DateCreated default(a2sys.fn_getCurrentDate()),
	DateModified datetime not null constraint DF_Documents_DateModified default(a2sys.fn_getCurrentDate())
)
end
go
-------------------------------------
if not exists(select * from INFORMATION_SCHEMA.SEQUENCES where SEQUENCE_SCHEMA=N'sample' and SEQUENCE_NAME=N'SQ_Rows')
	create sequence [sample].SQ_Rows as bigint start with 100 increment by 1;
go
-------------------------------------
if not exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA=N'sample' and TABLE_NAME=N'Rows')
begin
create table [sample].[Rows]
(
	Id bigint not null constraint DF_Rows_Id default(next value for [sample].SQ_Rows)
		constraint PK_Rows primary key,
	RowNo int not null,
	[Document] bigint null
		constraint FK_Rows_Document_Documents references [sample].[Documents](Id),
	[Product] bigint null
		constraint FK_Rows_Product_Products references [sample].[Products](Id),
	[Qty] float null,
	[Price] money null,
	[Sum] money null,
	[Memo] nvarchar(255) null
)
end
go
-------------------------------------
if not exists(select * from INFORMATION_SCHEMA.SEQUENCES where SEQUENCE_SCHEMA=N'sample' and SEQUENCE_NAME=N'SQ_WJournals')
	create sequence [sample].SQ_WJournals as bigint start with 100 increment by 1;
go
-------------------------------------
if not exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA=N'sample' and TABLE_NAME=N'WJournals')
begin
create table [sample].[WJournals]
(
	Id bigint not null constraint DF_WJournals_Id default(next value for [sample].SQ_WJournals)
		constraint PK_WJournals primary key,
	DateCreated datetime not null constraint DF_WJournals_DateCreated default(a2sys.fn_getCurrentDate()),
	DateModified datetime not null constraint DF_WJournals_DateModified default(a2sys.fn_getCurrentDate())
)
end
go

-- TABLE TYPES

-------------------------------------
if exists(select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'sample' and ROUTINE_NAME=N'Agent.Update')
	drop procedure [sample].[Agent.Update];
go
-------------------------------------
if exists(select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'sample' and ROUTINE_NAME=N'Unit.Update')
	drop procedure [sample].[Unit.Update];
go
-------------------------------------
if exists(select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'sample' and ROUTINE_NAME=N'Product.Update')
	drop procedure [sample].[Product.Update];
go
-------------------------------------
if exists(select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'sample' and ROUTINE_NAME=N'Document.Update')
	drop procedure [sample].[Document.Update];
go
-------------------------------------
if exists(select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'sample' and ROUTINE_NAME=N'Row.Update')
	drop procedure [sample].[Row.Update];
go-------------------------------------
if exists(select * from INFORMATION_SCHEMA.DOMAINS where DOMAIN_SCHEMA = N'sample' and DOMAIN_NAME = N'Agent.TableType')
	drop type [sample].[Agent.TableType];
go
-------------------------------------
create type [sample].[Agent.TableType]
as table (
	Id bigint,
	[Kind] nchar(4),
	[Name] nvarchar(50),
	[Code] nvarchar(16),
	[FullName] nvarchar(255),
	[Memo] nvarchar(255)
)
go
-------------------------------------
if exists(select * from INFORMATION_SCHEMA.DOMAINS where DOMAIN_SCHEMA = N'sample' and DOMAIN_NAME = N'Unit.TableType')
	drop type [sample].[Unit.TableType];
go
-------------------------------------
create type [sample].[Unit.TableType]
as table (
	Id bigint,
	[Short] nvarchar(8),
	[Name] nvarchar(50),
	[Memo] nvarchar(255)
)
go
-------------------------------------
if exists(select * from INFORMATION_SCHEMA.DOMAINS where DOMAIN_SCHEMA = N'sample' and DOMAIN_NAME = N'Product.TableType')
	drop type [sample].[Product.TableType];
go
-------------------------------------
create type [sample].[Product.TableType]
as table (
	Id bigint,
	[Name] nvarchar(255),
	[Article] nvarchar(20),
	[FullName] nvarchar(255),
	[Memo] nvarchar(255)
)
go
-------------------------------------
if exists(select * from INFORMATION_SCHEMA.DOMAINS where DOMAIN_SCHEMA = N'sample' and DOMAIN_NAME = N'Document.TableType')
	drop type [sample].[Document.TableType];
go
-------------------------------------
create type [sample].[Document.TableType]
as table (
	Id bigint,
	[Kind] nchar(4),
	[Date] date,
	[Customer] bigint,
	[Sum] money,
	[Memo] nvarchar(255)
)
go
-------------------------------------
if exists(select * from INFORMATION_SCHEMA.DOMAINS where DOMAIN_SCHEMA = N'sample' and DOMAIN_NAME = N'Row.TableType')
	drop type [sample].[Row.TableType];
go
-------------------------------------
create type [sample].[Row.TableType]
as table (
	Id bigint,
	ParentId bigint,
	RowNumber int,
	[Product] bigint,
	[Qty] float,
	[Price] money,
	[Sum] money,
	[Memo] nvarchar(255)
)
go
-- PROCEDURES
-------------------------------------
create or alter procedure [sample].[Agent.Index]
@UserId bigint,
@Id bigint = null,
@Kind nchar(4) = null,
@Offset int = 0,
@PageSize int = 20,
@Order nvarchar(255) = N'Id',
@Dir nvarchar(20) = N'desc',
@Fragment nvarchar(255) = null
as 
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	declare @rawFilter nvarchar(255);
	set @rawFilter = @Fragment;
	set @Fragment = N'%' + upper(@Fragment) + N'%';
	set @Order = lower(@Order);
	set @Dir = lower(@Dir);

	declare @paged table(_id bigint, _no int identity(1, 1), _rows int);

	insert into @paged(_id, _rows)
	select a.Id, count(*) over ()
	from 
		[sample].[Agents] a
	where 
		a.Kind = @Kind and (@Fragment is null or upper(a.Name) like @Fragment or upper(a.Code) like @Fragment or upper(a.FullName) like @Fragment or upper(a.Memo) like @Fragment)
	order by 
	case when @Dir=N'asc' then
		case @Order
			when N'name' then a.[Name]
			when N'code' then a.[Code]
			when N'fullname' then a.[FullName]
			when N'memo' then a.[Memo]
		end
	end asc,
	case when @Dir=N'desc' then
		case @Order
			when N'name' then a.[Name]
			when N'code' then a.[Code]
			when N'fullname' then a.[FullName]
			when N'memo' then a.[Memo]
		end
	end desc,
	case when @Dir=N'asc' then
		case @Order
			when N'id' then a.Id
		end
	end asc,
	case when @Dir=N'desc' then
		case @Order
			when N'id' then a.Id
		end
	end desc,
	a.Id desc
	offset @Offset rows fetch next @PageSize rows only
	option (recompile);

	select [Agents!TAgent!Array] = null, [Id!!Id] = a.Id, a.[Kind], a.[Name], a.[Code], a.[FullName], a.[Memo],
		[!!RowCount] = t._rows
	from [sample].[Agents] a inner join @paged t on t._id = a.Id
	order by t._no;


	-- system data
	select [!$System!] = null,  [!Agents!PageSize] = @PageSize, [!Agents!Offset] = @Offset,
		[!Agents!SortOrder] = @Order,  [!Agents!SortDir] = @Dir, 
		[!Agents.Fragment!Filter] = @rawFilter;
end
go
-------------------------------------
create or alter procedure [sample].[Agent.Load]
@UserId bigint,
@Kind nchar(4) = null,
@Id bigint = null
as 
begin
	set nocount on;
	set transaction isolation level read uncommitted;
	select [Agent!TAgent!Object] = null, [Id!!Id] = a.Id, a.[Kind], a.[Name], a.[Code], a.[FullName], a.[Memo]
	from [sample].[Agents] a
	where a.Id = @Id;
end
go
-------------------------------------
create or alter procedure [sample].[Agent.Metadata]
as 
begin
	set nocount on;
	set transaction isolation level read uncommitted;
	declare @Agent [sample].[Agent.TableType];

	select [Agent!Agent!Metadata] = null, * from @Agent;
end
go
-------------------------------------
create or alter procedure [sample].[Agent.Update]
@UserId bigint,
@Kind nchar(4) = null,
@Agent [sample].[Agent.TableType] readonly
as
begin
	set transaction isolation level read committed;
	set xact_abort on;

	declare @RetId bigint;
	declare @output table(op sysname, id bigint);

	merge [sample].[Agents] as t
	using @Agent as s
	on (t.Id = s.Id)
	when matched then update set 
		t.[Name] = s.[Name],
		t.[Code] = s.[Code],
		t.[FullName] = s.[FullName],
		t.[Memo] = s.[Memo],
		DateModified = a2sys.fn_getCurrentDate()
	when not matched by target then 
	insert ([Kind], [Name], [Code], [FullName], [Memo])
	values (@Kind, [Name], [Code], [FullName], [Memo])

	output $action, inserted.Id into @output(op, id);
	
	select top(1) @RetId = id from @output;

	execute [sample].[Agent.Load] @UserId = @UserId, @Id = @RetId;
end
go
-------------------------------------
create or alter procedure [sample].[Unit.Index]
@UserId bigint,
@Id bigint = null,
@Offset int = 0,
@PageSize int = 20,
@Order nvarchar(255) = N'Id',
@Dir nvarchar(20) = N'desc',
@Fragment nvarchar(255) = null
as 
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	declare @rawFilter nvarchar(255);
	set @rawFilter = @Fragment;
	set @Fragment = N'%' + upper(@Fragment) + N'%';
	set @Order = lower(@Order);
	set @Dir = lower(@Dir);

	declare @paged table(_id bigint, _no int identity(1, 1), _rows int);

	insert into @paged(_id, _rows)
	select u.Id, count(*) over ()
	from 
		[sample].[Units] u
	where 
		(@Fragment is null or upper(u.Short) like @Fragment or upper(u.Name) like @Fragment or upper(u.Memo) like @Fragment)
	order by 
	case when @Dir=N'asc' then
		case @Order
			when N'short' then u.[Short]
			when N'name' then u.[Name]
			when N'memo' then u.[Memo]
		end
	end asc,
	case when @Dir=N'desc' then
		case @Order
			when N'short' then u.[Short]
			when N'name' then u.[Name]
			when N'memo' then u.[Memo]
		end
	end desc,
	case when @Dir=N'asc' then
		case @Order
			when N'id' then u.Id
		end
	end asc,
	case when @Dir=N'desc' then
		case @Order
			when N'id' then u.Id
		end
	end desc,
	u.Id desc
	offset @Offset rows fetch next @PageSize rows only
	option (recompile);

	select [Units!TUnit!Array] = null, [Id!!Id] = u.Id, u.[Short], u.[Name], u.[Memo],
		[!!RowCount] = t._rows
	from [sample].[Units] u inner join @paged t on t._id = u.Id
	order by t._no;


	-- system data
	select [!$System!] = null,  [!Units!PageSize] = @PageSize, [!Units!Offset] = @Offset,
		[!Units!SortOrder] = @Order,  [!Units!SortDir] = @Dir, 
		[!Units.Fragment!Filter] = @rawFilter;
end
go
-------------------------------------
create or alter procedure [sample].[Unit.Load]
@UserId bigint,
@Id bigint = null
as 
begin
	set nocount on;
	set transaction isolation level read uncommitted;
	select [Unit!TUnit!Object] = null, [Id!!Id] = u.Id, u.[Short], u.[Name], u.[Memo]
	from [sample].[Units] u
	where u.Id = @Id;
end
go
-------------------------------------
create or alter procedure [sample].[Unit.Metadata]
as 
begin
	set nocount on;
	set transaction isolation level read uncommitted;
	declare @Unit [sample].[Unit.TableType];

	select [Unit!Unit!Metadata] = null, * from @Unit;
end
go
-------------------------------------
create or alter procedure [sample].[Unit.Update]
@UserId bigint,
@Unit [sample].[Unit.TableType] readonly
as
begin
	set transaction isolation level read committed;
	set xact_abort on;

	declare @RetId bigint;
	declare @output table(op sysname, id bigint);

	merge [sample].[Units] as t
	using @Unit as s
	on (t.Id = s.Id)
	when matched then update set 
		t.[Short] = s.[Short],
		t.[Name] = s.[Name],
		t.[Memo] = s.[Memo],
		DateModified = a2sys.fn_getCurrentDate()
	when not matched by target then 
	insert ([Short], [Name], [Memo])
	values ([Short], [Name], [Memo])

	output $action, inserted.Id into @output(op, id);
	
	select top(1) @RetId = id from @output;

	execute [sample].[Unit.Load] @UserId = @UserId, @Id = @RetId;
end
go
-------------------------------------
create or alter procedure [sample].[Product.Index]
@UserId bigint,
@Id bigint = null,
@Offset int = 0,
@PageSize int = 20,
@Order nvarchar(255) = N'Id',
@Dir nvarchar(20) = N'desc',
@Fragment nvarchar(255) = null
as 
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	declare @rawFilter nvarchar(255);
	set @rawFilter = @Fragment;
	set @Fragment = N'%' + upper(@Fragment) + N'%';
	set @Order = lower(@Order);
	set @Dir = lower(@Dir);

	declare @paged table(_id bigint, _no int identity(1, 1), _rows int);

	insert into @paged(_id, _rows)
	select p.Id, count(*) over ()
	from 
		[sample].[Products] p
	where 
		(@Fragment is null or upper(p.Name) like @Fragment or upper(p.Article) like @Fragment or upper(p.FullName) like @Fragment or upper(p.Memo) like @Fragment)
	order by 
	case when @Dir=N'asc' then
		case @Order
			when N'name' then p.[Name]
			when N'article' then p.[Article]
			when N'fullname' then p.[FullName]
			when N'memo' then p.[Memo]
		end
	end asc,
	case when @Dir=N'desc' then
		case @Order
			when N'name' then p.[Name]
			when N'article' then p.[Article]
			when N'fullname' then p.[FullName]
			when N'memo' then p.[Memo]
		end
	end desc,
	case when @Dir=N'asc' then
		case @Order
			when N'id' then p.Id
		end
	end asc,
	case when @Dir=N'desc' then
		case @Order
			when N'id' then p.Id
		end
	end desc,
	p.Id desc
	offset @Offset rows fetch next @PageSize rows only
	option (recompile);

	select [Products!TProduct!Array] = null, [Id!!Id] = p.Id, p.[Name], p.[Article], p.[FullName], p.[Memo],
		[!!RowCount] = t._rows
	from [sample].[Products] p inner join @paged t on t._id = p.Id
	order by t._no;


	-- system data
	select [!$System!] = null,  [!Products!PageSize] = @PageSize, [!Products!Offset] = @Offset,
		[!Products!SortOrder] = @Order,  [!Products!SortDir] = @Dir, 
		[!Products.Fragment!Filter] = @rawFilter;
end
go
-------------------------------------
create or alter procedure [sample].[Product.Load]
@UserId bigint,
@Id bigint = null
as 
begin
	set nocount on;
	set transaction isolation level read uncommitted;
	select [Product!TProduct!Object] = null, [Id!!Id] = p.Id, p.[Name], p.[Article], p.[FullName], p.[Memo]
	from [sample].[Products] p
	where p.Id = @Id;
end
go
-------------------------------------
create or alter procedure [sample].[Product.Metadata]
as 
begin
	set nocount on;
	set transaction isolation level read uncommitted;
	declare @Product [sample].[Product.TableType];

	select [Product!Product!Metadata] = null, * from @Product;
end
go
-------------------------------------
create or alter procedure [sample].[Product.Update]
@UserId bigint,
@Product [sample].[Product.TableType] readonly
as
begin
	set transaction isolation level read committed;
	set xact_abort on;

	declare @RetId bigint;
	declare @output table(op sysname, id bigint);

	merge [sample].[Products] as t
	using @Product as s
	on (t.Id = s.Id)
	when matched then update set 
		t.[Name] = s.[Name],
		t.[Article] = s.[Article],
		t.[FullName] = s.[FullName],
		t.[Memo] = s.[Memo],
		DateModified = a2sys.fn_getCurrentDate()
	when not matched by target then 
	insert ([Name], [Article], [FullName], [Memo])
	values ([Name], [Article], [FullName], [Memo])

	output $action, inserted.Id into @output(op, id);
	
	select top(1) @RetId = id from @output;

	execute [sample].[Product.Load] @UserId = @UserId, @Id = @RetId;
end
go
-------------------------------------
create or alter procedure [sample].[Warehouse.Index]
@UserId bigint,
@Id bigint = null,
@Offset int = 0,
@PageSize int = 20,
@Order nvarchar(255) = N'Id',
@Dir nvarchar(20) = N'desc',
@Fragment nvarchar(255) = null
as 
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	declare @rawFilter nvarchar(255);
	set @rawFilter = @Fragment;
	set @Fragment = N'%' + upper(@Fragment) + N'%';
	set @Order = lower(@Order);
	set @Dir = lower(@Dir);

	declare @paged table(_id bigint, _no int identity(1, 1), _rows int);

	insert into @paged(_id, _rows)
	select w.Id, count(*) over ()
	from 
		[sample].[Warehouses] w
	where 
		(@Fragment is null)
	order by 
	case when @Dir=N'asc' then
		case @Order
			when N'id' then w.Id
		end
	end asc,
	case when @Dir=N'desc' then
		case @Order
			when N'id' then w.Id
		end
	end desc,
	w.Id desc
	offset @Offset rows fetch next @PageSize rows only
	option (recompile);

	select [Warehouses!TWarehouse!Array] = null, [Id!!Id] = w.Id,
		[!!RowCount] = t._rows
	from [sample].[Warehouses] w inner join @paged t on t._id = w.Id
	order by t._no;


	-- system data
	select [!$System!] = null,  [!Warehouses!PageSize] = @PageSize, [!Warehouses!Offset] = @Offset,
		[!Warehouses!SortOrder] = @Order,  [!Warehouses!SortDir] = @Dir, 
		[!Warehouses.Fragment!Filter] = @rawFilter;
end
go
-------------------------------------
create or alter procedure [sample].[Warehouse.Load]
@UserId bigint,
@Id bigint = null
as 
begin
	set nocount on;
	set transaction isolation level read uncommitted;
	select [Warehouse!TWarehouse!Object] = null, [Id!!Id] = w.Id
	from [sample].[Warehouses] w
	where w.Id = @Id;
end
go
-------------------------------------
create or alter procedure [sample].[Document.Index]
@UserId bigint,
@Id bigint = null,
@Kind nchar(4) = null,
@Offset int = 0,
@PageSize int = 20,
@Order nvarchar(255) = N'Id',
@Dir nvarchar(20) = N'desc',
@Fragment nvarchar(255) = null
as 
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	declare @rawFilter nvarchar(255);
	set @rawFilter = @Fragment;
	set @Fragment = N'%' + upper(@Fragment) + N'%';
	set @Order = lower(@Order);
	set @Dir = lower(@Dir);

	declare @paged table(_id bigint, _no int identity(1, 1), _rows int);

	insert into @paged(_id, _rows)
	select d.Id, count(*) over ()
	from 
		[sample].[Documents] d
	where 
		d.Kind = @Kind and (@Fragment is null or upper(d.Date) like @Fragment or upper(d.Customer) like @Fragment or upper(d.Sum) like @Fragment or upper(d.Memo) like @Fragment)
	order by 
	case when @Dir=N'asc' then
		case @Order
			when N'memo' then d.[Memo]
		end
	end asc,
	case when @Dir=N'desc' then
		case @Order
			when N'memo' then d.[Memo]
		end
	end desc,
	case when @Dir=N'asc' then
		case @Order
			when N'id' then d.Id
		end
	end asc,
	case when @Dir=N'desc' then
		case @Order
			when N'id' then d.Id
		end
	end desc,
	d.Id desc
	offset @Offset rows fetch next @PageSize rows only
	option (recompile);

	select [Documents!TDocument!Array] = null, [Id!!Id] = d.Id, d.[Kind], d.[Date], d.[Customer], d.[Sum], d.[Memo],
		[!!RowCount] = t._rows
	from [sample].[Documents] d inner join @paged t on t._id = d.Id
	order by t._no;


	-- system data
	select [!$System!] = null,  [!Documents!PageSize] = @PageSize, [!Documents!Offset] = @Offset,
		[!Documents!SortOrder] = @Order,  [!Documents!SortDir] = @Dir, 
		[!Documents.Fragment!Filter] = @rawFilter;
end
go
-------------------------------------
create or alter procedure [sample].[Document.Load]
@UserId bigint,
@Kind nchar(4) = null,
@Id bigint = null
as 
begin
	set nocount on;
	set transaction isolation level read uncommitted;
	select [Document!TDocument!Object] = null, [Id!!Id] = d.Id, d.[Kind], d.[Date], d.[Customer], d.[Sum], d.[Memo]
	from [sample].[Documents] d
	where d.Id = @Id;
end
go
-------------------------------------
create or alter procedure [sample].[Document.Metadata]
as 
begin
	set nocount on;
	set transaction isolation level read uncommitted;
	declare @Document [sample].[Document.TableType];

	select [Document!Document!Metadata] = null, * from @Document;
end
go
-------------------------------------
create or alter procedure [sample].[Document.Update]
@UserId bigint,
@Kind nchar(4) = null,
@Document [sample].[Document.TableType] readonly
,
@Row [sample].[Row.TableType] readonly

as
begin
	set transaction isolation level read committed;
	set xact_abort on;

	declare @RetId bigint;
	declare @output table(op sysname, id bigint);

	merge [sample].[Documents] as t
	using @Document as s
	on (t.Id = s.Id)
	when matched then update set 
		t.[Date] = s.[Date],
		t.[Customer] = s.[Customer],
		t.[Sum] = s.[Sum],
		t.[Memo] = s.[Memo],
		DateModified = a2sys.fn_getCurrentDate()
	when not matched by target then 
	insert ([Kind], [Date], [Customer], [Sum], [Memo])
	values (@Kind, [Date], [Customer], [Sum], [Memo])

	output $action, inserted.Id into @output(op, id);
	
	select top(1) @RetId = id from @output;

	execute [sample].[Document.Load] @UserId = @UserId, @Id = @RetId;
end
go
