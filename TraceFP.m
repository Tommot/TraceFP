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

% Last Modified by GUIDE v2.5 12-Mar-2015 20:18:38

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
    set(handles.move_point,'CData',g);
    
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
% hObject    handle to show_wall_samples (see GCBO)
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
% hObject    handle to show_control_points (see GCBO)
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
% hObject    handle to show_floorplan (see GCBO)
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
% hObject    handle to new_triangle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

	fprintf('[TraceFP]\tNew triangle:  select three points...\n');
    triangle_created = false;
    while (true)
        % get the point indices
        pinds = zeros(1,3);
        i=1;
        while i<=3
            pinds(i) = TraceFP_select(handles);
            if (length(pinds) == 1 || pinds(1) <= 0)
                fprintf(['[TraceFP]\t\tExit point selection.\n']);
                if (triangle_created==1)
                    guidata(hObject, handles);
                end
                return;
            elseif(length(unique(pinds(1:i))) < i || any(pinds(1:i) <= 0))
                fprintf(['[TraceFP]\t\tFound repeated/invalid points, ', ...
                    'exiting triangle selection.\n']);
                return;
            else
                i=i+1;
            end
        end

        % check for invalid
        if(length(unique(pinds)) < 3 || any(pinds <= 0))
            fprintf(['[TraceFP]\t\tFound repeated/invalid points, ', ...
                    'discarding selection.\n']);
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
        triangle_created = true;
        handles.triangles = [handles.triangles; pinds];
        fprintf('[TraceFP]\t\tadded new triangle\n');

        % update rendering
        handles.room_ids = [handles.room_ids ; handles.current_room];

        % render and save data
        TraceFP_render(hObject, handles, false);
        handles=guidata(hObject);
        global undo_history
        undo_history.push_back(handles);
    end



% --- Executes on button press in remove_triangle.
function remove_triangle_Callback(hObject, eventdata, handles)
% hObject    handle to remove_triangle (see GCBO)
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
        global undo_history
        undo_history.push_back(handles);
    end


