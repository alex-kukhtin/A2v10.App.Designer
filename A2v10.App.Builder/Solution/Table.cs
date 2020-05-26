
using System;
using System.Collections.Generic;
using System.Linq;
using Microsoft.VisualBasic;
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
		public List<Feature> features { get; set; }
		public Dictionary<String, Table> details { get; set; }
		public Dictionary<String, String> parameters { get; set; }


		private ITable _parentTable = null;

		public ITable GetParentTable()
		{
			return _parentTable;
		}


		public String Alias => name[0].ToString().ToLowerInvariant();
		public String TableName => Plural;
		public String NameField => fields?.Where(f => f.Value.isName)?.Select(f => f.Value.name)?.FirstOrDefault();

		public ITable GetBaseTable()
		{
			return extends == null ? this : _solution.FindTable(extends);
		}

		public ITable GetReferenceTable(Field field)
		{
			if (field.type != FieldType.@ref)
				return null;
			return field.reference != null ? _solution.FindTable(field.reference) : null;
		}


		public override void SetParent(Solution solution, String name, TableKind kind)
		{
			base.SetParent(solution, name, kind);
			if (fields != null)
				foreach (var f in fields)
					f.Value.SetParent(solution, f.Key, TableKind.field);
			if (details != null)
				foreach (var d in details)
				{
					d.Value.SetParent(solution, d.Key, TableKind.details);
					d.Value._parentTable = this;
				}
		}

		public Boolean HasFeature(Feature feature)
		{
			return features != null && features.Contains(feature);
		}

		public Boolean IsBaseTable()
		{
			return String.IsNullOrEmpty(extends);
		}

		public IEnumerable<Field> AllFields(Func<Field, Boolean> predicate)
		{
			return AllFieldsImpl(this, predicate);
		}

		private IEnumerable<Field> AllFieldsImpl(ITable table, Func<Field, Boolean> predicate)
		{
			if (table.fields == null)
				yield break;
			foreach (var f in table.fields.Values)
			{
				if (predicate(f))
					yield return f;
			}

			if (table.details != null) { 
				foreach (var d in table.details.Values)
					foreach (var f1 in AllFieldsImpl(d, predicate))
						yield return f1;
			}
		}
	}
}
