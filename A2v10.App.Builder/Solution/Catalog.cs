using System;
using System.Collections.Generic;
using System.Text;
using System.Xml;
using System.Xml.Linq;
using Newtonsoft.Json;

namespace A2v10.App.Builder
{
	/*
	 todo:
	 1. Index View
	 2. Index Template
	 3. Edit dialog,
	 4. Edit template
	 5. Browse template
	 6. SQL procedures
	 7. 
	 */
	public class Catalog : ElementBase, ICatalog, ITable
	{
		public Boolean hidden { get; set; }
		
		[JsonProperty("base")]
		public String baseCatalog {get;set;}

		public String plural { get; set; }

		public Dictionary<String, Field> fields { get; set; }
		public List<String> features { get; set; }

		public String GetModelJson()
		{
			var m = new ModelJson()
			{
				schema = _solution.schema,
				model = name,
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
				dialogs = new Dictionary<string, ModelDialog>()
				{
					{ "edit", new ModelDialog()
						{
							template = "edit.template",
							view = "edit.dialog"
						}
					}
				},
				commands = new Dictionary<string, ModelCommand>()
				{
					{"fetch", new ModelCommand()
						{
						}
					}
				}
			};
			if (features != null)
			{
				foreach (var f in features)
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

		public String CreateIndexView(XamlBuilder builder)
		{
			XNamespace ns = XamlBuilder.XamlNamespace;
			var doc = new XElement(
				new XElement(ns + "Page",
					new XElement(ns + "Page.CollectionView",
						new XElement(ns + "CollectionView",
							new XAttribute("RunAt", "ServerUrl"),
							new XAttribute("ItemsSource", $"{{Bind {Plural}}}")
						)
					)
				)
			);
			var tb = new XElement(ns + "Toolbar",
				new XElement(ns + "Button",
					new XAttribute("Icon", "Reload"),
					new XAttribute("Content", "Оновити"),
					new XAttribute("Command", "{BindCmd Reload}")
				)
			);
			doc.Add(new XElement(ns + "Page.Toolbar", tb));
			doc.Add(
				new XElement(ns + "Page.Pager",
					builder.CreatePager("Parent.Pager")
				)
			);

			doc.Add(builder.CreateDataGrid("Parent.ItemsSource", GetTable()));

			Console.WriteLine(doc);
			return doc.ToString();
		}


		[JsonIgnore]
		public String Plural => plural == null ? name.ToPlural() : plural;

		public ITable GetTable()
		{
			return baseCatalog == null ? this : _solution.catalogs[baseCatalog];
		}
	}
}
