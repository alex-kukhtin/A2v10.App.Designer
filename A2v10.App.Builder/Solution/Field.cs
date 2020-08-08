/* Copyright © 2019-2020 Alex Kukhtin. All rights reserved. */

using System;
using Newtonsoft.Json;
using Newtonsoft.Json.Converters;

namespace A2v10.App.Builder
{
	public enum FieldType
	{
		@string,
		@char,
		date,
		datetime,
		money,
		@float,
		@ref
	}

	public class Field : ElementBase, IField
	{
		public Boolean parameter { get; set; }

		[JsonConverter(typeof(StringEnumConverter))]
		public FieldType type { get; set; }
		public Int32 len;

		public Boolean required { get; set; }

		[JsonProperty("name")]
		public Boolean isName { get; set; }

		[JsonProperty("ref")]
		public String reference { get; set; }

		public String SqlType() {
			return type switch
			{
				FieldType.@string => $"nvarchar({GetLen()})",
				FieldType.@char => $"nchar({GetLen()})",
				FieldType.date => $"date",
				FieldType.datetime => $"datetime",
				FieldType.@ref => "bigint",
				FieldType.money => $"money",
				FieldType.@float => $"float",
				_ => throw new NotImplementedException(type.ToString()),
			};
		}

		String SqlNull()
		{
			return required ? "not null" : "null";
		}

		String SqlRef(String selfName)
		{
			if (type != FieldType.@ref)
				return String.Empty;
			ITable refTable = _solution.FindTable(reference);
			if (refTable == null)
				throw new InvalidOperationException($"'{reference}' not found");
			return $"{Environment.NewLine}\t\tconstraint FK_{selfName}_{name}_{refTable.Plural} references [{refTable.Schema}].[{refTable.Plural}](Id)";
		}

		public String SqlField(String tableName) {
			return $"{SqlType()} {SqlNull()}{SqlRef(tableName)}";
		}

		public Int32 GetLen()
		{
			if (len == 0)
				return 255;
			return len;
		}

		public Boolean IsOrderByAsString()
		{
			return type == FieldType.@char || type == FieldType.@string;
		}

		public Boolean IsOrderByAsNumber()
		{
			return type == FieldType.money || type == FieldType.@float;
		}

		public Boolean IsOrderByAsDate()
		{
			return type == FieldType.date;
		}

		#region IField
		public String GetLabel()
		{
			return uiName ?? name;
		}
		#endregion
	}
}
