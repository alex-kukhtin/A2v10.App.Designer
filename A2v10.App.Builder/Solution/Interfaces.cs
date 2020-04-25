using System;
using System.Collections.Generic;
using System.Text;

namespace A2v10.App.Builder
{
	public interface ITable
	{
		String name { get; }
		Dictionary<String, Field> fields { get; }

		String TypeName { get; }
		String Schema { get; }
		String Plural { get; }

	}

	public interface ICatalog : ITable
	{
		List<String> features { get; set; }

		ITable GetTable();
	}
}
