
using System;
using System.Collections;
using System.Collections.Generic;
using System.Xml.Linq;

namespace A2v10.App.Builder.Xaml
{
	public class EditViewBuilder
	{
		public String Build(ITable table)
		{
			XNamespace ns = XamlBuilder.XamlNamespace;
			var doc = new XElement(
				new XElement(ns + "Page",
					CreateToolbar(table),
					CreateTaskpad(table),
					new XElement(ns + "Grid",
						new XAttribute("Columns", "30rem"),
						CreateMainFields(table)
					)
				)
			);
			return doc.ToString();
		}

		IEnumerable<XElement> CreateMainFields(ITable table)
		{
			XNamespace ns = XamlBuilder.XamlNamespace;
			if (table.fields == null)
				yield break;
			foreach (var f in table.fields)
				yield return CreateField(table, f.Value);
		}

		XElement CreateField(ITable table, Field f)
		{
			var bt = table.GetBaseTable();
			XNamespace ns = XamlBuilder.XamlNamespace;
			var label = f.name; // TODO: UI NAME
			//TODO: URL from browse, fetch delegate
			switch (f.type)
			{
				case FieldType.date:
					return new XElement(ns + "DatePicker",
						new XAttribute("Label", label),
						new XAttribute("Value", $"{{Bind {bt.name}.{f.name}}}")
					);
				case FieldType.money:
					return new XElement(ns + "TextBox",
						new XAttribute("Label", label),
						new XAttribute("Value", $"{{Bind {bt.name}.{f.name}, DataType=Currency}}"),
						new XAttribute("Align", "Right")
					); ;
				case FieldType.@ref:
					var browseUrl = $"/catalog/{f.reference.ToLowerInvariant()}/browse";
					return new XElement(ns + "Selector",
						new XAttribute("Label", label),
						new XAttribute("Value", $"{{Bind {bt.name}.{f.name}}}"),
						new XElement(ns + "Selector.AddOns",
							new XElement(ns + "Hyperlink",
								new XAttribute("Icon", "Search"),
								new XAttribute("Command", 
									$"{{BindCmd Dialog, Action=Browse, Argument={{Bind {bt.name}.{f.name}}}, Url='{browseUrl}'}}")
							)
						)
					);
			}
			return null;
		}

		XElement CreateToolbar(ITable table)
		{
			XNamespace ns = XamlBuilder.XamlNamespace;
			var doc = new XElement(ns + "Page.Toolbar",
				new XElement(ns + "Toolbar",
					new XElement(ns + "Button",
						new XAttribute("Icon", "Save"),
						new XAttribute("Content", "Зберегти"),
						new XAttribute("Command", "{BindCmd Save}")
					),
					new XElement(ns + "Button",
						new XAttribute("Icon", "Reload"),
						new XAttribute("Content", "Оновити"),
						new XAttribute("Command", "{BindCmd Reload}")
					),
					new XElement(ns + "Button",
						new XAttribute("Icon", "Close"),
						new XAttribute("Content", "Закрити"),
						new XAttribute("Toolbar.Align", "Right"),
						new XAttribute("Command", "{BindCmd Close}")
					)
				)
			);
			return doc;
		}

		XElement CreateTaskpad(ITable table)
		{
			XNamespace ns = XamlBuilder.XamlNamespace;
			var doc = new XElement(ns + "Page.Taskpad",
				new XElement(ns + "Taskpad")
			);
			return doc;
		}
	}
}
