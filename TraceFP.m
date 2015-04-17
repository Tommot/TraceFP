function varargout = TraceFP(varargin)
% TRACEFP MATLAB code for TraceFP.fig
%
%	This program allows a user to load, modify, and save .fp floorplan
%	files.
%
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
%      Written by:   Eric Turner <elturner@eecs.berkeley.edu>
%      Created on February 9, 2015
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help TraceFP

% Last Modified by GUIDE v2.5 09-Apr-2015 17:25:10

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TraceFP_OpeningFcn, ...
                   'gui_OutputFcn',  @TraceFP_OutputFcn, ...
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


% --- Executes just before TraceFP is made visible.
function TraceFP_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TraceFP (see VARARGIN)

	clc;
	fprintf('[TraceFP]\tHello!\n');

	% initialize handles structure
	handles.wall_samples = []; % no wall samples yet
	handles.control_points = zeros(0,2); 
			% no control points (each row (x,y))
	handles.triangles = zeros(0,3); 
			% no polygons yet, each indexes 3 ctrl pts
	handles.room_ids     = []; % one per triangle
	handles.current_room = 1;


	% initialize plot handles
	handles.wall_samples_plot = 0; % not valid handle
	handles.control_points_plot = 0;
	handles.triangles_plot = 0;
	
	% initialize GUI
	set(handles.show_wall_samples, 'Value', 1);
	set(handles.show_control_points, 'Value', 1);
	set(handles.show_floorplan, 'Value', 1);

	% Choose default command line output for TraceFP
	handles.output = hObject;
    
    % set constraints for functions
    % set tolerance for aligning lines function
    handles.align_line_tolerance = 10;

	% Update handles structure
	guidata(hObject, handles);
    global undo_history redo_history
    undo_history = TraceFP_history(handles);
    redo_history = TraceFP_history();

	% UIWAIT makes TraceFP wait for user response (see UIRESUME)
	%uiwait(handles.figure1);
    
    [a,map]=imread('img/dot.jpg');
    [r,c,d]=size(a); 
    x=ceil(r/30); 
    y=ceil(c/30); 
    g=a(1:x:end,1:y:end,:);
    g(g==255)=5.5*255;
    set(handles.new_point,'CData',g);
    
    [a,map]=imread('img/move_point.jpg');
    [r,c,d]=size(a); 
    x=ceil(r/30); 
    y=ceil(c/30); 
    g=a(1:x:end,1:y:end,:);
    g(g==255)=5.5*255;
    set(handles.merge_and_move_point,'CData',g);
    
    [a,map]=imread('img/remove_point.jpg');
    [r,c,d]=size(a); 
    x=ceil(r/30); 
    y=ceil(c/30); 
    g=a(1:x:end,1:y:end,:);
    g(g==255)=5.5*255;
    set(handles.remove_point,'CData',g);
    
    [a,map]=imread('img/new_triangle.jpg');
    [r,c,d]=size(a); 
    x=ceil(r/30); 
    y=ceil(c/30); 
    g=a(1:x:end,1:y:end,:);
    g(g==255)=5.5*255;
    set(handles.new_triangle,'CData',g);
    
    [a,map]=imread('img/remove_triangle.jpg');
    [r,c,d]=size(a); 
    x=ceil(r/30); 
    y=ceil(c/30); 
    g=a(1:x:end,1:y:end,:);
    g(g==255)=5.5*255;
    set(handles.remove_triangle,'CData',g);
    
    [a,map]=imread('img/new_rectangle.jpg');
    [r,c,d]=size(a); 
    x=ceil(r/30); 
    y=ceil(c/30); 
    g=a(1:x:end,1:y:end,:);
    g(g==255)=5.5*255;
    set(handles.new_rectangle,'CData',g);
    
    [a,map]=imread('img/cross.png');
    [r,c,d]=size(a); 
    x=ceil(r/30); 
    y=ceil(c/30); 
    g=a(1:x:end,1:y:end,:);
    g(g==255)=5.5*255;
    set(handles.clear,'CData',g);
    
    DEBUGGING = false;
    if (DEBUGGING)
        fp = read_fp(fullfile('/Users/tomlai/Documents/Projects/TraceFP/sample/mulford2/mulfordf2_gen1_s0.01.fp'));
        handles.control_points = fp.verts;
        handles.triangles      = fp.tris;
        handles.room_ids       = fp.room_inds;
        handles.current_room   = 1;        
        handles.wall_samples = readMapData(fullfile('/Users/tomlai/Documents/Projects/TraceFP/sample/mulford2/mulfordf2_gen1_s0.01.dq'));
        TraceFP_render(hObject, handles, true);
        handles=guidata(hObject);
        global undo_history redo_history
        undo_history.push_back(handles);
        redo_history.clear();
    end

% --- Outputs from this function are returned to the command line.
function varargout = TraceFP_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

	% Get default command line output from handles structure
	%varargout{1} = handles.output;


% --- Executes on button press in show_wall_samples.
function show_wall_samples_Callback(hObject, eventdata, handles)
% hObject    handle to figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

	% Hint: get(hObject,'Value') returns toggle state 
	% of show_wall_samples
	if(handles.wall_samples_plot == 0)
		fprintf('[TraceFP]\tNo wall samples defined.\n');
	elseif(get(handles.show_wall_samples, 'Value'))
		fprintf('[TraceFP]\tShow wall samples\n');
		set(handles.wall_samples_plot, 'Visible', 'on');
	else
		fprintf('[TraceFP]\tHide wall samples\n');
		set(handles.wall_samples_plot, 'Visible', 'off');
	end

