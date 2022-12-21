function box = bounding_box(vol, boundary_add, output)

% Create bounding box around given object (vol: 3D array or .nii). Assumes elements == 0 are
% to be excluded from object, while voxels > 0 are to be included. boundary_add specifies amount
% of space to be added along each dimension of box. If vol is .nii, boundary_add works in voxel
% size; if vol is a 3D array, boundary_add works in number of voxels. If boundary_add is a scalar,
% it is added to each dimension; if boundary_add is length(3), elements are added along x,y,z directions.

% Inputs:
%   vol             = Volume with object to be masked (3D-array, .nii, .nii.gz).
%   boundary_add    = Dimensions to be added to extremes of bounding box. 
%   output          = File name for output .nii.

if length(boundary_add) == 1
    boundary_add = repelem(boundary_add,3);
end

if ischar(vol)
    info = niftiinfo(vol);
    vol = niftiread(vol);
    boundary_add = boundary_add.*info.PixelDimensions;
end

vol(vol > 0) = 1;

box = zeros(size(vol));
[x,y,z] = ind2sub(size(vol),find(vol));
x = (min(x) - boundary_add(1)):(max(x) + boundary_add(1));
y = (min(y) - boundary_add(2)):(max(y) + boundary_add(2));
z = (min(z) - boundary_add(3)):(max(z) + boundary_add(3));

box(x,y,z) = 1;
box = cast(box,info.Datatype);
niftiwrite(box,output,info)

end