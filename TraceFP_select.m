function ind = TraceFP_select(handles)
	% ind = TraceFP_select(handles)
	%
	%	Selects a single control point via the mouse
	%


	% if wall samples are defined, then need to ignore them
	if(handles.wall_samples_plot ~= 0)

		% if triangles defined, ignore them
		if(handles.triangles_plot ~= 0)
			% ignore both
			ind = selectdata('sel', 'br', ...
				'Ignore', [handles.wall_samples_plot, ...
				handles.triangles_plot]);

		else
			% ignore wall samples
			ind = selectdata('sel', 'br', ...
				'Ignore', handles.wall_samples_plot);
		end

	else
		% if triangles defined, ignore them
		if(handles.triangles_plot ~= 0)
			% ignore triangles
			ind = selectdata('sel', 'br', ...
				'Ignore', handles.triangles_plot);
		else
			% ignore wall samples
			ind = selectdata('sel', 'br');
		end
    end
    % try to remove bad entries (does not work some of the times)

%     ind(cellfun(@(x) ~isa(x,'double'),ind)) = [];
%     ind(cellfun(@(x) isempty(x),ind)) = [];
%     ind(cellfun(@(x) isa(x,'vector'),ind)) = [];

	if(isempty(ind))
		fprintf('[TraceFP]\t\tno point selected\n');
		ind = 0;
        return;
	elseif(numel(ind) > 1)
		
        % the end of the cell array usually contains good entries
        % compared to the beginning of the cell array
        found=0;
        for i=numel(ind):-1:1
            if (numel(ind{i}) == 1)
                fprintf(['[TraceFP]\t\tpoint selected\n']);
                found=1;
                ind=ind{i};
                break;
            end
        end
        if (found==0)
            fprintf(['[TraceFP]\t\tno point selected\n']);
            ind=0;
        end
	end
end
