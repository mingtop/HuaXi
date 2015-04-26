function [ patches ] = normalizeData( patches )
%NORMALIZEDATA �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��

patches = bsxfun(@minus, patches, mean(patches));

% Truncate to +/-3 standard deviations and scale to -1 to 1
pstd = 3 * std(patches(:));
patches = max(min(patches, pstd), -pstd) / pstd;

% Rescale from [-1,1] to [0.1,0.9]
patches = (patches + 1) * 0.4 + 0.1;

end
