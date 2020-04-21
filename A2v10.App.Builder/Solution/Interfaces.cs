using System;
using System.Collections.Generic;
using System.Text;

namespace A2v10.App.Builder
{
	public interface ITable
	{
		public String name { get; }
		Dictionary<String, Field> fields { get; }

		public String TypeName { get; }
		public String Schema { get; }

	}

	public interface ICatalog
	{
		String Schema { get; }
		public String name { get; }

		public String Plural { get; }

		ITable GetTable();
	}
}
