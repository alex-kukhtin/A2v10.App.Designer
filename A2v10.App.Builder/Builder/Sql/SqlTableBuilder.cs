using System;
using System.Collections.Generic;
using System.Text;

namespace A2v10.App.Builder
{
	public enum IdType 
	{ 
		sequence
	}

	public class SqlTableOptions
	{
		public IdType IdType { get; set; }
	}

	public class SqlTableBuilder
	{
		private readonly ITable _table;
		private readonly SqlTableOptions _opts;

		private String TableName => _table.Plural;
		private String Schema => _table.Schema;

		public SqlTableBuilder(ITable table, SqlTableOptions opts)
		{
			_table = table;
			_opts = opts;
		}

		public String BuildTable()
		{
			return
$@"{SqlBuilder.divider}
if not exists(select * from INFORMATION_SCHEMA.SEQUENCES where SEQUENCE_SCHEMA=N'{Schema}' and SEQUENCE_NAME=N'SQ_{TableName}')
	create sequence [{_table.Schema}].SQ_{TableName} as bigint start with 100 increment by 1;
go
{SqlBuilder.divider}
if not exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA=N'{Schema}' and TABLE_NAME=N'{TableName}')
begin
create table [{Schema}].[{TableName}]
(
	Id bigint not null constraint DF_{TableName}_Id default(next value for [{Schema}].SQ_{TableName})
		constraint PK_{TableName} primary key,{GetTableFields()}
)
end
go";
		}

		String GetTableFields()
		{
			var sb = new StringBuilder();
			var pt = _table.GetParentTable();
			if (pt != null)
			{
				sb.AppendLine()
					.Append("\tRowNo int not null,");
				sb.AppendLine()
					.Append($"\t[{pt.name}] bigint null")
					.AppendLine()
					.Append($"\t\tconstraint FK_{TableName}_{pt.name}_{pt.Plural} references [{pt.Schema}].[{pt.Plural}](Id),");
			}
			if (_table.fields != null)
			{
				foreach (var f in _table.fields)
				{
					sb.AppendLine();
					sb.Append($"\t[{f.Key}] {f.Value.SqlField(TableName)},");
				}
			}
			if (pt == null)
			{
				sb.Append(
@$"
	DateCreated datetime not null constraint DF_{TableName}_DateCreated default(a2sys.fn_getCurrentDate()),
	DateModified datetime not null constraint DF_{TableName}_DateModified default(a2sys.fn_getCurrentDate())");
			}
			else
			{
				sb.RemoveLastComma();
			}
			return sb.ToString();
		}

	}
}
