/* Copyright © 2019-2020 Alex Kukhtin. All rights reserved. */

using System;
using System.Collections.Generic;
using System.Xml.Linq;

namespace A2v10.App.Builder.Xaml
{
	public class EditDialogBuilder
	{
		public String Build(ITable table)
		{
			XNamespace ns = XamlBuilder.XamlNamespace;
			var doc = new XElement(
				new XElement(ns + "Dialog",
					new XElement(ns + "Dialog.Buttons",
						new XElement(ns + "Button",
							new XAttribute("Content", "Зберегти"),
							new XAttribute("Command", "{BindCmd SaveAndClose}")
						),
						new XElement(ns + "Button",
							new XAttribute("Content", "Закрити"),
							new XAttribute("Command", "{BindCmd Close}")
						)
					),
					new XElement(ns + "Grid", Fields(table))
				)
			);
			return doc.ToString();
		}

		IEnumerable<XElement> Fields(ITable table)
		{
			if (table.fields == null)
				yield break;
			foreach (var f in table.fields)
			{
				if (f.Value.parameter)
					continue;
				yield return Field(table.name, f.Value);
			}
		}

		XElement Field(String tableName, IField field)
		{
			XNamespace ns = XamlBuilder.XamlNamespace;
			var elem = new XElement(ns + "TextBox",
				new XAttribute("Value", $"{{Bind {tableName}.{field.name}}}")
			);
			var label = field.GetLabel();
			if (label != null)
				elem.Add(new XAttribute("Label", label));
			return elem;
		}
	}
}
