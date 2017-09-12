%% flowline_for.m
% If a flowline was constructed based on the segment, return that
% flowline's name. If not, return the empty string
% @param int seg_id The segment's id
% @param handles The GUIDE handles object
% @return String fname The name of the flowline

function fname = flowline_for(seg_id,handles)
    for k = keys(handles.flow)
        key = k{1};
        flow = handles.flow(key);
        if flow.seg_id == seg_id
            fname = flow.name;
            return
        end
    end
    fname = '';
end
