using Newtonsoft.Json;
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
	}

	public class ModelAction : JsonBase
	{
	}

	public class ModelDialog : JsonBase
	{
	}

	public class ModelCommand
	{

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
