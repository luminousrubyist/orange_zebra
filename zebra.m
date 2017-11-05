function varargout = zebra(varargin)
    % ZEBRA MATLAB code for zebra.fig
    %      ZEBRA, by itself, creates a new ZEBRA or raises the existing
    %      singleton*.
    %
    %      H = ZEBRA returns the handle to a new ZEBRA or the handle to
    %      the existing singleton*.
    %
    %      ZEBRA('CALLBACK',hObject,eventData,handles,...) calls the local
    %      function named CALLBACK in ZEBRA.M with the given input arguments.
    %
    %      ZEBRA('Property','Value',...) creates a new ZEBRA or raises the
    %      existing singleton*.  Starting from the left, property value pairs are
    %      applied to the GUI before zebra_OpeningFcn gets called.  An
    %      unrecognized property name or invalid value makes property application
    %      stop.  All inputs are passed to zebra_OpeningFcn via varargin.
    %
    %      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
    %      instance to run (singleton)".
    %
    % See also: GUIDE, GUIDATA, GUIHANDLES

    % Edit the above text to modify the response to help zebra

    % Last Modified by GUIDE v2.5 28-Aug-2017 15:06:50

    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @zebra_OpeningFcn, ...
                       'gui_OutputFcn',  @zebra_OutputFcn, ...
                       'gui_LayoutFcn',  [] , ...
                       'gui_Callback',   []);
    if nargin && ischar(varargin{1})
        gui_State.gui_Callback = str2func(varargin{1});
    end

    if nargout
        [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
    else
        gui_mainfcn(gui_State, varargin{:});
    end
    % End initialization code - DO NOT EDIT
end

% --- Executes just before zebra is made visible.
function zebra_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to zebra (see VARARGIN)

    % Add library paths
    addpath('freezeColors_v23_cbfreeze/freezeColors');


    % CONFIGURATION
    % Files config
    handles.files = struct();
    handles.files.ETOPO = 'data/etopo1_bed_c_f4.flt';
    handles.files.FLOWLINES = 'data/flowlines';
    handles.files.PICKS = 'data/GSFML.global.picks.gmt_output_latlonage';
    handles.files.SEGMENTS = 'data/segments_allspreadingrates_Feb172012';
    % Window config
    %     Entire North Atlantic
    %     handles.latlim = [12 42];
    %     handles.lonlim = [-63 -20];

    handles.LATLIM = [-40 -20];
    handles.latlim = handles.LATLIM;
    handles.LONLIM = [60 80];
    handles.lonlim = handles.LONLIM;


    handles.ETOPOLIM = [-5000 -2000];
    % Axes limits
    % pick ages in Mya
    handles.AGEMIN = 0;
    handles.AGEMAX = 30;

    % Colors
    handles.JET = colormap('jet');
    handles.GRAYSCALE = colormap(flipud(colormap('gray')));

    % Load segments
    handles.SEGMENTS = tdfread(handles.files.SEGMENTS, 'tab');
    handles.segments = handles.SEGMENTS;
    handles.segments.picks = cell(length(handles.segments.lat1),1);
    handles.segments.has_flowline = false(length(handles.segments.lat1),1);

    % Load flowlines --> files must start with 'flowline'
    handles.flow = containers.Map;
    flowline_files = dir(fullfile(handles.files.FLOWLINES,'flowline*'));
    [nfiles,~] = size(flowline_files);
    for i = 1:nfiles
        fname = flowline_files(i).name;
        % Get a list of underscore-separated tokens in the filename, then
        % reverse it
        tokens = flip(strsplit(fname,'_'));
        % The last token (first in the reversed list) is the segment id
        seg_id = str2num(tokens{1});
        handles.segments.has_flowline(seg_id) = true;
        fullname = fullfile(handles.files.FLOWLINES,fname);
        % Build xflow data
        flow = struct();
        flow.name = fname;
        flow.seg_id = seg_id;
        coords = load(fullname);
        % Interpret center of the flowline to be the first line of the file
        flow.center = coords(1,:);

        % Identify each end of the flowline
        flow.first = coords(2,:);
        flow.last = coords(end,:);

        flow.lat = coords(:,1);
        flow.lon = coords(:,2);
        handles.flow(fname) = flow;
    end

    % Load picks
    picksformat = '%n %n %n';
    [plat, plon, page_ck] = textread(handles.files.PICKS,picksformat);

    handles.PLAT = plat;
    handles.PLON = plon;
    handles.PAGE_CK = page_ck;

    handles.plat = plat;
    handles.plon = plon;
    handles.page_ck = page_ck;
    handles.pid = 1:length(plat);

    % Set radiobutton selector to nothing
    handles.uibuttongroup_select_picks.SelectedObject = [];

    % Init plots
    handles.plots = struct();
    % Create an entry in the plots object for each axes
    all_axes = findobj(gcf,'type','axes');
    for i= 1:length(all_axes)
        ax = all_axes(i);
        tag = ax.Tag;
        handles.plots.(tag) = struct();
    end
    % Draw map and ETOPO
    axes(handles.axes_main);
    cla(handles.axes_right);
    handles = disable_panel(handles.panel_fine_tune,handles);
    handles = disable_panel(handles.panel_output,handles);

    handles = select_segment(694,handles); % default segment;

    % Session stuff
    if ~ (7==exist('output','dir'))
        disp('Output directory not found, creating it');
        mkdir('output');
    end

    % Choose default command line output for zebra
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);

    %   UIWAIT makes zebra wait for user response (see UIRESUME)
    %   uiwait(handles.figure1);