% --- Executes on button press in show_control_points.
function show_control_points_Callback(hObject, eventdata, handles)
% hObject    handle to figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

	% Hint: get(hObject,'Value') returns toggle state 
	% of show_control_points
	if(handles.control_points_plot == 0)
		fprintf('[TraceFP]\tNo control points defined.\n');
	elseif(get(handles.show_control_points, 'Value'))
		fprintf('[TraceFP]\tShow control points\n');
		set(handles.control_points_plot, 'Visible', 'on');
	else
		fprintf('[TraceFP]\tHide control points\n');
		set(handles.control_points_plot, 'Visible', 'off');
	end


% --- Executes on button press in show_floorplan.
function show_floorplan_Callback(hObject, eventdata, handles)
% hObject    handle to figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

	% Hint: get(hObject,'Value') returns toggle state of show_floorplan
	if(handles.triangles_plot == 0)
		fprintf('[TraceFP]\tNo triangles defined.\n');
	elseif(get(handles.show_floorplan, 'Value'))
		fprintf('[TraceFP]\tShow triangles\n');
		set(handles.triangles_plot, 'Visible', 'on');
	else
		fprintf('[TraceFP]\tHide triangles\n');
		set(handles.triangles_plot, 'Visible', 'off');
	end


% --- Executes on button press in new_triangle.
function new_triangle_Callback(hObject, eventdata, handles)
% hObject    handle to figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    while (size(handles.triangles, 1) > numel(handles.room_ids))
        handles.triangles(size(handles.triangles, 1),:) = [];
    end
    while (size(handles.triangles, 1) < numel(handles.room_ids))
        handles.room_ids(numel(handles.room_ids))=[];
    end

	fprintf('[TraceFP]\tNew triangle:  select three points...\n');
    while (true)
        % get the point indices
        pinds = TraceFP_select(handles);
        if (numel(pinds) ~= 3)
            fprintf(['[TraceFP]\t\tFound repeated/invalid points, ', ...
                    'exiting triangle selection.\n']);
            return;
        end

        % check if triangle oriented correctly
        orient = det([ 	(handles.control_points(pinds(1),:) ...
                    - handles.control_points(pinds(3),:)) ;
                (handles.control_points(pinds(2),:) ...
                    - handles.control_points(pinds(3),:)) ]);
        if(orient < 0)
            fprintf('[TraceFP]\t\treordering to be counterclockwise\n');
            pinds = fliplr(pinds);
        end

        % add this triangle
        handles.triangles = [handles.triangles; pinds];
        fprintf('[TraceFP]\t\tadded new triangle\n');

        % update rendering
        handles.room_ids
        handles.current_room
        handles.room_ids = [handles.room_ids; handles.current_room];

        % render and save data
        TraceFP_render(hObject, handles, false);
        handles=guidata(hObject);
        global undo_history redo_history
        undo_history.push_back(handles);
        redo_history.clear();
    end



% --- Executes on button press in remove_triangle.
function remove_triangle_Callback(hObject, eventdata, handles)
% hObject    handle to figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
	fprintf('[TraceFP]\tremove triangle...\n');
    triangles_removed=false;
    while (true)
        ind = TraceFP_findtri(handles);
        if(ind <= 0)
            fprintf('[TraceFP]\texit remove triangle\n');
            if (triangles_removed)
                guidata(hObject, handles);
            end
            return; % no triangle specified
        end

        % get the triangle and delete it
        handles.triangles(ind,:) = [];
        handles.room_ids(ind) = [];
        triangles_removed=true;

        % render and save data
        TraceFP_render(hObject, handles, false);
        handles=guidata(hObject);
        global undo_history redo_history
        undo_history.push_back(handles);
        redo_history.clear();
    end


% --- Executes on button press in set_room.
function set_room_Callback(hObject, eventdata, handles)
% hObject    handle to figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

	fprintf('[TraceFP]\tset current room...\n');

    if (numel(handles.triangles) == 0)
        fprintf('[TraceFP]\tNo room in floorplan right now. Reset current room id to 1\n');
        handles.current_room = 1;
        return;
    end
    
	% select a triangle
	ind = TraceFP_findtri(handles);
	if(ind <= 0)
		% no triangle selected.  Do they want a new room?
		answer = questdlg(['No reference triangle selected.  ', ...
			'Do you want to define a new room?'], 'New Room?');
		if(~strcmp(answer, 'Yes'))
			fprintf('[TraceFP]\t\tCancelling...\n');
			return;
		end

		% make a new room
		handles.current_room = 1 + max(handles.room_ids);
		fprintf('[TraceFp]\t\tNew room: %d\n', ...
				handles.current_room);
	else
		% make current room index to be the room of 
		% the selected triangle
		handles.current_room = handles.room_ids(ind);
		fprintf('[TraceFP]\t\tCurrent room: %d\n', ...
				handles.current_room);
	end

	% update gui data
	guidata(hObject, handles);
    handles=guidata(hObject);



