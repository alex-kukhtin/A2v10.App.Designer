
using System;
using System.Linq;
using System.Text;
using A2v10.App.Builder.Interfaces;

namespace A2v10.App.Builder.SqlServer
{
	public class SqlProcedureBuilder
	{
		private readonly ISolutionOptions _opts;

		public SqlProcedureBuilder(ISolutionOptions opts)
		{
			_opts = opts;
		}

		public String GetProcParams(ITable table)
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

	declare @{table.name} [{table.Schema}].[{table.name}.TableType];");
			if (table.details != null)
			{
				foreach (var dd in table.details.Values)
					sb.AppendLine($"	declare @{dd.Plural} [{dd.Schema}].[{dd.name}.TableType];");
			}
			// main table
			sb.AppendLine();
			sb.AppendLine($"	select [{table.name}!{table.name}!Metadata] = null, * from @{table.name};");

			if (table.details != null)
			{
				foreach (var dd in table.details.Values)
					sb.AppendLine($"	select [{dd.Plural}!{table.name}.{dd.Plural}!Metadata]=null, * from @{dd.Plural};");
			}
			// footer
			sb.AppendLine($"end{Environment.NewLine}go");
			return sb.ToString();
		}


		String BuildDetails(ITable model)
		{
			if (model == null) return null;
			if (model.details == null)
				return null;
			var sb = new StringBuilder();
			foreach (var (_, t) in model.details)
			{
				var tableName = t.Plural;
				sb.AppendLine(@$"
	merge [{t.Schema}].[{tableName}] as t
	using @{tableName} as s
	on t.[Id] = s.[Id] and t.[{model.name}] = @RetId
	when matched then update set {GetUpdateFields(t, model)}
	when not matched by target then {GetInsertFields(t, model)}
	when not matched by source and t.[{model.name}] = @RetId then delete;"
				);
			}
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
	when matched then update set {GetUpdateFields(table, null)}
	when not matched by target then {GetInsertFields(table, null)}
	output $action, inserted.Id into @output(op, id);

	select top(1) @RetId = id from @output;
{BuildDetails(table)}
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
			sb.AppendLine($"@UserId bigint,{GetProcParams(table)}");

			sb.Append($"@{table.name} [{table.Schema}].[{table.name}.TableType] readonly");

			if (table.details != null)
			{
				foreach (var d in table.details) {
					var row = d.Value;
					sb.AppendLine(",")
					.Append($"@{row.Plural} [{row.Schema}].[{row.name}.TableType] readonly");
				}
			}
			sb.AppendLine();
			return sb.ToString();
		}

		String GetUpdateFields(ITable table, ITable parent)
		{
			var sb = new StringBuilder();
			if (parent != null)
			{
				sb.AppendLine();
				sb.Append("		t.RowNo = s.RowNumber,");
			}
			sb.AppendJoin(",", table.fields.Where(f => !f.Value.parameter).Select(
					f => $"{Environment.NewLine}		t.[{f.Key}] = s.[{f.Key}]")
				);
			if (parent == null)
				sb.AppendLine(",")
					.Append("		DateModified = a2sys.fn_getCurrentDate()");
			return sb.ToString();
		}

		String GetInsertFields(ITable table, ITable parent)
		{
			var sb = new StringBuilder()
				.AppendLine()
				.Append($"	insert (");
			if (parent != null)
				sb.Append($"[{parent.name}], RowNo, ");
			sb.AppendJoin(", ", table.fields.Select(f => $"[{f.Key}]"))
				.AppendLine(")");
			sb.Append($"	values (");
			if (parent != null)
				sb.Append("@RetId, RowNumber, ");
			sb.AppendJoin(", ", table.fields.Select(f => f.Value.parameter ? $"@{f.Key}" : $"[{f.Key}]"))
				.Append(")");
			return sb.ToString();
		}

		public String BuildDropBeforeTableType(ITable model)
		{
			ITable table = model.GetBaseTable();
			if (table.fields == null)
				return null;
			return
$@"
{SqlBuilder.divider}
drop procedure if exists [{table.Schema}].[{table.name}.Update];
drop procedure if exists [{table.Schema}].[{table.name}.Metadata];
go";
		}
	}
}
