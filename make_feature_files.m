function make_feature_files(num_files_to_use)
%make_feature_file2(num_files_to_use)
%   input argument:
%       num_files_to_use -- an integer n, uses the first n .not.mat files
%   output (files):
%       feature_file.mat -- generated with makeAllFeatures
%       feature_file.txt -- same but in format that can be used by Liblinear
%       syls_per_song.txt -- used by liblinear_test.py

notmats = ls('*.not.mat');
num_notmats = size(notmats,1); % size(ls,rows) = number of .not.mat files
if num_files_to_use > num_notmats
    error(['There are less .not.mat files in the directory than ' num_files_to_use])
end

% initialization
ct_files = 0 ; % counter to keep track of files analyzed
ct=1; % counter for number of syllables
fn = strtrim(notmats(1,:));
d_num=fn2datenum(fn); % get date from filename
dstr = datestr(d_num,'yyddmm');
underscore_ids = strfind(fn,'_');
bird_name = fn(1:(underscore_ids(1)-1));
syls_save_fname = [bird_name '_sylspersong_from_' dstr '_generated_' datestr(now,'yyyyddmmTHHMMSS') '.txt'];
fid_syls = fopen(syls_save_fname,'w');
fprintf(fid_syls,'dir: %s\n',pwd);

for i=1:num_files_to_use
    fn=strtrim(notmats(i,:));
    cbin_fn=fn(1:end-8);

    load(fn);
    onsets=onsets/1000; % convert back to s
    offsets=offsets/1000; % convert back to s

    num_syls = numel(labels);
    fprintf(fid_syls,'%s\n',num2str(num_syls));
    
    [rawsong, Fs] = evsoundin('', cbin_fn,'obs0');

    %%% go through syllable by syllable and quantify different parameters %%%
    t = (1:length(rawsong)) / Fs;
    for x = 1:length(onsets)
        on = onsets(x);
        off = offsets(x);
        on_id = find(abs((t-on))==min(abs(t-on)));
        off_id = find(abs((t-off))==min(abs(t-off)));
        syl_wav = rawsong(on_id:off_id);
        features_mat(ct,:) = makeAllFeatures(syl_wav,Fs);
        label_vec(ct) = double(labels(x));
        ct = ct + 1;
    end
    
    ct_files = ct_files + 1;
    disp(['Processed ' num2str(ct_files) ' of ' num2str(num_files_to_use) ' files: ' fn])
end

fclose(fid_syls);

feature_save_fname = [bird_name '_feature_file_from_' dstr '_generated_' datestr(now,'yyyyddmmTHHMMSS')];
save(feature_save_fname,'features_mat','label_vec')
convert_feature_file_to_txt(feature_save_fname)