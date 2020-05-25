using System;
using System.Collections.Generic;
using System.Text;
using System.Xml.Linq;

namespace A2v10.App.Builder.Xaml
{
	public class BaseBuilder
	{
		private readonly Styles _styles;

		public BaseBuilder(Styles styles)
		{
			_styles = styles;
		}

		public void SetElementStyle(XElement elem)
		{
			if (_styles == null)
				return;
			if (_styles.TryGetValue(elem.Name.LocalName, out ElementStyle elemStyle))
			{
				foreach (var s in elemStyle)
					elem.Add(new XAttribute(s.Key, s.Value));
			}
		}

	}
}
