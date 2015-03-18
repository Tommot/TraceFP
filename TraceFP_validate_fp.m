function handles = TraceFP_validate_fp( handles )
%TRACEFP_VALIDATE_FP Summary of this function goes here
%   Detailed explanation goes here
    % remove invalid triangles
    fprintf('[TraceFP]\tvalidate floorplan...\n');
    fprintf('[TraceFP]\t\tstep 1: removing invalid/duplicate/empty triangles...\n');
    for idx=size(handles.triangles,1):-1:1
        row = handles.triangles(idx, :);
        duplicate_triangles = any(handles.triangles==row(1), 2) ...
         & any(handles.triangles==row(2), 2) ...
         & any(handles.triangles==row(3), 2);
        xV = [];
        yV = [];
        for i=1:3
            xV = [xV, handles.control_points(handles.triangles(...
                    idx, i),1)];
            yV = [yV, handles.control_points(handles.triangles(...
                    idx, i),2)];
        end
        xV = [xV, handles.control_points(handles.triangles(...
                    idx, 1),1)];
        yV = [yV, handles.control_points(handles.triangles(...
                    idx, 1),2)];
        if (numel(unique(row)) ~= numel(row) || ...
                sum(duplicate_triangles)>1 || ...
                polyarea(xV, yV) < 0.001)
            handles.triangles(idx,:)=[];
            handles.room_ids(idx)=[];
        end
    end
    % remove old points which no edge points to
    fprintf('[TraceFP]\t\tstep 2: removing dangling points...\n');
    for pind=size(handles.control_points,1):-1:1
        if (isempty(find(handles.triangles==pind)))
            % if point does not exist, remove it and update indexing
            handles.control_points(pind,:)=[];
            idx = [[1:pind] [pind:size(handles.control_points,1)]];
            handles.triangles = idx( handles.triangles );
        end
    end
    %remove points that are inside any other triangles
    fprintf('[TraceFP]\t\tstep 3: removing invalid points...\n');
    for triangleIdx=1:size(handles.triangles,1)
        xV = [];
        yV = [];
        for i=1:3
            xV = [xV, handles.control_points(handles.triangles(...
                    triangleIdx, i),1)];
            yV = [yV, handles.control_points(handles.triangles(...
                    triangleIdx, i),2)];
        end
        xV = [xV, handles.control_points(handles.triangles(...
                    triangleIdx, 1),1)];
            yV = [yV, handles.control_points(handles.triangles(...
                    triangleIdx, 1),2)];
        if (triangleIdx ~= size(handles.triangles,1))
            xV = [xV,NaN];
            xV = [xV,NaN];
        end
    end
    for pind=size(handles.control_points,1):-1:1
        inside  = false;
        query = handles.control_points(pind,:);
        [in,on] = inpolygon(query(1),query(2),xV,yV);
        if (in & ~on)
            inside = true;
            break;
        end
        
        if (~inside)
            continue;
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
    end
    % fprintf('[TraceFP]\t\tstep 4: removing unused room_id...\n');
    
end

