classdef TraceFP_history_node < handle
    %TRACEFP_HISTORY_NODE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
%         wall_samples
%         control_points
%         triangles
        val
        next
        prev
    end
    
    methods
        function obj = TraceFP_history_node(handles)
            if nargin > 0
%                 obj.wall_samples = handles.wall_samples;
%                 obj.control_points = handles.control_points;
%                 obj.triangles = handles.triangles;
%                 obj.next = 0;
%                 obj.prev; 
                obj.val = handles;
            end
        end
    end
    
end

