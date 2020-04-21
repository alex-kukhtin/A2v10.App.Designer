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
			var s = Solution.LoadFromFile("../../../../Application/solution.json");
			var b = new AppBuilder(s);
			b.Build();
		}
	}
}
