%% select_picks.m
% select picks in the rectangular region between the given coordinates
% @param lat1 lower-left boundary lattitude
% @param lon1 lower-left boundary longitude
% @param lat2 upper-right boundary lattitude
% @param longitude upper-right boundary longitude
% @param handles the application's handles object
% @return Array<Integer> array of pick-indexes in the given region
function picks = select_picks(lat1,lon1,lat2,lon2,handles)
    maxlat = max(lat1,lat2);
    minlat = min(lat1,lat2);
    maxlon = max(lon1,lon2);
    minlon = min(lon1,lon2);
    plat = handles.plat;
    plon = handles.plon;

    validlat = find(plat > minlat & plat < maxlat);
    validlon = find(plon > minlon & plon < maxlon);
    picks = intersect(validlat,validlon);
end
