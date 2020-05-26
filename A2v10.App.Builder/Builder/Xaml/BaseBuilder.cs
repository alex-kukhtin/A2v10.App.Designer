/* Copyright © 2019-2020 Alex Kukhtin. All rights reserved. */

using System.Xml.Linq;

namespace A2v10.App.Builder.Xaml
{
	public class BaseBuilder
	{
		protected readonly Styles _styles;

		public BaseBuilder(Styles styles)
		{
			_styles = styles;
		}

		public XElement SetElementStyle(XElement elem)
		{
			return SetElementStyle(elem, _styles);
		}

		public static XElement SetElementStyle(XElement elem, Styles styles)
		{
			if (styles == null)
				return elem;
			if (styles.TryGetValue(elem.Name.LocalName, out ElementStyle elemStyle))
			{
				foreach (var s in elemStyle)
					elem.Add(new XAttribute(s.Key, s.Value));
			}
			return elem;
		}
	}

	public static class StyleExtensions
	{
		public static XElement SetStyle(this XElement elem, Styles styles)
		{
			return BaseBuilder.SetElementStyle(elem, styles);
		}
	}
}
