using System;
using System.Collections.Generic;
using System.Text;

namespace A2v10.App.Builder
{
	public interface IField
	{
		String name { get; }
		String GetLabel();
	}
}
