function x = readData(fname)
% Read data from the given filename

fid = fopen(fname);
x = [];

while ~feof(fid)
    vec = fgetl(fid);
    l = sscanf(vec, '%d');
    
    x = [x l];
end

fclose(fid);

return
