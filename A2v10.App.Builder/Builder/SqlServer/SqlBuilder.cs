/* Copyright © 2019-2020 Alex Kukhtin. All rights reserved. */

using System;
using System.Text;
using System.Linq;
using A2v10.App.Builder.Interfaces;
using System.Collections;
using System.Collections.Generic;

namespace A2v10.App.Builder.SqlServer
{
	public class SqlBuilder : ISqlBuilder
	{
		public const String divider = "-------------------------------------";
		const Int32 PAGE_SIZE = 20;

		private readonly SqlTableTypeBuilder _tableTypeBuilder;
		private readonly SqlProcedureBuilder _procedureBuilder;

		public SqlBuilder(ISolutionOptions opts)
		{
			_tableTypeBuilder = new SqlTableTypeBuilder();
			_procedureBuilder = new SqlProcedureBuilder(opts);
		}

		public String BuildProcedures(ITable model)
		{
			var sb = new StringBuilder();
			sb.Append(BuildPagedIndex(model));

			sb.Append(BuildLoad(model));

			if (model.IsBaseTable())
			{
				sb.Append(_procedureBuilder.BuildMetadata(model));
				sb.Append(_procedureBuilder.BuildUpdate(model));
			}
			return sb.ToString();
		}

		public String BuildPagedIndex(ITable model)
		{
			var propName = model.Plural;
			ITable table = model.GetBaseTable();
			var alias = table.name[0].ToString().ToLowerInvariant();
			var tableName = table.Plural;

			var sb = new StringBuilder();
sb.AppendLine(
@$"{divider}
create or alter procedure [{model.Schema}].[{model.name}.Index]
@UserId bigint,
@Id bigint = null,{_procedureBuilder.GetProcParams(table)}
@Offset int = 0,
@PageSize int = {PAGE_SIZE},
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
@$"	select [{propName}!{table.TypeName}!Array] = null, {GetFields(alias, table, false)},
		[!!RowCount] = t._rows
	from [{table.Schema}].[{tableName}] {alias} inner join @paged t on t._id = {alias}.Id
	order by t._no;
");
			sb.Append(GetReferencedMapIndex(table));
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


		String GetFields(String alias, ITable table, Boolean withDetails)
		{
			var sb = new StringBuilder();
			sb.Append($"[Id!!Id] = {alias}.Id,");
			if (table.fields != null)
			{
				foreach (var (k, v) in table.fields)
				{
					if (v.type == FieldType.@ref)
					{
						var refTable = table.GetReferenceTable(v);
						sb.Append($" [{k}!{refTable.TypeName}!RefId] = {alias}.[{k}],");
					}
					else
						sb.Append($" {alias}.[{k}],");
				}
			}
			if (withDetails && table.details != null)
			{
				foreach (var (_, t) in table.details)
				{
					sb.Append($"[{t.TableName}!{t.TypeName}!Array] = null,");
				}
			}
			return sb.RemoveLastComma().ToString();
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
				sb.Append($" or upper({alias}.[{f.Key}]) like @Fragment");
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

			sb.Append($"\t{alias}.Id desc");
			return sb.ToString();
		}

		public String BuildLoadDetails(ITable model, ITable parent)
		{
			ITable table = model.GetBaseTable();
			var alias = table.name[0].ToString().ToLowerInvariant();
			var tableName = table.Plural;
			var sb = new StringBuilder();
			sb.AppendLine(
@$"
	select [!{table.TypeName}!Array] = null, {GetFields(alias, table, false)}, [!{parent.TypeName}.{tableName}!ParentId]=[{parent.name}], [RowNo!!RowNumber] = RowNo
	from [{table.Schema}].[{tableName}] {alias}
	where {alias}.[{parent.name}] = @Id;

	{GetReferencedMap(table, parent)}"
);
			return sb.ToString();
		}

		public String BuildLoad(ITable model)
		{
			ITable table = model.GetBaseTable();
			var alias = table.name[0].ToString().ToLowerInvariant();
			var tableName = table.Plural;
			var sb = new StringBuilder();

			sb.AppendLine(
			@$"{divider}
create or alter procedure [{model.Schema}].[{model.name}.Load]
@UserId bigint,{_procedureBuilder.GetProcParams(table)}
@Id bigint = null
as 
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	select [{table.name}!{table.TypeName}!Object] = null, {GetFields(alias, table, true)}
	from [{table.Schema}].[{tableName}] {alias}
	where {alias}.Id = @Id;
	{GetDetailsMap(table)}
	{GetReferencedMap(table)}
end
go");
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

		public String GetDetailsMap(ITable table)
		{
			if (table.details == null)
				return null;
			var sb = new StringBuilder();
			foreach (var (_, t) in table.details)
			{
				sb.Append(BuildLoadDetails(t, table));
			}
			return sb.ToString();
		}

		public String GetReferencedMapIndex(ITable table)
		{
			if (table.fields == null)
				return null;
			var sb = new StringBuilder();
			Dictionary<String, Tuple<ITable, List<String>>> refs = new Dictionary<String, Tuple<ITable, List<String>>>();
			foreach (var f in table.fields.Where(f => f.Value.type == FieldType.@ref))
			{
				var refTable = table.GetReferenceTable(f.Value);
				var fieldName = f.Value.name;
				if (refs.ContainsKey(refTable.TypeName))
					refs[refTable.TypeName].Item2.Add(fieldName);
				else
					refs.Add(refTable.TypeName, Tuple.Create(refTable, new List<string>() { fieldName }));
			}
			foreach (var r in refs)
			{
				if (sb.Length != 0)
					sb.AppendLine();
				sb.Append(BuildReferenceMapIndex(table, r.Value.Item1, r.Value.Item2));
			}
			return sb.ToString();
		}

		public String GetReferencedMap(ITable table, ITable parent = null)
		{
			if (table.fields == null)
				return null;
			var sb = new StringBuilder();
			Dictionary<String, Tuple<ITable, List<String>>> refs = new Dictionary<String, Tuple<ITable, List<String>>>();
			foreach (var f in table.fields.Where(f => f.Value.type == FieldType.@ref))
			{
				var refTable = table.GetReferenceTable(f.Value);
				var fieldName = f.Value.name;
				if (refs.ContainsKey(refTable.TypeName))
					refs[refTable.TypeName].Item2.Add(fieldName);
				else
				refs.Add(refTable.TypeName, Tuple.Create(refTable, new List<string>() { fieldName}));
			}
			foreach (var r in refs) { 
				if (sb.Length != 0)
					sb.AppendLine();
				sb.Append(BuildReferenceMap(table, r.Value.Item1, r.Value.Item2, parent));
			}
			return sb.ToString();
		}

		public String BuildReferenceMap(ITable baseTable, ITable refTable, IEnumerable<String> links, ITable parent = null)
		{
			var refAlias = refTable.Alias;
			var baseAlias = baseTable.Alias;
			if (refAlias == baseAlias)
				baseAlias += "_1";
			var strLinks = String.Join(", ", links.Select(s => $"{baseAlias}.{s}"));

			String whereParent = null;
			if (parent != null)
			{
				whereParent = @$"
	where {baseAlias}.[{parent.name}] = @Id";
			} else
			{
				whereParent = $@"
	where {baseAlias}.[Id] = @Id";
			}
			return
$@"select [!{refTable.TypeName}!Map] = null, {GetFields(refAlias, refTable, false)}
	from [{refTable.Schema}].[{refTable.TableName}] {refAlias}
		inner join [{baseTable.Schema}].[{baseTable.TableName}] {baseAlias} on {refAlias}.[Id] in ({strLinks}){whereParent};";
		}

		public String BuildReferenceMapIndex(ITable baseTable, ITable refTable, IEnumerable<String> links)
		{
			var refAlias = refTable.Alias;
			var baseAlias = baseTable.Alias;
			if (refAlias == baseAlias)
				baseAlias += "_1";
			var strLinks = String.Join(", ", links.Select(s => $"{baseAlias}.{s}"));

			return
$@"	select [!{refTable.TypeName}!Map] = null, {GetFields(refAlias, refTable, false)}
	from @paged 
		inner join [{baseTable.Schema}].[{baseTable.TableName}] {baseAlias} on _id = {baseAlias}.[Id]
		inner join [{refTable.Schema}].[{refTable.TableName}] {refAlias} on {refAlias}.[Id] in ({strLinks});
";
		}

		public String BuildTable(ITable table)
		{
			var tb = new SqlTableBuilder(table, null);
			return tb.BuildTable();
		}


		public String BuldTableType(ITable table)
		{
			return _tableTypeBuilder.Build(table);
		}

		public String BuldDropBeforeTableType(ITable table)
		{
			return _procedureBuilder.BuildDropBeforeTableType(table);
		}
	}
}
