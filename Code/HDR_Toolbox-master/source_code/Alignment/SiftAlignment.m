function stackOut = SiftAlignment(stack, bStackOut, dir_name, format, target_exposure)
%
%
%       stackOut = SiftAlignment(stack, bStackOut, dir_name, format,
%       target_exposure)
%
%       This function shifts pixels on the right with wrapping of the moved
%       pixels. This can be used as rotation on the Y-axis for environment
%       map encoded as longituted-latitude encoding.
%
%       Input:
%           -stack: a stack (4D) containing all images.
%           -bStackOut: if it is sets to 1 it outputs an aligned stack in
%           stackOut. Otherwise, stackOut = [].
%           -dir_name: the folder name where the stack is stored. This flag
%           is valid if stack=[]
%           -format: the file format of the stack. This flag is valid if
%           stack=[].
%           -target_exposure: The index of the target exposure for aligning
%           images. If stack=[] the name of the target exposure for alignment.
%           If not provided the stack will be analyzed.
%
%       Output:
%           -stackOut: the aligned stack as output
%
%     Copyright (C) 2013  Francesco Banterle
% 
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.
%

lst = [];

bStack = ~isempty(stack);

if(~bStack)
    lst = dir([dir_name,'/*.',format]);
    n = length(lst);
else
    [r,c,col,n] = size(stack);
end

if(n<=1)
    return;
end

if(~exist('target_exposure','var'))
    disp('Finding the best target exposure...');
    values = zeros(n,1);
    for i=1:n
        if(bStack)
            tmpImg = stack(:,:,:,i);
        else
            tmpImg = single(imread([dir_name,'/',lst(i).name]))/255;
        end
        [r,c,col] = size(tmpImg);
        values(i) = mean(tmpImg(:));
        clear('tmpImg');
    end
    [values,indx] = sort(values);
    
    target_exposure = indx(round(n/2));
    disp('OK');
else
    if(~bStack)
        tmpTarget_exposure = 1;
        
        for i=1:n
            if(strcmp(target_exposure,lst(i).name)==1)
                tmpTarget_exposure = i;
            end
        end
        target_exposure = tmpTarget_exposure;
    end
end

if(bStack)
    img = stack(:,:,:,target_exposure);
else
    img = single(imread([dir_name,'/',lst(target_exposure).name]))/255;
end

stackOut = [];
if(bStackOut)
    stackOut = zeros(r,c,col,n);
    stackOut(:,:,:,target_exposure) = img;
end

for i=1:n
    
    if(i~=target_exposure)
        disp(['Aligning image ',num2str(i),' to image ',num2str(target_exposure)]);
       
        if(~bStack)
            imgWork = single(imread([dir_name,'/',lst(i).name]))/255;  
        else
            imgWork = stack(:,:,:,i);
        end

        imWork_align = SiftImageAlignment(img, imgWork);
        
        if(bStackOut)
            stackOut(:,:,:,i) = imWork_align;
        end
        
        if(~bStack)
            oldName = lst(i).name;
            name = strrep(lst(i).name, ['.',format], ['_align.',format]);
            if(strcmp(oldName,name)==1)
                name = [name,'_align.',format];
            end
            
            imwrite(imWork_align,[dir_name,'/',name]);
        end
        
        clear('imWork_align');
        clear('imgWork');
    end
end

end