% --- Executes on button press in new_point.
function new_point_Callback(hObject, eventdata, handles)
% hObject    handle to figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	% get new point
    fprintf('[TraceFP]\tnew point...\n');
    while (true)
        [X,Y,BUTTON] = myginput(1, 'crosshair');
        if (BUTTON == 1)
            fprintf('[TraceFP]\t\tinsert new point\n');
            % add to figure
            handles.control_points = [handles.control_points; X Y];
            % render data
            TraceFP_render(hObject, handles, false);
            handles=guidata(hObject);
            global undo_history redo_history
            undo_history.push_back(handles);
            redo_history.clear();
        else
            fprintf('[TraceFP]\texit create new point\n');
            return;
        end
    end


% --- Executes on button press in merge_and_move_point.
function merge_and_move_point_Callback(hObject, eventdata, handles)
% hObject    handle to figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

	% tell user what's going on
	fprintf('[TraceFP]\tmove point...\n');
	% use selection tool to find a point
    while (true)
        fprintf('[TraceFP]\t\tSelect new point\n');
        pinds = TraceFP_select(handles);
        if (pinds == 0)
            fprintf('[TraceFP]\t\tExit move point\n');
            return;
        end

        % now ask the user to click a new spot
        fprintf('[TraceFP]\t\tSelect new location\n');
        [X,Y, BUTTON] = myginput(1, 'crosshair');
        if(BUTTON ~= 1)
            fprintf('[TraceFP]\tExit move point\n');
            return;
        end
        
        handles.control_points = [handles.control_points; X Y];
        pind = size(handles.control_points, 1);
        handles = TraceFP_merge_points(handles, pind, pinds);

        % set point to that location
        TraceFP_render(hObject, handles, false);
        handles=guidata(hObject);
        global undo_history redo_history
        undo_history.push_back(handles);
        redo_history.clear();
        fprintf('[TraceFP]\t\tpoint moved\n');
    end



% --- Executes on button press in remove_point.
function remove_point_Callback(hObject, eventdata, handles)
% hObject    handle to figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

	% tell user what we're doing
	fprintf('[TraceFP]\tremove point...\n');
    while (true)
        % use selection tool to find a point
        pinds = TraceFP_select(handles);
        if(pinds == 0)
            fprintf('[TraceFP]\t\texit remove points\n');
            return;
        end
        
        pinds = sort(pinds, 2, 'descend');

        for idx=1:numel(pinds)
            % remove triangles that contain this point
            pind = pinds(idx);
            to_remove = any( handles.triangles == pind, 2);
            handles.triangles( to_remove , :) = [];
            handles.room_ids( to_remove ) = [];

            % update the indexing in remaining triangles
            idx = [[1:pind] [pind:size(handles.control_points,1)]];
            handles.triangles = idx( handles.triangles );

            % remove this point from our list of points
            handles.control_points(pind, :) = [];
        end

        fprintf('[TraceFP]\t\tpoint removed\n');
        TraceFP_render(hObject, handles, false);
        handles=guidata(hObject);
        global undo_history redo_history
        undo_history.push_back(handles);
        redo_history.clear();
    end
	


% --------------------------------------------------------------------
function open_wall_samples_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

	fprintf('[TraceFP]\tOpen Wall Samples...\n');

	% get the file path
	[dqfile, pathname, success] = uigetfile('*.dq','Open Wall Samples');
	if(~success)
		fprintf('[TraceFP]\t\tNevermind.\n');
		return;
	end

	% load it
	fprintf('[TraceFP]\t\tloading (this may take a while)...\n');
	handles.wall_samples = readMapData(fullfile([pathname, dqfile]));

	TraceFP_render(hObject, handles, false);
    handles=guidata(hObject);
    global undo_history redo_history
    undo_history.push_back(handles);
    redo_history.clear();
	fprintf('[TraceFP]\t\tDONE\n');


% --------------------------------------------------------------------
function save_fp_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

	fprintf('[TraceFP]\tSave Floorplan file...\n');

	% ask user for a file
	[fpfile, pathname, success] = uiputfile(...
		{'*.fp', 'Floorplan files (*.fp)'}, 'Save floorplan as');
	if(~success)
		fprintf('[TraceFP]\t\tnevermind.\n');
		return;
	end

	% populate floorplan structure
	num_rooms = length(unique(handles.room_ids));
	floorplan = struct('res', 0, ...
			'num_verts', size(handles.control_points,1),...
			'verts', handles.control_points, ...
			'num_tris', size(handles.triangles,1), ...
			'tris', handles.triangles, ...
			'num_rooms', num_rooms, ...
			'room_inds', handles.room_ids, ...
			'room_floors', zeros(num_rooms, 1), ...
			'room_ceilings', 3*ones(num_rooms, 1));

	% write out file
	fprintf('[TraceFP]\t\twriting file (this may take a while) ...\n');
	write_fp(fullfile([pathname, fpfile]), floorplan);
	fprintf('[TraceFP]\t\tDONE\n');




