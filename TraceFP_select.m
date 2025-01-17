function ind = TraceFP_select(handles)
	% ind = TraceFP_select(handles)
	%
	%   return a list of control points via the cursor lasso selection
	%   return 0 if nothing is selected
    
    % avoid double selection with pan
    pan OFF;

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
    number_of_element_selected = numel(ind);
	if (number_of_element_selected==0)
		fprintf('[TraceFP]\t\tno point selected\n');
        ind = 0;
    elseif (number_of_element_selected>1)
        if (iscell(ind))
            rtn = [];
            for i=1:size(ind,1)
                rtn = [rtn, ind{i}];
            end
            ind = rtn;
        end
        ind = transpose(ind);
    else
        fprintf('[TraceFP]\t\tone point selected\n');
    end
% 	elseif(numel(ind) > 1)
%         found=0;
%         for i=numel(ind):-1:1
%             if (numel(ind{i}) == 1)
%                 fprintf(['[TraceFP]\t\tpoint selected\n']);
%                 found=1;
%                 ind=ind{i};
%                 break;
%             end
%         end
%         if (found==0)
%             fprintf(['[TraceFP]\t\tno point selected\n']);
%             ind=0;
%         end
% 	end
end
