
update streettrees_workorde set census_id = nycb2010.bctcb2010 from nycb2010 where st_intersects(streettrees_workorde.the_geom,nycb2010.the_geom);