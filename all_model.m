 
fprintf( 'Creating m Model \n')
HH = [];

load('/home/leo/mega/maqbool-data/models/vd16_pitts30k_to_oxford_4096_data', 'data');
for i = 1:size(data,2)
    XX = data(i).X';
    XX = reshape(XX,1,[]);
    HH = [HH ; data(i).pre data(i).H XX double(data(i).Y)];
end



load('/home/leo/mega/maqbool-data/models/vd16_pitts30k_to_paris_4096_data','data');
for i = 1:size(data,2)
    XX = data(i).X';
    XX = reshape(XX,1,[]);
    HH = [HH ; data(i).pre data(i).H XX double(data(i).Y)];
end

load('/home/leo/mega/maqbool-data/models/vd16_pitts30k_to_holiday_4096_data','data');
for i = 1:size(data,2)
    XX = data(i).X';
    XX = reshape(XX,1,[]);
    HH = [HH ; data(i).pre data(i).H XX double(data(i).Y)];
end
GTHH = sortrows(HH,112,'descend');
GT = GTHH(1:nnz(HH== 2)*2,:);

Data = array2table(GT);
hypopts = struct('ShowPlots',false,'Verbose',0,'UseParallel',false);

% Decision tree
mdls{1} = fitctree(Data,'GT112', ...
   'OptimizeHyperparameters','auto','HyperparameterOptimizationOptions', hypopts);
mdls{1} = prune(mdls{1} );
% Random fitrensemble (Works better with 512 Dimension)
mdls{2} = TreeBagger(50,Data,'GT112','Method','regression',...
'OOBPrediction','On');
mdls{2} = prune(mdls{1} );


save(m_config.save_m_data_mdl,'mdls');
fprintf( 'm Model is created. \n')


function Gt = getData(data)

end