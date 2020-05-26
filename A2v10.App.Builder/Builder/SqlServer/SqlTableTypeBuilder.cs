/* Copyright © 2019-2020 Alex Kukhtin. All rights reserved. */

using System;
using System.Text;

namespace A2v10.App.Builder.SqlServer
{
	public class SqlTableTypeBuilder
	{
		public String Build(ITable table)
		{
			if (table.fields == null)
				return null;

			String TableName = table.name;
			String Schema = table.Schema;

			return
$@"{SqlBuilder.divider}
if exists(select * from INFORMATION_SCHEMA.DOMAINS where DOMAIN_SCHEMA = N'{Schema}' and DOMAIN_NAME = N'{TableName}.TableType')
	drop type [{Schema}].[{TableName}.TableType];
go
{SqlBuilder.divider}
create type [{Schema}].[{TableName}.TableType]
as table (
	Id bigint,{GetTableFields(table)}
)
go
";
		}

		String GetTableFields(ITable table)
		{
			var sb = new StringBuilder();
			var pt = table.GetParentTable();
			if (pt != null)
			{
				sb.AppendLine()
				.AppendLine($"\tParentId bigint,")
				.Append("\tRowNumber int,");
			}
			foreach (var f in table.fields)
			{
				sb.AppendLine();
				sb.Append($"\t[{f.Key}] {f.Value.SqlType()},");
			}
			sb.RemoveLastComma();
			return sb.ToString();
		}
	}
}
