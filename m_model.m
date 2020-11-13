function m_model(m_config) 
    
    fprintf( 'Creating m Model \n')

    load(m_config.save_m_data,'data');
    
    HH = [];
    for i = 1:size(data,2)/2
        XX = data(i).X';
        XX = reshape(XX,1,[]);
        HH = [HH ; data(i).pre data(i).H XX double(data(i).Y)];
    end
    GT = HH;
%        if nnz(GTHH== 2) < nnz(GTHH== 1)
%          GTHH = sortrows(HH,113,'descend');
%          GT = GTHH(1:nnz(GTHH== 2)*2,:);
%        else
%          GTHH = sortrows(HH,113);
%          GT = GTHH(1:nnz(GTHH== 1)*2,:);
%       end

    
    paroptions = statset('UseParallel','Always');
    
    Data = array2table(GT);
   % hypopts = struct('ShowPlots',false,'Verbose',0,'UseParallel',false);

   % Decision tree
 %  mdls{1} = fitctree(Data,'GT112', ...
      % 'OptimizeHyperparameters','auto','HyperparameterOptimizationOptions', hypopts);
  % mdls{1} = prune(mdls{1});
  % 'OOBPrediction','On'
    %Random fitrensemble (Works better with 512 Dimension)

 % mdls{1} = fitrgp(Data,'GT112');
  % nlm = fitnlm
    mdls{1} = TreeBagger(50,Data,'GT113','Method','regression','OOBPrediction','On');  
  %  
   
   % Random fitrensemble (Works better with 512 Dimension)
    mdls{2} = TreeBagger(100,Data,'GT113','Method','regression', 'OOBPrediction','On');  
  %  
    
    save(m_config.save_m_data_mdl,'mdls');
    fprintf( 'm Model is created. \n')
end