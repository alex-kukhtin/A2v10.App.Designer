﻿using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Xml;
using System.Xml.Linq;

namespace A2v10.App.Builder
{
	public class ElementBase
	{
		public String uiName { get; set; }
		public String schema { get; set; }
		public String plural { get; set; }

		[JsonIgnore]
		protected Solution _solution;
		[JsonIgnore]
		public String name { get; private set; }

		[JsonIgnore]
		public String TypeName => $"T{name}";
		[JsonIgnore]
		public String Schema => schema == null ? _solution.schema : schema;
		[JsonIgnore]
		public String Plural => plural == null ? name.ToPlural() : plural;

		public virtual void SetParent(Solution solution, String name)
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

	public class Solution
	{
		public String schema { get; set; }

		public Dictionary<String, Table> catalogs { get; set; } = new Dictionary<String, Table>();
		public Dictionary<String, Table> documents { get; set; } = new Dictionary<String, Table>();
		public Dictionary<String, Table> journals { get; set; } = new Dictionary<string, Table>();

		public void SetParent()
		{
			foreach (var c in catalogs)
				c.Value.SetParent(this, c.Key);
			foreach (var d in documents)
				d.Value.SetParent(this, d.Key);
			foreach (var j in journals)
				j.Value.SetParent(this, j.Key);
		}

		public IEnumerable<String> AllSchemas()
		{
			var schemas =
				catalogs.Select(x => x.Value.Schema)
				.Union(documents.Select(x => x.Value.Schema))
				.Union(journals.Select(x => x.Value.Schema))
				.Distinct();
			return schemas;
		}

		public IEnumerable<ITable> AllTables()
		{
			foreach (var c in catalogs.Where(x => String.IsNullOrEmpty(x.Value.extends)))
				yield return c.Value;
			foreach (var d in documents.Where(x => String.IsNullOrEmpty(x.Value.extends))) {
				yield return d.Value;
			}
			foreach (var d in journals.Where(x => String.IsNullOrEmpty(x.Value.extends)))
			{
				yield return d.Value;
			}
		}

		public ITable FindTable(String name)
		{
			if (catalogs.TryGetValue(name, out Table cat))
				return cat.GetTable();
			if (documents.TryGetValue(name, out Table doc))
				return doc.GetTable();
			return null;
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