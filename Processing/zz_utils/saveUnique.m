function [  ] = saveUnique( obj, filename )
%% Save a file with a unique filename
% 
% function [  ] = saveUnique( obj, filename )
%
% If a file by the given name already exists, saveUnique adds a suffix to 
% the filename to prevent overwriting
% 
% Input - 
%  - obj: the object to be saved, usually a figure
%  - filename: a string representing the desired name of the file
%
% Example - 
%  >> x = [0:0.1:10];
%  >> y = x.^2;
%  >> figure; plot(x,y);
%  >> saveUnique(gcf, 'x_squared.jpg')
%
% Zachary Tweed - Art Week 2016


%%
[path, name, ext] = fileparts(filename);

count = 0;

% If the filename already exists, choose a new one
if exist(filename, 'file') ~= 2
    saveas(obj, filename);
else
    while exist(filename, 'file') == 2
        
        count = count + 1;
        
        filename = strcat(path,'/',name, '_', num2str(count), ext);
        
    end
    saveas(obj, filename);
end

end