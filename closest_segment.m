%% closest_segment.m
% Get the id of the closest segment to the given lat/lon coordinates
% Approximate the position of the segment to its midpoint
% @param double lat Latitude
% @param double lon Longitude
% @param handles the application's handles object
% @return int seg_id the id of the closest segment
function seg_id = closest_segment(lat,lon,handles)
    segment_id = 0;
    mindist = Inf;
    for i=1:length(handles.segments.lat1)
        seglat1 = handles.segments.lat1(i);
        seglon1 = handles.segments.lon1(i);
        seglat2 = handles.segments.lat2(i);
        seglon2 = handles.segments.lon2(i);
        
        % Calculate midpoint
        mlat = (seglat1 + seglat2) / 2;
        mlon = (seglon1 + seglon2) / 2;
        
        [dist, ~] = distance(mlat, mlon, lat, lon);
        if dist < mindist
            mindist = dist;
            segment_id = i;
        end
    end
    seg_id = segment_id;
end