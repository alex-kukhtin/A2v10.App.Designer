
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

		void SetElementStyle(XElement elem)
		{
			if (_styles == null)
				return;
			if (_styles.TryGetValue(elem.Name.LocalName, out ElementStyle elemStyle)) 
			{
				foreach (var s in elemStyle)
					elem.Add(new XAttribute(s.Key, s.Value));
			}
		}

		XElement CreateDataGrid(String itemsSource, ITable table)
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

			if (table.fields == null)
				yield break;
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

		XElement CreatePager(String source)
		{
			var pager = new XElement(XamlNamespace + "Pager",
				new XAttribute("Source", $"{{Bind {source}}}")
			);
			SetElementStyle(pager);
			return pager;
		}

		public String CreateIndexView(ICatalog catalog)
		{
			XNamespace ns = XamlBuilder.XamlNamespace;
			var doc = new XElement(
				new XElement(ns + "Page",
					new XElement(ns + "Page.CollectionView",
						new XElement(ns + "CollectionView",
							new XAttribute("RunAt", "ServerUrl"),
							new XAttribute("ItemsSource", $"{{Bind {catalog.Plural}}}")
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
					CreatePager("Parent.Pager")
				)
			);

			doc.Add(CreateDataGrid("Parent.ItemsSource", catalog.GetTable()));

			Console.WriteLine(doc);
			return doc.ToString();
		}

	}
}
