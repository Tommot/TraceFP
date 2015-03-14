classdef TraceFP_history < handle
    %TRACEFP_HISTORY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        tail
    end
    
    methods
        function obj = TraceFP_history(handles)
            if nargin > 0
                obj.tail = TraceFP_history_node(handles);
            else
                obj.tail = 0;
            end
        end
        
        function push_back(self, handles)
            if (self.tail == 0)
                self.tail = TraceFP_history_node(handles);
            else
                new_tail = TraceFP_history_node(handles);
                self.tail.next = new_tail;
                new_tail.prev = self.tail;
                self.tail = self.tail.next;
            end
        end
        
        function obj = pop(self)
            if (self.tail == 0)
                obj = 0;
                return
            elseif (self.tail.prev == 0)
                obj = self.tail;
                self.tail = 0;
            else
                obj = self.tail;
                self.tail = self.tail.prev;
                self.tail.next = 0;
            end
            obj.prev = 0;
        end
        
        function clear(self)
            obj = self.pop();
            while (obj~=0)
                delete(obj);
                obj = self.pop();
            end
        end
    end
    
end

