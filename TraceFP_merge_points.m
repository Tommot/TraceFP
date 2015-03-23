function handles = TraceFP_merge_points(handles, pind1, pind2)
%TRACEFP_MERGE_POINT Summary of this function goes here
%   Detailed explanation goes here
%   Output -- handles, a new handle that has pind1 and pind2 merged
%   pind1: point to be merged into, and kept
%   pind2: point to be removed
%   merge point pind2 into pind1 will result in one point
%   at location of point 1
    if (numel(pind1)~=1)
        fprintf(['[TraceFP]\t\tInvalid number of arguments to ',...
                    'TraceFP_merge_points. Now exiting function\n']);
        return
    end
    if (pind1 == pind2)
        fprintf(['[TraceFP]\t\tInvalid arguments to ',...
                    'TraceFP_merge_points. Now exiting function\n']);
        return
    end
    if (numel(pind2)~=1)
        pind2(pind2==pind1)=[];
    end
    if (numel(pind2)==1)
        pind1_map = any(handles.triangles==pind1, 2);
        pind2_map = any(handles.triangles==pind2, 2);
        both_id_exist = pind1_map & pind2_map;

        % replace all pind2 with pind1
        handles.triangles(handles.triangles==pind2)=pind1;

        % remove corresponding triangles that links both points
        handles.triangles(both_id_exist, :)=[];
        handles.room_ids( both_id_exist ) = [];

        % update index in handle.triangles
        idx = [[1:pind2] [pind2:size(handles.control_points,1)]];
        handles.triangles = idx( handles.triangles );

        % remove pind2 from control point
        handles.control_points(pind2, :) = [];

        handles = TraceFP_validate_fp(handles);
    elseif (numel(pind2)>1)
        % replace all pind2 with pind1
        for idx=1:numel(pind2)
            handles.triangles(handles.triangles==pind2(idx))=pind1;
        end
       
        % remove corresponding triangles that links both points
        duplicate_id_exist = (sum(handles.triangles==pind1,2) ...
            - ones(size(handles.triangles,1), 1)) > 0;
        handles.triangles(duplicate_id_exist, :)=[];
        handles.room_ids( duplicate_id_exist ) = [];

        % update index in handle.triangles and index in points
        sorted_pind2 = sort(pind2, 2, 'descend');
        for i=1:numel(sorted_pind2)
            idx = [[1:sorted_pind2(i)] [sorted_pind2(i):size(handles.control_points,1)]];
            handles.triangles = idx( handles.triangles );
            handles.control_points(sorted_pind2(i), :) = [];
        end

        handles = TraceFP_validate_fp(handles);
    end
end

