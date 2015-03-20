classdef TraceFP_history_node < handle
    %TRACEFP_HISTORY_NODE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        wall_samples
        control_points
        triangles
        room_ids
        current_room
        next
        prev
    end
    
    methods
        function obj = TraceFP_history_node(handles)
            if nargin > 0
                obj.wall_samples = handles.wall_samples;
                obj.control_points = handles.control_points;
                obj.triangles = handles.triangles;
                obj.room_ids = handles.room_ids;
                obj.current_room = handles.current_room;
                obj.next = 0;
                obj.prev = 0; 
            end
        end
    end
    
end