% --- Executes on button press in update_triangle_room.
function update_triangle_room_Callback(hObject, eventdata, handles)
% hObject    handle to figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
%     % best rendering efficient code (for swift debugging)
%     fprintf('[TraceFP]\tUpdate triangle room...\n');
%     change = false;
% 	while (true)
%         % find a triangle
%         ind = TraceFP_findtri(handles);
%         if(ind <= 0)
%             fprintf('[TraceFP]\t\tNo triangle selected.  Exiting.\n');
%             if (change)
%                 TraceFP_render(hObject, handles, false);
%                 handles=guidata(hObject);
%                 global undo_history redo_history
%                 undo_history.push_back(handles);
%                 redo_history.clear();
%                 fprintf('[TraceFP]\t\tUpdated to %d.\n', handles.current_room);
%             end
%             return;
%         end
% 
%         % change its room to current
%         change = true;
%         handles.room_ids(ind) = handles.current_room;
%     end

    % best responsiveness code
	fprintf('[TraceFP]\tUpdate triangle room...\n');
	while (true)
        % find a triangle
        ind = TraceFP_findtri(handles);
        if(ind <= 0)
            fprintf('[TraceFP]\t\tNo triangle selected.  Exiting.\n');
            return;
        end

        % change its room to current
        handles.room_ids(ind) = handles.current_room;

        TraceFP_render(hObject, handles, false);
        handles=guidata(hObject);
        global undo_history redo_history
        undo_history.push_back(handles);
        redo_history.clear();
        fprintf('[TraceFP]\t\tUpdated to %d.\n', handles.current_room);
    end

% --------------------------------------------------------------------
function open_fp_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

	fprintf('[TraceFP]\tOpen floorplan (*.fp) file...\n');
	
	% open the file
	[fpfile,pathname,success] = uigetfile('*.fp', ...
			'Open Existing Floorplan');
	if(~success)
		fprintf('[TraceFP]\t\tNevermind.\n');
		return;
	end
	confirm = questdlg(...
		['Loading a floorplan will erase any existing data. ',...
		'Do you wish to proceed?'], 'Confirm');
	if(~strcmp(confirm, 'Yes'))
		fprintf('[TraceFP]\t\tCancelling import\n');
		return;
	end

	% load it
	fprintf('[TraceFP]\t\tloading (this may take a while)...\n');
	fp = read_fp(fullfile([pathname, fpfile]));
	handles.control_points = fp.verts;
	handles.triangles      = fp.tris;
	handles.room_ids       = fp.room_inds;
	handles.current_room   = 1;

	TraceFP_render(hObject, handles, true);
    handles=guidata(hObject);
    global undo_history redo_history
    undo_history.push_back(handles);
    redo_history.clear();
	fprintf('[TraceFP]\t\tDONE\n');


% --- Executes on button press in button New Polygon.
function new_polygon_clicked_Callback(hObject, eventdata, handles)
% hObject    handle to figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    fprintf('[TraceFP]\tNew polygon:  select four points...\n');
    while (true)
        % get the point indices
        pinds = TraceFP_select(handles);
        if (numel(pinds)<3)
            fprintf(['[TraceFP]\t\tInsufficient points selected.', ...
                ' Exiting construct new polygon function.\n']);
            return
        end
        
        coordinates = [];
        xV = [];
        yV = [];
        for idx=1:numel(pinds)
            xV = [xV; handles.control_points(pinds(idx), 1)];
            yV = [yV; handles.control_points(pinds(idx), 2)];
        end
        
        new_triangles = pinds(delaunay(xV, yV));
        % check if second triangle oriented correctly
        for idx=1:size(new_triangles,1)
            triangle_pinds = new_triangles(idx,:);
            orient = det([(handles.control_points(triangle_pinds(1),:) ...
                        - handles.control_points(triangle_pinds(3),:)) ;
                    (handles.control_points(triangle_pinds(2),:) ...
                        - handles.control_points(triangle_pinds(3),:)) ]);
            if(orient < 0)
                new_triangles(idx, :) = fliplr(triangle_pinds);
            end
        end
        % add triangles
        handles.triangles = [handles.triangles; new_triangles]; 
        handles.room_ids = [handles.room_ids; ...
            repmat(handles.current_room, [size(new_triangles, 1), 1])];

        % render and save data
        TraceFP_render(hObject, handles, false);
        handles=guidata(hObject);
        global undo_history redo_history
        undo_history.push_back(handles);
        redo_history.clear();
    end


% --- Executes on button press in clear.
function clear_Callback(hObject, eventdata, handles)
% hObject    handle to figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    answer = questdlg(['All current points, triangles, labels will be removed. ', ...
			'Unsaved data will be lost. ', ...
            'Do you still want to proceed?'], 'Clear');
    if(~strcmp(answer, 'Yes'))
        fprintf('[TraceFP]\t\tCancelling clear...\n');
        return;
    end
    % initialize handles structure
	handles.wall_samples = []; % no wall samples yet
	handles.control_points = zeros(0,2); 
			% no control points (each row (x,y))
	handles.triangles = zeros(0,3); 
			% no polygons yet, each indexes 3 ctrl pts
	handles.room_ids     = []; % one per triangle
	handles.current_room = 1;
    TraceFP_render(hObject, handles, false);
    handles=guidata(hObject);
    global undo_history redo_history
    delete(undo_history);
    delete(redo_history);
    redo_history = TraceFP_history();
    undo_history = TraceFP_history(handles);


