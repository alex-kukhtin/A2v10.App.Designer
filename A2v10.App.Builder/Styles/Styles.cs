using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.IO;
using System.Text;

namespace A2v10.App.Builder
{
	public class ElementStyle : Dictionary<String, String>
	{
	}

	public class Styles : Dictionary<String, ElementStyle>
	{
		public static Styles LoadFromFile(String path)
		{
			var json = File.ReadAllText(path);
			var s = JsonConvert.DeserializeObject<Styles>(json);
			return s;
		}
	}
}
