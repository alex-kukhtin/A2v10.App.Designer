
using A2v10.App.Builder.Xaml;
using Microsoft.VisualBasic;
using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Xml.Linq;

namespace A2v10.App.Builder.Xaml
{
	public class XamlBuilder : IViewBuilder
	{
		public static XNamespace XamlNamespace { get; } = "clr-namespace:A2v10.Xaml;assembly=A2v10.Xaml";

		private readonly Styles _styles;
		private readonly DataGridBuilder _dataGridBuilder;

		public XamlBuilder(Styles styles)
		{
			_styles = styles;
			_dataGridBuilder = new DataGridBuilder(_styles);


		}

		public String Extension => "xaml";

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


		XElement CreatePager(String source)
		{
			var pager = new XElement(XamlNamespace + "Pager",
				new XAttribute("Source", $"{{Bind {source}}}")
			);
			SetElementStyle(pager);
			return pager;
		}

		public String IndexView(ITable table)
		{
			if (!table.HasFeature(Feature.index))
				return null;
			var baseTable = table.GetBaseTable();
			XNamespace ns = XamlBuilder.XamlNamespace;
			var doc = new XElement(
				new XElement(ns + "Page",
					new XElement(ns + "Page.CollectionView",
						new XElement(ns + "CollectionView",
							new XAttribute("RunAt", "ServerUrl"),
							new XAttribute("ItemsSource", $"{{Bind {baseTable.Plural}}}")
						)
					)
				)
			);
			var tb = new XElement(ns + "Toolbar",
				CreateToolbarButtons(table),
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

			doc.Add(_dataGridBuilder.BuildDataGrid(baseTable, "Parent.ItemsSource"));

			return doc.ToString();
		}

		IEnumerable<XElement> CreateToolbarButtons(ITable table)
		{
			// TODO /catalog/document????
			XNamespace ns = XamlBuilder.XamlNamespace;
			var tn = table.name.ToLowerInvariant();
			if (table.HasFeature(Feature.editDialog))
			{
				yield return new XElement(ns + "Button",
					new XAttribute("Icon", "Add"),
					new XAttribute("Content", "Додати"),
					new XAttribute("Command", $"{{BindCmd Dialog, Action=Append, Argument={{Bind Parent.ItemsSource}}, Url='/catalog/{tn}/edit'}}")
				);
				yield return new XElement(ns + "Button",
					new XAttribute("Icon", "Edit"),
					new XAttribute("Content", "Змінити"),
					new XAttribute("Command", $"{{BindCmd Dialog, Action=EditSelected, Argument={{Bind Parent.ItemsSource}}, Url='/catalog/{tn}/edit'}}")
				);
				yield return new XElement(ns + "Separator");
			}
			else if (table.HasFeature(Feature.editPage))
			{
				yield return new XElement(ns + "Button",
					new XAttribute("Icon", "Add"),
					new XAttribute("Content", "Створити"),
					new XAttribute("Command", $"{{BindCmd Create, Url='/document/{tn}/edit'}}")
				);
				yield return new XElement(ns + "Button",
					new XAttribute("Icon", "ArrowOpen"),
					new XAttribute("Content", "Відкрити"),
					new XAttribute("Command", $"{{BindCmd OpenSelected, Argument={{Bind Parent.ItemsSource}}, Url='/document/{tn}/edit'}}")
				);
				yield return new XElement(ns + "Separator");
			}
		}


		public String EditDialog(ITable table)
		{
			if (!table.HasFeature(Feature.editDialog))
				return null;
			var ed = new EditDialogBuilder();
			return ed.Build(table);
		}

		public String EditView(ITable table)
		{
			if (!table.HasFeature(Feature.editPage))
				return null;
			var ev = new EditViewBuilder();
			return ev.Build(table);
		}

		public String BrowseDialog(ITable table)
		{
			return null;
		}
	}
}
