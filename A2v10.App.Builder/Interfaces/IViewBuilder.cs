using System;
using System.Collections.Generic;
using System.Text;

namespace A2v10.App.Builder
{
	public interface IViewBuilder
	{
		String Extension { get; }
		String IndexView(ITable table);
		String EditView(ITable table);
		String EditDialog(ITable table);
		String BrowseDialog(ITable table);
	}
}
