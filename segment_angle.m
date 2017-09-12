%% segment_angle.m
function angle = segment_angle(seg_id,handles)
    lat1 = handles.segments.lat1(seg_id);
    lon1 = handles.segments.lon1(seg_id);
    lat2 = handles.segments.lat2(seg_id);
    lon2 = handles.segments.lon2(seg_id);
    y = (lat2 - lat1);
    x = (lon2 - lon1);
    angle = atan2(y,x);
end
