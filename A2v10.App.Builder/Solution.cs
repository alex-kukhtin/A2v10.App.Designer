using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Xml;
using System.Xml.Linq;

namespace A2v10.App.Builder
{
	public class ElementBase
	{
		public String uiName { get; set; }

		[JsonIgnore]
		protected Solution _solution;
		[JsonIgnore]
		protected String _name;

		public void SetParent(Solution solution, String name)
		{
			_solution = solution;
			_name = name;
		}

		public String SerializeXml(XDocument doc)
		{
			var sb = new StringBuilder();
			using (var xr = XmlWriter.Create(sb))
			{
				doc.WriteTo(xr);
			}
			return sb.ToString();
		}
	}

	public class Field : ElementBase
	{
	}

	public class Document : ElementBase
	{
	}

	public class Solution
	{
		public String schema { get; set; }

		public Dictionary<String, Catalog> catalogs { get; set; }

		public Dictionary<String, Document> documents { get; set; }

		public void SetParent()
		{
			if (catalogs != null)
				foreach (var c in catalogs)
					c.Value.SetParent(this, c.Key);
		}

		public static Solution LoadFromFile(String path)
		{
			var json = File.ReadAllText(path);
			var s = JsonConvert.DeserializeObject<Solution>(json);
			s.SetParent();
			return s;
		}
	}
}