% --------------------------------------------------------------------
function undo_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global redo_history undo_history 
    node = undo_history.pop();
    if (node ~= 0)
        redo_history.push_back(node);
    end
    if (undo_history.tail==0)
        return;
    end
    handles.control_points = undo_history.tail.control_points;
    handles.triangles = undo_history.tail.triangles;
    handles.wall_samples = undo_history.tail.wall_samples;
    handles.room_ids = undo_history.tail.room_ids;
    handles.current_room = undo_history.tail.current_room;
    handles.align_line_tolerance = undo_history.tail.align_line_tolerance;
    delete(node);
    TraceFP_render(hObject, handles, false);


% --------------------------------------------------------------------
function redo_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global redo_history undo_history
    node = redo_history.pop();
    if (node==0)
        return;
    end
    undo_history.push_back(node);
    handles.control_points = undo_history.tail.control_points;
    handles.triangles = undo_history.tail.triangles;
    handles.wall_samples = undo_history.tail.wall_samples;
    handles.room_ids = undo_history.tail.room_ids;
    handles.current_room = undo_history.tail.current_room;
    handles.align_line_tolerance = undo_history.tail.align_line_tolerance;
    delete(node);
    TraceFP_render(hObject, handles, false);


% --------------------------------------------------------------------
function fit_to_line_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    while (true)
        points = [];
        fprintf('[TraceFP]\tselect points to fit into one line...\n');
        fprintf('[TraceFP]\t\tSelect new point\n');
        pinds = TraceFP_select(handles);
        if (pinds == 0)
            fprintf('[TraceFP]\t\tExiting line fitting.\n');
            return
        end

        % retrieves coordinates of points
        points_coordinates = zeros(0,2);
        for i=1:numel(points)
            points_coordinates = [points_coordinates; handles.control_points(points(i), :)];
        end
        P = polyfit(points_coordinates(:,1),points_coordinates(:,2),1);
        for i=1:numel(points)
           new_coordinate = projectPointToLine(points_coordinates(i, :), P);
           handles.control_points(points(i), :) = new_coordinate;
        end
        TraceFP_render(hObject, handles, false);
        handles=guidata(hObject);
        global undo_history redo_history
        undo_history.push_back(handles);
        redo_history.clear();
        fprintf('[TraceFP]\t\tpoints fit to line\n');
    end


% --------------------------------------------------------------------
function fit_to_orthogonal_lines_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    while (true)
        fprintf('[TraceFP]\tselect points to fit into one line...\n');
        points = TraceFP_select(handles);
        if (points == 0)
            fprintf('[TraceFP]\t\tExiting orthogonal line fitting.\n');
            return
        end
        fprintf('[TraceFP]\t\tpoints fit to first line determined\n');
        
        % obtain fix point between the two line
        fprintf(['[TraceFP]\tselect fix point of orthogonal line\n']);
        fix_point_pind = TraceFP_select(handles);
        if (fix_point_pind == 0)
            fprintf('[TraceFP]\t\tExiting orthogonal line fitting.\n');
            return
        elseif (numel(fix_point_pind) > 1)
            fix_point_pind = fix_point_pind(1);
        end
        fprintf(['[TraceFP]\tfix point determined\n']);
        
        % obtain data of the second line, points to be fitted
        points_2 = [];
        fprintf(['[TraceFP]\tselect points to fit into the ',...
            'orthogonal line...\n']);
        points_2 = TraceFP_select(handles);
        if (points_2 == 0)
            fprintf('[TraceFP]\t\tExiting orthogonal line fitting.\n');
            return
        end

        % retrieves coordinates of points
        points_coordinates = zeros(0,2);
        for i=1:numel(points)
            points_coordinates = [points_coordinates; handles.control_points(points(i), :)];
        end
        P = polyfit(points_coordinates(:,1),points_coordinates(:,2),1);
        for i=1:numel(points)
           new_coordinate = projectPointToLine(points_coordinates(i, :), P);
           handles.control_points(points(i), :) = new_coordinate;
        end

        % retrieves coordinates of points
        points_coordinates_2 = zeros(0,2);
        for i=1:numel(points_2)
            points_coordinates_2 = [points_coordinates_2; handles.control_points(points_2(i), :)];
        end
        second_line_arg = handles.control_points(fix_point_pind, :);
        second_line_arg = [second_line_arg; ...
            handles.control_points(fix_point_pind, 1) + 1, ...
            handles.control_points(fix_point_pind, 2) - 1/P(1)];
        P = polyfit(second_line_arg(:,1),second_line_arg(:,2),1);
        for i=1:numel(points_2)
           new_coordinate = projectPointToLine(points_coordinates_2(i, :), P);
           handles.control_points(points_2(i), :) = new_coordinate;
        end
        TraceFP_render(hObject, handles, false);
        handles=guidata(hObject);
        global undo_history redo_history
        undo_history.push_back(handles);
        redo_history.clear();
        fprintf('[TraceFP]\t\tpoints fit to orthogonal lines\n');
    end


