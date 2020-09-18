clc;
clear all;

addpath(genpath(pwd));
setup; 

paths= localPaths();
pslen_config = pslen_settings(paths);

netID = pslen_config.netID;
load( sprintf('%s%s.mat', paths.ourCNNs, netID), 'net' );


%% Check PSLEN model available

if ~exist(pslen_config.save_pslen_data_mdl, 'file') && strcmp(pslen_config.pslen_on,'paris')
    pslen_config.createPslenModel = true;
    dbTest= dbVGG('paris');
    pslen_config.datasets_path = paths.dsetRootParis; %% PC
    pslen_config.query_folder = 'images';    
    
    qFeatFn = sprintf('%s%s_%s_q.bin', paths.outPrefix, netID, dbTest.name);   % just to create the files in the out folder
    dbFeatFn = sprintf('%s%s_%s_db.bin', paths.outPrefix, netID, dbTest.name);  % just to create the files in the out folder

    % Create models if not available
    if ~exist(qFeatFn, 'file')
        %%
        net= relja_simplenn_tidy(net); % potentially upgrate the network to the latest version of NetVLAD / MatConvNet
        serialAllFeats(net, dbTest.qPath, dbTest.qImageFns, qFeatFn, 'batchSize', 1); % Tokyo 24/7 query images have different resolutions so batchSize is constrained to 1[recall, ~, ~, opts]= testFromFn(dbTest, dbFeatFn, qFeatFn);
    end

    if ~exist(qFeatFn, 'file')
        serialAllFeats(net, dbTest.dbPath, dbTest.dbImageFns, dbFeatFn, 'batchSize', 1); % adjust batchSize depending on your GPU / network size
    end
    
    pslen_testFromFn(dbTest, dbFeatFn, qFeatFn, pslen_config, [], 'cropToDim', pslen_config.cropToDim);
    pslen_model(pslen_config) 
end

%% Whole Process

dbTest = pslen_config.dbTest;

qFeatFn = sprintf('%s%s_%s_q.bin', paths.outPrefix, netID, dbTest.name);   % just to create the files in the out folder
dbFeatFn = sprintf('%s%s_%s_db.bin', paths.outPrefix, netID, dbTest.name);  % just to create the files in the out folder


% Create models if not available
if ~exist(qFeatFn, 'file')
    %%
    net= relja_simplenn_tidy(net); % potentially upgrate the network to the latest version of NetVLAD / MatConvNet
    serialAllFeats(net, dbTest.qPath, dbTest.qImageFns, qFeatFn, 'batchSize', 1); % Tokyo 24/7 query images have different resolutions so batchSize is constrained to 1[recall, ~, ~, opts]= testFromFn(dbTest, dbFeatFn, qFeatFn);
end

if ~exist(qFeatFn, 'file')
    serialAllFeats(net, dbTest.dbPath, dbTest.dbImageFns, dbFeatFn, 'batchSize', 1); % adjust batchSize depending on your GPU / network size
end

% Use PSLEN model
[recalll, ~,recall,allrecalls_pslen, opts]= pslen_testFromFn(dbTest, dbFeatFn, qFeatFn, pslen_config, [], 'cropToDim', pslen_config.cropToDim);


%% Results

netvlad_results = [opts.recallNs',recall*100];
maqbool_results_D = [opts.recallNs',allrecalls_pslen(:,1)*100];
maqbool_results_R = [opts.recallNs',allrecalls_pslen(:,2)*100];

    pslen_config.maqbool_d_results_fname = strcat('results/vd16_tokyoTM_to_tokyo247_maqbool_D_512.dat');
    pslen_config.maqbool_r_results_fname = strcat('results/vd16_tokyoTM_to_tokyo247_maqbool_R_512.dat');



dlmwrite(pslen_config.netvlad_results_fname,netvlad_results,'delimiter',' ');
dlmwrite(pslen_config.maqbool_d_results_fname,maqbool_results_D,'delimiter',' ');
dlmwrite(pslen_config.maqbool_r_results_fname,maqbool_results_R,'delimiter',' ');

%recallNs = opts.recallNs';
%save(pslen_config.save_results, 'recall','recallNs', 'recall_ori');
%pre = load(pslen_config.save_results);

plot(opts.recallNs, allrecalls_pslen(:,2), 'bo-', ...
     opts.recallNs, allrecalls_pslen(:,1), 'ro-' ,...
     opts.recallNs, recall, 'go-' ...
     ); grid on; xlabel('N'); ylabel('Recall@N'); title('Tokyo247 HYBRID Edge Image', 'Interpreter', 'none'); legend({'Previous Best','Original', 'New'});


