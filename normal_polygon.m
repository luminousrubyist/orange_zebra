%% normal_polygon.m
% Create a pick-selection polygon by constructing line segments normal to
% the segment
% @param int seg_id the segment identifier
% @param handles the GUIDE handles object
% @return matrix polygon a matrix with four rows and two columns (lat and lon) to
% represent the four points of the rhomboid polygon

function polygon = normal_polygon(seg_id,handles)
    lat1 = handles.segments.lat1(seg_id);
    lon1 = handles.segments.lon1(seg_id);
    lat2 = handles.segments.lat2(seg_id);
    lon2 = handles.segments.lon2(seg_id);
    len = 8; % The length of each segment to construct
    theta = segment_angle(seg_id,handles);
    lonb1 = lon1 + ( -(len/2) * cos((pi/2) + theta) );
    latb1 = lat1 + ( -(len/2) * sin((pi/2) + theta) );
    lonb2 = lon1 + ( (len/2) * cos((pi/2) + theta) );
    latb2 = lat1 + ( (len/2) * sin((pi/2) + theta) );
    
    lone1 = lon2 + ( -(len/2) * cos((pi/2) + theta) );
    late1 = lat2 + ( -(len/2) * sin((pi/2) + theta) );
    lone2 = lon2 + ( (len/2) * cos((pi/2) + theta) );
    late2 = lat2 + ( (len/2) * sin((pi/2) + theta) );
    
    polygon = vertcat([latb1 lonb1],[latb2 lonb2],[late2,lone2],[late1,lone1]);
end