% --------------------------------------------------------------------
function fit_to_existing_line_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    while (true)
        % obtain line (represented by 2 points) to fit points into
        fprintf('[TraceFP]\tselect points of designated line...\n');
        line = [];
        for i=1:2
            [X,Y,BUTTON] = myginput(1, 'crosshair');
            if (BUTTON~=1)
                fprintf('[TraceFP]\t\tNo point selected. Exiting line fitting.\n');
                return;
            else
                line = [line; X, Y];
            end
        end
        
        fprintf('[TraceFP]\tselect points to fit to the line...\n');
        % obtain points to fit
        points = TraceFP_select(handles);
        if (points == 0)
            fprintf('[TraceFP]\t\tExiting fit points to exiting line.\n');
            return
        end
        
        % calculate polynomial for the line
        P = polyfit(line(:,1),line(:,2),1);
        
        % obtain coordinates of the points to fit
        points_coordinates = zeros(0,2);
        for i=1:numel(points)
            points_coordinates = [points_coordinates; ...
                handles.control_points(points(i), :)];
        end

        % fit points onto the line
        for i=1:numel(points)
           new_coordinate = projectPointToLine(points_coordinates(i, :), P);
           handles.control_points(points(i), :) = new_coordinate;
        end

        TraceFP_render(hObject, handles, false);
        handles=guidata(hObject);
        global undo_history redo_history
        undo_history.push_back(handles);
        redo_history.clear();
        fprintf('[TraceFP]\t\tpoints fit to existing line\n');
    end


% --------------------------------------------------------------------
function merge_nearby_point_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% WARNING: this function will remove all dangling control points

%   method using cluster
%   use of cluster function refereced from:
%   https://www.youtube.com/watch?v=aYzjenNNOcc
    fprintf('[TraceFP]\tmerging nearby points...\n');
    Y=pdist(handles.control_points);
    Z=linkage(Y);
    thershold=0.1;
    label = cluster(Z,'cutoff', thershold);
    
    % first create centroid point and redirect all edges to the new points
    fprintf('[TraceFP]\t\tstep 1: clustering points...\n');
    for clusterIdx=1:max(label)
        
        % first add a new point
        % then redirect all 
        mappedPointsCoor = handles.control_points(...
                            any(label==clusterIdx,2),:);
        coor = sum(mappedPointsCoor, 1) / size(mappedPointsCoor,1);
        handles.control_points = [handles.control_points; coor];
        idxOfPoint = size(handles.control_points,1);
        idxToRedirect = find(label==clusterIdx);
        ArrayIdxToChange = ismember(handles.triangles, idxToRedirect);
        handles.triangles(ArrayIdxToChange) = idxOfPoint;
    end
    
    % remove invalid points and triangles
    handles = TraceFP_validate_fp(handles);
    TraceFP_render(hObject, handles, false);
    handles=guidata(hObject);
    global undo_history redo_history
    undo_history.push_back(handles);
    redo_history.clear();
    fprintf('[TraceFP]\t\tNearby points clustered together.\n');


% --------------------------------------------------------------------
function merge_points_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% will merge points in second selection (to be removed)
% to points in first selection (point to be kept and merged into)
% if any point in second selection is not connected to points in 
% first selection, unexpected outcome might happen in some  
% circumstances
    while (true)
        fprintf('[TraceFP]\tmerging points...\n');

        % now ask the user to click a new spot
        fprintf('[TraceFP]\t\tSelect points to be removed after merge\n');
        pinds1 = TraceFP_select(handles);
        if(pinds1 == 0)
            fprintf('[TraceFP]\t\tInvalid point selected. Exit merge points\n');
            return;
        end
        
        fprintf('[TraceFP]\t\tSelect point to be merged into...\n');
        pind2 = TraceFP_select(handles);
        if(pind2 == 0)
            fprintf('[TraceFP]\t\tInvalid point selected. Exit merge points\n');
            return;
        elseif (numel(pind2) > 1)
            pind2 = pind2(1);
        end
        
        handles = TraceFP_merge_points(handles, pind2, pinds1);
        TraceFP_render(hObject, handles, false);
        handles=guidata(hObject);
        global undo_history redo_history
        undo_history.push_back(handles);
        redo_history.clear();
    end


