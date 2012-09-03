function [data, m] = readdata(filename)

    fid = fopen(filename);
    data = [];
    m = 0;

%     for i = 1:100
%         vec = fgetl(fid);
%         l = sscanf(vec, '%d');
%         
%         data = [data l(1:3)];
%         m = m + 1;
%     end
    while ~feof(fid)
        vec = fgetl(fid);
        l = sscanf(vec, '%d');

        data = [data l];
        m = m + 1;
    end
end