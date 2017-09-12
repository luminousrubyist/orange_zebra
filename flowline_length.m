%% flowline_length.m
% Use linear approximation
function len = flowline_length(fname,handles)
    flow = handles.flow(fname);
    [len, ~] = distance(flow.first(1),flow.first(2),flow.last(1),flow.last(2));
end