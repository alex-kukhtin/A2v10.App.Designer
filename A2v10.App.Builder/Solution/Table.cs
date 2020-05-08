
using System;
using System.Collections.Generic;
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
	public class Table : ElementBase, ITable
	{
		public String extends {get;set;}

		public Dictionary<String, Field> fields { get; set; }
		public List<String> features { get; set; }
		public Dictionary<String, Table> details { get; set; }
		public Dictionary<String, String> parameters { get; set; }


		private ITable _parentTable = null;

		public ITable GetParentTable()
		{
			return _parentTable;
		}


		public ITable GetBaseTable()
		{
			return extends == null ? this : _solution.FindTable(extends);
		}

		public override void SetParent(Solution solution, string name)
		{
			base.SetParent(solution, name);
			if (fields != null)
				foreach (var f in fields)
					f.Value.SetParent(solution, f.Key);
			if (details != null)
				foreach (var d in details)
				{
					d.Value.SetParent(solution, d.Key);
					d.Value._parentTable = this;
				}
		}

		public Boolean HasFeature(String feature)
		{
			return features != null && features.Contains(feature);
		}

		public Boolean IsBaseTable()
		{
			return String.IsNullOrEmpty(extends);
		}
	}
}
