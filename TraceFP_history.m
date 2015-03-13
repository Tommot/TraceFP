classdef TraceFP_history < handle
    %TRACEFP_HISTORY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties 
        tail
    end
    
    methods
        function obj = TraceFP_history(handles)
            if nargin > 0
%                 obj.wall_samples = handles.wall_samples;
%                 obj.control_points = handles.control_points;
%                 obj.triangles = handles.triangles;
%                 obj.next = 0;
%                 obj.prev; 
                obj.tail = TraceFP_history_node(handles);
            end
        end
        
        function push_back_action(self, handles)
            new_tail = TraceFP_history_node(handles);
            self.tail.next = new_tail;
            new_tail.prev = self.tail;
            self.tail = self.tail.next;
        end
        
        function obj = pop_action(self)
            obj = self.tail;
            self.tail = self.tail.prev;
            self.tail.next = 0;
            obj.prev = 0;
        end
    end
    
end

