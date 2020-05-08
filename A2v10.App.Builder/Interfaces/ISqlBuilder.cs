
using System;

namespace A2v10.App.Builder
{
	public interface ISqlBuilder
	{
		String BuildSchema(String schema);
		String BuildTable(ITable table);
		String BuldTableType(ITable table);
		String BuldDropBeforeTableType(ITable table);
		String BuildProcedures(ITable model);
	}
}
