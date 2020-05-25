
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
		private readonly IViewBuilder _viewBuilder;
		private readonly ISqlBuilder _sqlBuilder;

		private readonly CatalogTemplateBuilder _templateBuilder;

		public AppBuilder(Solution solution, IViewBuilder viewBuilder, ISqlBuilder sqlBuilder)
		{
			_solution = solution;
			_viewBuilder = viewBuilder;
			_sqlBuilder = sqlBuilder;
			_templateBuilder = new CatalogTemplateBuilder();
		}

		public void Build(String basePath)
		{
			BuildCatalogs(basePath);
			BuildDocuments(basePath);
		}

		void BuildCatalogs(String basePath)
		{
			foreach (var c in _solution.catalogs)
			{
				ITable catalog = c.Value;
				String tail = $"catalog/{c.Key.ToLowerInvariant()}";
				String dirName = $"{basePath}/{tail}";
				Directory.CreateDirectory(dirName);

				String modelJsonfile = $"{dirName}/model.json";
				File.WriteAllText(modelJsonfile, BuildCatalogModelJson(catalog));

				BuildCatalogFiles(tail, dirName, catalog);
				_templateBuilder.BuildFiles("catalog", basePath, catalog);
				//Console.WriteLine("----TEMPLATE---");
				//Console.WriteLine();
				//Console.WriteLine("----SQL ---");
				//Console.WriteLine(sqlBuilder.BuildPagedIndex(c.Value));
			}
		}

		void BuildCatalogFiles(String tail, String dir, ITable table)
		{
			if (table.features == null)
				return;
			String xaml = _viewBuilder.IndexView(table);
			if (xaml != null)
			{
				String fileName = $"index.view.{_viewBuilder.Extension}";
				Console.WriteLine($"{tail}/{fileName}");
				File.WriteAllText($"{dir}/{fileName}", xaml);
			}
			if (table.HasFeature(Feature.editDialog)) {
				xaml = _viewBuilder.EditDialog(table);
				if (xaml != null)
				{
					String fileName = $"edit.dialog.{_viewBuilder.Extension}";
					Console.WriteLine($"{tail}/{fileName}");
					File.WriteAllText($"{dir}/{fileName}", xaml);
				}
			}
			if (table.HasFeature(Feature.browse))
				WriteFile(tail, dir, "browse.dialog", _viewBuilder.BrowseDialog(table));
		}

		void WriteFile(String tail, String dir, String name, String text)
		{
			String fileName = $"{name}.{_viewBuilder.Extension}";
			Console.WriteLine($"{tail}/{fileName}");
			File.WriteAllText($"{dir}/{fileName}", text);
		}

		void BuildDocumentFiles(String tail, String dir, ITable table)
		{
			if (table.HasFeature(Feature.index))
			{
				String xaml = _viewBuilder.IndexView(table);
				if (xaml != null)
				{
					String fileName = $"index.view.{_viewBuilder.Extension}";
					Console.WriteLine($"{tail}/{fileName}");
					File.WriteAllText($"{dir}/{fileName}", xaml);
				}
			}
			if (table.HasFeature(Feature.editPage))
			{
				String xaml = _viewBuilder.EditView(table);
				if (xaml != null)
				{
					String fileName = $"edit.view.{_viewBuilder.Extension}";
					Console.WriteLine($"{tail}/{fileName}");
					File.WriteAllText($"{dir}/{fileName}", xaml);
				}
			}
		}

		public void BuildSql(String path)
		{
			var sb = new StringBuilder();

			// header
			// TODO:

			sb.AppendLine("-- SCHEMAS");
			foreach (var c in _solution.AllSchemas())
				sb.AppendLine(_sqlBuilder.BuildSchema(c));

			sb.AppendLine("-- TABLES");
			foreach (var t in _solution.AllTables())
				sb.AppendLine(_sqlBuilder.BuildTable(t));
			sb.AppendLine();

			sb.AppendLine("-- TABLE TYPES");
			foreach (var c in _solution.AllTables())
				sb.Append(_sqlBuilder.BuldDropBeforeTableType(c));

			foreach (var c in _solution.AllTables())
				sb.Append(_sqlBuilder.BuldTableType(c));

			sb.AppendLine("-- PROCEDURES");
			foreach (var c in _solution.catalogs.Values.Where(x => x.IsBaseTable()))
				sb.Append(_sqlBuilder.BuildProcedures(c));

			foreach (var d in _solution.documents.Values.Where(x => x.IsBaseTable()))
				sb.Append(_sqlBuilder.BuildProcedures(d));

			File.WriteAllText(path, sb.ToString(), Encoding.UTF8);
		}

		void BuildDocuments(String basePath)
		{
			foreach (var d in _solution.documents)
			{
				ITable document = d.Value;
				String tail = $"document/{d.Key.ToLowerInvariant()}";
				String dir = $"{basePath}/{tail}";
				Directory.CreateDirectory(dir);
				String modelJsonfile = $"{dir}/model.json";
				File.WriteAllText(modelJsonfile, BuildCatalogModelJson(document));
				_templateBuilder.BuildFiles("document", basePath, document);

				BuildDocumentFiles(tail, dir, document);
			}
		}

		String BuildCatalogModelJson(ITable elem)
		{
			var builder = new ModelJsonBuilder(elem);
			return builder.Build();
		}
	}
}
