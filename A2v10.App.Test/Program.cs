using A2v10.App.Builder;
using Newtonsoft.Json;
using System;
using System.IO;

namespace A2v10.App.Test
{
	class Program
	{
		static void Main(string[] args)
		{
			var basePath = "../../../../Application";
			var s = Solution.LoadFromFile($"{basePath}/solution.json");
			var styles = Styles.LoadFromFile($"{basePath}/styles.json");
			var b = new AppBuilder(s, styles, basePath);
			b.Build();
			//Directory.CreateDirectory("../../../../Application/sample");
			b.BuildSql($"{basePath}/sample_full.sql");
		}
	}
}
