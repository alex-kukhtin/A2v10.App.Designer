using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Text;

namespace A2v10.App.Builder
{
	public class ModelJsonBuilder
	{
		private readonly ICatalog _catalog;
		public ModelJsonBuilder(ICatalog catalog)
		{
			_catalog = catalog;
		}

		public String Build()
		{
			var m = new ModelJson()
			{
				schema = _catalog.Schema,
				model = _catalog.name,
				actions = new Dictionary<String, ModelAction>()
				{
					{"index", new ModelAction()
						{
							index = true,
							template = "index.template",
							view = "index.view"
						}
					}
				},
				dialogs = new Dictionary<String, ModelDialog>()
				{
					{ "edit", new ModelDialog()
						{
							template = "edit.template",
							view = "edit.dialog"
						}
					}
				}
			};
			// Add parameters
			if (_catalog.features != null)
			{
				foreach (var f in _catalog.features)
				{
					switch (f)
					{
						case "browse":
							m.dialogs.Add("browse", new ModelDialog
							{
								index = true,
								view = "browse.dialog"
							});
							break;
						case "fetch":
							if (m.commands == null)
								m.commands = new Dictionary<String, ModelCommand>();
							m.commands.Add("fetch", new ModelCommand()
							{
								type = CommandType.sql,
								procedure = $"{_catalog.name}.Fetch"
							});
							break;
					}
				}
			}

			var json = JsonConvert.SerializeObject(m, new JsonSerializerSettings()
			{
				NullValueHandling = NullValueHandling.Ignore,
				DefaultValueHandling = DefaultValueHandling.Ignore,
				Formatting = Newtonsoft.Json.Formatting.Indented
			});
			return json;
		}
	}
}
