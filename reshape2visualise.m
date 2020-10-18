function M = reshape2visualise(M3D)
%RESHAPE2VISUALISE reshape a 3D matrix into a 2D for visualization 
%   It gets a PxQxR matrix and traforms it into a (PxR) x Q

% careful when using reshape : it gets the elements of the input matrix
% column wise to build the output matrix

P = size(M3D, 1);
Q = size(M3D, 2);
R = size(M3D, 3);

% first permute the dimensions
M3D_ = permute(M3D, [3 1 2]);
M = reshape(M3D_, P*R, Q);

end

