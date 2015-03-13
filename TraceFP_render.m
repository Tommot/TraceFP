function [] = TraceFP_render(hObject, handles, resize)
	% TRACEFP_RENDER(hObject, handles)
	%
	%	renders the currently loaded data to the axes specified
	%	by the handles structure.
	%
	% author:
	%
	%	Written by Eric Turner <elturner@eecs.berkeley.edu>
	%	February 9, 2015
	%

	% set to the program's axes
	axes(handles.axes1);
    XL=xlim;
    YL=ylim;
	hold off;
    
    % ------------------------------------------------------------
    % special case where nothing is supposed to appear on screen
    % clear / undo to empty screen
    % ------------------------------------------------------------
    if (isempty(handles.wall_samples) && isempty(handles.control_points) ...
            && isempty(handles.triangles))
        if (handles.control_points_plot~=0)
            delete(handles.control_points_plot);
        end
        if (handles.triangles_plot~=0)
            delete(handles.triangles_plot);
        end
        if (handles.wall_samples_plot~=0)
            delete(handles.wall_samples_plot);
        end
        cla;
        if (~resize)
            xlim(XL);
            ylim(YL);
        end
        guidata(hObject,handles)
        return;
    end

	% --------------
	% Control points
	% --------------
    
	% render any control points, if toggled
	if(~isempty(handles.control_points))
        if (handles.control_points_plot ~= 0)
            delete(handles.control_points_plot);
        end
		handles.control_points_plot = ...
			plot(handles.control_points(:,1), ...
				handles.control_points(:,2), ...
					'*m', 'LineWidth', 2);
    end
    
    %-------------
	% Wall samples 
	%-------------
    hold on;
	% check if wall samples have a handle.  if not, render them
	if(~isempty(handles.wall_samples))

		% plot the points
        if (handles.wall_samples_plot~=0)
            delete(handles.wall_samples_plot);
        end
        hold on;
		X = handles.wall_samples.pos(1,:);
		Y = handles.wall_samples.pos(2,:);
		handles.wall_samples_plot = plot(X, Y, 'b.');
    end
    hold on;
	% render triangles, if toggled
	if(~isempty(handles.triangles))
		% get coordinates for every triangle
        if (handles.triangles_plot~=0)
            delete(handles.triangles_plot);
        end
		N = size(handles.triangles, 1);
		X = zeros(3, N);
		Y = zeros(size(X));
		C = zeros(1,N,3);
		for i = 1:N

			% get geometry
			X(:,i) = handles.control_points(...
					handles.triangles(i,:), 1);
			Y(:,i) = handles.control_points(...
					handles.triangles(i,:), 2);

			% get color
			rng(handles.room_ids(i));
			C(1,i,1) = 0.25 + 0.5*rand();
			C(1,i,2) = 0.25 + 0.5*rand();
			C(1,i,3) = 0.25 + 0.5*rand();
		end

		% plot the triangles
		handles.triangles_plot = patch(X, Y, C, 'EdgeAlpha', 0.2);
    end
    if (~resize)
        xlim(XL);
        ylim(YL);
    end
    guidata(hObject,handles)
end
