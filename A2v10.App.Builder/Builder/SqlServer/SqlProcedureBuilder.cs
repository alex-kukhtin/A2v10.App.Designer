using A2v10.App.Builder.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace A2v10.App.Builder.SqlServer
{
	public class SqlProcedureBuilder
	{
		ISolutionOptions _opts;

		public SqlProcedureBuilder(ISolutionOptions opts)
		{
			_opts = opts;
		}

		public String BuildMetadata(ITable model)
		{
			ITable table = model.GetBaseTable();
			if (table.fields == null)
				return null;

			var sb = new StringBuilder();

			sb.AppendLine(
			@$"{SqlBuilder.divider}
create or alter procedure [{model.Schema}].[{model.name}.Metadata]
as 
begin
	set nocount on;
	set transaction isolation level read uncommitted;
	declare @{table.name} [{table.Schema}].[{table.name}.TableType];

	select [{table.name}!{table.name}!Metadata] = null, * from @{table.name};
end
go");
			return sb.ToString();
		}

		public String BuildUpdate(ITable model)
		{
			ITable table = model.GetBaseTable();
			if (table.fields == null)
				return null;
			var tableName = table.Plural;
			var sb = new StringBuilder();
			sb.AppendLine(SqlBuilder.divider)
			.AppendLine($"create or alter procedure [{model.Schema}].[{model.name}.Update]")
			.Append(GetUpdateProcedureParameters(table))
			.AppendLine(
@$"as
begin
	set transaction isolation level read committed;
	set xact_abort on;

	declare @RetId bigint;
	declare @output table(op sysname, id bigint);

	merge [{table.Schema}].[{tableName}] as t
	using @{table.name} as s
	on (t.Id = s.Id)
	when matched then update set {GetUpdateFields(table)}
	when not matched by target then {GetInsertFields(table)}
	output $action, inserted.Id into @output(op, id);
	
	select top(1) @RetId = id from @output;

	execute [{table.Schema}].[{table.name}.Load] @UserId = @UserId, @Id = @RetId;"
			);

			sb.AppendLine(@"end")
				.AppendLine("go");
			return sb.ToString();
		}

		String GetUpdateProcedureParameters(ITable table)
		{
			var sb = new StringBuilder();
			if (_opts.MultiTenant)
				sb.AppendLine("@TenantId int = 1");
			sb.AppendLine("@UserId bigint,");

			sb.AppendJoin(String.Empty, table.fields.Where(
				f => f.Value.parameter).Select(
					f => $"@{f.Key} {f.Value.SqlType()} = null,{Environment.NewLine}"
				)
			)
			.AppendLine($"@{table.name} [{table.Schema}].[{table.name}.TableType] readonly");

			if (table.details != null)
			{
				foreach (var d in table.details) {
					var row = d.Value;
					sb.AppendLine(",")
					.AppendLine($"@{row.name} [{row.Schema}].[{row.name}.TableType] readonly");
				}
				sb.AppendLine();
			}
			return sb.ToString();
		}

		String GetUpdateFields(ITable table)
		{
			return new StringBuilder()
				.AppendJoin(",", table.fields.Where(f => !f.Value.parameter).Select(
					f => $"{Environment.NewLine}		t.[{f.Key}] = s.[{f.Key}]")
				)
				.AppendLine(",")
				.Append("		DateModified = a2sys.fn_getCurrentDate()")
				.ToString();
		}

		String GetInsertFields(ITable table)
		{
			return new StringBuilder()
				.AppendLine()
				.Append($"	insert (")
				.AppendJoin(", ", table.fields.Select(f => $"[{f.Key}]"))
				.AppendLine(")")
				.Append($"	values (")
				.AppendJoin(", ", table.fields.Select(f => f.Value.parameter ? $"@{f.Key}" : $"[{f.Key}]"))
				.AppendLine(")")
				.ToString();
		}

		public String BuildDropBeforeTableType(ITable model)
		{
			ITable table = model.GetBaseTable();
			if (table.fields == null)
				return null;
			return
$@"
{SqlBuilder.divider}
if exists(select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'{table.Schema}' and ROUTINE_NAME=N'{table.name}.Update')
	drop procedure [{table.Schema}].[{table.name}.Update];
go";
		}
	}
}
