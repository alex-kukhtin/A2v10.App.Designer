
using A2v10.App.Builder;
using A2v10.App.Builder.Interfaces;
using A2v10.App.Builder.SqlServer;
using A2v10.App.Builder.Xaml;

namespace A2v10.App.Test
{
	class Program
	{
		static void Main(string[] args)
		{
			var basePath = "../../../../A2v10.Application/App_Application";
			var s = Solution.LoadFromFile($"{basePath}/solution.json");
			var styles = Styles.LoadFromFile($"{basePath}/styles.json");

			var opts = new SolutionOptions();
			var xaml = new XamlBuilder(styles);
			var sql = new SqlBuilder(opts);

			var b = new AppBuilder(s, xaml, sql);
			b.Build(basePath + "/sample");
			//Directory.CreateDirectory("../../../../Application/sample");
			b.BuildSql($"{basePath}/sample_full.sql");
		}
	}
}