end

function h = draw_map(latlim,lonlim,handles)
    warning('off','MATLAB:nargchk:deprecated');
    ax = gca;
    tag = ax.Tag;
    cla(ax);

    % axes plots
    ap = handles.plots.(tag);

    if isfield(ap,'etopo')
        delete(ap.etopo);
        ap = rmfield(ap,'etopo');
    end

    worldmap(latlim,lonlim);


    % Load ETOPO
    [z,~] = etopo(handles.files.ETOPO,1,latlim,lonlim);

    ap.etopo = surfm(latlim,lonlim,z,z);

    % ETOPO axis
    colormap(ax,handles.GRAYSCALE);
    colorbar;
    caxis(handles.ETOPOLIM);
    hold on;

    freezeColors();

    handles.plots.(tag) = ap;

    h = handles;
end

function h = zoom_region(latlim,lonlim,handles)
  axes(handles.axes_right);
  handles = draw_map(latlim,lonlim,handles);
  handles = plot_picks(handles);
  handles = highlight_picks(handles.segments.picks{handles.selected_segment},handles);

  seg_id = handles.selected_segment;

  if(handles.segments.has_flowline(seg_id))
    fname = flowline_for(seg_id,handles);
    handles = plot_flowline(fname,handles);
  end
  handles = plot_segments(handles);
  handles = highlight_segment(seg_id,handles);
  h = handles;
end

% Plot or refresh picks, based on current status of handles
% @param handles
% @return h, newly modified handles object
function h = plot_picks(handles)
    ax = gca;
    tag = ax.Tag;
    indices = find(handles.plat < handles.latlim(2) & handles.plat > handles.latlim(1) & handles.plon < handles.lonlim(2) & handles.plon > handles.lonlim(1));

    % axes plots
    ap = handles.plots.(tag);
    if isfield(ap,'picks')
        delete(ap.picks);
        ap = rmfield(ap,'picks');
    end
    if isfield(ap,'picks_white')
        delete(ap.picks_white);
        ap = rmfield(ap,'picks_white');
    end

    ap.picks_white = scatterm(handles.plat(indices),handles.plon(indices),40,'wd');
    hold on;
    ap.picks = scatterm(handles.plat(indices),handles.plon(indices),100,handles.page_ck(indices),'diamond','MarkerFaceColor','flat','MarkerEdgeColor','flat');
    hold on;
    colormap(ax,'jet');
    colorbar;
    caxis([handles.AGEMIN,handles.AGEMAX]);
    hold on;

    handles.plots.(tag) = ap;

    h = handles;
end

function h = highlight_segment(seg_id,handles)
    ax = gca;
    tag = ax.Tag;
    ap = handles.plots.(tag);
    if(isfield(ap,'segment_highlight'))
        delete(ap.segment_highlight);
        ap = rmfield(ap,'segments');
    end
    lat1 = handles.segments.lat1(seg_id);
    lat2 = handles.segments.lat2(seg_id);
    lon1 = handles.segments.lon1(seg_id);
    lon2 = handles.segments.lon2(seg_id);
    ap.segment_highlight = plotm([lat1 lat2], [lon1 lon2],'g-','LineWidth',5);
    h = handles;
