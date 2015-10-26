function convert_feature_file_to_txt(load_fname)
% convert_feature_file_to_txt

load(load_fname)
[row,col] = size(features_mat);

save_fname = [load_fname(1:end-4) '.txt'];
fid = fopen(save_fname,'w');

for i = 1:row
    fprintf(fid,'%s ',num2str(label_vec(i)));
    for j = 1:col
        fprintf(fid,'%s:%s ',num2str(j),num2str(features_mat(i,j)));
    end
    fprintf(fid,'\n');
end

fclose(fid);