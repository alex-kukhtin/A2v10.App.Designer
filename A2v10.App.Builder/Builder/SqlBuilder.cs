using System;
using System.Collections.Generic;
using System.Text;
using System.Linq;

namespace A2v10.App.Builder
{
	public class SqlBuilder
	{
		const String divider = "-------------------------------------";

		public String BuildProcedures(ICatalog model)
		{
			var sb = new StringBuilder();
			sb.Append(BuildLoad(model));
			sb.Append(BuildPagedIndex(model));
			return sb.ToString();
		}

		public String BuildPagedIndex(ICatalog model)
		{
			var propName = model.Plural;
			ITable table = model.GetTable();
			var alias = table.name[0].ToString().ToLowerInvariant();
			var tableName = table.Plural;

			var sb = new StringBuilder();
sb.AppendLine(
@$"{divider}
create or alter procedure [{model.Schema}].[{model.name}.Index]
@UserId bigint,
@Id bigint = null,{GetProcParams(table)}
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
");

sb.AppendLine(
@$"	declare @paged table(_id bigint, _no int identity(1, 1), _rows int);

	insert into @paged(_id, _rows)
	select {alias}.Id, count(*) over ()
	from 
		[{table.Schema}].[{tableName}] {alias}
	where 
		{GetWhereParams(alias, table)}(@Fragment is null{GetFragmentParams(alias, table)})
	order by 
{GetOrderByFields(alias, table)}
	offset @Offset rows fetch next @PageSize rows only
	option (recompile);
");
		
sb.AppendLine(
@$"	select [{propName}!{table.TypeName}!Array] = null, {GetFields(alias, table)},
		[!!RowCount] = t._rows
	from [{table.Schema}].[{tableName}] {alias} inner join @paged t on t._id = {alias}.Id
	order by t._no;
");

// system recordset
sb.Append(
@$"
	-- system data
	select [!$System!] = null,  [!{propName}!PageSize] = @PageSize, [!{propName}!Offset] = @Offset,
		[!{propName}!SortOrder] = @Order,  [!{propName}!SortDir] = @Dir, 
		[!{propName}.Fragment!Filter] = @rawFilter;
end
go
"
);
			return sb.ToString();
		}


		String GetFields(String alias, ITable table)
		{
			var sb = new StringBuilder();
			sb.Append($"[Id!!Id] = {alias}.Id,");
			if (table.fields != null)
			{
				foreach (var f in table.fields)
				{
					if (f.Value.parameter)
						continue;
					sb.Append($" {alias}.[{f.Key}],");
				}
			}
			return sb.RemoveLastComma().ToString();
		}

		String GetTableFields(ITable table)
		{
			var sb = new StringBuilder();
			if (table.fields != null)
			{
				foreach (var f in table.fields)
				{
					sb.AppendLine();
					sb.Append($"	[{f.Key}] {f.Value.SqlField(table.Plural)},");
				}
			}
			return sb.ToString();
		}

		String GetWhereParams(String alias, ITable table)
		{
			var prms = table.fields?.Where(x => x.Value.parameter);
			if (prms == null)
				return String.Empty;
			var sb = new StringBuilder();
			foreach (var f in prms)
			{
				sb.Append($"{alias}.{f.Key} = @{f.Key} and ");
			}
			return sb.ToString();
		}

		String GetFragmentParams(String alias, ITable table)
		{
			var fields = table.fields?.Where(x => !x.Value.parameter);
			if (fields == null)
				return String.Empty;
			var sb = new StringBuilder();
			foreach (var f in fields)
			{
				sb.Append($" or upper({alias}.{f.Key}) like @Fragment");
			}
			return sb.ToString();
		}

		String GetProcParams(ITable table)
		{
			var prms = table.fields?.Where(x => x.Value.parameter);
			if (prms == null)
				return String.Empty;
			var sb = new StringBuilder();
			foreach (var f in prms)
			{
				sb.AppendLine();
				sb.Append($"@{f.Key} {f.Value.SqlType()} = null,");
			}
			return sb.ToString();
		}

		String GetOrderByFields(String alias, ITable table)
		{
			void AppendHeader(StringBuilder sb, String dir)
			{
				sb.AppendLine(@$"	case when @Dir=N'{dir}' then")
					.AppendLine("		case @Order");
			};
			void AppendFooter(StringBuilder sb, String dir)
			{
				sb.AppendLine("		end")
				.AppendLine($"	end {dir},");
			}

			void AppendBlock(StringBuilder sb, String dir, StringBuilder block)
			{
				if (block.Length == 0)
					return;
				AppendHeader(sb, dir);
				sb.Append(block);
				AppendFooter(sb, dir);
			}

			var sbStr = new StringBuilder();
			var strFields = table.fields?.Where(x => !x.Value.parameter && x.Value.IsOrderByAsString());
			if (strFields != null)
			{
				foreach (var f in strFields)
					sbStr.AppendLine($"			when N'{f.Key.ToLowerInvariant()}' then {alias}.[{f.Key}]");
			}
			var sbNum = new StringBuilder($"			when N'id' then {alias}.Id").AppendLine();

			var sb = new StringBuilder();

			AppendBlock(sb, "asc", sbStr);
			AppendBlock(sb, "desc", sbStr);

			AppendBlock(sb, "asc", sbNum);
			AppendBlock(sb, "desc", sbNum);

			sb.AppendLine($"	{alias}.Id desc");
			return sb.ToString();
		}

		public String BuildLoad(ICatalog model)
		{
			ITable table = model.GetTable();
			var alias = table.name[0].ToString().ToLowerInvariant();
			var tableName = table.Plural;
			var sb = new StringBuilder();

			sb.AppendLine(
			@$"{divider}
create or alter procedure [{model.Schema}].[{model.name}.Load]
@UserId bigint,{GetProcParams(table)}
@Id bigint = null
as 
begin
	set nocount on;
	set transaction isolation level read uncommitted;
	select [{table.name}!{table.TypeName}!Object] = null, {GetFields(alias, table)}
	from [{table.Schema}].[{tableName}] {alias}
	where {alias}.Id = @Id;
end
go
");
			return sb.ToString();
		}

		public String BuildSchema(String schema)
		{
			return
$@"{divider}
if not exists(select * from INFORMATION_SCHEMA.SCHEMATA where SCHEMA_NAME=N'{schema}')
begin
	exec sp_executesql N'create schema {schema}';
end
go
";
		}

		public String BuildTable(ITable table)
		{
			var tableName = table.Plural;
			return
$@"{divider}
if not exists(select * from INFORMATION_SCHEMA.SEQUENCES where SEQUENCE_SCHEMA=N'{table.Schema}' and SEQUENCE_NAME=N'SQ_{tableName}')
	create sequence [{table.Schema}].SQ_{tableName} as bigint start with 100 increment by 1;
go
{divider}
if not exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA=N'{table.Schema}' and TABLE_NAME=N'{tableName}')
begin
create table [{table.Schema}].[{tableName}]
(
	Id bigint not null constraint DF_{tableName}_Id default(next value for [{table.Schema}].SQ_{tableName})
		constraint PK_{tableName} primary key,{GetTableFields(table)}
	DateCreated datetime not null constraint DF_{tableName}_DateCreated default(a2sys.fn_getCurrentDate()),
	DateModified datetime not null constraint DF_{tableName}_DateModified default(a2sys.fn_getCurrentDate()),
)
end
go";
		}
	}
}
