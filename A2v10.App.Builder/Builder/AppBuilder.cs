using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Text;
using System.Xml.Linq;

namespace A2v10.App.Builder
{
	public class AppBuilder
	{
		private readonly Solution _solution;
		private readonly Styles _styles;

		public AppBuilder(Solution solution, Styles styles)
		{
			_solution = solution;
			_styles = styles;
		}

		public void Build()
		{
			BuildCatalogs();
			BuildDocuments();
		}

		void BuildCatalogs()
		{
			var sqlBuilder = new SqlBuilder();
			var xamlBuilder = new XamlBuilder(_styles);
			var templateBuilder = new CatalogTemplateBuilder();
			foreach (var c in _solution.catalogs)
			{
				if (c.Value.hidden)
					continue;
				ICatalog catalog = c.Value;
				BuildCatalogModelJson(c.Key, catalog);
				Console.WriteLine("----INDEX XAML ---");
				xamlBuilder.CreateIndexView(catalog);
				Console.WriteLine("----TEMPLATE---");
				Console.WriteLine(templateBuilder.BuildCatalog(catalog));
				Console.WriteLine("----SQL ---");
				Console.WriteLine(sqlBuilder.BuildPagedIndex(c.Value));
			}
		}

		void BuildDocuments()
		{
			foreach (var d in _solution.documents)
			{
				//BuildModelJson($"documents/{d.Key}", d.Value);
			}
		}

		void BuildCatalogModelJson(String name, ICatalog elem)
		{
			String path = $"catalogs/{name}";
			var builder = new ModelJsonBuilder(elem);
			var json = builder.Build();
			Console.WriteLine(json);
		}
	}
}
