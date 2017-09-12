%% picks_in_polygon.m
% Get all picks that are inside the current handles.polygon selection
% bounds

function picks = picks_in_polygon(handles)
    latv = handles.polygon(:,1);
    lonv = handles.polygon(:,2);
    latq = handles.plat;
    lonq = handles.plon;
    hits = inpolygon(latq, lonq, latv, lonv);
    ary = 1:length(hits);
    picks = ary(hits);
end