end

% Plot or refresh segments, based on current status of handles
% @param handles
% @return h, newly modified handles object
function h = plot_segments(handles)
    ax = gca;
    tag = ax.Tag;

    % axes plots
    ap = handles.plots.(tag);
    if(isfield(ap,'segments'))
        delete(ap.segments);
        ap = rmfield(ap,'segments');
    end
    lat1 = handles.segments.lat1;
    lon1 = handles.segments.lon1;
    lat2 = handles.segments.lat2;
    lon2 = handles.segments.lon2;

    % Include in indices only indices of segments whose start and end points are
    % both within the viewing window
    indices = find(max([lat1 lat2],[],2)>=handles.latlim(1) & min([lat1 lat2],[],2)<=handles.latlim(2) & max([lon1 lon2],[],2)>=handles.lonlim(1) & min([lon1 lon2],[],2)<=handles.lonlim(2));
    lat1=lat1(indices);
    lat2=lat2(indices);
    lon1=lon1(indices);
    lon2=lon2(indices);
    for i = 1:length(lat1)
        ap.segments = plotm([lat1(i) lat2(i)],[lon1(i) lon2(i)],'r-','linewidth',4);
        hold on;
    end

    handles.plots.(tag) = ap;

    h = handles;
end

function h = plot_flowline(fname, handles)
    ax = gca;
    tag = ax.Tag;

    % axes plots
    ap = handles.plots.(tag);
    if(isfield(ap,fname))
        delete(ap.(fname));
        ap = rmfield(ap,fname);
    end

    flow = handles.flow(fname);
    ap.(fname) = plotm(flow.lat,flow.lon,'o','color',[0,0.5,1]);
    hold on;

    handles.plots.(tag) = ap;

    h = handles;
end

function h = plot_polygon(handles)
    polygon = handles.polygon;
    if(isfield(handles.plots,'polygon'))
        delete(handles.plots.polygon);
        handles.plots = rmfield(handles.plots,'polygon');
    end

    handles.plots.polygon = plotm(vertcat(polygon,polygon(1,:)),'-','LineWidth',4,'color',[1,1,0.3]);
    hold on;
    h = handles;
end

function h = highlight_picks(picks,handles)
    ax = gca;
    tag = ax.Tag;
    % axes plots
    ap = handles.plots.(tag);

    if(isfield(ap,'picks_highlight'))
        delete(ap.picks_highlight);
        ap = rmfield(ap,'picks_highlight');
    end

    ap.picks_highlight = plotm(handles.plat(picks),handles.plon(picks),'ro','MarkerSize',10,'MarkerFaceColor','red');
    hold on;
    handles.plots.(tag) = ap;
    h = handles;
end

function h = enable_panel(panel,handles)
    set(findall(panel, '-property', 'enable'), 'enable', 'on');
    h = handles;
end

function h = disable_panel(panel,handles)
    set(findall(panel, '-property', 'enable'), 'enable', 'off');
    h = handles;
end

function h = select_segment(seg_id,handles)
    nminlat = min(handles.segments.lat1(seg_id),handles.segments.lat2(seg_id)) - 6;
    nmaxlat = max(handles.segments.lat2(seg_id),handles.segments.lat2(seg_id)) + 6;
    nminlon = min(handles.segments.lon1(seg_id),handles.segments.lon2(seg_id)) - 6;
    nmaxlon = max(handles.segments.lon2(seg_id),handles.segments.lon2(seg_id)) + 6;
    handles.latlim = [nminlat nmaxlat];
    handles.lonlim = [nminlon nmaxlon];
    handles.selected_segment = seg_id;

    set(handles.edit_minlat,'String',nminlat);
    set(handles.edit_maxlat,'String',nmaxlat);
    set(handles.edit_minlon,'String',nminlon);
    set(handles.edit_maxlon,'String',nmaxlon);


    handles = draw_map(handles.latlim,handles.lonlim,handles);

    fname = flowline_for(seg_id,handles);
    if(fname)
        handles = plot_flowline(fname,handles);
    end

    handles = plot_picks(handles);
    handles = plot_segments(handles);
    handles = highlight_segment(seg_id,handles);

    % Set radiobutton selector to nothing
    handles.uibuttongroup_select_picks.SelectedObject = [];

    if(handles.segments.has_flowline(seg_id))
        handles.radiobutton_flowline_polygon.Enable = 'on';
    else
        handles.radiobutton_flowline_polygon.Enable = 'off';
    end

    handles.edit_seg_id.String = seg_id;
    h = handles;
