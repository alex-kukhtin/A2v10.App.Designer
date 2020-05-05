using System;
using System.Collections.Generic;
using System.Text;

namespace A2v10.App.Builder
{
	public interface ITable
	{
		String name { get; }
		String extends { get; }

		Dictionary<String, Field> fields { get; }
		Dictionary<String, Table> details { get; }
		Dictionary<String, String> parameters { get; }

		List<String> features { get; set; }

		String TypeName { get; }
		String Schema { get; }
		String Plural { get; }

		ITable GetParentTable();

		ITable GetBaseTable();
	}
}
