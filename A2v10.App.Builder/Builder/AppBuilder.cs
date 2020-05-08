
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
				String dir = $"{basePath}/catalog/{c.Key.ToLowerInvariant()}";
				Directory.CreateDirectory(dir);

				String modelJsonfile = $"{dir}/model.json";
				File.WriteAllText(modelJsonfile, BuildCatalogModelJson(catalog));

				BuildCatalogFiles(dir, catalog);
				_templateBuilder.BuildFiles("catalog", basePath, catalog);
				//Console.WriteLine("----TEMPLATE---");
				//Console.WriteLine();
				//Console.WriteLine("----SQL ---");
				//Console.WriteLine(sqlBuilder.BuildPagedIndex(c.Value));
			}
		}

		void BuildCatalogFiles(String dir, ITable table)
		{
			if (table.features == null)
				return;
			String xaml = _viewBuilder.IndexView(table);
			if (xaml != null)
			{
				String indexViewFile = $"{dir}/index.view.{_viewBuilder.Extension}";
				File.WriteAllText(indexViewFile, xaml);
			}
			if (table.HasFeature("editDialog")) {
				xaml = _viewBuilder.EditDialog(table);
				if (xaml != null)
				{
					String dialogViewFile = $"{dir}/edit.dialog.{_viewBuilder.Extension}";
					File.WriteAllText(dialogViewFile, xaml);
				}
			}
		}

		void BuildDocumentFiles(String dir, ITable table)
		{
			String xaml = _viewBuilder.IndexView(table);
			if (xaml != null)
			{
				String indexViewFile = $"{dir}/index.view.{_viewBuilder.Extension}";
				File.WriteAllText(indexViewFile, xaml);
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
				String dir = $"{basePath}/document/{document.name.ToLowerInvariant()}";
				Directory.CreateDirectory(dir);
				String modelJsonfile = $"{dir}/model.json";
				File.WriteAllText(modelJsonfile, BuildCatalogModelJson(document));
				_templateBuilder.BuildFiles("document", basePath, document);

				BuildDocumentFiles(dir, document);
			}
		}

		String BuildCatalogModelJson(ITable elem)
		{
			var builder = new ModelJsonBuilder(elem);
			return builder.Build();
		}
	}
}
