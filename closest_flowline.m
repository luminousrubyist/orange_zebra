%% closest_flowline.m
% Get the name of the closest flowline to the given lat/lon coordinates
% Approximate the position of the flowline to its center
% @param double lat Latitude
% @param double lon Longitude
% @param handles the application's handles object
% @return flowname the name of the closest flowline
function flowname = closest_flowline(lat,lon,handles)
    fname = '';
    mindist = Inf;
    for k = keys(handles.flow)
        key = k{1};
        center = handles.flow(key).center;
        flat = center(1);
        flon = center(2);
        dist = distance(lat, lon, flat, flon);
        if(dist < mindist)
            fname = handles.flow(key).name;
            mindist = dist;
        end
    end
    flowname = fname;
end
