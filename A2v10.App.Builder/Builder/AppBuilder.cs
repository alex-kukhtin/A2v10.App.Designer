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
			var xamlBuilder = new XamlBuilder(_styles);
			BuildCatalogs(xamlBuilder);
			BuildDocuments();
		}

		void BuildCatalogs(XamlBuilder builder)
		{
			var sqlBuilder = new SqlBuilder();
			foreach (var c in _solution.catalogs)
			{
				if (c.Value.hidden)
					continue;
				BuildCatalogModelJson(c.Key, c.Value);
				c.Value.CreateIndexView(builder);
				Console.WriteLine(sqlBuilder.BuildPagedIndex(c.Value));
				return;
			}
		}

		void BuildDocuments()
		{
			foreach (var d in _solution.documents)
			{
				//BuildModelJson($"documents/{d.Key}", d.Value);
			}
		}

		void BuildCatalogModelJson(String name, Catalog elem)
		{
			String path = $"catalogs/{name}";
			var json = elem.GetModelJson();
			Console.WriteLine(json);
		}
	}
}
