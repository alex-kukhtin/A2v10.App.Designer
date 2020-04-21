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
		public String typeName { get; set; }
		public String schema { get; set; }

		[JsonIgnore]
		protected Solution _solution;
		[JsonIgnore]
		public String name { get; private set; }

		[JsonIgnore]
		public String TypeName => typeName == null ? $"T{name}".ToSingular() : typeName;
		[JsonIgnore]
		public String Schema => schema == null ? _solution.schema : schema;

		public void SetParent(Solution solution, String name)
		{
			_solution = solution;
			this.name = name;
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
