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
	public class Catalog : ElementBase, ICatalog, ITable
	{
		public Boolean hidden { get; set; }
		
		[JsonProperty("base")]
		public String baseCatalog {get;set;}

		public String plural { get; set; }

		public Dictionary<String, Field> fields { get; set; }
		public List<String> features { get; set; }

		[JsonIgnore]
		public String Plural => plural == null ? name.ToPlural() : plural;

		public ITable GetTable()
		{
			return baseCatalog == null ? this : _solution.catalogs[baseCatalog];
		}
	}
}
