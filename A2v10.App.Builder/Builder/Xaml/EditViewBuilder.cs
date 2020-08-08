/* Copyright © 2019-2020 Alex Kukhtin. All rights reserved. */

using System;
using System.Collections.Generic;
using System.Xml.Linq;

namespace A2v10.App.Builder.Xaml
{
	public class EditViewBuilder : BaseBuilder
	{
		public EditViewBuilder(Styles styles)
			:base(styles)
		{

		}

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
					),
					CreateDetails(table)
				)
			);
			return doc.SetStyle(_styles).ToString();
		}

		IEnumerable<XElement> CreateMainFields(ITable table)
		{
			if (table.fields == null)
				yield break;
			var bt = table.GetBaseTable();
			foreach (var f in table.fields)
			{
				var xField = CreateField(table, f.Value, $"{bt.name}.");
				yield return xField;
			}
		}


		XElement CreateField(ITable table, Field f, String fieldPrefix = null)
		{
			XNamespace ns = XamlBuilder.XamlNamespace;
			var label = f.name; // TODO: UI NAME
			//TODO: fetch delegate
			switch (f.type)
			{
				case FieldType.date:
					return new XElement(ns + "DatePicker",
						new XAttribute("Label", label),
						new XAttribute("Value", $"{{Bind {fieldPrefix}{f.name}}}")
					).SetStyle(_styles);
				case FieldType.money:
					return new XElement(ns + "TextBox",
						new XAttribute("Label", label),
						new XAttribute("Value", $"{{Bind {fieldPrefix}{f.name}, DataType=Currency}}"),
						new XAttribute("Align", "Right")
					).SetStyle(_styles);
				case FieldType.@float:
					return new XElement(ns + "TextBox",
						new XAttribute("Label", label),
						new XAttribute("Value", $"{{Bind {fieldPrefix}{f.name}, DataType=Number}}"),
						new XAttribute("Align", "Right")
					).SetStyle(_styles);
				case FieldType.@ref:
					var refTable = table.GetReferenceTable(f);
					var browseUrl = $"/{refTable?.Kind}/{f.reference.ToLowerInvariant()}/browse";
					return new XElement(ns + "Selector",
						new XAttribute("Label", label),
						new XAttribute("Value", $"{{Bind {fieldPrefix}{f.name}}}"),
						new XAttribute("DisplayProperty", refTable?.NameField ?? String.Empty),
						new XAttribute("Delegate", $"fetch{f.reference}"),
						new XElement(ns + "Selector.AddOns",
							new XElement(ns + "Hyperlink",
								new XAttribute("Icon", "Search"),
								new XAttribute("Command",
									$"{{BindCmd Dialog, Action=Browse, Argument={{Bind {fieldPrefix}{f.name}}}, Url='{browseUrl}'}}")
							)
						)
					).SetStyle(_styles);
				case FieldType.@string:
					return new XElement(ns + "TextBox",
						new XAttribute("Label", label),
						new XAttribute("Value", $"{{Bind {fieldPrefix}{f.name}}}")
					).SetStyle(_styles);
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
					).SetStyle(_styles),
					new XElement(ns + "Button",
						new XAttribute("Icon", "Reload"),
						new XAttribute("Content", "Оновити"),
						new XAttribute("Command", "{BindCmd Reload}")
					).SetStyle(_styles),
					new XElement(ns + "Button",
						new XAttribute("Icon", "Close"),
						new XAttribute("Content", "Закрити"),
						new XAttribute("Toolbar.Align", "Right"),
						new XAttribute("Command", "{BindCmd Close}")
					).SetStyle(_styles)
				).SetStyle(_styles)
			);
			return doc;
		}

		XElement CreateTaskpad(ITable table)
		{
			XNamespace ns = XamlBuilder.XamlNamespace;
			return new XElement(ns + "Page.Taskpad",
				new XElement(ns + "Taskpad")
			).SetStyle(_styles);
		}

		IEnumerable<XElement> CreateDetails(ITable table)
		{
			if (table.details == null)
				yield break;
			foreach (var d in table.details.Values)
				yield return CreateSingleDetails(d, $"{table.name}.{d.Plural}");
		}

		XElement CreateSingleDetails(ITable table, String itemsSource)
		{
			XNamespace ns = XamlBuilder.XamlNamespace;
			var xElem = new XElement(ns + "Block",
				new XElement(ns + "Toolbar",
					new XElement(ns + "Button", 
						new XAttribute("Icon", "Add"),
						new XAttribute("Content", "Додати рядок"),
						new XAttribute("Command", $"{{BindCmd Append, Argument={{Bind {itemsSource}}}}}")
					).SetStyle(_styles)
				).SetStyle(_styles),
				new XElement(ns + "Table",
					new XAttribute("ItemsSource", $"{{Bind {itemsSource}}}"),
					new XElement(ns + "TableRow",
						GetDetailsColumns(table))
				).SetStyle(_styles)
			);
			return xElem;
		}

		IEnumerable<XElement> GetDetailsColumns(ITable table)
		{
			if (table.fields == null)
				yield break;
			foreach (var f in table.fields)
			{
				yield return CreateField(table, f.Value);
			}
		}
	}
}
