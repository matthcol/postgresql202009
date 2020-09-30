do
$$
begin
	for i in 1 .. 80000 loop
		insert into movies(id, title, year) values (i+12880000, 'SQL Server' || i, 2020);
	end loop;
end;
$$;