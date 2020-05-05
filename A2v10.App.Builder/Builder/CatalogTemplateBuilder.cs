﻿
using System;
using System.Collections.Generic;
using System.IO;
using System.Text;

/*
TODO:
index.d.ts
model.d.ts
edit.template.ts
 */

namespace A2v10.App.Builder
{
	public class CatalogTemplateBuilder
	{

		public void BuildCatalogFiles(String basePath, ITable table)
		{
			if (!String.IsNullOrEmpty(table.extends))
				return;

			String dir = $"catalog/{table.name.ToLowerInvariant()}";

			String template = BuildIndexTemplate(table);
			Console.WriteLine($"{dir}/index.template.ts");
			File.WriteAllText($"{basePath}/{dir}/index.template.ts", template);

			template = BuildEditTemplate(table);
			Console.WriteLine($"{dir}/edit.template.ts");
			File.WriteAllText($"{basePath}/{dir}/edit.template.ts", template);
		}

		String BuildEditTemplate(ITable table)
		{
			return
@"
const template: Template = {
};

export default template;
";
		}

		String BuildIndexTemplate(ITable table)
		{ 
			StringBuilder sb = new StringBuilder();

			sb.AppendLine();
			sb.AppendLine("const template: Template = {");
			var props = CreateProperties(sb);
			var events = CreateEvents(sb);
			var commands = CreateCommands(sb, table);
			var delegates = CreateDelegates(sb, table);
			sb.AppendLine(
@"};

export default template;

");
			sb.Append(props)
			.Append(events)
			.Append(commands)
			.Append(delegates);
			return sb.ToString();
		}

		String CreateProperties(StringBuilder sb)
		{
			return String.Empty;
		}

		String CreateEvents(StringBuilder sb)
		{
			return String.Empty;
		}

		String CreateCommands(StringBuilder sb, ITable catalog)
		{
			var fetch = catalog.features?.Find(s => s == "fetch");
			return String.Empty;
		}

		String CreateDelegates(StringBuilder sb, ITable catalog)
		{
			return String.Empty;
		}
	}
}
