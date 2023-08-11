clear all;
clc % clear command window
close all force;

X = 512;
Y = 512;
Z = 3;
T = 30;

k_size_x = 3; 
k_size_y = 3;
k_size_z = 3;
k_size_t = 3;

% -------------------------------------------------------------------------
%% Conv1D vs Conv2D
% -------------------------------------------------------------------------
img = zeros(X,Y);
img(2:X,2:Y-1) = 5;

f = randi(10,[1 k_size_y]); 
g = randi(10,[k_size_x 1]); 
flt = g*f;

% -------------------------------------------------------------------------
%% Conv1D
% -------------------------------------------------------------------------
res1d = zeros(X,Y);
for x=1:X
    res1d(x,:) = conv(img(x,:),f,'same');
end
for y=1:Y
    res1d(:,y) = conv(res1d(:,y),g,'same');
end

% -------------------------------------------------------------------------
%% Conv2D
% -------------------------------------------------------------------------
res2d = conv2(img,flt,'same');

disp("Filters")
disp(f);
disp(g);
disp(flt);
disp("Difference Conv1D vs Conv2D")
disp(sum(res2d-res1d,"all"));

% -------------------------------------------------------------------------
%% Conv2D (with 3D input) vs Conv3D
% -------------------------------------------------------------------------
img3d = zeros(X,Y,Z);
img3d(1:X-1,1:Y-1,1:Z) = 9;
res2d = zeros(X,Y,Z);

f = randi(10,[1 k_size_y]); 
g = randi(10,[k_size_x 1]); 
flt = g*f;

for z=1:Z    
    img_to_feed = img3d(:,:,z);
    img_to_feed = conv2(img_to_feed,flt,'same');
    res2d(:,:,z) = res2d(:,:,z)+img_to_feed;
end

res3d = convn(img3d,flt,'same');
disp("Difference Conv2D (with 3D input and 2D kernel) vs Conv3D")
disp("Convolution overt the third dimension")
disp(sum(res3d-res2d,"all"));

% -------------------------------------------------------------------------
%% Conv2D vs Conv3D
% -------------------------------------------------------------------------
img3d = zeros(X,Y,Z);
img3d(1:X-1,1:Y-1,1:Z) = 9;

f = randi([1 5],[1 k_size_x]); 
g = randi([1 5],[k_size_y 1]); 
h = randi([1 5],[1 k_size_z]); 
hh = permute(h,[1 3 2]);
flt = g*f.*hh;

% Conv2D
res2d = zeros(X,Y,Z);

for f=1:size(flt,3)
    for z=1:Z
        if (f==1 && z==Z) || (f==size(flt,3) && z==1)
            continue
        end
        res2d(:,:,z) = res2d(:,:,z)+conv2(img3d(:,:,z),flt(:,:,f),'same');
    end
end

% Conv3D
res3d = convn(img3d,flt,'same');

disp("Difference Conv3D vs Conv2D")
disp(sum(res3d-res2d,"all"));

% -------------------------------------------------------------------------
%% Conv3D (with 4D input) vs Conv4D
% -------------------------------------------------------------------------
img4d = zeros(X,Y,Z,T);
img4d(1:X-1,1:Y-1,1:Z,3:T-3) = 1;
res3d = zeros(X,Y,Z,T);

f = randi([1 5],[1 k_size_x]); 
g = randi([1 5],[k_size_y 1]); 
h = randi([1 5],[1 k_size_z]); 
hh = permute(h,[1 3 2]);
i = randi([1 5],[1 k_size_t]); 
ii = permute(i,[1 3 2]);

flt = g*f.*ii;

for z=1:Z
    img_to_feed = permute(img4d(:,:,z,:), [1 2 4 3]);
    img_to_feed = convn(img_to_feed,flt,'same');
    img_to_feed = permute(img_to_feed,[1 2 4 3]);
    res3d(:,:,z,:) = res3d(:,:,z,:)+img_to_feed;
end

% Conv4D
ii = permute(i,[1 3 4 2]);
flt = g*f.*ii;
res4d = convn(img4d,flt,'same');
disp("Difference Conv3D (with 4D input and 3D kernel) vs Conv4D")
disp("Convolution overt the third dimension")
disp(sum(res4d-res3d, "all"));

% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------

img4d = zeros(X,Y,Z,T);
img4d(1:X-1,1:Y-1,1:Z,3:T-3) = 1;
res3d = zeros(X,Y,Z,T);

f = randi([1 5],[1 k_size_x]); 
g = randi([1 5],[k_size_y 1]); 
h = randi([1 5],[1 k_size_z]); 
hh = permute(h,[1 3 2]);
flt = g*f.*hh;

for t=1:T
    img_to_feed = img4d(:,:,:,t);
    img_to_feed = convn(img_to_feed,flt,'same');
    res3d(:,:,:,t) = res3d(:,:,:,t)+img_to_feed;
end

% Conv4D
res4d = convn(img4d,flt,'same');
disp("Difference Conv3D (with 4D input and 3D kernel) vs Conv4D")
disp("Convolution overt the fourth dimension")
disp(sum(res4d-res3d, "all"));

% -------------------------------------------------------------------------
%% Conv4D vs Conv3D
% -------------------------------------------------------------------------
img4d = zeros(X,Y,Z,T);
img4d(1:X-1,1:Y-1,1:Z,3:T-3) = 1;

f = randi([1 10],[1 k_size_x]); 
g = randi([1 10],[k_size_y 1]); 
h = randi([1 10],[1 k_size_z]); 
hh = permute(h,[1 3 2]);
i = randi([1 3],[1 k_size_t]); 
ii = permute(i,[1 3 4 2]);
flt = g*f.*hh.*ii;

% -------------------------------------------------------------------------
%% Conv4D
% -------------------------------------------------------------------------
res4d = convn(img4d,flt,'same');

% -------------------------------------------------------------------------
%% Conv3D
% -------------------------------------------------------------------------
res3d = zeros(X,Y,Z,T);
for fz=1:size(flt,3)
    for z=1:Z
        if (fz==1 && z==Z) || (fz==size(flt,3) && z==1)
            continue
        end
        img = permute(img4d(:,:,z,:), [1 2 4 3]);
        kernel = permute(flt(:,:,fz,:), [1 2 4 3]);
        out = convn(img,kernel,'same');
        out = permute(out, [1 2 4 3]);
        res3d(:,:,z,:) = res3d(:,:,z,:)+out;
    end
end
disp("Difference Conv4D vs Conv3D")
disp(sum(res4d-res3d, "all"));