end

% --- Outputs from this function are returned to the command line.
function varargout = zebra_OutputFcn(hObject, eventdata, handles)
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Get default command line output from handles structure
    varargout{1} = handles.output;
end



function edit_seg_id_Callback(hObject, eventdata, handles)
  % hObject    handle to edit_seg_id (see GCBO)
  % eventdata  reserved - to be defined in a future version of MATLAB
  % handles    structure with handles and user data (see GUIDATA)

  % Hints: get(hObject,'String') returns contents of edit_seg_id as text
  %        str2double(get(hObject,'String')) returns contents of edit_seg_id as a double
end


% --- Executes during object creation, after setting all properties.
function edit_seg_id_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to edit_seg_id (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

% --- Executes on button press in pushbutton_segment_select.
% OK
function pushbutton_segment_select_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton_segment_select (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    seg_id = str2double(get(handles.edit_seg_id,'String'));

    handles = select_segment(seg_id,handles);
    handles = disable_panel(handles.panel_fine_tune,handles);
    handles = disable_panel(handles.panel_output,handles);
    guidata(hObject,handles);
end

% --- Executes on key press with focus on figure1 and none of its controls.
% TODO: move all this functionality into separate buttons
function figure1_KeyPressFcn(hObject, eventdata, handles)
    % hObject    handle to figure1 (see GCBO)
    % eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
    %	Key: name of the key that was pressed, in lower case
    %	Character: character interpretation of the key(s) that was pressed
    %	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
    % handles    structure with handles and user data (see GUIDATA)
    switch(eventdata.Key)
        case 'c' % is the pick NE or SW?
            [lat, lon] = inputm(1);
            pid = closest_pick(lat,lon,handles);
            pid
            pick_orientation(pid,handles.selected_segment,handles)
        case 'r' % reset
            disp 'Resetting... Please wait'
            % Draw map and ETOPO
            handles.latlim = handles.LATLIM;
            handles.lonlim = handles.LONLIM;
            axes(handles.axes_main);
            handles = draw_map(handles.latlim,handles.lonlim,handles);
            % Plot picks
            handles = plot_picks(handles);
            % Plot segments
            handles = plot_segments(handles);

            % Plot flowline
            handles = plot_flowline('flowline_FZ_SEIR_20_704',handles);
        case 'a' % get angle of flowline
            [lat, lon] = inputm(1);
            fname = closest_flowline(lat,lon,handles);
            fname
            angle = flowline_angle(fname,handles)
        case 'y' % go auto box
            for seg_id = 128:700

                nminlat = min(handles.segments.lat1(seg_id),handles.segments.lat2(seg_id)) - 6;
                nmaxlat = max(handles.segments.lat2(seg_id),handles.segments.lat2(seg_id)) + 6;
                nminlon = min(handles.segments.lon1(seg_id),handles.segments.lon2(seg_id)) - 6;
                nmaxlon = max(handles.segments.lon2(seg_id),handles.segments.lon2(seg_id)) + 6;
                handles.latlim = [nminlat nmaxlat];
                handles.lonlim = [nminlon nmaxlon];

                handles = draw_map(handles.axes_main,handles.latlim,handles.lonlim,handles);

                fname = closest_flowline(handles.segments.lat1(seg_id),handles.segments.lon1(seg_id),handles);
                handles = plot_flowline(fname,handles);

                handles = plot_picks(handles);
                handles = plot_segments(handles);
                handles = highlight_segment(seg_id,handles);

                lat1 = handles.segments.lat1(seg_id);
                lon1 = handles.segments.lon1(seg_id);
                lat2 = handles.segments.lat2(seg_id);
                lon2 = handles.segments.lon2(seg_id);
                seg_id
                fname = flowline_for(seg_id,handles);
                flow = handles.flow(fname);
                flow.center
                displacement_1 = flow.center - [lat1 lon1]
                plotm([flow.lat flow.lon] - displacement_1,'r--','LineWidth',2);
                hold on;
                displacement_2 = flow.center - [lat2 lon2]
                plotm([flow.lat flow.lon] - displacement_2,'r--','LineWidth', 2);
                pause(1);
            end

    end

    guidata(hObject,handles); % save changes
end

% Desired output:
% For each segment
% Which ridge (boundary)
% segment id
% which side of the ridge SW or NE
% lat/lon of picks
% chrons of picks

% Start at SE Indian ridge (segment 694)
% and proceed south


% --- Executes on button press in pushbutton_segment_select_on_map.
% 'Select segment on map'
function pushbutton_segment_select_on_map_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton_segment_select_on_map (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    [lat lon] = inputm(1);
    seg_id = closest_segment(lat,lon,handles);
    handles.edit_seg_id.String = seg_id;
    guidata(hObject,handles);
end


% --- Executes on button press in pushbutton_output_segment.
% 'Output segment'
function pushbutton_output_segment_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton_output_segment (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    seg_id = handles.selected_segment;
    boundary = handles.segments.boundary(seg_id,:);
    filename = sprintf('output/%d%s.segment',seg_id,boundary);
    fprintf('Writing data on segment %d to %s\n',seg_id,filename);
    output = segment_output(handles.selected_segment,handles);
    fhandle = fopen(filename,'w');
    fprintf(fhandle,output{1});
    fclose(fhandle);
end


function edit_minlat_Callback(hObject, eventdata, handles)
    % hObject    handle to edit_minlat (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: get(hObject,'String') returns contents of edit_minlat as text
    %        str2double(get(hObject,'String')) returns contents of edit_minlat as a double
end

% --- Executes during object creation, after setting all properties.
function edit_minlat_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to edit_minlat (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end


function edit_maxlat_Callback(hObject, eventdata, handles)
    % hObject    handle to edit_maxlat (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % Hints: get(hObject,'String') returns contents of edit_maxlat as text
    %        str2double(get(hObject,'String')) returns contents of edit_maxlat as a double
end

% --- Executes during object creation, after setting all properties.
function edit_maxlat_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to edit_maxlat (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end


function edit_minlon_Callback(hObject, eventdata, handles)
    % hObject    handle to edit_minlon (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: get(hObject,'String') returns contents of edit_minlon as text
    %        str2double(get(hObject,'String')) returns contents of edit_minlon as a double
end

% --- Executes during object creation, after setting all properties.
function edit_minlon_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to edit_minlon (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

function edit_maxlon_Callback(hObject, eventdata, handles)
    % hObject    handle to edit_maxlon (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: get(hObject,'String') returns contents of edit_maxlon as text
    %        str2double(get(hObject,'String')) returns contents of edit_maxlon as a double
end

% --- Executes during object creation, after setting all properties.
function edit_maxlon_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to edit_maxlon (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called


    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end


% --- Executes on button press in scope_ok.
function scope_ok_Callback(hObject, eventdata, handles)
    % hObject    handle to scope_ok (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    minlat = str2double(get(handles.edit_minlat,'String'));
    maxlat = str2double(get(handles.edit_maxlat,'String'));
    minlon = str2double(get(handles.edit_minlon,'String'));
    maxlon = str2double(get(handles.edit_maxlon,'String'));
    handles.latmin = [minlat maxlat];
    handles.lonlim = [minlon maxlon];
    handles = draw_map(handles.latlim,handles.lonlim,handles);
    handles = plot_picks(handles);
    handles = plot_segments(handles);
    handles = disable_panel(handles.uibuttongroup_select_picks,handles);
    handles = disable_panel(handles.panel_output,handles);

    guidata(hObject,handles);
end


% --- Executes on button press in pushbutton_select_picks_confirm.
function pushbutton_select_picks_confirm_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton_select_picks_confirm (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    seg_id = handles.selected_segment;
    picks = picks_in_polygon(handles);
    handles.segments.picks{seg_id} = picks;
    handles = highlight_picks(handles.segments.picks{seg_id},handles);
    handles = enable_panel(handles.panel_output,handles);
    guidata(hObject,handles);
end


% --- Executes when selected object is changed in uibuttongroup_select_picks.
function uibuttongroup_select_picks_SelectionChangedFcn(hObject, eventdata, handles)
    % hObject    handle to the selected object in uibuttongroup_select_picks
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    seg_id = handles.selected_segment;
    switch eventdata.NewValue.Tag
        case 'radiobutton_autogenerate_polygon'
            handles.polygon = normal_polygon(seg_id,handles);
        case 'radiobutton_flowline_polygon'
            handles.polygon = flowline_polygon(seg_id,handles);
        otherwise
            throw 'Unrecognized radio button';
    end
    handles = plot_polygon(handles);
    guidata(hObject,handles);
end


% --- Executes on button press in pushbutton_fine_tune.
function pushbutton_fine_tune_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton_fine_tune (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    axes(handles.axes_main);
    [lat1 lon1] = inputm(1);
    [lat2 lon2] = inputm(1);
    minlat = min(lat1,lat2);
    maxlat = max(lat1,lat2);
    minlon = min(lon1,lon2);
    maxlon = max(lon1,lon2);
    latlim = [minlat maxlat];
    lonlim = [minlon maxlon];
    handles = zoom_region(latlim,lonlim,handles);

    handles = disable_panel(handles.panel_scope,handles);
    handles = disable_panel(handles.panel_select_segment,handles);
    handles = disable_panel(handles.uibuttongroup_select_picks,handles);
    handles = disable_panel(handles.panel_output,handles);
    handles = enable_panel(handles.panel_fine_tune,handles);

    seg_id = handles.selected_segment;
    handles.fine_tune_picks = handles.segments.picks{seg_id};

    guidata(hObject,handles);
end


% --- Executes on button press in pushbutton_add_picks.
function pushbutton_add_picks_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton_add_picks (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    [lat1 lon1] = inputm(1);
    [lat2 lon2] = inputm(1);
    new_picks = select_picks(lat1,lon1,lat2,lon2,handles);
    handles.fine_tune_picks = union(handles.fine_tune_picks,new_picks);
    handles = highlight_picks(handles.fine_tune_picks,handles);
    guidata(hObject,handles);
end

% --- Executes on button press in pushbutton_remove_picks.
function pushbutton_remove_picks_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton_remove_picks (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    [lat1 lon1] = inputm(1);
    [lat2 lon2] = inputm(1);
    picks_to_remove = select_picks(lat1,lon1,lat2,lon2,handles);
    handles.fine_tune_picks = setdiff(handles.fine_tune_picks,picks_to_remove);
    handles = highlight_picks(handles.fine_tune_picks,handles);
    guidata(hObject,handles);
end

% --- Executes on button press in pushbutton_fine_tune_confirm.
function pushbutton_fine_tune_confirm_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton_fine_tune_confirm (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    seg_id = handles.selected_segment;
    handles.segments.picks{seg_id} = handles.fine_tune_picks;
    handles.fine_tune_picks = [];
    cla(handles.axes_right);
    axes(handles.axes_main);
    handles = enable_panel(handles.panel_scope,handles);
    handles = enable_panel(handles.panel_select_segment,handles);
    handles = enable_panel(handles.uibuttongroup_select_picks,handles);
    handles = enable_panel(handles.panel_output,handles);
    handles = disable_panel(handles.panel_fine_tune,handles);
    handles = highlight_picks(handles.segments.picks{seg_id},handles);
    guidata(hObject,handles);
end


% --- Executes on button press in pushbutton_fine_tune_cancel.
function pushbutton_fine_tune_cancel_Callback(hObject, eventdata, handles)
  % hObject    handle to pushbutton_fine_tune_cancel (see GCBO)
  % eventdata  reserved - to be defined in a future version of MATLAB
  % handles    structure with handles and user data (see GUIDATA)cla(handles.axes_right);
  handles.fine_tune_picks = [];
  axes(handles.axes_main);
  handles = enable_panel(handles.panel_scope,handles);
  handles = enable_panel(handles.panel_select_segment,handles);
  handles = enable_panel(handles.uibuttongroup_select_picks,handles);
  handles = enable_panel(handles.panel_output,handles);
  handles = disable_panel(handles.panel_fine_tune,handles);
  guidata(hObject,handles);
end


% --- Executes on button press in pushbutton_rezoom.
function pushbutton_rezoom_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton_rezoom (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)[lat1 lon1] = inputm(1);
    axes(handles.axes_main);
    [lat1 lon1] = inputm(1);
    [lat2 lon2] = inputm(1);
    minlat = min(lat1,lat2);
    maxlat = max(lat1,lat2);
    minlon = min(lon1,lon2);
    maxlon = max(lon1,lon2);
    latlim = [minlat maxlat];
    lonlim = [minlon maxlon];
    handles = zoom_region(latlim,lonlim,handles);
    guidata(hObject,handles);
end
