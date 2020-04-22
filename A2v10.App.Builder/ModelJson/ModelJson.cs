using Newtonsoft.Json;
using Newtonsoft.Json.Converters;
using System;
using System.Collections.Generic;
using System.Text;

namespace A2v10.App.Builder
{
	public class JsonBase
	{
		public String schema { get; set; }
		public String template { get; set; }
		public String view { get; set; }
		public Boolean index { get; set; }
		public Dictionary<String, String > parameters { get; set; }
	}

	public class ModelAction : JsonBase
	{
	}

	public class ModelDialog : JsonBase
	{
	}

	public enum CommandType
	{
		unknown,
		sql
	}

	public class ModelCommand
	{
		[JsonConverter(typeof(StringEnumConverter))]
		public CommandType type { get; set; }
		public String procedure { get; set; }
	}

	public class ModelJson
	{
		public String schema { get; set; }
		public String model { get; set; }
		public Dictionary<String, ModelAction> actions { get; set; }
		public Dictionary<String, ModelDialog> dialogs { get; set; }
		public Dictionary<String, ModelCommand> commands { get; set; }
	}
}
