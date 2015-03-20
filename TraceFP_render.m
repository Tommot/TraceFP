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
    fprintf('[TraceFP]\trendering...\n');
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
            handles.control_points_plot == 0;
        end
        if (handles.triangles_plot~=0)
            delete(handles.triangles_plot);
            handles.triangles_plot == 0;
        end
        if (handles.wall_samples_plot~=0)
            delete(handles.wall_samples_plot);
            handles.wall_samples_plot == 0;
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
            handles.control_points_plot = 0;
        end
        
        if (numel(handles.control_points_plot) > 0)
            handles.control_points_plot = ...
                plot(handles.control_points(:,1), ...
                    handles.control_points(:,2), ...
                        '*m', 'LineWidth', 2);

            % hide control points if 'show control points' box unchecked
            if(get(handles.show_control_points, 'Value'))
                set(handles.control_points_plot, 'Visible', 'on');
            else
                set(handles.control_points_plot, 'Visible', 'off');
            end
        end
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
            handles.wall_samples_plot = 0;
        end
        if (numel(handles.wall_samples) > 0)
            hold on;
            X = handles.wall_samples.pos(1,:);
            Y = handles.wall_samples.pos(2,:);
            handles.wall_samples_plot = plot(X, Y, 'b.');

            % hide wall samples if 'show wall samples' box unchecked
            if(get(handles.show_wall_samples, 'Value'))
                set(handles.wall_samples_plot, 'Visible', 'on');
            else
                set(handles.wall_samples_plot, 'Visible', 'off');
            end
        end
    end
    
    %------------
    % Triangles
    %------------
    hold on;
	% render triangles, if toggled
	if(~isempty(handles.triangles))
		% get coordinates for every triangle
        if (handles.triangles_plot~=0)
            delete(handles.triangles_plot);
            handles.triangles_plot = 0;
        end
        if (numel(handles.triangles) > 0)
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

            % hide triangles if 'show triangles' box unchecked
            if(get(handles.show_floorplan, 'Value'))
                set(handles.triangles_plot, 'Visible', 'on');
            else
                set(handles.triangles_plot, 'Visible', 'off');
            end
        end
    end
    
    
    
    if (~resize)
        xlim(XL);
        ylim(YL);
    end
    guidata(hObject,handles)
    fprintf('[TraceFP]\t\tfinish rendering\n');
end
