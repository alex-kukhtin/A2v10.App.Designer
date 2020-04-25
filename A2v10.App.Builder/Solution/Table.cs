using System;
using System.Collections.Generic;
using System.Text;
using System.Xml;
using System.Xml.Linq;
using Newtonsoft.Json;

namespace A2v10.App.Builder
{
	/*
	 todo:
	 1. Index View
	 2. Index Template
	 3. Edit dialog,
	 4. Edit template
	 5. Browse template
	 6. SQL procedures
	 7. 
	 */
	public class Table : ElementBase, ICatalog, ITable
	{
		public String extends {get;set;}

		public Dictionary<String, Field> fields { get; set; }
		public List<String> features { get; set; }

		public ITable GetTable()
		{
			return extends == null ? this : _solution.catalogs[extends];
		}

		public override void SetParent(Solution solution, string name)
		{
			base.SetParent(solution, name);
			if (fields != null)
				foreach (var f in fields)
					f.Value.SetParent(solution, f.Key);
		}
	}
}
