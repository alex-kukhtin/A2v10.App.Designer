
using System;
using System.Collections.Generic;
using System.Text;
using System.Xml.Linq;

namespace A2v10.App.Builder
{
	public class XamlBuilder
	{
		public static XNamespace XamlNamespace { get; } = "clr-namespace:A2v10.Xaml;assembly=A2v10.Xaml";

		private readonly Styles _styles;

		public XamlBuilder(Styles styles)
		{
			_styles = styles;
		}

		public void SetElementStyle(XElement elem)
		{
			if (_styles == null)
				return;
			if (_styles.TryGetValue(elem.Name.LocalName, out ElementStyle elemStyle)) 
			{
				foreach (var s in elemStyle)
					elem.Add(new XAttribute(s.Key, s.Value));
			}
		}

		public XElement CreateDataGrid(String itemsSource, ITable table)
		{
			var dg = new XElement(XamlNamespace + "DataGrid",
				new XAttribute("ItemsSource", $"{{Bind {itemsSource}}}")
			);
			SetElementStyle(dg);
			dg.Add(GetDataGridColums(table));
			return dg;
		}

		IEnumerable<XElement> GetDataGridColums(ITable table)
		{
			yield return new XElement(XamlNamespace + "DataGridColumn",
				new XAttribute("Header", "Код"),
				new XAttribute("Content", "{Bind {Id}"),
				new XAttribute("Align", "Right"),
				new XAttribute("Wrap", "NoWrap"),
				new XAttribute("Fit", "True")
			);

			foreach (var f in table.fields)
			{
				if (f.Value.parameter)
					continue;
				var name = f.Value.uiName;
				if (String.IsNullOrEmpty(name))
					name = f.Key;
				var col = new XElement(XamlNamespace + "DataGridColumn",
					new XAttribute("Header", name),
					new XAttribute("Content", $"{{Bind {f.Key}}}")
				);
				yield return col;
			}

		}

		public XElement CreatePager(String source)
		{
			var pager = new XElement(XamlNamespace + "Pager",
				new XAttribute("Source", $"{{Bind {source}}}")
			);
			SetElementStyle(pager);
			return pager;
		}
	}
}
