%% flowline_angle.m
function angle = flowline_angle(fname,handles)
    flow = handles.flow(fname);
    lat1 = flow.first(1);
    lon1 = flow.first(2);
    lat2 = flow.last(1);
    lon2 = flow.last(2);
    y = (lat2 - lat1);
    x = (lon2 - lon1);
    angle = atan2(y,x);
end