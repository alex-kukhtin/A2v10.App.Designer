using System;
using System.Collections.Generic;
using System.Text;
using System.Xml;
using System.Xml.Linq;
using Newtonsoft.Json;

namespace A2v10.App.Builder
{
	public class Catalog : ElementBase
	{
		public Boolean hidden { get; set; }
		public Dictionary<String, Field> fields { get; set; }

		public String GetModelJson()
		{
			var m = new ModelJson()
			{
				schema = _solution.schema,
				model = _name,
				actions = new Dictionary<String, ModelAction>()
				{
					{"index", new ModelAction()
						{
							template = "index.template",
							view = "index.view"
						}
					}
				},
				dialogs = new Dictionary<string, ModelDialog>()
				{
					{ "browse", new ModelDialog()
						{
							index = true,
							view = "browse.dialog"
						}
					},
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

			var json = JsonConvert.SerializeObject(m, new JsonSerializerSettings()
			{
				NullValueHandling = NullValueHandling.Ignore,
				DefaultValueHandling = DefaultValueHandling.Ignore,
				Formatting = Newtonsoft.Json.Formatting.Indented
			});
			return json;
		}

		public String CreateIndexView()
		{
			XNamespace aw = "clr-namespace:A2v10.Xaml;assembly=A2v10.Xaml";
			var doc = new XElement(
				new XElement(aw + "Page",
					new XElement(aw + "Page.CollectionView",
						new XElement(aw + "CollectionView",
							new XAttribute("RunAt", "ServerUrl"),
							new XAttribute("ItemsSource", $"{{Bind Customers}}")
						)
					)
				)
			);
			var tb = new XElement(aw + "Toolbar",
				new XElement(aw + "Button",
					new XAttribute("Icon", "Reload"),
					new XAttribute("Content", "Оновити"),
					new XAttribute("Command", "{BindCmd Reload}")
				)
			);
			doc.Add(new XElement(aw + "Page.Toolbar", tb));
			doc.Add(
				new XElement(aw + "Page.Pager",
					new XElement(aw + "Pager",
						new XAttribute("Source", "{Bind Parent.Pager}")
					)
				)
			);
			var dg = new XElement(aw + "DataGrid", 
				new XAttribute("ItemsSource", "{Bind Parent.ItemsSource}")
			);
			doc.Add(dg);

			var col = new XElement(aw + "DataGridColumn",
				new XAttribute("Header", "Наименование"),
				new XAttribute("Content", "{Bind Name}")
			);
			dg.Add(col);

			Console.WriteLine(doc);
			return doc.ToString();
		}
	}
}
