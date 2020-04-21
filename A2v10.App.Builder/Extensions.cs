using System;
using System.Collections.Generic;
using System.Text;

namespace A2v10.App.Builder
{
	public static class Extensions
	{
		public static String ToSingular(this String source)
		{
			if (source == null)
				return null;
			if (source.EndsWith("ies"))
				return source.Substring(0, source.Length - 3) + "y";
			else if (source.EndsWith("s"))
				return source.Substring(0, source.Length - 1);
			return source;
		}

		public static String ToPlural(this String source)
		{
			if (source == null)
				return null;
			if (source.EndsWith("y"))
				return source.Substring(source.Length - 1) + "ies";
			return source + "s";
		}
	}
}
