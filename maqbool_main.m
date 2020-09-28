clc;
clear all;

addpath(genpath(pwd));
setup; 

paths= localPaths();
m_config = m_settings(paths);

netID = m_config.netID;
load( sprintf('%s%s.mat', paths.ourCNNs, netID), 'net' );


%% Check Maqbool model available

if ~exist(m_config.save_m_data_mdl, 'file')
    m_config.create_Model = true;
    
    if strcmp(m_config.m_on,'paris')
        dbTest= dbVGG('paris');
        m_config.datasets_path = paths.dsetRootParis; 
        m_config.query_folder = 'images';                
        
    elseif strcmp(m_config.m_on,'oxford')
        dbTest= dbVGG('ox5k');
        m_config.datasets_path = paths.dsetRootOxford; 
        m_config.query_folder = 'images';
    
    end
       
    qFeatFn = sprintf('%s%s_%s_q.bin', paths.outPrefix, netID, dbTest.name);   % just to create the files in the out folder
    dbFeatFn = sprintf('%s%s_%s_db.bin', paths.outPrefix, netID, dbTest.name);  % just to create the files in the out folder

    % Create models if not available
    if ~exist(qFeatFn, 'file')
        %%
        net= relja_simplenn_tidy(net); % potentially upgrate the network to the latest version of NetVLAD / MatConvNet
        serialAllFeats(net, dbTest.qPath, dbTest.qImageFns, qFeatFn, 'batchSize', 1); % Tokyo 24/7 query images have different resolutions so batchSize is constrained to 1[recall, ~, ~, opts]= testFromFn(dbTest, dbFeatFn, qFeatFn);
    end

    if ~exist(dbFeatFn, 'file')
        serialAllFeats(net, dbTest.dbPath, dbTest.dbImageFns, dbFeatFn, 'batchSize', 1); % adjust batchSize depending on your GPU / network size
    end
    
    m_testFromFn(dbTest, dbFeatFn, qFeatFn, m_config, [], 'cropToDim', m_config.cropToDim);
    m_model(m_config) 
    m_config.create_Model = false;
    m_config = m_settings(paths); % Reset to original
end

%% Whole Process
dbTest = m_config.dbTest;
qFeatFn = sprintf('%s%s_%s_q.bin', paths.outPrefix, netID, dbTest.name);   % just to create the files in the out folder
dbFeatFn = sprintf('%s%s_%s_db.bin', paths.outPrefix, netID, dbTest.name);  % just to create the files in the out folder


% Create models if not available
if ~exist(qFeatFn, 'file')
    %%
    net= relja_simplenn_tidy(net); % potentially upgrate the network to the latest version of NetVLAD / MatConvNet
    serialAllFeats(net, dbTest.qPath, dbTest.qImageFns, qFeatFn, 'batchSize', 1); % Tokyo 24/7 query images have different resolutions so batchSize is constrained to 1[recall, ~, ~, opts]= testFromFn(dbTest, dbFeatFn, qFeatFn);
end

if ~exist(dbFeatFn, 'file')
    serialAllFeats(net, dbTest.dbPath, dbTest.dbImageFns, dbFeatFn, 'batchSize', 1); % adjust batchSize depending on your GPU / network size
end

% Use m model
[recalll, ~,recall,allrecalls_m, opts]= m_testFromFn(dbTest, dbFeatFn, qFeatFn, m_config, [], 'cropToDim', m_config.cropToDim);


%% Results

netvlad_results = [opts.recallNs',recall*100];
maqbool_results_D = [opts.recallNs',allrecalls_m(:,1)*100];
maqbool_results_R = [opts.recallNs',allrecalls_m(:,2)*100];
maqbool_results_RR = [opts.recallNs',allrecalls_m(:,3)*100];


dlmwrite(m_config.netvlad_results_fname,netvlad_results,'delimiter',' ');
dlmwrite(m_config.m_d_results_fname,maqbool_results_D,'delimiter',' ');
dlmwrite(m_config.m_r_results_fname,maqbool_results_R,'delimiter',' ');

plot(opts.recallNs, allrecalls_m(:,3), 'bo-', ...
     opts.recallNs, allrecalls_m(:,2), 'go-', ...
     opts.recallNs, allrecalls_m(:,1), 'ro-' ,...
     opts.recallNs, recall, 'ko-' ...
     ); grid on; xlabel('N'); ylabel('Recall@N'); title('Tokyo247 HYBRID Edge Image', 'Interpreter', 'none'); legend({'Previous Best','Original', 'New'});


