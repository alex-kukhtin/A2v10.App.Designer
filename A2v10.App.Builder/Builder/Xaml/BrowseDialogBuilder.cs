/* Copyright © 2019-2020 Alex Kukhtin. All rights reserved. */

using System;
using System.Collections.Generic;
using System.Xml.Linq;

namespace A2v10.App.Builder.Xaml
{
	public class BrowseDialogBuilder : BaseBuilder
	{
		private readonly DataGridBuilder _dataGridBuilder;

		public BrowseDialogBuilder(Styles styles)
			: base(styles)
		{
			_dataGridBuilder = new DataGridBuilder(styles);
		}

		public String Build(ITable table)
		{
			XNamespace ns = XamlBuilder.XamlNamespace;
			String propNames = table.GetBaseTable().Plural;
			var doc = new XElement(
				new XElement(ns + "Dialog",
					new XElement(ns + "Dialog.Buttons",
						new XElement(ns + "Button",
							new XAttribute("Content", "Обрати"),
							new XAttribute("Command", $"{{BindCmd Select, Argument={{Bind {propNames}}}}}")
						),
						new XElement(ns + "Button",
							new XAttribute("Content", "Закрити"),
							new XAttribute("Command", "{BindCmd Close}")
						)
					),
					_dataGridBuilder.BuildDataGrid(table, propNames)
				)
			);
			return doc.SetStyle(_styles).ToString();
		}
	}
}
