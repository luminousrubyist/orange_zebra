%% segment_output.m
% Generate output for a given segment
% @param int seg_id the segment id
% @param handles the GUIDE handles object
% @return string output the output associated with the segment
function output = segment_output(seg_id,handles)
    lines = {};
    lines{end+1} = 'seg_id boundary';
    seg_str = sprintf('%d %s',seg_id,handles.segments.boundary(seg_id,:));
    lines{end+1} = seg_str;
    
    % Pick format
    lines{end+1} = 'pick_id plat plon page_ck ridge_side';
    % Picks
    picks = handles.segments.picks{seg_id};
    
    pid = handles.pid(picks);
    plat = handles.plat(picks);
    plon = handles.plon(picks);
    page_ck = handles.page_ck(picks);
    
    for i=1:length(pid)
        orientation = pick_orientation(pid(i),seg_id,handles);
        str = sprintf('%d %f %f %f %s',pid(i),plat(i),plon(i),page_ck(i),orientation);
        lines{end+1} = str;
    end
    
    output = join(lines,sprintf('\n'));
end