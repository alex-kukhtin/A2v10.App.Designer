using System;
using System.Collections.Generic;
using System.Text;

namespace A2v10.App.Builder
{
	public class SqlBuilder
	{
		public String BuildPagedIndex(ICatalog model)
		{
			var propName = model.Plural;
			ITable table = model.GetTable();
			var alias = table.name[0].ToString().ToLowerInvariant();

			var sb = new StringBuilder();
sb.AppendLine(
@$"-------------------------------------
create or alter procedure [{model.Schema}].[{model.name}.Index]
@UserId bigint,
@Id bigint = null,
@Offset int = 0,
@PageSize int = 20,
@Order nvarchar(255) = N'Id',
@Dir nvarchar(20) = N'desc',
@Fragment nvarchar(255) = null
as 
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	declare @rawFilter nvarchar(255);
	set @rawFilter = @Fragment;
	set @Fragment = N'%' + upper(@Fragment) + N'%';
");

sb.AppendLine(
@$"	declare @paged table(_id bigint, _no int identity(1, 1), _rows int);

	insert into @paged(Id, _rows)
	select {alias}.Id, count(*) over ()
	from 
		[{table.Schema}].[{table.name}] {alias}
	where 
		@Fragment is null [TODO:OR params]
	order by [TODO: order by fields]
	offset @Offset rows fetch next @PageSize rows only
	option (recompile);
");
		
sb.AppendLine(
@$"	select [{propName}!{table.TypeName}!Array] = null, {GetFields(alias, table)}
		[!!RowCount] = t._rows
	from [{table.Schema}].[{table.name}] {alias} inner join @paged t on t._id = {alias}.Id
	order by t._rowNo;
");

// system recordset
sb.Append(
@$"
	-- system data
	select [!$System!] = null,  [!{propName}!PageSize] = @PageSize, [!{propName}!Offset] = @Offset,
		[!{propName}!SortOrder] = @Order,  [!{propName}!SortDir] = @Dir, 
		[!{propName}.Fragment!Filter] = @rawFilter;
end
go
"
);
			return sb.ToString();
		}


		String GetFields(String alias, ITable table)
		{
			var sb = new StringBuilder();
			sb.Append($"[Id!!Id] = {alias}.Id, ");
			foreach (var f in table.fields)
			{
				if (f.Value.parameter)
					continue;
				sb.Append($"{alias}.[{f.Key}], ");
			}
			return sb.ToString();
		}
	}
}
