# set geom
update workordersfull set the_geom = st_transform(st_setsrid(st_makepoint(x::float,y::float),2263), 4326) where x != '' and y != '';


# intersects
update streettrees set census_block = nycb2010.bctcb2010 from nycb2010 where st_intersects(streettrees.the_geom,nycb2010.the_geom);
update streettrees set census_tract = nyct2010.ct2010 from nyct2010 where st_intersects(streettrees.the_geom,nyct2010.the_geom);
update workordersfull set census_block = nycb2010.bctcb2010 from nycb2010 where st_intersects(workordersfull.the_geom,nycb2010.the_geom);
update workordersfull set census_tract = nyct2010.ct2010 from nyct2010 where st_intersects(workordersfull.the_geom,nyct2010.the_geom);		