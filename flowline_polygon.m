%% flowline_polygon.m
% Create a pick-selection polygon by transforming the flowline onto the
% segment
% This code will fail if there is not a flowline associated with the segment

function polygon = flowline_polygon(seg_id,handles)
    fname = flowline_for(seg_id,handles);
    flow = handles.flow(fname);
    center = flow.center;

    lat1 = handles.segments.lat1(seg_id);
    lon1 = handles.segments.lon1(seg_id);
    lat2 = handles.segments.lat2(seg_id);
    lon2 = handles.segments.lon2(seg_id);

    npoints = length(flow.lat);

    displacement1 = center - [lat1 lon1];
    flow1 = horzcat(flow.lat(2:npoints),flow.lon(2:npoints)) + displacement1;
    displacement2 = center - [lat2 lon2];
    flow2 = horzcat(flow.lat(2:npoints),flow.lon(2:npoints)) + displacement2;

    flow2 = flipud(flow2);

    polygon = vertcat(flow1,flow2);

end
