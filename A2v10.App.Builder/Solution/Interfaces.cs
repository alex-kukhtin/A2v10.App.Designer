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

	}

	public interface ICatalog
	{
		String Schema { get; }
		String name { get; }

		String Plural { get; }
		List<String> features { get; set; }

		ITable GetTable();
	}
}