% --- Executes on button press in set_room.
function set_room_Callback(hObject, eventdata, handles)
% hObject    handle to set_room (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

	fprintf('[TraceFP]\tset current room...\n');

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



% --- Executes on button press in new_point.
function new_point_Callback(hObject, eventdata, handles)
% hObject    handle to new_point (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	% get new point
    fprintf('[TraceFP]\tnew point...\n');
    points_created=false;
    while (true)
        [X,Y,BUTTON] = myginput(1, 'crosshair');
        if (BUTTON == 1)
            fprintf('[TraceFP]\t\tinsert new point\n');

            % add to figure
            handles.control_points = [handles.control_points; X Y];
            points_created=true;
            % render data
            TraceFP_render(hObject, handles, false);
            handles=guidata(hObject);
            global undo_history
            undo_history.push_back(handles);
        else
            fprintf('[TraceFP]\texit create new point\n');
            return;
        end
    end


% --- Executes on button press in move_point.
function move_point_Callback(hObject, eventdata, handles)
% hObject    handle to move_point (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

	% tell user what's going on
	fprintf('[TraceFP]\tmove point...\n');
    points_moved=false;

	% use selection tool to find a point
    while (true)
        fprintf('[TraceFP]\t\tSelect new point\n');
        pind = TraceFP_select(handles);
        if(pind <= 0)
            fprintf('[TraceFP]\tExit move point\n');
            return;
        end

        % now ask the user to click a new spot
        fprintf('[TraceFP]\t\tSelect new location\n');
        [X,Y, BUTTON] = myginput(1, 'crosshair');
        if(BUTTON ~= 1)
            fprintf('[TraceFP]\tExit move point\n');
            return;
        end

        % set point to that location
        handles.control_points(pind, :) = [X, Y];
        points_moved=true;
        
        TraceFP_render(hObject, handles, false);
        handles=guidata(hObject);
        global undo_history
        undo_history.push_back(handles);
        fprintf('[TraceFP]\t\tpoint moved\n');
    end



% --- Executes on button press in remove_point.
function remove_point_Callback(hObject, eventdata, handles)
% hObject    handle to remove_point (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

	% tell user what we're doing
	fprintf('[TraceFP]\tremove point...\n');
    points_removed=false;
    while (true)
        % use selection tool to find a point
        pind = TraceFP_select(handles);
        if(pind <= 0)
            fprintf('[TraceFP]\t\texit remove points\n');
            return;
        end

        % remove triangles that contain this point
        to_remove = any( handles.triangles == pind, 2);
        handles.triangles( to_remove , :) = [];
        handles.room_ids( to_remove ) = [];

        % update the indexing in remaining triangles
        idx = [[1:pind] [pind:size(handles.control_points,1)]];
        handles.triangles = idx( handles.triangles );

        % remove this point from our list of points
        handles.control_points(pind, :) = [];

        fprintf('[TraceFP]\t\tpoint removed\n');
        points_removed=true;
        TraceFP_render(hObject, handles, false);
        handles=guidata(hObject);
        global undo_history
        undo_history.push_back(handles);
    end
	


% --------------------------------------------------------------------
function open_wall_samples_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to open_wall_samples (see GCBO)
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

	TraceFP_render(hObject, handles, true);
    handles=guidata(hObject);
    global undo_history
    undo_history.push_back(handles);
	fprintf('[TraceFP]\t\tDONE\n.');


% --------------------------------------------------------------------
function save_fp_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to save_fp (see GCBO)
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
% hObject    handle to update_triangle_room (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

	fprintf('[TraceFP]\tUpdate triangle room...\n');
	
	% find a triangle
	ind = TraceFP_findtri(handles);
	if(ind <= 0)
		fprintf('[TraceFP]\t\tNo triangle selected.  Nevermind.\n');
		return;
	end

	% change its room to current
	handles.room_ids(ind) = handles.current_room;

	TraceFP_render(hObject, handles, false);
    handles=guidata(hObject);
    global undo_history
    undo_history.push_back(handles);
	fprintf('[TraceFP]\t\tUpdated to %d.\n', handles.current_room);


% --------------------------------------------------------------------
function open_fp_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to open_fp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

	fprintf('[TraceFP]\tOpen floorplan (*.fp) file...\n');
	
	% open the file
	[fpfile, pathname,success] = uigetfile('*.fp', ...
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
    global undo_history
    undo_history.push_back(handles);
	fprintf('[TraceFP]\t\tDONE\n.');


% --- Executes on button press in button New Rectangle.
function new_rectangle_clicked_Callback(hObject, eventdata, handles)
% hObject    handle to new_rectangle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    fprintf('[TraceFP]\tNew rectangle:  select four points...\n');
    rectangle_created = false;
    while (true)
        % get the point indices
        pinds = zeros(1,3);
        i=1;
        while i<=3
            pinds(i) = TraceFP_select(handles);
            if (length(pinds) == 1 || pinds(1) <= 0)
                fprintf(['[TraceFP]\t\tExit point selection.\n']);
                return;
            elseif(length(unique(pinds(1:i))) < i || any(pinds(1:i) <= 0))
                fprintf(['[TraceFP]\t\tSelected invalid point, ', ...
                'exiting rectangle creation.\n']);
                return;
            else
                i=i+1;
            end
        end

        % check for invalid
        if(length(unique(pinds)) < 3 || any(pinds <= 0))
            fprintf(['[TraceFP]\t\tFound repeated/invalid points, ', ...
                    'discarding selection.\n']);
            return;
        end

        % check if first triangle oriented correctly
        orient = det([ 	(handles.control_points(pinds(1),:) ...
                    - handles.control_points(pinds(3),:)) ;
                (handles.control_points(pinds(2),:) ...
                    - handles.control_points(pinds(3),:)) ]);
        if(orient < 0)
            fprintf('[TraceFP]\t\treordering to be counterclockwise\n');
            pinds = fliplr(pinds);
        end
        
        new_point=TraceFP_select(handles);
        
        % check whether new_point is inside triangle created by 
        % first 3 points
        triangle_coordinates=[handles.control_points(pinds(1),:);...
            handles.control_points(pinds(2),:); ...
            handles.control_points(pinds(3),:)];
        triangle_xv=triangle_coordinates(:,1);
        triangle_yv=triangle_coordinates(:,2);
        if (new_point<=0 || inpolygon(handles.control_points(new_point, 1), ...
                handles.control_points(new_point, 2), ...
                triangle_xv, ...
                triangle_yv))
            % add the triangle
            rectangle_created = true;
            handles.triangles = [handles.triangles; pinds];
            fprintf('[TraceFP]\t\tadded new triangle\n');
            handles.room_ids = [handles.room_ids ; handles.current_room];
            % render and save data
            TraceFP_render(hObject, handles, false);
            handles=guidata(hObject);
            global undo_history
            undo_history.push_back(handles);
            continue;
        end
        
        % find second triangle
        second_pinds=[];
        i=1;
        x=handles.control_points(new_point, 1);
        y=handles.control_points(new_point, 2);
        triangle_line_x = [handles.control_points(pinds(1), 1), ...
                handles.control_points(pinds(2), 1), ...
                handles.control_points(pinds(3), 1), ...
                handles.control_points(pinds(1), 1)];
        triangle_line_y = [handles.control_points(pinds(1), 2), ...
            handles.control_points(pinds(2), 2), ...
            handles.control_points(pinds(3), 2), ...
            handles.control_points(pinds(1), 2)];
        while (i<4 && numel(second_pinds) ~= 2)
            % if there is no intersection, i.e. xi is empty
            % this target is a correct point
            xV=[x, handles.control_points(pinds(i), 1)];
            yV=[y, handles.control_points(pinds(i), 2)];
            [xi, yi] = polyxpoly(xV, yV, ...
                triangle_line_x, triangle_line_y, 'unique');
            if (numel(xi)==1)
                second_pinds=[second_pinds, pinds(i)];
            end
            i = i + 1;
        end
        if (numel(second_pinds) ~= 2)
            fprintf('[TraceFP]\t\tinvalid rectangle selected. exiting.\n');
            return;
        else
            second_pinds=[second_pinds, new_point];
        end        
        
        % check if second triangle oriented correctly
        orient = det([ 	(handles.control_points(second_pinds(1),:) ...
                    - handles.control_points(second_pinds(3),:)) ;
                (handles.control_points(second_pinds(2),:) ...
                    - handles.control_points(second_pinds(3),:)) ]);
        if(orient < 0)
            fprintf('[TraceFP]\t\treordering to be counterclockwise\n');
            second_pinds = fliplr(second_pinds);
        end
        
        % add first triangle
        rectangle_created = true;
        handles.triangles = [handles.triangles; pinds];
        fprintf('[TraceFP]\t\tadded new triangle\n');
        handles.room_ids = [handles.room_ids ; handles.current_room];
        
        % add second triangle
        handles.triangles = [handles.triangles; second_pinds];
        fprintf('[TraceFP]\t\tadded new triangle\n');
        handles.room_ids = [handles.room_ids ; handles.current_room];

        % render and save data
        TraceFP_render(hObject, handles, false);
        handles=guidata(hObject);
        global undo_history
        undo_history.push_back(handles);
    end


% --- Executes on button press in clear.
function clear_Callback(hObject, eventdata, handles)
% hObject    handle to clear (see GCBO)
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
% hObject    handle to fit_to_line (see GCBO)
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
    delete(node);
    TraceFP_render(hObject, handles, false);


% --------------------------------------------------------------------
function redo_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to fit_to_line (see GCBO)
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
    delete(node);
    TraceFP_render(hObject, handles, false);


% --------------------------------------------------------------------
function fit_to_line_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to fit_to_line (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    while (true)
        points = [];
        fprintf('[TraceFP]\tselect points to fit into one line...\n');
        fprintf('[TraceFP]\t\tSelect new point\n');
        pind = 1;
        while (pind > 0)
            pind = TraceFP_select(handles);
            if(pind <= 0)
                break;
            else
                points = [points, pind];
            end
        end

        if (numel(points)==0)
            fprintf('[TraceFP]\t\tExiting line fitting.\n');
            return;
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
        global undo_history
        undo_history.push_back(handles);
        fprintf('[TraceFP]\t\tpoints fit to line\n');
    end
