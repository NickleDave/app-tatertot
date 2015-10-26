function make_sylspersong_file

!dir /B *.not.mat > batchfile

fid_batch = fopen('batchfile','r');

notmats = ls('*.not.mat');
fn = notmats(1,:);
underscore_ids = strfind(fn,'_');
bird_name = fn(1:(underscore_ids(1)-1));
save_fname = [bird_name '_sylspersong_' datestr(now,'yyyyddmmTHHMMSS') '.txt'];
fid_txt = fopen(save_fname,'w');
fprintf(fid_txt,'dir: %s\n',pwd);

while 1
    fn = fgetl(fid_batch);
    if (~ischar(fn));break;end
    load(fn);
    num_syls = numel(labels);
    fprintf(fid_txt,'%s\n',num2str(num_syls));
end

fclose(fid_batch);
fclose(fid_txt);
    