function plen_opts= pslen_settings(paths)
    
 
    iTestSample_Start= 1; startfrom = 1;  show_output = 0; 
    pslen_mode = 'training' ; %'training' , 'test'
    proj = 'pslen'; %'vt-rgb'
    f_dimension = 512;% '512' or '4096'
    pre_net = 'vd16';% 'vd16', 'caffe'
    net_dataset = 'tokyoTM'; %tokyoTM', 'pitts30k' 
    job_net = strcat(pre_net,'_',net_dataset); 
    job_datasets = 'tokyo247';  %'tokyo247' 'pitts30k' 'oxford' , 'paris', 'paris-vt-rgb', 'pitts30k-vt-rgb
    pslen_on = 'paris'; % PSLEN model using Paris dataset.
    
    pslen_directory = '/home/leo/mega/pslen-1/';
    %%
    
    
    
    if strcmp(job_net,'vd16_pitts30k')
        % PITTSBURGH DATASET
        netID= 'vd16_pitts30k_conv5_3_vlad_preL2_intra_white';

    elseif strcmp(job_net,'vd16_tokyoTM')
        % TOKYO DATASET
        netID= 'vd16_tokyoTM_conv5_3_vlad_preL2_intra_white';
    end

    if strcmp(job_datasets,'pitts30k')
        dbTest= dbPitts('30k','test');
        datasets_path = paths.dsetRootPitts;
        query_folder = 'queries';

    elseif strcmp(job_datasets,'pitts30k-vt-rgb')
        dbTest= dbPitts('30k','test');
        datasets_path = '/mnt/0287D1936157598A/docker_ws/datasets/NetvLad/view-tags/Pittsburgh_Viewtag_3_rgb'; %% PC
        query_folder = 'queries';

    elseif strcmp(job_datasets,'tokyo247')
        dbTest= dbTokyo247();
        datasets_path = paths.dsetRootTokyo247; 
        query_folder = 'query';

    elseif strcmp(job_datasets,'paris')
        dbTest= dbVGG('paris');
        datasets_path = paths.dsetRootParis; %% PC
        query_folder = 'images';                
        
    elseif strcmp(job_datasets,'oxford')
        dbTest= dbVGG('ox5k');
        datasets_path = paths.dsetRootOxford; %% PC
        query_folder = 'images';

    elseif strcmp(job_datasets,'paris-vt-rgb')
        dbTest= dbVGG('paris');
        datasets_path = paths.dsetRootHolidays; %% PC
        query_folder = 'images';
    end

    
    save_path = strcat(pslen_directory,job_net,'_to_',job_datasets,'_',int2str(f_dimension),'_',proj);
    save_pslen_data = strcat(pslen_directory,'models/',job_net,'_to_',pslen_on,int2str(f_dimension),'_data.mat');
    save_pslen_data_mdl = strcat(pslen_directory,'models/', job_net,'_to_',pslen_on,int2str(f_dimension),'_mdls.mat');

    save_path_all = strcat(pslen_directory,job_net,'_to_',job_datasets,'_box_50_plus','.mat');
        
    % Save result for tikz latex
    maqbool_d_results_fname = strcat('results/',job_net,'_to_',job_datasets,'_maqbool_D_',int2str(f_dimension),'.dat');
    maqbool_r_results_fname = strcat('results/',job_net,'_to_',job_datasets,'_maqbool_R_',int2str(f_dimension),'.dat');
    netvlad_results_fname = strcat('results/',job_net,'_to_',job_datasets,'_netvlad_',int2str(f_dimension),'.dat');
    save_results = strcat('results/',job_net,'_to_',job_datasets,'_both_results_',int2str(f_dimension),'.mat');
    
    %% TOKYO DATASET
    %netID= 'vd16_tokyoTM_conv5_3_vlad_preL2_intra_white'; % netID= 'caffe_tokyoTM_conv5_vlad_preL2_intra_white';

    %dbTest= dbTokyo247();fra
    %datasets_path = 'datasets/Test_247_Tokyo_GSV'; %% PC

    %save_path = '/home/leo/mega/vt-6';
    %save_path = '/home/leo/mega/vt-7-pitts2tokyo';

    %datasets_path = '/home/leo/docker_ws/datasets/Test_247_Tokyo_GSV'; %% LAPTOP
    %save_path = '/home/leo/MEGA/vt-6';

    %datasets_path = '/home/leo/docker_ws/datasets/Test_247_Tokyo_GSV'; %% LAPTOP
    %save_path = '/home/leo/MEGA/Tokyo24-boxed-vt-6';
    %save_path_all = 'pslen-results/pslen-tokyo2tokto-vt-6.mat';



    %% Pitts 2 TOKYO DATASET
    %netID= 'vd16_pitts30k_conv5_3_vlad_preL2_intra_white';

    %dbTest= dbTokyo247();

    %datasets_path = '/home/leo/docker_ws/datasets/Test_247_Tokyo_GSV'; %% LAPTOP
    %datasets_path = 'datasets/Test_247_Tokyo_GSV'; %% LAPTOP

    %save_path = '/home/leo/MEGA/vt-7-pitts2tokyo';


    %%
    plen_opts = struct(...
                'pslen_directory',          pslen_directory, ...
                'netID',                    netID, ...
                'proj',                     proj, ...
                'job_net',                  job_net, ...
                'datasets_path',            datasets_path, ...
                'save_path',                save_path, ...
                'save_results',             save_results, ...
                'save_path_all',            save_path_all, ...
                'save_pslen_data',          save_pslen_data, ...
                'save_pslen_data_mdl',      save_pslen_data_mdl, ...
                'maqbool_d_results_fname',  maqbool_d_results_fname, ...
                'maqbool_r_results_fname',  maqbool_r_results_fname, ...
                'netvlad_results_fname',    netvlad_results_fname, ...
                'vt_type',                  3, ...
                'iTestSample_Start',        iTestSample_Start, ...
                'startfrom',                startfrom, ...
                'show_output',              show_output, ...
                'query_folder',             query_folder, ...
                'dbTest',                   dbTest, ...
                'cropToDim',                f_dimension, ...
                'pslen_on',                 pslen_on, ....    
                'createPslenModel',         0 ...
                );


end
