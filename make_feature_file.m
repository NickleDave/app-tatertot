!dir /B *.not.mat > batchfile
n_files = size(ls('*.not.mat'),1); % size(ls,rows) = number of .not.mat files

% initialization
ct_files = 0 ; % counter to keep track of files analyzed
ct=1; % counter for number of syllables

fid=fopen('batchfile','r');
while 1
    fn=fgetl(fid);
    if (~ischar(fn));break;end
    cbin_fn=fn(1:end-8);
 
    d_num=fn2datenum(cbin_fn); % get date from filename

    load(fn);
    onsets=onsets/1000; % convert back to s
    offsets=offsets/1000; % convert back to s

    [rawsong, Fs] = evsoundin('.', cbin_fn,'obs0');

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
    disp(['Processed ' num2str(ct_files) ' of ' num2str(n_files) ' files: ' fn])
end

underscore_ids = strfind(cbin_fn,'_');
bird_name = cbin_fn(1:(underscore_ids(1)-1));
save_fname = [bird_name '_feature_file_' datestr(now,'yyyyddmmTHHMMSS')];
save(save_fname,'features_mat','label_vec')