% --------------------------------------------------------------------
function add_point_to_room_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    fprintf('[TraceFP]\tinsert new point for current room...\n');
    while (true)
        [X,Y,BUTTON] = myginput(1, 'crosshair');
        if (BUTTON ~= 1)
            fprintf('[TraceFP]\t\texit insert new point for current room\n');
            return;
        end

        % add to figure
        handles.control_points = [handles.control_points; X Y];
        pind_new_point = size(handles.control_points, 1);

        % obtain the polyline representing all lines on the floorplan
        % obtain all the pind of points in the current room
        lineX = [];
        lineY = [];
        line_in_current_room = [];
        for triangleIdx=1:size(handles.triangles, 1)
            triangle = handles.triangles(triangleIdx, :);
            for i=1:3
                lineX = [lineX, handles.control_points(triangle(i), 1)];
                lineY = [lineY, handles.control_points(triangle(i), 2)];
            end
            lineX = [lineX, handles.control_points(triangle(1), 1)];
            lineY = [lineY, handles.control_points(triangle(1), 2)];
            if (triangleIdx~=size(handles.triangles, 1))
                lineX = [lineX,NaN];
                lineY = [lineY,NaN];
            end
            if (handles.room_ids(triangleIdx) == handles.current_room)
                line_in_current_room = [line_in_current_room; ...
                    handles.triangles(triangleIdx, 1:2); ...
                    handles.triangles(triangleIdx, 2:3); ...
                    handles.triangles(triangleIdx, 1), ...
                    handles.triangles(triangleIdx, 3)];
            end
        end

        % for each line, try to add the corresponding triangle
        for lineIdx=1:size(line_in_current_room,1)
            % list out the line of the triangle
            pind_1=line_in_current_room(lineIdx,1);
            pind_2=line_in_current_room(lineIdx,2);
            triangle_line_X = [X, ...
                            handles.control_points(pind_1,1),...
                            handles.control_points(pind_2,1),...
                            X];
            triangle_line_Y = [Y, ...
                            handles.control_points(pind_1,2),...
                            handles.control_points(pind_2,2),...
                            Y];
            [intersectX intersectY] = polyxpoly(lineX,...
                                                lineY,...
                                                triangle_line_X,...
                                                triangle_line_Y, 'unique');
            % there must be only a line of intersection
            % before check need to remove all pind_1 and pind_2
            for intersectIdx = numel(intersectX):-1:1
                if ((intersectX(intersectIdx) == ...
                        handles.control_points(pind_1,1)  && ...
                        intersectY(intersectIdx) == ...
                        handles.control_points(pind_1,2)) || ...
                    (intersectX(intersectIdx) == ...
                        handles.control_points(pind_2,1)  && ...
                        intersectY(intersectIdx) == ...
                        handles.control_points(pind_2,2)))
                    intersectX(intersectIdx) = [];
                    intersectY(intersectIdx) = [];
                end
            end

            if (numel(intersectX) == 0)
                pinds = [pind_new_point, pind_1, pind_2];
                % check if triangle oriented correctly
                orient = det([ 	(handles.control_points(pinds(1),:) ...
                            - handles.control_points(pinds(3),:)) ;
                        (handles.control_points(pinds(2),:) ...
                            - handles.control_points(pinds(3),:)) ]);
                if(orient < 0)
                    fprintf('[TraceFP]\t\treordering to be counterclockwise\n');
                    pinds = fliplr(pinds);
                end

                % add this triangle
                handles.triangles = [handles.triangles; pinds];
                handles.room_ids = [handles.room_ids ; handles.current_room];
                fprintf('[TraceFP]\t\tadded new triangle\n'); 
            end
        end

        handles = TraceFP_validate_fp(handles);
        TraceFP_render(hObject, handles, false);
        handles=guidata(hObject);
        global undo_history redo_history
        undo_history.push_back(handles);
        redo_history.clear(); 
        fprintf('[TraceFP]\tDONE inserting new point for current room\n');
    end


% --------------------------------------------------------------------
function refresh_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles = TraceFP_validate_fp(handles);
    TraceFP_render(hObject, handles, true);
    handles=guidata(hObject);
    global undo_history redo_history
    undo_history.push_back(handles);
    redo_history.clear(); 
    fprintf('[TraceFP]\tfloorplan validated and refreshed\n');
    


% --------------------------------------------------------------------
function align_lines_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    tolerance = handles.align_line_tolerance; % degree
    fprintf('[TraceFP]\talign lines to direction...\n');
    [X1,Y1,BUTTON] = myginput(1, 'crosshair');
    if (BUTTON~=1)
        fprintf('[TraceFP]\t\tNo point selected. Exiting line aligning.\n');
        return;
    end
    [X2,Y2,BUTTON] = myginput(1, 'crosshair');
    if (BUTTON~=1)
        fprintf('[TraceFP]\t\tNo point selected. Exiting line aligning.\n');
        return;
    end
    target_vector = [X2-X1, Y2-Y1];
    aligned_points = [];
    while (numel(aligned_points) < size(handles.control_points,1))
        % get first unaligned point
        pind = 1;
        while (any(aligned_points==pind))
            pind = pind + 1;
        end
        
        % get all points in the same line
        current_cluster_pind = [pind];
        pind2 = 1;
        while pind2 <= size(handles.control_points,1)
            if (any(current_cluster_pind==pind2))
                pind2 = pind2+1;
                continue;
            end
            for idx = 1:numel(current_cluster_pind)
                pind1 = current_cluster_pind(idx);
                point_1_map = any(handles.triangles==pind1,2);
                point_2_map = any(handles.triangles==pind2,2);
                line_exist = any(point_1_map & point_2_map);
                if (line_exist)
                    line = [handles.control_points(pind1,1) ...
                                - handles.control_points(pind2,1), ...
                            handles.control_points(pind1,2) ...
                                - handles.control_points(pind2,2)];
                    if (is_parallel(target_vector, line, tolerance))
                        current_cluster_pind = [current_cluster_pind, pind2];
                        pind2=1;
                        break;
                    end
                end
            end
            pind2 = pind2+1;
        end
        
        % process current cluster
        mid_point = [0,0];
        for idx = 1:numel(current_cluster_pind)
            iter_pind = current_cluster_pind(idx);
            mid_point = [mid_point(1)+handles.control_points(iter_pind,1), ...
                         mid_point(2)+handles.control_points(iter_pind,2)];
        end
        mid_point = mid_point / numel(current_cluster_pind);
        line_on_mid_point = [mid_point; mid_point + target_vector];
        P = polyfit(line_on_mid_point(:,1),line_on_mid_point(:,2),1);
        for idx = 1:numel(current_cluster_pind)
            iter_pind = current_cluster_pind(idx);
            handles.control_points(iter_pind, :) = ...
                projectPointToLine(handles.control_points(iter_pind,:), P);
        end
        
        % mark current cluster's points as done
        aligned_points = [aligned_points, current_cluster_pind];
    end

    handles = TraceFP_validate_fp(handles);
    TraceFP_render(hObject, handles, false);
    handles=guidata(hObject);
    global undo_history redo_history
    undo_history.push_back(handles);
    redo_history.clear(); 
    fprintf('[TraceFP]\tfloorplan aligned to selected direction\n');
    

    


