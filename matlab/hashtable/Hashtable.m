classdef Hashtable < handle
    % Hashtable
    % Copyright (c) 2004 Matthew Krauski (mkrauski@uci.edu), CNLM, UC Irvine
    %               Written the original class
    % Copyright (c) 2010 Dean Mark
    %               Repackaged the class in modern form.
    %
    %   Clear     - Clear hash table
    %   Elements  - Get all hash table elements
    %   Get       - Get data from the hash table
    %   Hashtable - Constructor for Hashtable class
    %   IsEmpty   - Check to see if the hash is empty
    %   IsKey     - Check to see if the hash is currently using a key
    %   Keys      - Get all the keys currently being used in the hash
    %   Put       - Put data in the hash table
    %   Remove    - Remove element from the hash
    %   Values    - Get all data contained in the hash table
        
    properties (SetAccess = private)
        
        keys;
        data;
        
    end
    
    methods(Access = public)
        
        function h = Hashtable(Keys, Data)
            %HASHTABLE Constructor for HashTable class
            %   hash = Hashtable() - Default constructor, empty hash table
            %   hash = Hashtable(keys,data) - keys and data are N-by-1 lists
            
            if nargin == 0
                h.keys = {};
                h.data = {};
            elseif nargin == 2
                if numel(Keys)==numel(Data)
                    h.keys = Keys;
                    h.data = Data;
                else
                    ME = MException('LookupTable:LookupTable', 'Invalid arguments. numel(Keys) must equal numel(Data)');
                    throw(ME);
                end                
            else
                ME = MException('LookupTable:LookupTable', 'Invalid arguments.');
                throw(ME);
            end
            
        end
        
        function hash = Clear(hash)
            %CLEAR Clear hash table

            hash.keys = {};
            hash.data = {};
        end
        
        function data = Elements(hash)
            %ELEMENTS Get all hash table elements
            %
            % Get all hash table elements in a N-by-2 cell matrix where N is the number of
            % elements, first column contains the element keys, and second column contains
            % the element values.
            
            data(:,1) = hash.keys;
            data(:,2) = hash.data;
            
        end
        
        function data = Get(hash,key)
            %GET Get data from the hash table
            
            index = find(strcmp(hash.keys,key));
            if isempty(index)
                data = {};
            else
                data = hash.data{index};
            end
        end
        
        function bool = IsEmpty(hash)
            %ISEMPTY Check to see if the hash is empty
            
            bool = isempty(hash.keys);
        end
        
        function bool = IsKey(hash,key)
            %ISKEY Check to see if the hash is currently using a key
            
            index = find(strcmp(hash.keys,key), 1);
            bool = ~isempty(index);
            
        end
        
        function keys = Keys(hash)
            %KEYS Get all the keys currently being used in the hash
            
            keys = hash.keys;
            
        end
        
        function hash = Put(hash,key,data)
            %PUT Put data in the hash table
            
            if ~ischar(key)
                ME = MException('VerifyInput:invalidInputParameter', 'Error in input. key must be of type string');
                throw(ME);
            end
            
            index = find(strcmp(hash.keys,key));
            if isempty(index)
                if isempty(hash.keys)
                    hash.keys{1} = key;
                    hash.data{1} = data;
                else
                    hash.keys{end+1} = key;
                    hash.data{end+1} = data;
                end
            else
                hash.data{index} = data;
            end
        end
        
        function hash = Remove(hash,key)
            %REMOVE Remove element from the hash
            
            index = find(strcmp(hash.keys,key));
            if ~isempty(index)
                hash.keys = {hash.keys{1:index-1} hash.keys{index+1:end}};
                hash.data = {hash.data{1:index-1} hash.data{index+1:end}};
            end
        end
        
        function data = Values(hash)
            %VALUES Get all data contained in the hash table
            
            data = hash.data;
            
        end
        
    end
    
end