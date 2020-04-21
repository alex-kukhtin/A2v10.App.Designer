using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Text;

namespace A2v10.App.Builder
{
	public class AppBuilder
	{
		private readonly Solution _solution;

		public AppBuilder(Solution solution)
		{
			_solution = solution;
		}

		public void Build()
		{
			BuildCatalogs();
			BuildDocuments();
		}

		void BuildCatalogs()
		{
			foreach (var c in _solution.catalogs)
			{
				if (c.Value.hidden)
					continue;
				BuildCatalogModelJson(c.Key, c.Value);
				c.Value.CreateIndexView();
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