% --------------------------------------------------------------------
function set_constraints_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    name='Set constraints';
    prompt={'Tolerance (angle) for aligning lines:'};
    numlines=1;
    defaultanswer={num2str(handles.align_line_tolerance)};
    options.WindowStyle='modal';
    answer=inputdlg(prompt,name,numlines,defaultanswer,options);
    new_tolerance_align_lines = str2num(answer{1});
    if (~isempty(new_tolerance_align_lines))
        handles.align_line_tolerance = new_tolerance_align_lines;
    end
    
    % save result
    guidata(hObject,handles)
    global undo_history redo_history
    undo_history.push_back(handles);
    redo_history.clear(); 
        


% --------------------------------------------------------------------
function remove_point_from_polygon_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    fprintf('[TraceFP]\tauto-select points to be removed from any room\n');
    final_points = [];
    for room_id = 1:max(handles.room_ids)
        room_idx = handles.room_ids==room_id;
        triangles = handles.triangles(room_idx, :);
        tmp_edges_for_room = [];
        for triangleIdx=1:size(triangles,1)
            triangle = triangles(triangleIdx, :);
            edge1=triangle(1:2);
            edge2=triangle(2:3);
            edge3=[triangle(3),triangle(1)];
            edges = [edge1; edge2; edge3];
            for edgeIdx=1:3
                edge = edges(edgeIdx, :);
                if numel(tmp_edges_for_room)==0
                    tmp_edges_for_room = [tmp_edges_for_room; edge];
                    continue;
                end
                inverted_match = tmp_edges_for_room(:,2)==edge(1) & ...
                                    tmp_edges_for_room(:,1)==edge(2);
                if any(inverted_match)
                    tmp_edges_for_room(inverted_match, :)=[];
                    continue;
                end
                tmp_edges_for_room = [tmp_edges_for_room; edge];
            end
        end
        final_points = unique([final_points; unique(tmp_edges_for_room)]);
    end
    points_to_not_include=unique(final_points);
    pinds_to_be_removed = [];
    for i=1:size(handles.control_points,1)
        if any(points_to_not_include==i)
            continue;
        end
        pinds_to_be_removed = [pinds_to_be_removed,i];
    end
    if (pinds_to_be_removed == 0)
        fprintf('[TraceFP]\tNo points selected. Exiting remove point from room tool\n');
        return ;
    end
    for pinds_to_be_removed_idx = numel(pinds_to_be_removed):-1:1
        pind = pinds_to_be_removed(pinds_to_be_removed_idx);
        triangles_idx_to_remove = any(handles.triangles==pind,2);
        mapped_triangles = handles.triangles(triangles_idx_to_remove,:);
        room_id = handles.room_ids(triangles_idx_to_remove);
        room_id = room_id(1);
        handles.room_ids(triangles_idx_to_remove,:) = [];
        handles.triangles(triangles_idx_to_remove,:) = [];
        % construct all the counterclockwise lines
        lines = [];
        for row_idx = 1:size(mapped_triangles,1)
            row = mapped_triangles(row_idx,:);
            while row(1) ~= pind
                row = circshift(row, 1, 2);
            end
            lines = [lines; row(2:3)];
        end
        % iterate through the point counterclockwise to get the
        % entire polygon
        polygon = [lines(1,:)];
        while polygon(1) ~= polygon(size(polygon,2))
            point_to_include = polygon(1);
            point_to_not_include = polygon(2);
            selected_line = lines(any(lines==point_to_include,2),:);
            selected_line = selected_line(...
                all(selected_line~=point_to_not_include,2),:);
            polygon = [selected_line(1), polygon];
        end
        P_pind = polygon(2:numel(polygon));
        P = handles.control_points(P_pind,:);
        N = numel(P_pind);
        C = [(1:(N-1))' (2:N)'; N 1];
        DT = delaunayTriangulation(P,C);
        new_triangles = P_pind(DT.ConnectivityList(isInterior(DT),:));
        handles.triangles = [handles.triangles; new_triangles];
        handles.room_ids = [handles.room_ids; ...
            repmat(room_id, [size(new_triangles, 1), 1])];
        idx = [[1:pind] [pind:size(handles.control_points,1)]];
        handles.triangles = idx( handles.triangles );
        pinds_to_be_removed = idx(pinds_to_be_removed);
        handles.control_points(pind,:)=[];
    end
    handles = TraceFP_validate_fp(handles);
    TraceFP_render(hObject, handles, false);
    handles=guidata(hObject);
    global undo_history redo_history
    undo_history.push_back(handles);
    redo_history.clear(); 
    fprintf('[TraceFP]\tpoints removed from room\n');
    
