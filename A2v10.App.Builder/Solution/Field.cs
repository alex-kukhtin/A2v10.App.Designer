using Newtonsoft.Json.Converters;
using System;
using System.Collections.Generic;
using System.Text;
using System.Text.Json.Serialization;

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

		[JsonConverter(typeof(StringEnumConverter))]
		public FieldType type { get; set; }
		public Int32 len;

		public String SqlType() { 
			switch (type)
			{
				case FieldType.@string:
					return $"nvarchar({GetLen()})";
				case FieldType.@char:
					return $"nchar({GetLen()})";
			}
			throw new NotImplementedException(type.ToString());
		}

		public Int32 GetLen()
		{
			if (len == 0)
				return 255;
			return len;
		}
	}
}
