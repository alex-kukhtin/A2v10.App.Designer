
using System;
using System.IO;
using System.Text;
using System.Xml.Linq;
using System.Linq;

namespace A2v10.App.Builder
{
	public class AppBuilder
	{
		private readonly Solution _solution;
		private readonly Styles _styles;
		private readonly String _basePath;

		public AppBuilder(Solution solution, Styles styles, String path)
		{
			_solution = solution;
			_styles = styles;
			_basePath = path;
		}

		public void Build()
		{
			BuildCatalogs();
			BuildDocuments();
		}

		void BuildCatalogs()
		{
			var xamlBuilder = new XamlBuilder(_styles);
			var templateBuilder = new CatalogTemplateBuilder();
			foreach (var c in _solution.catalogs)
			{
				ITable catalog = c.Value;
				String dir = $"{_basePath}/catalog/{c.Key.ToLowerInvariant()}";
				Directory.CreateDirectory(dir);

				String modelJsonfile = $"{dir}/model.json";
				File.WriteAllText(modelJsonfile, BuildCatalogModelJson(catalog));

				xamlBuilder.BuildCatalogFiles(dir, catalog);
				templateBuilder.BuildCatalogFiles(_basePath, catalog);
				//String indexViewFile = $"{dir}/index.view.xaml";
				//File.WriteAllText(indexViewFile, xamlBuilder.CreateIndexView(catalog));
				//Console.WriteLine("----TEMPLATE---");
				//Console.WriteLine();
				//Console.WriteLine("----SQL ---");
				//Console.WriteLine(sqlBuilder.BuildPagedIndex(c.Value));
			}
		}

		public void BuildSql(String path)
		{
			var sqlBuilder = new SqlBuilder();
			var sb = new StringBuilder();
			// header
			// TODO:

			sb.AppendLine("-- SCHEMAS");
			foreach (var c in _solution.AllSchemas())
				sb.AppendLine(sqlBuilder.BuildSchema(c));

			sb.AppendLine("-- TABLES");
			foreach (var t in _solution.AllTables())
				sb.AppendLine(sqlBuilder.BuildTable(t));
			sb.AppendLine();

			// table types
			// TODO:

			sb.AppendLine("-- PROCEDURES");
			foreach (var c in _solution.catalogs.Where(x => String.IsNullOrEmpty(x.Value.extends)))
			{
				sb.Append(sqlBuilder.BuildProcedures(c.Value));
			}

			File.WriteAllText(path, sb.ToString(), Encoding.UTF8);
		}

		void BuildDocuments()
		{
			foreach (var d in _solution.documents)
			{
				ITable table = d.Value;
				String dir = $"{_basePath}/document/{table.name.ToLowerInvariant()}";
				Directory.CreateDirectory(dir);
				String modelJsonfile = $"{dir}/model.json";
				File.WriteAllText(modelJsonfile, BuildCatalogModelJson(table));
			}
		}

		String BuildCatalogModelJson(ITable elem)
		{
			var builder = new ModelJsonBuilder(elem);
			return builder.Build();
		}
	}
}
