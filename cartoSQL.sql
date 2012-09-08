# set geom
update workorders set the_geom = st_setsrid(st_makepoint(x::float,y::float),2263) where x != '' and y != '';


# intersects
update streettrees set census_block = nycb2010.bctcb2010 from nycb2010 where st_intersects(streettrees.the_geom,nycb2010.the_geom);
update streettrees set census_tract = nyct2010.ct2010 from nyct2010 where st_intersects(streettrees.the_geom,nyct2010.the_geom);
update workorders set census_block = nycb2010.bctcb2010 from nycb2010 where st_intersects(workorders.the_geom,nycb2010.the_geom);
update workorders set census_tract = nyct2010.ct2010 from nyct2010 where st_intersects(workorders.the_geom,nyct2010.the_geom);		