/* Copyright © 2019-2020 Alex Kukhtin. All rights reserved. */

using System;
using System.Collections.Generic;
using System.Text;
using Newtonsoft.Json;

namespace A2v10.App.Builder
{
	public class ModelJsonBuilder
	{
		private readonly ITable _table;
		public ModelJsonBuilder(ITable table)
		{
			_table = table;
		}

		public String Build()
		{
			String parentLink = String.Empty;
			Dictionary<String, String> prms = null;

			var baseTable = _table.GetBaseTable();

			if (!String.IsNullOrEmpty(_table.extends))
			{
				parentLink = $"../{_table.extends.ToLowerInvariant()}/";
				prms = _table.parameters;
			}

			var m = new ModelJson()
			{
				schema = baseTable.Schema,
				model = baseTable.name,
				actions = new Dictionary<String, ModelAction>()
				{
					{"index", new ModelAction()
						{
							index = true,
							template = $"index.template",
							view = $"index.view",
							parameters = prms
						}
					}
				},
				dialogs = new Dictionary<String, ModelDialog>()
				{
					{ "edit", new ModelDialog()
						{
							template = $"{parentLink}edit.template",
							view = $"{parentLink}edit.dialog",
							parameters = prms
						}
					}
				}
			};
			// features
			if (_table.features != null)
			{
				foreach (var f in _table.features)
				{
					switch (f)
					{
						case Feature.browse:
							m.dialogs.Add("browse", new ModelDialog
							{
								index = true,
								view = $"{parentLink}browse.dialog",
								parameters = prms
							});
							break;
						case Feature.fetch:
							if (m.commands == null)
								m.commands = new Dictionary<String, ModelCommand>();
							m.commands.Add("fetch", new ModelCommand()
							{
								type = CommandType.sql,
								procedure = $"{baseTable.name}.Fetch",
								parameters = prms
							});
							break;
						case Feature.editPage:
							m.actions.Add("edit", new ModelAction
							{
								view = $"{parentLink}edit.view",
								template = $"{parentLink}edit.template",
								parameters = prms
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
