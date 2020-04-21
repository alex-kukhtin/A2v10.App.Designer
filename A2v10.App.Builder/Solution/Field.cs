using System;
using System.Collections.Generic;
using System.Text;

namespace A2v10.App.Builder
{
	public enum FieldType
	{
		@string,
		@char,
		date,
		currency
	}

	public class Field : ElementBase
	{
		public Boolean parameter { get; set; }
		public FieldType type { get; set; }
		public Int32 len;
	}
}
