%% pick_orientation.m
% Figure out what orientation the pick has relative to the segment
% Either NE or SW
% @param int pid the pick's id
% @param int seg_id the segment's id
% @param handles the GUIDE handles object
% @return String orientation either 'NE' or 'SW'
function orientation = pick_orientation(pid,seg_id,handles)
     x1 = handles.segments.lon1(seg_id);
     y1 = handles.segments.lat1(seg_id);
     x2 = handles.segments.lon2(seg_id);
     y2 = handles.segments.lat2(seg_id);
     
     if x1 > x2
         disp 'switching'
         temp = x1;
         x1 = x2;
         x2 = temp;
         temp = y1;
         y1 = y2;
         y2 = temp;
     end
     
     m = (y2 - y1) / (x2 - x1);
     
     x = handles.plon(pid);
     y = handles.plat(pid);
     if y > (m * (x - x1)) + y1
         orientation = 'NE';
     else
         orientation = 'SW';
     end
end