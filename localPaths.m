function paths= localPaths()
    
    % --- dependencies
    
    % refer to README.md for the information on dependencies
    paths.libReljaMatlab= 'depends/relja_matlab/';
    paths.libMatConvNet= '3rd-party-support/matconvnet/'; % should contain matlab/
    
    % If you have installed yael_matlab (**highly recommended for speed**),
    % provide the path below. Otherwise, provide the path as 'yael_dummy/':
    % this folder contains my substitutes for the used yael functions,
    % which are **much slower**, and only included for demonstration purposes
    % so do consider installing yael_matlab, or make your own faster
    % version (especially of the yael_nn function)
    paths.libYaelMatlab= 'yael_dummy/';
    
    % --- dataset specifications
    % XPS
    % paths.dsetSpecDir= '/home/leo/docker_ws/datasets/datasets-specs';
    % HKPC
    paths.dsetSpecDir= '../maqbool-datasets/datasets-specs';

    % --- dataset locations
    % XPS
    %paths.dsetRootPitts= '/home/leo/docker_ws/datasets/Pittsburgh-all/Pittsburgh/'; % should contain images/ and queries/
    % HKPC
    paths.dsetRootPitts= '../maqbool-datasets/Test_Pitts30k/'; % should contain images/ and queries/

    % XPS
    paths.dsetRootTokyo247= '/home/leo/docker_ws/datasets/Test_247_Tokyo_GSV/'; % should contain images/ and query/
    % HKPC
     paths.dsetRootTokyoTM= '/home/leo/docker_ws/datasets/tokyoTimeMachine/'; % should contain images/
        
    % XPS
    %paths.dsetRootTokyoTM= '/home/leo/docker_ws/datasets/tinyTimeMachine/'; % should contain images/
    % HKPC
    paths.dsetRootTokyo247= '../maqbool-datasets/Test_247_Tokyo_GSV/'; % should contain images/ and query/

    % XPS  
    % paths.dsetRootOxford= '/home/leo/docker_ws/datasets/test-oxford/'; % should contain images/ and groundtruth/, and be writable
    % HKPC
    paths.dsetRootOxford= '../maqbool-datasets/test_oxford/'; % should contain images/ and groundtruth/, and be writable
    
    % XPS
    %paths.dsetRootParis= '/home/leo/docker_ws/datasets/test_paris/'; % should contain images/ (with subfolders defense, eiffel, etc), groundtruth/ and corrupt.txt, and be writable
    % HKPC    
    paths.dsetRootParis= '../maqbool-datasets/test_paris/'; % should contain images/ (with subfolders defense, eiffel, etc), groundtruth/ and corrupt.txt, and be writable
    
    % HKPC    
    paths.dsetRootHolidays= '/mnt/0287D1936157598A/docker_ws/datasets/NetvLad/Holidays/'; % should contain jpg/ for the original holidays, or jpg_rotated/ for rotated Holidays, and be writable
    
    % --- our networks
    % models used in our paper, download them from our research page
    % paths.ourCNNs= '~/Data/models/';
   % paths.ourCNNs= '/mnt/0287D1936157598A/docker_ws/datasets/NetvLad/models_v103_pre-trained/';
    % XPS
    %paths.ourCNNs= '/home/leo/docker_ws/datasets/models_v103_pre-trained/';
    % HKPC    
    paths.ourCNNs= '../maqbool-datasets/models_v103_pre-trained/';

    
    % --- pretrained networks
    % off-the-shelf networks trained on other tasks, available from the MatConvNet
    % website: http://www.vlfeat.org/matconvnet/pretrained/
    % XPS

    paths.pretrainedCNNs= '/home/leo/docker_ws/netvlad/netvlad-original/pretrained/';
    
    % --- initialization data (off-the-shelf descriptors, clusters)
    % Not necessary: these can be computed automatically, but it is recommended
    % in order to use the same initialization as we used in our work
    paths.initData= '/home/leo/docker_ws/netvlad/netvlad-pre-data/initdata/';
    
    % --- output directory
    % XPS
    paths.outPrefix= '/home/leo/docker_ws/datasets/netvlad-original-output/';

    % HKPC
    paths.outPrefix= '../maqbool-datasets/netvlad-original-output-4096/';


end
