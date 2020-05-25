using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml.Linq;

namespace A2v10.App.Builder.Xaml
{
	public class DataGridBuilder : BaseBuilder
	{

		public DataGridBuilder(Styles styles)
			: base(styles)
		{

		}

		public XElement BuildDataGrid(ITable table, String itemsSource)
		{
			var ns = XamlBuilder.XamlNamespace;

			var dg = new XElement(ns + "DataGrid",
				new XAttribute("ItemsSource", $"{{Bind {itemsSource}}}")
			);

			SetElementStyle(dg);
			dg.Add(GetDataGridColums(table));
			return dg;
		}

		IEnumerable<XElement> GetDataGridColums(ITable table)
		{
			var ns = XamlBuilder.XamlNamespace;
			yield return new XElement(ns + "DataGridColumn",
				new XAttribute("Header", "Код"),
				new XAttribute("Content", "{Bind Id}"),
				new XAttribute("Align", "Right"),
				new XAttribute("Wrap", "NoWrap"),
				new XAttribute("Fit", "True")
			);

			if (table.fields == null)
				yield break;
			foreach (var f in table.fields.Where(f => !f.Value.parameter))
				yield return BuildColumn(table, f.Value);
		}

		XElement BuildColumn(ITable table, Field f)
		{
			var ns = XamlBuilder.XamlNamespace;
			// TODO: ui name
			var name = f.uiName;
			if (String.IsNullOrEmpty(name))
				name = f.name;
			var col = new XElement(ns + "DataGridColumn",
				new XAttribute("Header", name)
			);
			switch (f.type)
			{
				case FieldType.date:
					col.Add(
						new XAttribute("Content", $"{{Bind {f.name}, DataType=Date}}"),
						new XAttribute("Fit", "True"),
						new XAttribute("Wrap", "NoWrap")
					);
					break;
				case FieldType.money:
					col.Add(
						new XAttribute("Content", $"{{Bind {f.name}, DataType=Currency}}"),
						new XAttribute("Fit", "True"),
						new XAttribute("Align", "Right"),
						new XAttribute("Wrap", "NoWrap")
					);
					break;
				default:
					col.Add(new XAttribute("Content", $"{{Bind {f.name}}}"));
					break;
			}
			return col;
		}

	}
}
