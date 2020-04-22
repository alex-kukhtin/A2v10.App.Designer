using System;
using System.Collections.Generic;
using System.Text;

namespace A2v10.App.Builder
{
	public class CatalogTemplateBuilder
	{

		public String BuildCatalog(ICatalog catalog)
		{
			StringBuilder sb = new StringBuilder();

			sb.AppendLine("const template = {");
			var props = CreateProperties(sb);
			var events = CreateEvents(sb);
			var commands = CreateCommands(sb, catalog);
			var delegates = CreateDelegates(sb, catalog);
			sb.AppendLine(
@"};
module.exports = template;

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

		String CreateCommands(StringBuilder sb, ICatalog catalog)
		{
			var fetch = catalog.features?.Find(s => s == "fetch");
			return String.Empty;
		}

		String CreateDelegates(StringBuilder sb, ICatalog catalog)
		{
			return String.Empty;
		}
	}
}
